import 'dart:convert';

class OrderPlan {
  final int? id;
  final String date;
  final double targetCost;
  final List<int> selectedFoodIds;

  OrderPlan({
    this.id,
    required this.date,
    required this.targetCost,
    required this.selectedFoodIds,
  });

  factory OrderPlan.fromMap(Map<String, dynamic> map) {
    return OrderPlan(
      id: map['id'] as int?,
      date: map['date'] as String,
      targetCost: (map['targetCost'] as num).toDouble(),
      selectedFoodIds: (jsonDecode(map['selectedFoodIds'] as String) as List<dynamic>)
          .map((value) => (value as num).toInt())
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'targetCost': targetCost,
      'selectedFoodIds': jsonEncode(selectedFoodIds),
    };
  }
}
