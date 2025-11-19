import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../models/food_item.dart';
import '../models/order_plan.dart';

/// Screen to query saved plans by date.
class QueryPlanScreen extends StatefulWidget {
  const QueryPlanScreen({super.key});

  @override
  State<QueryPlanScreen> createState() => _QueryPlanScreenState();
}

class _QueryPlanScreenState extends State<QueryPlanScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  DateTime? _queryDate;
  OrderPlan? _plan;
  List<FoodItem> _selectedFoods = [];

  String get _dateLabel =>
      _queryDate == null ? 'Pick a date to query' : _formatDate(_queryDate!);

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _queryDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      setState(() => _queryDate = picked);
    }
  }

  Future<void> _loadPlan() async {
    if (_queryDate == null) {
      _showMessage('Please select a date first');
      return;
    }
    final dateKey = _formatDate(_queryDate!);
    final plan = await _db.getPlanByDate(dateKey);
    if (plan == null) {
      setState(() {
        _plan = null;
        _selectedFoods = [];
      });
      _showMessage('No plan saved for $dateKey');
      return;
    }
    final foods = await _db.fetchFoodItems();
    final selected = foods
        .where((item) => plan.selectedFoodIds.contains(item.id))
        .toList();
    setState(() {
      _plan = plan;
      _selectedFoods = selected;
    });
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  double get _selectedTotal {
    return _selectedFoods.fold(0, (prev, element) => prev + element.cost);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Query Plan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(_dateLabel)),
                ElevatedButton(
                  onPressed: _pickDate,
                  child: const Text('Pick Date'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadPlan,
              child: const Text('Query Plan'),
            ),
            const SizedBox(height: 24),
            if (_plan != null) ...[
              Text('Target cost: ${_plan!.targetCost.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              Text('Selected items (${_selectedFoods.length}) - total ${_selectedTotal.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _selectedFoods.length,
                  itemBuilder: (context, index) {
                    final item = _selectedFoods[index];
                    return ListTile(
                      title: Text(item.name),
                      subtitle: Text('Cost: ${item.cost.toStringAsFixed(2)}'),
                    );
                  },
                ),
              ),
            ] else
              const Expanded(
                child: Center(
                  child: Text('No plan loaded'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
