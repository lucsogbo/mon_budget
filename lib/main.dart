import 'package:flutter/material.dart';
import 'db/DatabaseHelper.dart';
import 'view/dashboard.dart';
import 'view/depenses.dart';
import 'view/revenus.dart';
import 'view/budgets.dart';
import 'view/categories.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = await DatabaseHelper().database;
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mon Budget',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    DashboardScreen(),
    DepensesScreen(),
    RevenusScreen(),
    BudgetsScreen(),
    CategoriesScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Tableau'),
          BottomNavigationBarItem(icon: Icon(Icons.money_off), label: 'Dépenses'),
          BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: 'Revenus'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Budgets'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Catégories'),
        ],
      ),
    );
  }
}
