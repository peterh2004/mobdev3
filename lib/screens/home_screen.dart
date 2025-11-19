import 'package:flutter/material.dart';

/// Main navigation hub.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem('Create Plan', '/createPlan', Icons.edit_calendar),
      _NavItem('Query Plan', '/queryPlan', Icons.search),
      _NavItem('Manage Food Items', '/foodCrud', Icons.restaurant),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Food Ordering Planner')),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Icon(item.icon),
              title: Text(item.title),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, item.route),
            ),
          );
        },
      ),
    );
  }
}

class _NavItem {
  final String title;
  final String route;
  final IconData icon;

  _NavItem(this.title, this.route, this.icon);
}
