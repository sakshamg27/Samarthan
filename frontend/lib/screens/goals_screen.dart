import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/models.dart';

class GoalsScreen extends StatefulWidget {
  final VoidCallback? onDataChanged;
  
  const GoalsScreen({super.key, this.onDataChanged});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> with WidgetsBindingObserver {
  List<Savings> _savings = [];
  DashboardData? _dashboardData;
  bool _isLoading = true;
  double _monthlySavingsGoal = 1500.0; // Made configurable
  final double _scoreGoal = 1000.0; // Maximum possible score

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Refresh data when app becomes active
    if (state == AppLifecycleState.resumed) {
      _loadData();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when screen becomes visible
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    
    try {
      // Load saved monthly savings goal first
      try {
        final prefs = await SharedPreferences.getInstance();
        final savedGoal = prefs.getDouble('samarthan_monthly_savings_goal');
        
        if (savedGoal != null && savedGoal > 0) {
          if (mounted) {
            setState(() {
              _monthlySavingsGoal = savedGoal;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _monthlySavingsGoal = 1500.0; // Default value
            });
          }
        }
      } catch (prefsError) {
        if (mounted) {
          setState(() {
            _monthlySavingsGoal = 1500.0; // Default value
          });
        }
      }

      // Load other data with better error handling
      try {
        final dashboardData = await ApiService.getDashboardData();
        final allSavings = await ApiService.getSavings();
        
        if (mounted) {
          setState(() {
            _dashboardData = dashboardData;
            _savings = allSavings; // Use all savings for monthly calculation
            _isLoading = false;
          });
          
          // Debug: Print current data
          print('Goals Screen - Samarthan Score: ${dashboardData.samarthanScore}');
          print('Goals Screen - Monthly Savings: ${_getMonthlySavings()}');
          print('Goals Screen - Total Savings Count: ${allSavings.length}');
          
          // Notify parent about data changes
          if (widget.onDataChanged != null) {
            widget.onDataChanged!();
          }
        }
      } catch (apiError) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  double _getMonthlySavings() {
    final now = DateTime.now();
    return _savings
        .where((s) => s.createdAt.year == now.year && s.createdAt.month == now.month)
        .fold(0.0, (sum, s) => sum + s.amount);
  }

  double _getSavingsProgress() {
    return (_getMonthlySavings() / _monthlySavingsGoal * 100).clamp(0.0, 100.0);
  }

  double _getScoreProgress() {
    if (_dashboardData == null) return 0.0;
    return (_dashboardData!.samarthanScore / _scoreGoal * 100).clamp(0.0, 100.0);
  }

  void _showSetSavingsGoalDialog() {
    final TextEditingController goalController = TextEditingController(
      text: _monthlySavingsGoal.toStringAsFixed(0),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Monthly Savings Goal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your monthly savings target:'),
            const SizedBox(height: 16),
            TextField(
              controller: goalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount (₹)',
                prefixText: '₹ ',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newGoal = double.tryParse(goalController.text);
              if (newGoal != null && newGoal > 0) {
                // Save to SharedPreferences
                final prefs = await SharedPreferences.getInstance();
                await prefs.setDouble('samarthan_monthly_savings_goal', newGoal);
                
                setState(() {
                  _monthlySavingsGoal = newGoal;
                });
                
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Monthly savings goal set to ₹${newGoal.toStringAsFixed(0)}'),
                    backgroundColor: const Color(0xFF2E7D32),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid amount'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Set Goal'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final monthlySavings = _getMonthlySavings();
    final savingsProgress = _getSavingsProgress();
    final scoreProgress = _getScoreProgress();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Beautiful Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF667EEA),
                  Color(0xFF764BA2),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667EEA).withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.flag,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Goals & Targets',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'लक्ष्य और लक्ष्य',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: _loadData,
                    tooltip: 'Refresh Goals',
                  ),
                ),
              ],
            ),
          ),
          // Main content
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Monthly Savings Goal
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Monthly Savings Goal',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                            IconButton(
                              onPressed: _showSetSavingsGoalDialog,
                              icon: const Icon(
                                Icons.edit,
                                color: Color(0xFF2E7D32),
                                size: 20,
                              ),
                              tooltip: 'Edit Goal',
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '₹${monthlySavings.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                            Text(
                              'of ₹${_monthlySavingsGoal.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: savingsProgress / 100,
                          backgroundColor: Colors.grey[300],
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${savingsProgress.toStringAsFixed(1)}% Complete',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Samarthan Score Goal
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Samarthan Score Goal',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_dashboardData?.samarthanScore ?? 0}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                            Text(
                              'of ${_scoreGoal.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: scoreProgress / 100,
                          backgroundColor: Colors.grey[300],
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${scoreProgress.toStringAsFixed(1)}% Complete',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Action Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          'Add Savings',
                          'Quick savings entry',
                          Icons.savings,
                          Colors.green,
                          () => _showAddSavingsDialog(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionCard(
                          'Pay Bills',
                          'Mark bills as paid',
                          Icons.payment,
                          Colors.blue,
                          () => _showPayBillsDialog(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Tips Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.lightbulb, color: Colors.blue[700]),
                            const SizedBox(width: 8),
                            Text(
                              'Tips to Reach Your Goals',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '• Save ₹50 daily to reach ₹1,500 monthly\n'
                          '• Pay bills on time to improve your score\n'
                          '• Set smaller weekly goals for better progress',
                          style: TextStyle(color: Colors.blue[700]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSavingsDialog() {
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Quick Savings'),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Amount (₹)',
            prefixIcon: Icon(Icons.currency_rupee),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ApiService.addSavings(amount: double.parse(amountController.text));
                Navigator.pop(context);
                await _loadData(); // Wait for data to reload
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Savings added successfully!'),
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
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showPayBillsDialog() async {
    try {
      // Fetch unpaid bills
      final expenses = await ApiService.getExpenses();
      final unpaidBills = expenses.where((expense) => !expense.isPaid).toList();
      
      if (unpaidBills.isEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('No Unpaid Bills'),
            content: const Text('All your bills are paid! Great job! 🎉'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Pay Bills'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: unpaidBills.length,
              itemBuilder: (context, index) {
                final bill = unpaidBills[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getCategoryColor(bill.category),
                      child: Icon(
                        _getCategoryIcon(bill.category),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      bill.description,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Category: ${bill.category}'),
                        if (bill.dueDate != null)
                          Text(
                            'Due: ${DateFormat('MMM dd, yyyy').format(bill.dueDate!)}',
                            style: TextStyle(
                              color: bill.dueDate!.isBefore(DateTime.now()) 
                                ? Colors.red 
                                : Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '₹${bill.amount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => _markBillAsPaid(bill.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: const Size(60, 28),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text(
                            'Pay',
                            style: TextStyle(fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading bills: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Future<void> _markBillAsPaid(String billId) async {
    try {
      await ApiService.markExpenseAsPaid(billId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bill marked as paid! ✅'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Close dialog and refresh data
        Navigator.pop(context);
        await _loadData(); // Wait for data to reload
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error paying bill: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'utilities':
        return Colors.blue;
      case 'rent & housing':
        return Colors.purple;
      case 'food & dining':
        return Colors.orange;
      case 'transportation':
        return Colors.green;
      case 'shopping':
        return Colors.pink;
      case 'healthcare':
        return Colors.red;
      case 'entertainment':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
  
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'utilities':
        return Icons.electrical_services;
      case 'rent & housing':
        return Icons.home;
      case 'food & dining':
        return Icons.restaurant;
      case 'transportation':
        return Icons.directions_car;
      case 'shopping':
        return Icons.shopping_bag;
      case 'healthcare':
        return Icons.medical_services;
      case 'entertainment':
        return Icons.movie;
      default:
        return Icons.receipt;
    }
  }
}