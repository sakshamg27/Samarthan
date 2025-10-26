class User {
  final String id;
  final String name;
  final String email;
  final String? phone;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
    };
  }
}

class Expense {
  final String id;
  final String description;
  final double amount;
  final String category;
  final DateTime? dueDate;
  final DateTime? paidDate;
  final bool isPaid;
  final DateTime createdAt;

  Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.category,
    this.dueDate,
    this.paidDate,
    required this.isPaid,
    required this.createdAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] ?? json['_id'] ?? '',
      description: json['description'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      category: json['category'] ?? '',
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      paidDate: json['paidDate'] != null ? DateTime.parse(json['paidDate']) : null,
      isPaid: json['isPaid'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'amount': amount,
      'category': category,
      'dueDate': dueDate?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Expense(id: $id, description: $description, amount: $amount, category: $category, isPaid: $isPaid)';
  }
}

class Savings {
  final String id;
  final double amount;
  final String type;
  final String? description;
  final DateTime createdAt;

  Savings({
    required this.id,
    required this.amount,
    required this.type,
    this.description,
    required this.createdAt,
  });

  factory Savings.fromJson(Map<String, dynamic> json) {
    return Savings(
      id: json['id'] ?? json['_id'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      type: json['type'] ?? 'manual',
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'type': type,
      'description': description,
    };
  }

  @override
  String toString() {
    return 'Savings(id: $id, amount: $amount, type: $type, description: $description)';
  }
}

class SamarthanScore {
  final int score;
  final ScoreFactors factors;
  final DateTime lastUpdated;

  SamarthanScore({
    required this.score,
    required this.factors,
    required this.lastUpdated,
  });

  factory SamarthanScore.fromJson(Map<String, dynamic> json) {
    return SamarthanScore(
      score: json['score'] ?? 0,
      factors: ScoreFactors.fromJson(json['factors'] ?? {}),
      lastUpdated: json['lastUpdated'] != null 
          ? DateTime.parse(json['lastUpdated']) 
          : DateTime.now(),
    );
  }
}

class ScoreFactors {
  final int billPaymentConsistency;
  final int savingsDiscipline;
  final int cashFlowManagement;
  final int overdueBills;

  ScoreFactors({
    required this.billPaymentConsistency,
    required this.savingsDiscipline,
    required this.cashFlowManagement,
    required this.overdueBills,
  });

  factory ScoreFactors.fromJson(Map<String, dynamic> json) {
    return ScoreFactors(
      billPaymentConsistency: json['billPaymentConsistency'] ?? 0,
      savingsDiscipline: json['savingsDiscipline'] ?? 0,
      cashFlowManagement: json['cashFlowManagement'] ?? 0,
      overdueBills: json['overdueBills'] ?? 0,
    );
  }
}

class DashboardData {
  final int samarthanScore;
  final ScoreFactors scoreFactors;
  final List<Expense> recentExpenses;
  final List<Savings> recentSavings;
  final double totalExpenses;
  final double totalSavings;

  DashboardData({
    required this.samarthanScore,
    required this.scoreFactors,
    required this.recentExpenses,
    required this.recentSavings,
    required this.totalExpenses,
    required this.totalSavings,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      samarthanScore: json['samarthanScore'] ?? 0,
      scoreFactors: ScoreFactors.fromJson(json['scoreFactors'] ?? {}),
      recentExpenses: (json['recentExpenses'] as List?)
          ?.map((e) => Expense.fromJson(e))
          .toList() ?? [],
      recentSavings: (json['recentSavings'] as List?)
          ?.map((e) => Savings.fromJson(e))
          .toList() ?? [],
      totalExpenses: (json['totalExpenses'] ?? 0).toDouble(),
      totalSavings: (json['totalSavings'] ?? 0).toDouble(),
    );
  }
}
