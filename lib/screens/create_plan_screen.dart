import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../models/food_item.dart';
import '../models/order_plan.dart';

/// Screen for creating and saving a plan.
class CreatePlanScreen extends StatefulWidget {
  const CreatePlanScreen({super.key});

  @override
  State<CreatePlanScreen> createState() => _CreatePlanScreenState();
}

class _CreatePlanScreenState extends State<CreatePlanScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final TextEditingController _targetController = TextEditingController();
  DateTime? _selectedDate;
  List<FoodItem> _foodItems = [];
  final Set<int> _selectedIds = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFoodItems();
  }

  Future<void> _loadFoodItems() async {
    final items = await _db.fetchFoodItems();
    setState(() {
      _foodItems = items;
      _loading = false;
    });
  }

  double get _totalCost {
    double total = 0;
    for (final item in _foodItems) {
      if (_selectedIds.contains(item.id)) {
        total += item.cost;
      }
    }
    return total;
  }

  String get _dateDisplay =>
      _selectedDate == null ? 'Select date' : _formatDate(_selectedDate!);

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _toggleSelection(FoodItem item) {
    if (item.id == null) return;
    setState(() {
      if (_selectedIds.contains(item.id)) {
        _selectedIds.remove(item.id);
      } else {
        final target = double.tryParse(_targetController.text);
        final newTotal = _totalCost + item.cost;
        if (target != null && target > 0 && newTotal > target) {
          _showMessage('Total exceeds target cost');
          return;
        }
        _selectedIds.add(item.id!);
      }
    });
  }

  Future<void> _savePlan() async {
    final target = double.tryParse(_targetController.text);
    if (target == null || target <= 0) {
      _showMessage('Enter a valid target cost');
      return;
    }
    if (_selectedDate == null) {
      _showMessage('Select a date');
      return;
    }
    if (_selectedIds.isEmpty) {
      _showMessage('Select at least one food item');
      return;
    }
    if (_totalCost > target) {
      _showMessage('Total cost cannot exceed target');
      return;
    }

    final plan = OrderPlan(
      date: _formatDate(_selectedDate!),
      targetCost: target,
      selectedFoodIds: _selectedIds.toList(),
    );
    await _db.insertOrderPlan(plan);
    _showMessage('Plan saved for ${plan.date}');
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  void dispose() {
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Plan')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _targetController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Target cost per day',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: Text(_dateDisplay)),
                          ElevatedButton(
                            onPressed: _pickDate,
                            child: const Text('Pick Date'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('Selected total: ${_totalCost.toStringAsFixed(2)}'),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    itemCount: _foodItems.length,
                    itemBuilder: (context, index) {
                      final item = _foodItems[index];
                      final selected = _selectedIds.contains(item.id);
                      return CheckboxListTile(
                        value: selected,
                        title: Text(item.name),
                        subtitle: Text('Cost: ${item.cost.toStringAsFixed(2)}'),
                        onChanged: (_) => _toggleSelection(item),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _savePlan,
                      child: const Text('Save Plan'),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
