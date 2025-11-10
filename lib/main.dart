import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/login.dart';
import 'pages/monthly_breakdown.dart';
import 'pages/profile.dart';
import 'pages/add_bill.dart';
import 'package:finalproject/notifications.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Notifications().initNotification(); // Initializing Notifications
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Final Project',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: LoginPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    MonthlyBreakdown(),
    AddBill(),
    Profile(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.book), label: 'Breakdown'),
          NavigationDestination(icon: Icon(Icons.money), label: 'Add Bill'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
