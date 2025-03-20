import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myfinance/helper/transaction.dart';
import 'package:myfinance/screens/addtansactionscreen.dart';
import 'package:myfinance/services/transactionservices.dart';


class TransactionsScreen extends StatefulWidget {
  @override
  _TransactionsScreenState createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TransactionService _transactionService = TransactionService();
  List<Transaction> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final transactions = await _transactionService.getTransactions();
      setState(() {
        _transactions = transactions;
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load transactions');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteTransaction(String id) async {
    try {
      await _transactionService.deleteTransaction(id);
      _loadTransactions();
      _showSuccessSnackBar('Transaction deleted');
    } catch (e) {
      _showErrorSnackBar('Failed to delete transaction');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _editTransaction(Transaction transaction) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(transaction: transaction),
      ),
    );

    if (result == true) {
      _loadTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transactions'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              // Implement filtering logic here
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _transactions.isEmpty
              ? Center(child: Text('No transactions yet'))
              : ListView.builder(
                  itemCount: _transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = _transactions[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: transaction.type == 'income' 
                              ? Colors.green.shade100 
                              : Colors.red.shade100,
                          child: Icon(
                            transaction.type == 'income' 
                                ? Icons.arrow_upward 
                                : Icons.arrow_downward,
                            color: transaction.type == 'income' 
                                ? Colors.green 
                                : Colors.red,
                          ),
                        ),
                        title: Text(transaction.title),
                        subtitle: Text(
                          '${transaction.categoryName} • ${DateFormat('MMM d, yyyy').format(transaction.date)}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '₹${transaction.amount.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: transaction.type == 'income' 
                                    ? Colors.green 
                                    : Colors.red,
                              ),
                            ),
                            PopupMenuButton(
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              ],
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _editTransaction(transaction);
                                } else if (value == 'delete') {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Delete Transaction'),
                                      content: Text('Are you sure you want to delete this transaction?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            _deleteTransaction(transaction.id);
                                          },
                                          child: Text('Delete'),
                                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTransactionScreen()),
          );

          if (result == true) {
            _loadTransactions();
          }
        },
        child: Icon(Icons.add),
        tooltip: 'Add Transaction',
      ),
    );
  }
}