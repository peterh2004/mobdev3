import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../models/food_item.dart';

/// Screen for managing CRUD operations on food items.
class FoodCRUDScreen extends StatefulWidget {
  const FoodCRUDScreen({super.key});

  @override
  State<FoodCRUDScreen> createState() => _FoodCRUDScreenState();
}

class _FoodCRUDScreenState extends State<FoodCRUDScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  List<FoodItem> _foodItems = [];

  @override
  void initState() {
    super.initState();
    _loadFoods();
  }

  Future<void> _loadFoods() async {
    final items = await _db.fetchFoodItems();
    setState(() => _foodItems = items);
  }

  Future<void> _addFoodItem() async {
    final name = _nameController.text.trim();
    final cost = double.tryParse(_costController.text);
    if (name.isEmpty || cost == null || cost <= 0) {
      _showMessage('Provide valid name and cost');
      return;
    }
    await _db.insertFoodItem(FoodItem(name: name, cost: cost));
    _nameController.clear();
    _costController.clear();
    await _loadFoods();
  }

  Future<void> _deleteFoodItem(int id) async {
    await _db.deleteFoodItem(id);
    await _loadFoods();
  }

  Future<void> _editFoodItem(FoodItem item) async {
    final nameController = TextEditingController(text: item.name);
    final costController = TextEditingController(text: item.cost.toString());
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Food Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: costController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Cost'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final cost = double.tryParse(costController.text);
                if (name.isEmpty || cost == null || cost <= 0) {
                  _showMessage('Enter valid values');
                  return;
                }
                final updated = item.copyWith(name: name, cost: cost);
                await _db.updateFoodItem(updated);
                if (context.mounted) Navigator.pop(context);
                await _loadFoods();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _costController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Food Items')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Food name'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _costController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Cost'),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _addFoodItem,
                    child: const Text('Add Food Item'),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadFoods,
              child: ListView.builder(
                itemCount: _foodItems.length,
                itemBuilder: (context, index) {
                  final item = _foodItems[index];
                  return ListTile(
                    title: Text(item.name),
                    subtitle: Text('Cost: ${item.cost.toStringAsFixed(2)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editFoodItem(item),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteFoodItem(item.id!),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
