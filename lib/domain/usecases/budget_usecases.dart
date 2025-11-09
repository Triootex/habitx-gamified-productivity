import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../entities/budget_entity.dart';
import '../../data/repositories/budget_repository_impl.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';

// Create Budget Use Case
@injectable
class CreateBudgetUseCase implements UseCase<BudgetEntity, CreateBudgetParams> {
  final BudgetRepository repository;

  CreateBudgetUseCase(this.repository);

  @override
  Future<Either<Failure, BudgetEntity>> call(CreateBudgetParams params) async {
    return await repository.createBudget(params.userId, params.budgetData);
  }
}

class CreateBudgetParams {
  final String userId;
  final Map<String, dynamic> budgetData;

  CreateBudgetParams({required this.userId, required this.budgetData});
}

// Add Transaction Use Case
@injectable
class AddTransactionUseCase implements UseCase<TransactionEntity, AddTransactionParams> {
  final BudgetRepository repository;

  AddTransactionUseCase(this.repository);

  @override
  Future<Either<Failure, TransactionEntity>> call(AddTransactionParams params) async {
    return await repository.addTransaction(params.userId, params.transactionData);
  }
}

class AddTransactionParams {
  final String userId;
  final Map<String, dynamic> transactionData;

  AddTransactionParams({required this.userId, required this.transactionData});
}

// Get User Transactions Use Case
@injectable
class GetUserTransactionsUseCase implements UseCase<List<TransactionEntity>, GetUserTransactionsParams> {
  final BudgetRepository repository;

  GetUserTransactionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<TransactionEntity>>> call(GetUserTransactionsParams params) async {
    return await repository.getUserTransactions(
      params.userId,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class GetUserTransactionsParams {
  final String userId;
  final DateTime? startDate;
  final DateTime? endDate;

  GetUserTransactionsParams({
    required this.userId,
    this.startDate,
    this.endDate,
  });
}

// Get User Budgets Use Case
@injectable
class GetUserBudgetsUseCase implements UseCase<List<BudgetEntity>, String> {
  final BudgetRepository repository;

  GetUserBudgetsUseCase(this.repository);

  @override
  Future<Either<Failure, List<BudgetEntity>>> call(String userId) async {
    return await repository.getUserBudgets(userId);
  }
}

// Create Financial Goal Use Case
@injectable
class CreateFinancialGoalUseCase implements UseCase<FinancialGoalEntity, CreateFinancialGoalParams> {
  final BudgetRepository repository;

  CreateFinancialGoalUseCase(this.repository);

  @override
  Future<Either<Failure, FinancialGoalEntity>> call(CreateFinancialGoalParams params) async {
    return await repository.createGoal(params.userId, params.goalData);
  }
}

class CreateFinancialGoalParams {
  final String userId;
  final Map<String, dynamic> goalData;

  CreateFinancialGoalParams({required this.userId, required this.goalData});
}

// Get User Financial Goals Use Case
@injectable
class GetUserFinancialGoalsUseCase implements UseCase<List<FinancialGoalEntity>, String> {
  final BudgetRepository repository;

  GetUserFinancialGoalsUseCase(this.repository);

  @override
  Future<Either<Failure, List<FinancialGoalEntity>>> call(String userId) async {
    return await repository.getUserGoals(userId);
  }
}

// Get Budget Analytics Use Case
@injectable
class GetBudgetAnalyticsUseCase implements UseCase<Map<String, dynamic>, GetBudgetAnalyticsParams> {
  final BudgetRepository repository;

  GetBudgetAnalyticsUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(GetBudgetAnalyticsParams params) async {
    return await repository.getBudgetAnalytics(
      params.userId,
      params.startDate,
      params.endDate,
    );
  }
}

class GetBudgetAnalyticsParams {
  final String userId;
  final DateTime? startDate;
  final DateTime? endDate;

  GetBudgetAnalyticsParams({
    required this.userId,
    this.startDate,
    this.endDate,
  });
}

// Categorize Transaction Use Case
@injectable
class CategorizeTransactionUseCase implements UseCase<Map<String, dynamic>, CategorizeTransactionParams> {
  final BudgetRepository repository;

  CategorizeTransactionUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(CategorizeTransactionParams params) async {
    return await repository.categorizeTransaction(params.description, params.amount);
  }
}

class CategorizeTransactionParams {
  final String description;
  final double amount;

  CategorizeTransactionParams({required this.description, required this.amount});
}

// Generate Grocery List Use Case
@injectable
class GenerateGroceryListUseCase implements UseCase<List<String>, GenerateGroceryListParams> {
  final BudgetRepository repository;

  GenerateGroceryListUseCase(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(GenerateGroceryListParams params) async {
    return await repository.generateGroceryList(params.userId, params.mealPlanIds);
  }
}

class GenerateGroceryListParams {
  final String userId;
  final List<String> mealPlanIds;

  GenerateGroceryListParams({required this.userId, required this.mealPlanIds});
}

// Calculate Net Worth Use Case
@injectable
class CalculateNetWorthUseCase implements UseCase<Map<String, dynamic>, String> {
  final BudgetRepository repository;

  CalculateNetWorthUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(String userId) async {
    return await repository.calculateNetWorth(userId);
  }
}

// Sync Budget Data Use Case
@injectable
class SyncBudgetDataUseCase implements UseCase<bool, String> {
  final BudgetRepository repository;

  SyncBudgetDataUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(String userId) async {
    return await repository.syncBudgetData(userId);
  }
}

// Sync with Bank Accounts Use Case
@injectable
class SyncWithBankAccountsUseCase implements UseCase<bool, String> {
  final BudgetRepository repository;

  SyncWithBankAccountsUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(String userId) async {
    return await repository.syncWithBankAccounts(userId);
  }
}

// Calculate Budget Health Score Use Case
@injectable
class CalculateBudgetHealthScoreUseCase implements UseCase<Map<String, dynamic>, String> {
  final BudgetRepository repository;

  CalculateBudgetHealthScoreUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(String userId) async {
    try {
      final budgetsResult = await repository.getUserBudgets(userId);
      final transactionsResult = await repository.getUserTransactions(
        userId,
        startDate: DateTime.now().subtract(const Duration(days: 30)),
      );
      
      return budgetsResult.fold(
        (failure) => Left(failure),
        (budgets) async {
          final transactions = await transactionsResult.fold(
            (failure) => <TransactionEntity>[],
            (txns) => txns,
          );
          
          final healthScore = _calculateBudgetHealthScore(budgets, transactions);
          return Right(healthScore);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to calculate budget health: ${e.toString()}'));
    }
  }

  Map<String, dynamic> _calculateBudgetHealthScore(List<BudgetEntity> budgets, List<TransactionEntity> transactions) {
    if (budgets.isEmpty) {
      return {
        'health_score': 50,
        'budget_adherence': 0.0,
        'savings_rate': 0.0,
        'expense_control': 50,
        'financial_stability': 50,
        'grade': 'No Budget',
        'recommendations': [
          'Create a budget to track your spending',
          'Set up savings goals for better financial health',
        ],
      };
    }
    
    // Calculate budget adherence
    double totalBudgetAdherence = 0.0;
    final categoryPerformance = <String, Map<String, dynamic>>{};
    
    for (final budget in budgets) {
      final categoryTransactions = transactions.where((t) => t.category == budget.category).toList();
      final totalSpent = categoryTransactions.fold<double>(0.0, (sum, t) => sum + t.amount.abs());
      final budgetLimit = budget.limitAmount;
      
      final adherence = budgetLimit > 0 ? (1 - (totalSpent / budgetLimit).clamp(0, 2)) : 0.0;
      totalBudgetAdherence += adherence;
      
      categoryPerformance[budget.category] = {
        'budget': budgetLimit,
        'spent': totalSpent,
        'remaining': (budgetLimit - totalSpent).clamp(0, double.infinity),
        'adherence': adherence,
        'status': totalSpent <= budgetLimit ? 'on_track' : 'over_budget',
      };
    }
    
    final avgBudgetAdherence = budgets.isNotEmpty ? totalBudgetAdherence / budgets.length : 0.0;
    
    // Calculate savings rate
    final income = transactions.where((t) => t.amount > 0).fold<double>(0.0, (sum, t) => sum + t.amount);
    final expenses = transactions.where((t) => t.amount < 0).fold<double>(0.0, (sum, t) => sum + t.amount.abs());
    final savingsRate = income > 0 ? ((income - expenses) / income).clamp(-1, 1) : 0.0;
    
    // Calculate expense control (variance in spending)
    final expenseVariance = _calculateExpenseVariance(transactions);
    final expenseControl = (100 - (expenseVariance * 100)).clamp(0, 100);
    
    // Calculate financial stability
    final emergencyFund = _estimateEmergencyFund(transactions);
    final monthlyExpenses = expenses / 1; // Assuming 1 month of data
    final emergencyRatio = monthlyExpenses > 0 ? emergencyFund / (monthlyExpenses * 3) : 0; // 3 months target
    final stabilityScore = (emergencyRatio * 100).clamp(0, 100);
    
    // Overall health score (weighted average)
    final healthScore = (
      (avgBudgetAdherence * 100 * 0.3) + // 30% budget adherence
      (savingsRate * 100 * 0.25) + // 25% savings rate
      (expenseControl * 0.25) + // 25% expense control
      (stabilityScore * 0.2) // 20% financial stability
    ).clamp(0, 100);
    
    final grade = _getFinancialGrade(healthScore.round());
    final recommendations = _generateFinancialRecommendations(
      avgBudgetAdherence, 
      savingsRate, 
      expenseControl, 
      stabilityScore,
      categoryPerformance,
    );
    
    return {
      'health_score': healthScore.round(),
      'budget_adherence': double.parse((avgBudgetAdherence * 100).toStringAsFixed(1)),
      'savings_rate': double.parse((savingsRate * 100).toStringAsFixed(1)),
      'expense_control': expenseControl.round(),
      'financial_stability': stabilityScore.round(),
      'grade': grade,
      'category_performance': categoryPerformance,
      'monthly_income': income,
      'monthly_expenses': expenses,
      'emergency_fund_estimate': emergencyFund,
      'recommendations': recommendations,
    };
  }

  double _calculateExpenseVariance(List<TransactionEntity> transactions) {
    final dailyExpenses = <String, double>{};
    
    for (final transaction in transactions.where((t) => t.amount < 0)) {
      final dateKey = _formatDateKey(transaction.date);
      dailyExpenses[dateKey] = (dailyExpenses[dateKey] ?? 0) + transaction.amount.abs();
    }
    
    if (dailyExpenses.length < 2) return 0.0;
    
    final expenses = dailyExpenses.values.toList();
    final mean = expenses.reduce((a, b) => a + b) / expenses.length;
    final variance = expenses.fold<double>(0.0, (sum, expense) => sum + ((expense - mean) * (expense - mean))) / expenses.length;
    
    return variance > 0 ? (variance / (mean * mean)) : 0.0; // Coefficient of variation
  }

  double _estimateEmergencyFund(List<TransactionEntity> transactions) {
    // Simple heuristic: look for large positive balances or savings transactions
    final savingsTransactions = transactions.where((t) => 
        t.category == 'savings' || 
        t.category == 'investment' ||
        t.description.toLowerCase().contains('emergency')
    ).toList();
    
    return savingsTransactions.fold<double>(0.0, (sum, t) => sum + t.amount.abs());
  }

  String _getFinancialGrade(int score) {
    if (score >= 90) return 'A+';
    if (score >= 80) return 'A';
    if (score >= 70) return 'B';
    if (score >= 60) return 'C';
    if (score >= 50) return 'D';
    return 'F';
  }

  List<String> _generateFinancialRecommendations(
    double budgetAdherence,
    double savingsRate,
    double expenseControl,
    double stability,
    Map<String, Map<String, dynamic>> categoryPerformance,
  ) {
    final recommendations = <String>[];
    
    if (budgetAdherence < 0.7) {
      recommendations.add('Review and adjust your budget limits - you\'re exceeding budgets frequently');
    }
    
    if (savingsRate < 0.1) {
      recommendations.add('Aim to save at least 10% of your income for better financial health');
    } else if (savingsRate < 0.2) {
      recommendations.add('Great savings habit! Try to increase to 20% if possible');
    }
    
    if (expenseControl < 60) {
      recommendations.add('Your spending varies significantly - try to establish more consistent spending patterns');
    }
    
    if (stability < 50) {
      recommendations.add('Build an emergency fund covering 3-6 months of expenses');
    }
    
    // Category-specific recommendations
    categoryPerformance.forEach((category, performance) {
      if (performance['status'] == 'over_budget') {
        recommendations.add('You\'re over budget in $category - consider reducing spending in this area');
      }
    });
    
    if (recommendations.isEmpty) {
      recommendations.add('Excellent financial management! Keep up the great work');
    }
    
    return recommendations.take(5).toList();
  }

  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

// Get Spending Insights Use Case
@injectable
class GetSpendingInsightsUseCase implements UseCase<Map<String, dynamic>, GetSpendingInsightsParams> {
  final BudgetRepository repository;

  GetSpendingInsightsUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(GetSpendingInsightsParams params) async {
    try {
      final transactionsResult = await repository.getUserTransactions(
        params.userId,
        startDate: params.startDate ?? DateTime.now().subtract(const Duration(days: 30)),
        endDate: params.endDate ?? DateTime.now(),
      );
      
      return transactionsResult.fold(
        (failure) => Left(failure),
        (transactions) {
          final insights = _generateSpendingInsights(transactions);
          return Right(insights);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to generate spending insights: ${e.toString()}'));
    }
  }

  Map<String, dynamic> _generateSpendingInsights(List<TransactionEntity> transactions) {
    if (transactions.isEmpty) {
      return {
        'insights': ['Start tracking transactions to get spending insights'],
        'top_categories': {},
        'spending_patterns': {},
        'recommendations': ['Add your first transaction to begin analysis'],
      };
    }
    
    final expenses = transactions.where((t) => t.amount < 0).toList();
    final insights = <String>[];
    
    // Category analysis
    final categorySpending = <String, double>{};
    for (final expense in expenses) {
      categorySpending[expense.category] = (categorySpending[expense.category] ?? 0) + expense.amount.abs();
    }
    
    final sortedCategories = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    if (sortedCategories.isNotEmpty) {
      final topCategory = sortedCategories.first;
      final totalSpending = categorySpending.values.fold<double>(0, (sum, amount) => sum + amount);
      final percentage = ((topCategory.value / totalSpending) * 100).round();
      
      insights.add('${topCategory.key} is your biggest expense category at $percentage% of spending');
    }
    
    // Day of week patterns
    final daySpending = <int, double>{};
    for (final expense in expenses) {
      final day = expense.date.weekday;
      daySpending[day] = (daySpending[day] ?? 0) + expense.amount.abs();
    }
    
    if (daySpending.isNotEmpty) {
      final mostExpensiveDay = daySpending.entries.reduce((a, b) => a.value > b.value ? a : b);
      final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      insights.add('You spend most on ${dayNames[mostExpensiveDay.key - 1]}s');
    }
    
    // Frequency analysis
    final dailyTransactionCount = <String, int>{};
    for (final transaction in transactions) {
      final dateKey = _formatDateKey(transaction.date);
      dailyTransactionCount[dateKey] = (dailyTransactionCount[dateKey] ?? 0) + 1;
    }
    
    final avgTransactionsPerDay = dailyTransactionCount.values.isNotEmpty
        ? dailyTransactionCount.values.reduce((a, b) => a + b) / dailyTransactionCount.length
        : 0;
    
    if (avgTransactionsPerDay > 5) {
      insights.add('You make ${avgTransactionsPerDay.round()} transactions per day on average');
    }
    
    final recommendations = _generateSpendingRecommendations(categorySpending, insights);
    
    return {
      'insights': insights,
      'top_categories': Map.fromEntries(sortedCategories.take(5)),
      'daily_average': avgTransactionsPerDay.round(),
      'total_transactions': transactions.length,
      'spending_patterns': {
        'day_of_week': daySpending,
        'category_distribution': categorySpending,
      },
      'recommendations': recommendations,
    };
  }

  List<String> _generateSpendingRecommendations(Map<String, double> categorySpending, List<String> insights) {
    final recommendations = <String>[];
    
    final sortedCategories = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    if (sortedCategories.isNotEmpty) {
      final topCategory = sortedCategories.first;
      recommendations.add('Consider ways to reduce ${topCategory.key} spending - it\'s your largest expense');
    }
    
    recommendations.addAll([
      'Set up budget alerts to avoid overspending',
      'Review subscriptions and recurring charges monthly',
      'Use the 24-hour rule for non-essential purchases',
      'Track daily expenses to stay aware of spending patterns',
    ]);
    
    return recommendations.take(4).toList();
  }

  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class GetSpendingInsightsParams {
  final String userId;
  final DateTime? startDate;
  final DateTime? endDate;

  GetSpendingInsightsParams({
    required this.userId,
    this.startDate,
    this.endDate,
  });
}
