import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class ApiService {
  // Use environment-based URL for production deployment
  static const String baseUrl = kDebugMode 
    ? 'http://localhost:8000/api'
    : '/api';  // Same domain for single-platform deployment
  
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<http.Response> _handleResponse(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else {
      // Check if response is JSON or HTML
      final contentType = response.headers['content-type'] ?? '';
      if (contentType.contains('application/json')) {
        try {
          final errorData = json.decode(response.body);
          throw Exception(errorData['message'] ?? 'An error occurred');
        } catch (e) {
          throw Exception('Failed to parse error response: ${response.body}');
        }
      } else {
        // Handle HTML responses (like 404 pages)
        throw Exception('Server error (${response.statusCode}): ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}...');
      }
    }
  }

  // Google OAuth endpoint
  static Future<Map<String, dynamic>> googleSignIn({
    required String idToken,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/google'),
      headers: await _getHeaders(),
      body: json.encode({
        'idToken': idToken,
      }),
    );

    final handledResponse = await _handleResponse(response);
    return json.decode(handledResponse.body);
  }

  // Dashboard endpoint
  static Future<DashboardData> getDashboardData() async {
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard'),
      headers: await _getHeaders(),
    );

    final handledResponse = await _handleResponse(response);
    final data = json.decode(handledResponse.body);
    return DashboardData.fromJson(data);
  }

  // Expense endpoints
  static Future<Expense> addExpense({
    required String description,
    required double amount,
    required String category,
    DateTime? dueDate,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/expenses'),
      headers: await _getHeaders(),
      body: json.encode({
        'description': description,
        'amount': amount,
        'category': category,
        'dueDate': dueDate?.toIso8601String(),
      }),
    );

    final handledResponse = await _handleResponse(response);
    final data = json.decode(handledResponse.body);
    return Expense.fromJson(data['expense']);
  }

  static Future<Expense> markExpenseAsPaid(String expenseId) async {
    if (expenseId.isEmpty) {
      throw Exception('Expense ID cannot be empty');
    }
    
    final response = await http.put(
      Uri.parse('$baseUrl/expenses/$expenseId/paid'),
      headers: await _getHeaders(),
    );

    final handledResponse = await _handleResponse(response);
    final data = json.decode(handledResponse.body);
    return Expense.fromJson(data['expense']);
  }

  // Delete expense
  static Future<void> deleteExpense(String expenseId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/expenses/$expenseId'),
      headers: await _getHeaders(),
    );

    await _handleResponse(response);
  }

  static Future<List<Expense>> getExpenses() async {
    final response = await http.get(
      Uri.parse('$baseUrl/expenses'),
      headers: await _getHeaders(),
    );

    final handledResponse = await _handleResponse(response);
    final data = json.decode(handledResponse.body);
    return (data as List).map((e) => Expense.fromJson(e)).toList();
  }

  // Savings endpoints
  static Future<Savings> addSavings({
    required double amount,
    String type = 'manual',
    String? description,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/savings'),
      headers: await _getHeaders(),
      body: json.encode({
        'amount': amount,
        'type': type,
        'description': description,
      }),
    );

    final handledResponse = await _handleResponse(response);
    final data = json.decode(handledResponse.body);
    return Savings.fromJson(data['savings']);
  }

  static Future<List<Savings>> getSavings() async {
    final response = await http.get(
      Uri.parse('$baseUrl/savings'),
      headers: await _getHeaders(),
    );

    final handledResponse = await _handleResponse(response);
    final data = json.decode(handledResponse.body);
    return (data as List).map((e) => Savings.fromJson(e)).toList();
  }

  // Delete savings
  static Future<void> deleteSavings(String savingsId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/savings/$savingsId'),
      headers: await _getHeaders(),
    );

    await _handleResponse(response);
  }

  // Score endpoint
  static Future<SamarthanScore> getSamarthanScore() async {
    final response = await http.get(
      Uri.parse('$baseUrl/score'),
      headers: await _getHeaders(),
    );

    final handledResponse = await _handleResponse(response);
    final data = json.decode(handledResponse.body);
    return SamarthanScore.fromJson(data);
  }

  // Analytics endpoint
  static Future<Map<String, dynamic>> getAnalytics() async {
    final response = await http.get(
      Uri.parse('$baseUrl/analytics'),
      headers: await _getHeaders(),
    );

    final handledResponse = await _handleResponse(response);
    return json.decode(handledResponse.body);
  }

  // Notifications endpoint
  static Future<List<Map<String, dynamic>>> getNotifications() async {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications'),
      headers: await _getHeaders(),
    );

    final handledResponse = await _handleResponse(response);
    final data = json.decode(handledResponse.body);
    return List<Map<String, dynamic>>.from(data);
  }
}
