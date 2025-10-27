import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/models.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final expenses = await ApiService.getExpenses();
      setState(() {
        _expenses = expenses;
        _notifications = _generateNotifications(expenses);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> _generateNotifications(List<Expense> expenses) {
    List<Map<String, dynamic>> notifications = [];
    final now = DateTime.now();

    // Bill due date reminders
    for (var expense in expenses) {
      if (!expense.isPaid && expense.dueDate != null) {
        final daysUntilDue = expense.dueDate!.difference(now).inDays;
        
        if (daysUntilDue < 0) {
          notifications.add({
            'type': 'overdue',
            'title': 'Overdue Bill',
            'message': '${expense.description} is overdue by ${-daysUntilDue} days',
            'icon': Icons.warning,
            'color': Colors.red,
            'expense': expense,
          });
        } else if (daysUntilDue <= 3) {
          notifications.add({
            'type': 'due_soon',
            'title': 'Bill Due Soon',
            'message': '${expense.description} is due in $daysUntilDue days',
            'icon': Icons.schedule,
            'color': Colors.orange,
            'expense': expense,
          });
        }
      }
    }

    // Savings tips
    notifications.add({
      'type': 'tip',
      'title': 'Savings Tip',
      'message': 'Try saving ₹50 daily to reach ₹1,500 this month!',
      'icon': Icons.lightbulb,
      'color': Colors.blue,
    });

    // Score improvement tips
    notifications.add({
      'type': 'score_tip',
      'title': 'Improve Your Score',
      'message': 'Pay overdue bills to improve your Samarthan Score',
      'icon': Icons.trending_up,
      'color': Colors.green,
    });

    return notifications;
  }

  Future<void> _markBillAsPaid(Expense expense) async {
    try {
      await ApiService.markExpenseAsPaid(expense.id);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bill marked as paid!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You\'re all caught up!',
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: notification['color'].withValues(alpha: 0.1),
                      child: Icon(
                        notification['icon'],
                        color: notification['color'],
                      ),
                    ),
                    title: Text(
                      notification['title'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(notification['message']),
                    trailing: notification['type'] == 'overdue' || notification['type'] == 'due_soon'
                        ? TextButton(
                            onPressed: () => _markBillAsPaid(notification['expense']),
                            child: const Text('Pay Now'),
                          )
                        : null,
                  ),
                );
              },
            ),
    );
  }
}
