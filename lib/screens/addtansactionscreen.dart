import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myfinance/helper/category.dart';
import 'package:myfinance/helper/transaction.dart';
import 'package:myfinance/services/categoryservice.dart';
import 'package:myfinance/services/transactionservices.dart';

class AddTransactionScreen extends StatefulWidget {
  final Transaction? transaction;

  const AddTransactionScreen({Key? key, this.transaction}) : super(key: key);

  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final TransactionService _transactionService = TransactionService();
  final CategoryService _categoryService = CategoryService();
  
  DateTime _selectedDate = DateTime.now();
  String _transactionType = 'expense';
  String? _selectedCategoryId;
  List<Category> _categories = [];
  bool _isLoading = false;
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    
    // If editing an existing transaction
    if (widget.transaction != null) {
      _isEdit = true;
      _titleController.text = widget.transaction!.title;
      _amountController.text = widget.transaction!.amount.toString();
      _transactionType = widget.transaction!.type;
      _selectedCategoryId = widget.transaction!.categoryId;
      _selectedDate = widget.transaction!.date;
    }
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final categories = await _categoryService.getCategories();
      setState(() {
        _categories = categories;
        if (categories.isNotEmpty && _selectedCategoryId == null) {
          _selectedCategoryId = categories[0].id;
        }
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load categories');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final selectedCategory = _categories.firstWhere(
        (category) => category.id == _selectedCategoryId,
        orElse: () => _categories[0],
      );
      
      final transaction = Transaction(
        id: widget.transaction?.id ?? '',
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        type: _transactionType,
        categoryId: selectedCategory.id,
        categoryName: selectedCategory.name,
        date: _selectedDate,
      );

      if (_isEdit) {
        await _transactionService.updateTransaction(transaction.id, transaction);
      } else {
        await _transactionService.createTransaction(transaction);
      }

      Navigator.pop(context, true);
    } catch (e) {
      _showErrorSnackBar('Failed to save transaction');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Transaction' : 'Add Transaction'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        border: OutlineInputBorder(),
                        prefixText: '₹',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an amount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0),
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Transaction Type', style: TextStyle(fontSize: 16)),
                            Row(
                              children: [
                                Expanded(
                                  child: RadioListTile<String>(
                                    title: Text('Expense'),
                                    value: 'expense',
                                    groupValue: _transactionType,
                                    onChanged: (value) {
                                      setState(() {
                                        _transactionType = value!;
                                      });
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: RadioListTile<String>(
                                    title: Text('Income'),
                                    value: 'income',
                                    groupValue: _transactionType,
                                    onChanged: (value) {
                                      setState(() {
                                        _transactionType = value!;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Category', style: TextStyle(fontSize: 16)),
                            SizedBox(height: 8.0),
                            _categories.isEmpty
                                ? Text('No categories available')
                                : DropdownButtonFormField<String>(
                                    value: _selectedCategoryId,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                    ),
                                    items: _categories.map((category) {
                                      return DropdownMenuItem<String>(
                                        value: category.id,
                                        child: Row(
                                          children: [
                                            Icon(category.icon, color: category.color),
                                            SizedBox(width: 8.0),
                                            Text(category.name),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedCategoryId = value;
                                      });
                                    },
                                  ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Card(
                      child: ListTile(
                        title: Text('Date'),
                        subtitle: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                        trailing: Icon(Icons.calendar_today),
                        onTap: () => _selectDate(context),
                      ),
                    ),
                    SizedBox(height: 32.0),
                    ElevatedButton(
                      onPressed: _saveTransaction,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      child: Text(
                        _isEdit ? 'Update Transaction' : 'Add Transaction',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}