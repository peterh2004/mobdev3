class FoodItem {
  final int? id;
  final String name;
  final double cost;

  FoodItem({this.id, required this.name, required this.cost});

  FoodItem copyWith({int? id, String? name, double? cost}) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      cost: cost ?? this.cost,
    );
  }

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      id: map['id'] as int?,
      name: map['name'] as String,
      cost: (map['cost'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'cost': cost,
    };
  }
}
