import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/food_item.dart';
import '../models/order_plan.dart';

/// Handles all database access for the app.
class DatabaseHelper {
  static const _databaseName = 'food_planner.db';
  static const _databaseVersion = 1;

  static final DatabaseHelper instance = DatabaseHelper._internal();
  Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);
    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE food_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            cost REAL NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE order_plans (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT UNIQUE NOT NULL,
            targetCost REAL NOT NULL,
            selectedFoodIds TEXT NOT NULL
          )
        ''');
      },
      onOpen: (db) async {
        await _insertDefaultFoods(db);
      },
    );
  }

  Future<void> _insertDefaultFoods(Database db) async {
    final count = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM food_items'),
        ) ??
        0;
    if (count > 0) return;

    final defaults = <Map<String, dynamic>>[
      {'name': 'Grilled Chicken', 'cost': 8.5},
      {'name': 'Veggie Salad', 'cost': 6.0},
      {'name': 'Beef Burger', 'cost': 9.0},
      {'name': 'Fish Tacos', 'cost': 7.5},
      {'name': 'Pasta Alfredo', 'cost': 11.0},
      {'name': 'Fruit Bowl', 'cost': 5.0},
      {'name': 'Turkey Sandwich', 'cost': 7.0},
      {'name': 'Quinoa Bowl', 'cost': 8.0},
      {'name': 'Cheese Pizza', 'cost': 9.5},
      {'name': 'Chicken Wrap', 'cost': 7.2},
      {'name': 'Avocado Toast', 'cost': 6.8},
      {'name': 'Sushi Roll', 'cost': 10.0},
      {'name': 'Tomato Soup', 'cost': 4.5},
      {'name': 'Steak Bites', 'cost': 12.5},
      {'name': 'Oatmeal', 'cost': 4.0},
      {'name': 'Greek Yogurt', 'cost': 3.5},
      {'name': 'Smoothie', 'cost': 5.5},
      {'name': 'Chicken Curry', 'cost': 9.8},
      {'name': 'Rice Bowl', 'cost': 6.5},
      {'name': 'Chocolate Cake', 'cost': 4.8},
    ];

    for (final item in defaults) {
      await db.insert('food_items', item);
    }
  }

  Future<List<FoodItem>> fetchFoodItems() async {
    final db = await database;
    final maps = await db.query('food_items', orderBy: 'name ASC');
    return maps.map((e) => FoodItem.fromMap(e)).toList();
  }

  Future<int> insertFoodItem(FoodItem item) async {
    final db = await database;
    return db.insert('food_items', item.toMap());
  }

  Future<int> updateFoodItem(FoodItem item) async {
    final db = await database;
    return db.update(
      'food_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteFoodItem(int id) async {
    final db = await database;
    return db.delete('food_items', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertOrderPlan(OrderPlan plan) async {
    final db = await database;
    return db.insert('order_plans', plan.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateOrderPlan(OrderPlan plan) async {
    final db = await database;
    return db.update(
      'order_plans',
      plan.toMap(),
      where: 'id = ?',
      whereArgs: [plan.id],
    );
  }

  Future<OrderPlan?> getPlanByDate(String date) async {
    final db = await database;
    final maps = await db.query('order_plans', where: 'date = ?', whereArgs: [date]);
    if (maps.isEmpty) return null;
    return OrderPlan.fromMap(maps.first);
  }
}
