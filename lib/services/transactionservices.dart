import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myfinance/helper/transaction.dart';


class TransactionService {
  final String baseUrl = 'http://localhost:3000/api/transactions';

  Future<List<Transaction>> getTransactions() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        List<Transaction> transactions = body
            .map((dynamic item) => Transaction.fromJson(item))
            .toList();
        return transactions;
      } else {
        throw Exception('Failed to load transactions');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Transaction> createTransaction(Transaction transaction) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(transaction.toJson()),
      );

      if (response.statusCode == 201) {
        return Transaction.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create transaction');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Transaction> updateTransaction(String id, Transaction transaction) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(transaction.toJson()),
      );

      if (response.statusCode == 200) {
        return Transaction.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update transaction');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));

      if (response.statusCode != 200) {
        throw Exception('Failed to delete transaction');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}