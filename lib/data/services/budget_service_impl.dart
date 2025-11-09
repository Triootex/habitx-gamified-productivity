import 'package:injectable/injectable.dart';
import '../../domain/entities/budget_entity.dart';
import '../../core/utils/budget_utils.dart';
import '../../core/utils/date_utils.dart';

abstract class BudgetService {
  Future<BudgetEntity> createBudget(String userId, Map<String, dynamic> budgetData);
  Future<TransactionEntity> addTransaction(String userId, Map<String, dynamic> transactionData);
  Future<List<TransactionEntity>> getUserTransactions(String userId, {DateTime? startDate, DateTime? endDate});
  Future<List<BudgetEntity>> getUserBudgets(String userId);
  Future<FinancialGoalEntity> createGoal(String userId, Map<String, dynamic> goalData);
  Future<Map<String, dynamic>> getBudgetAnalytics(String userId, DateTime? startDate, DateTime? endDate);
  Future<Map<String, dynamic>> categorizeTransaction(String description, double amount);
  Future<List<String>> generateGroceryList(String userId, List<String> mealPlanIds);
  Future<Map<String, dynamic>> calculateNetWorth(String userId);
  Future<List<String>> getBillNegotiationTips(String userId, String billType);
}

@LazySingleton(as: BudgetService)
class BudgetServiceImpl implements BudgetService {
  @override
  Future<BudgetEntity> createBudget(String userId, Map<String, dynamic> budgetData) async {
    try {
      final now = DateTime.now();
      final budgetId = 'budget_${now.millisecondsSinceEpoch}';
      
      final budget = BudgetEntity(
        id: budgetId,
        userId: userId,
        name: budgetData['name'] as String,
        description: budgetData['description'] as String?,
        budgetType: budgetData['budget_type'] as String? ?? 'monthly',
        method: budgetData['method'] as String? ?? '50-30-20',
        startDate: DateTime.parse(budgetData['start_date'] as String),
        endDate: DateTime.parse(budgetData['end_date'] as String),
        totalIncome: budgetData['total_income'] as double? ?? 0.0,
        totalBudgeted: budgetData['total_budgeted'] as double? ?? 0.0,
        savingsGoal: budgetData['savings_goal'] as double? ?? 0.0,
        financialGoals: (budgetData['financial_goals'] as List<dynamic>?)?.cast<String>() ?? [],
        categories: _createBudgetCategories(budgetId, budgetData['categories'] as Map<String, dynamic>? ?? {}),
        createdAt: now,
      );
      
      return budget;
    } catch (e) {
      throw Exception('Failed to create budget: ${e.toString()}');
    }
  }

  @override
  Future<TransactionEntity> addTransaction(String userId, Map<String, dynamic> transactionData) async {
    try {
      final now = DateTime.now();
      final transactionId = 'transaction_${now.millisecondsSinceEpoch}';
      
      // Auto-categorize transaction if category not provided
      final categorization = await categorizeTransaction(
        transactionData['description'] as String,
        transactionData['amount'] as double,
      );
      
      final transaction = TransactionEntity(
        id: transactionId,
        userId: userId,
        budgetId: transactionData['budget_id'] as String?,
        categoryId: transactionData['category_id'] as String?,
        type: transactionData['type'] as String,
        amount: transactionData['amount'] as double,
        description: transactionData['description'] as String,
        merchant: transactionData['merchant'] as String?,
        category: transactionData['category'] as String? ?? categorization['category'] as String?,
        subcategory: transactionData['subcategory'] as String?,
        date: transactionData['date'] != null 
            ? DateTime.parse(transactionData['date'] as String)
            : now,
        location: transactionData['location'] as String?,
        paymentMethod: transactionData['payment_method'] as String? ?? 'card',
        isRecurring: transactionData['is_recurring'] as bool? ?? false,
        recurringPattern: transactionData['recurring_pattern'] as String?,
        tags: (transactionData['tags'] as List<dynamic>?)?.cast<String>() ?? [],
        notes: transactionData['notes'] as String?,
        isBusinessExpense: transactionData['is_business'] as bool? ?? false,
        isTaxDeductible: transactionData['is_tax_deductible'] as bool? ?? false,
        isAICategorized: categorization['is_ai_categorized'] as bool? ?? false,
        aiConfidence: categorization['confidence'] as double?,
        createdAt: now,
      );
      
      return transaction;
    } catch (e) {
      throw Exception('Failed to add transaction: ${e.toString()}');
    }
  }

  @override
  Future<List<TransactionEntity>> getUserTransactions(String userId, {DateTime? startDate, DateTime? endDate}) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      
      final mockTransactions = _generateMockTransactions(userId);
      
      if (startDate != null || endDate != null) {
        final start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
        final end = endDate ?? DateTime.now();
        
        return mockTransactions.where((transaction) {
          return transaction.date.isAfter(start) && transaction.date.isBefore(end);
        }).toList();
      }
      
      return mockTransactions;
    } catch (e) {
      throw Exception('Failed to retrieve user transactions: ${e.toString()}');
    }
  }

  @override
  Future<List<BudgetEntity>> getUserBudgets(String userId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      return _generateMockBudgets(userId);
    } catch (e) {
      throw Exception('Failed to retrieve user budgets: ${e.toString()}');
    }
  }

  @override
  Future<FinancialGoalEntity> createGoal(String userId, Map<String, dynamic> goalData) async {
    try {
      final now = DateTime.now();
      final goalId = 'goal_${now.millisecondsSinceEpoch}';
      
      final goal = FinancialGoalEntity(
        id: goalId,
        userId: userId,
        name: goalData['name'] as String,
        description: goalData['description'] as String,
        goalType: goalData['goal_type'] as String,
        targetAmount: goalData['target_amount'] as double,
        currentAmount: goalData['current_amount'] as double? ?? 0.0,
        targetDate: DateTime.parse(goalData['target_date'] as String),
        priority: goalData['priority'] as String? ?? 'medium',
        monthlyContribution: goalData['monthly_contribution'] as double? ?? 0.0,
        autoSave: goalData['auto_save'] as bool? ?? false,
        autoSaveAmount: goalData['auto_save_amount'] as double? ?? 0.0,
        autoSaveFrequency: goalData['auto_save_frequency'] as String? ?? 'monthly',
        linkedAccounts: (goalData['linked_accounts'] as List<dynamic>?)?.cast<String>() ?? [],
        createdAt: now,
      );
      
      return goal;
    } catch (e) {
      throw Exception('Failed to create financial goal: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getBudgetAnalytics(String userId, DateTime? startDate, DateTime? endDate) async {
    try {
      final transactions = await getUserTransactions(userId, startDate: startDate, endDate: endDate);
      final budgets = await getUserBudgets(userId);
      
      if (transactions.isEmpty) {
        return {
          'total_income': 0.0,
          'total_expenses': 0.0,
          'net_cash_flow': 0.0,
          'savings_rate': 0.0,
        };
      }
      
      final income = transactions
          .where((t) => t.type == 'income')
          .fold<double>(0.0, (sum, t) => sum + t.amount);
      
      final expenses = transactions
          .where((t) => t.type == 'expense')
          .fold<double>(0.0, (sum, t) => sum + t.amount);
      
      final netCashFlow = income - expenses;
      final savingsRate = income > 0 ? netCashFlow / income : 0.0;
      
      // Category breakdown
      final categorySpending = <String, double>{};
      for (final transaction in transactions.where((t) => t.type == 'expense')) {
        final category = transaction.category ?? 'Uncategorized';
        categorySpending[category] = (categorySpending[category] ?? 0.0) + transaction.amount;
      }
      
      // Monthly trends
      final monthlyTrends = <String, Map<String, double>>{};
      for (final transaction in transactions) {
        final monthKey = DateUtils.formatDate(transaction.date, 'yyyy-MM');
        monthlyTrends.putIfAbsent(monthKey, () => {'income': 0.0, 'expenses': 0.0});
        
        if (transaction.type == 'income') {
          monthlyTrends[monthKey]!['income'] = monthlyTrends[monthKey]!['income']! + transaction.amount;
        } else if (transaction.type == 'expense') {
          monthlyTrends[monthKey]!['expenses'] = monthlyTrends[monthKey]!['expenses']! + transaction.amount;
        }
      }
      
      return {
        'period': {
          'start': (startDate ?? DateTime.now().subtract(const Duration(days: 30))).toIso8601String(),
          'end': (endDate ?? DateTime.now()).toIso8601String(),
        },
        'summary': {
          'total_income': income,
          'total_expenses': expenses,
          'net_cash_flow': netCashFlow,
          'savings_rate': savingsRate,
          'transaction_count': transactions.length,
        },
        'breakdown': {
          'by_category': categorySpending,
          'by_payment_method': _getPaymentMethodBreakdown(transactions),
        },
        'trends': {
          'monthly': monthlyTrends,
        },
        'insights': _generateBudgetInsights(transactions, budgets),
      };
    } catch (e) {
      throw Exception('Failed to get budget analytics: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> categorizeTransaction(String description, double amount) async {
    try {
      // Mock AI categorization - in real implementation, would use ML model
      await Future.delayed(const Duration(milliseconds: 200));
      
      final categories = {
        'groceries': ['grocery', 'supermarket', 'walmart', 'kroger', 'safeway'],
        'gas': ['gas', 'fuel', 'shell', 'bp', 'exxon', 'chevron'],
        'restaurants': ['restaurant', 'cafe', 'mcdonald', 'pizza', 'starbucks'],
        'utilities': ['electric', 'water', 'internet', 'phone', 'cable'],
        'shopping': ['amazon', 'target', 'mall', 'store', 'retail'],
        'entertainment': ['movie', 'theater', 'netflix', 'spotify', 'game'],
        'transportation': ['uber', 'lyft', 'bus', 'train', 'parking'],
        'healthcare': ['doctor', 'pharmacy', 'hospital', 'medical', 'dental'],
      };
      
      final lowerDescription = description.toLowerCase();
      
      for (final entry in categories.entries) {
        for (final keyword in entry.value) {
          if (lowerDescription.contains(keyword)) {
            return {
              'category': entry.key,
              'subcategory': keyword,
              'confidence': 0.85,
              'is_ai_categorized': true,
            };
          }
        }
      }
      
      // Default categorization based on amount
      String category = 'other';
      if (amount > 500) {
        category = 'major_purchase';
      } else if (amount < 10) {
        category = 'miscellaneous';
      }
      
      return {
        'category': category,
        'confidence': 0.3,
        'is_ai_categorized': true,
      };
    } catch (e) {
      throw Exception('Failed to categorize transaction: ${e.toString()}');
    }
  }

  @override
  Future<List<String>> generateGroceryList(String userId, List<String> mealPlanIds) async {
    try {
      return BudgetUtils.generateGroceryList(
        mealPlanIds: mealPlanIds,
        householdSize: 2, // Mock household size
        dietaryRestrictions: [], // Mock dietary restrictions
        preferredBrands: {}, // Mock brand preferences
        budgetLimit: 150.0, // Mock budget limit
      );
    } catch (e) {
      throw Exception('Failed to generate grocery list: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> calculateNetWorth(String userId) async {
    try {
      return BudgetUtils.calculateNetWorth(
        assets: {
          'cash': 5000.0,
          'savings': 15000.0,
          'investments': 25000.0,
          'real_estate': 200000.0,
          'vehicle': 15000.0,
        },
        liabilities: {
          'mortgage': 150000.0,
          'car_loan': 10000.0,
          'credit_card': 2500.0,
          'student_loan': 20000.0,
        },
        userId: userId,
      );
    } catch (e) {
      throw Exception('Failed to calculate net worth: ${e.toString()}');
    }
  }

  @override
  Future<List<String>> getBillNegotiationTips(String userId, String billType) async {
    try {
      return BudgetUtils.generateBillNegotiationStrategy(
        billType: billType,
        currentAmount: 100.0, // Mock current amount
        marketRates: {}, // Mock market rates
        userHistory: {}, // Mock user history
        loyaltyStatus: 'regular',
      );
    } catch (e) {
      throw Exception('Failed to get bill negotiation tips: ${e.toString()}');
    }
  }

  // Private helper methods
  Map<String, BudgetCategoryEntity> _createBudgetCategories(String budgetId, Map<String, dynamic> categoriesData) {
    final now = DateTime.now();
    final categories = <String, BudgetCategoryEntity>{};
    
    final defaultCategories = {
      'Housing': {'budgeted': 1200.0, 'color': '#FF6B6B', 'essential': true},
      'Food': {'budgeted': 400.0, 'color': '#4ECDC4', 'essential': true},
      'Transportation': {'budgeted': 300.0, 'color': '#45B7D1', 'essential': true},
      'Entertainment': {'budgeted': 200.0, 'color': '#96CEB4', 'essential': false},
      'Shopping': {'budgeted': 150.0, 'color': '#FFEAA7', 'essential': false},
    };
    
    for (final entry in defaultCategories.entries) {
      final categoryId = 'category_${entry.key.toLowerCase()}_${now.millisecondsSinceEpoch}';
      categories[entry.key] = BudgetCategoryEntity(
        id: categoryId,
        budgetId: budgetId,
        name: entry.key,
        color: entry.value['color'] as String,
        budgetedAmount: entry.value['budgeted'] as double,
        isEssential: entry.value['essential'] as bool,
        createdAt: now,
      );
    }
    
    return categories;
  }

  List<BudgetEntity> _generateMockBudgets(String userId) {
    final now = DateTime.now();
    
    return [
      BudgetEntity(
        id: 'budget_1',
        userId: userId,
        name: 'Monthly Budget',
        budgetType: 'monthly',
        method: '50-30-20',
        startDate: DateTime(now.year, now.month, 1),
        endDate: DateTime(now.year, now.month + 1, 0),
        totalIncome: 4000.0,
        totalBudgeted: 3500.0,
        totalSpent: 2800.0,
        remainingBudget: 700.0,
        savingsGoal: 800.0,
        currentSavings: 600.0,
        budgetHealth: 85.0,
        isOverBudget: false,
        createdAt: now.subtract(const Duration(days: 30)),
      ),
    ];
  }

  List<TransactionEntity> _generateMockTransactions(String userId) {
    final now = DateTime.now();
    
    return [
      TransactionEntity(
        id: 'transaction_1',
        userId: userId,
        type: 'expense',
        amount: 85.50,
        description: 'Grocery Store',
        category: 'Food',
        date: now.subtract(const Duration(days: 1)),
        paymentMethod: 'card',
        merchant: 'Whole Foods',
        isVerified: true,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      TransactionEntity(
        id: 'transaction_2',
        userId: userId,
        type: 'income',
        amount: 4000.0,
        description: 'Salary',
        category: 'Salary',
        date: now.subtract(const Duration(days: 5)),
        paymentMethod: 'bank_transfer',
        isVerified: true,
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      TransactionEntity(
        id: 'transaction_3',
        userId: userId,
        type: 'expense',
        amount: 45.00,
        description: 'Gas Station',
        category: 'Transportation',
        date: now.subtract(const Duration(days: 2)),
        paymentMethod: 'card',
        merchant: 'Shell',
        isVerified: true,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    ];
  }

  Map<String, double> _getPaymentMethodBreakdown(List<TransactionEntity> transactions) {
    final breakdown = <String, double>{};
    
    for (final transaction in transactions.where((t) => t.type == 'expense')) {
      breakdown[transaction.paymentMethod] = (breakdown[transaction.paymentMethod] ?? 0.0) + transaction.amount;
    }
    
    return breakdown;
  }

  List<String> _generateBudgetInsights(List<TransactionEntity> transactions, List<BudgetEntity> budgets) {
    final insights = <String>[];
    
    if (transactions.isEmpty) {
      insights.add('Start tracking your expenses to get personalized budget insights!');
      return insights;
    }
    
    final expenses = transactions.where((t) => t.type == 'expense').toList();
    final income = transactions.where((t) => t.type == 'income').fold<double>(0.0, (sum, t) => sum + t.amount);
    final totalExpenses = expenses.fold<double>(0.0, (sum, t) => sum + t.amount);
    
    // Spending insights
    if (totalExpenses > income * 0.9) {
      insights.add('⚠️ You\'re spending over 90% of your income. Consider reducing expenses.');
    } else if (totalExpenses < income * 0.7) {
      insights.add('💰 Great job! You\'re living below your means and saving well.');
    }
    
    // Category insights
    final categorySpending = <String, double>{};
    for (final transaction in expenses) {
      final category = transaction.category ?? 'Other';
      categorySpending[category] = (categorySpending[category] ?? 0.0) + transaction.amount;
    }
    
    final topCategory = categorySpending.entries.reduce((a, b) => a.value > b.value ? a : b);
    insights.add('Your top spending category is ${topCategory.key} at \$${topCategory.value.toStringAsFixed(2)}');
    
    // Frequency insights
    if (expenses.length >= 20) {
      insights.add('You have many transactions. Consider consolidating purchases to reduce fees.');
    }
    
    return insights;
  }
}
