import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:myfinance/authpages/loginpage.dart';
import 'package:myfinance/config.dart';
import 'package:myfinance/screens/categoryscreen.dart';
import 'package:myfinance/screens/onboardingpage.dart';

import 'dart:ui';

import 'package:myfinance/screens/transactionscreen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Client client = Client()
      .setEndpoint(Config.endpoint)
      .setProject(Config.projectId);
  Account account = Account(client);
 
  runApp(MaterialApp(
    home: MyApp(account: account),
  ));
}

class MyApp extends StatefulWidget {
  final Account account;

  const MyApp({super.key, required this.account});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MyFinance',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      home: HomeController(),
      routes: {
         '/dashboard': (context) => DashboardScreen(),
        '/transactions': (context) => TransactionsScreen(),
        '/categories': (context) => CategoriesScreen(),
     
      },
    );
  }
}

class HomeController extends StatefulWidget {
  @override
  _HomeControllerState createState() => _HomeControllerState();
}

class _HomeControllerState extends State<HomeController> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    DashboardScreen(),
    TransactionsScreen(),
    CategoriesScreen(),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add_transaction');
        },
        child: Icon(Icons.add),
        tooltip: 'Add Transaction',
      ),
    );
  }
}