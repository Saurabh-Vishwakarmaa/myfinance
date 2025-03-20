import 'package:flutter/material.dart';
import 'package:myfinance/helper/transaction.dart';
import 'package:myfinance/services/transactionservices.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TransactionService _transactionService = TransactionService();
  double _income = 0;
  double _expenses = 0;
  double _balance = 0;
  double _savings = 0;
  List<Transaction> _recentTransactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // This would typically call your transaction service
      // For now, using mock data until connected to backend
      _income = 60000;
      _expenses = 4500;
      _balance = _income - _expenses;
      _savings = 10000;
      
      // Example of pulling recent transactions
      _recentTransactions = [
        Transaction(
          id: '1',
          title: 'Grocery Shopping',
          amount: 1200,
          type: 'expense',
          categoryId: '1',
          categoryName: 'Groceries',
          date: DateTime.now().subtract(const Duration(days: 2)),
        ),
        Transaction(
          id: '2',
          title: 'Electricity Bill',
          amount: 800,
          type: 'expense',
          categoryId: '2',
          categoryName: 'Utilities',
          date: DateTime.now().subtract(const Duration(days: 5)),
        ),
        Transaction(
          id: '3',
          title: 'Internet Bill',
          amount: 999,
          type: 'expense',
          categoryId: '2',
          categoryName: 'Utilities',
          date: DateTime.now().subtract(const Duration(days: 10)),
        ),
        Transaction(
          id: '4',
          title: 'Salary Deposit',
          amount: 60000,
          type: 'income',
          categoryId: '3',
          categoryName: 'Salary',
          date: DateTime.now().subtract(const Duration(days: 19)),
        ),
      ];
    } catch (e) {
      // Handle errors
      debugPrint('Error loading dashboard data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Finance Dashboard"),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Your Financial Summary",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildDashboardCard(
                          "Income",
                          "₹${_income.toStringAsFixed(0)}",
                          Colors.green.shade50,
                          Colors.green,
                          Icons.arrow_upward,
                        ),
                        _buildDashboardCard(
                          "Expenses",
                          "₹${_expenses.toStringAsFixed(0)}",
                          Colors.red.shade50,
                          Colors.red,
                          Icons.arrow_downward,
                        ),
                        _buildDashboardCard(
                          "Balance",
                          "₹${_balance.toStringAsFixed(0)}",
                          Colors.blue.shade50,
                          Colors.blue,
                          Icons.account_balance_wallet,
                        ),
                        _buildDashboardCard(
                          "Savings",
                          "₹${_savings.toStringAsFixed(0)}",
                          Colors.purple.shade50,
                          Colors.purple,
                          Icons.savings,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildRecentTransactionsSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildDashboardCard(String title, String amount, Color backgroundColor, 
      Color iconColor, IconData icon) {
    return Card(
      elevation: 2,
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(icon, color: iconColor),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              amount,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: iconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Recent Transactions",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 200,
          child: _recentTransactions.isEmpty
              ? const Center(child: Text("No recent transactions"))
              : ListView.builder(
                  itemCount: _recentTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = _recentTransactions[index];
                    return _buildTransactionItem(
                      transaction.title,
                      transaction.type == 'income' 
                          ? "₹${transaction.amount}" 
                          : "-₹${transaction.amount}",
                      "${transaction.date.day}/${transaction.date.month}/${transaction.date.year}"
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(String title, String amount, String date) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        title: Text(title),
        subtitle: Text(date),
        trailing: Text(
          amount,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: amount.contains("-") ? Colors.red : Colors.green,
          ),
        ),
      ),
    );
  }
}