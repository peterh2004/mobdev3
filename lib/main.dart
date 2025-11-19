import 'package:flutter/material.dart';

import 'db/database_helper.dart';
import 'screens/create_plan_screen.dart';
import 'screens/food_crud_screen.dart';
import 'screens/home_screen.dart';
import 'screens/query_plan_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database;
  runApp(const MyApp());
}

/// Root of the Food Ordering app.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Ordering Planner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      routes: {
        '/': (context) => const HomeScreen(),
        '/createPlan': (context) => const CreatePlanScreen(),
        '/queryPlan': (context) => const QueryPlanScreen(),
        '/foodCrud': (context) => const FoodCRUDScreen(),
      },
    );
  }
}
