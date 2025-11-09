import 'package:equatable/equatable.dart';

class BudgetEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String budgetType; // monthly, weekly, yearly, project-based
  final String method; // 50-30-20, zero-based, envelope, percentage
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  
  // Budget amounts
  final double totalIncome;
  final double totalBudgeted;
  final double totalSpent;
  final double remainingBudget;
  final Map<String, BudgetCategoryEntity> categories;
  
  // Goals and targets
  final double savingsGoal;
  final double currentSavings;
  final List<String> financialGoals;
  final Map<String, double> goalProgress;
  
  // Analysis and insights
  final Map<String, double> monthlyTrends;
  final List<String> recommendations;
  final double budgetHealth; // 0-100 score
  final bool isOverBudget;
  final List<String> alerts;
  
  final DateTime createdAt;
  final DateTime? updatedAt;

  const BudgetEntity({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.budgetType = 'monthly',
    this.method = '50-30-20',
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.totalIncome = 0.0,
    this.totalBudgeted = 0.0,
    this.totalSpent = 0.0,
    this.remainingBudget = 0.0,
    this.categories = const {},
    this.savingsGoal = 0.0,
    this.currentSavings = 0.0,
    this.financialGoals = const [],
    this.goalProgress = const {},
    this.monthlyTrends = const {},
    this.recommendations = const [],
    this.budgetHealth = 100.0,
    this.isOverBudget = false,
    this.alerts = const [],
    required this.createdAt,
    this.updatedAt,
  });

  double get spentPercentage => totalBudgeted > 0 ? totalSpent / totalBudgeted : 0.0;
  double get savingsRate => totalIncome > 0 ? currentSavings / totalIncome : 0.0;
  bool get onTrack => !isOverBudget && spentPercentage <= 1.0;

  BudgetEntity copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? budgetType,
    String? method,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    double? totalIncome,
    double? totalBudgeted,
    double? totalSpent,
    double? remainingBudget,
    Map<String, BudgetCategoryEntity>? categories,
    double? savingsGoal,
    double? currentSavings,
    List<String>? financialGoals,
    Map<String, double>? goalProgress,
    Map<String, double>? monthlyTrends,
    List<String>? recommendations,
    double? budgetHealth,
    bool? isOverBudget,
    List<String>? alerts,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BudgetEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      budgetType: budgetType ?? this.budgetType,
      method: method ?? this.method,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      totalIncome: totalIncome ?? this.totalIncome,
      totalBudgeted: totalBudgeted ?? this.totalBudgeted,
      totalSpent: totalSpent ?? this.totalSpent,
      remainingBudget: remainingBudget ?? this.remainingBudget,
      categories: categories ?? this.categories,
      savingsGoal: savingsGoal ?? this.savingsGoal,
      currentSavings: currentSavings ?? this.currentSavings,
      financialGoals: financialGoals ?? this.financialGoals,
      goalProgress: goalProgress ?? this.goalProgress,
      monthlyTrends: monthlyTrends ?? this.monthlyTrends,
      recommendations: recommendations ?? this.recommendations,
      budgetHealth: budgetHealth ?? this.budgetHealth,
      isOverBudget: isOverBudget ?? this.isOverBudget,
      alerts: alerts ?? this.alerts,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        description,
        budgetType,
        method,
        startDate,
        endDate,
        isActive,
        totalIncome,
        totalBudgeted,
        totalSpent,
        remainingBudget,
        categories,
        savingsGoal,
        currentSavings,
        financialGoals,
        goalProgress,
        monthlyTrends,
        recommendations,
        budgetHealth,
        isOverBudget,
        alerts,
        createdAt,
        updatedAt,
      ];
}

class BudgetCategoryEntity extends Equatable {
  final String id;
  final String budgetId;
  final String name;
  final String? icon;
  final String color;
  final double budgetedAmount;
  final double spentAmount;
  final double remainingAmount;
  final bool isEssential;
  final List<TransactionEntity> transactions;
  final Map<String, double> subcategories;
  final DateTime createdAt;

  const BudgetCategoryEntity({
    required this.id,
    required this.budgetId,
    required this.name,
    this.icon,
    required this.color,
    required this.budgetedAmount,
    this.spentAmount = 0.0,
    this.remainingAmount = 0.0,
    this.isEssential = false,
    this.transactions = const [],
    this.subcategories = const {},
    required this.createdAt,
  });

  double get spentPercentage => budgetedAmount > 0 ? spentAmount / budgetedAmount : 0.0;
  bool get isOverBudget => spentAmount > budgetedAmount;
  bool get isNearLimit => spentPercentage >= 0.8;

  BudgetCategoryEntity copyWith({
    String? id,
    String? budgetId,
    String? name,
    String? icon,
    String? color,
    double? budgetedAmount,
    double? spentAmount,
    double? remainingAmount,
    bool? isEssential,
    List<TransactionEntity>? transactions,
    Map<String, double>? subcategories,
    DateTime? createdAt,
  }) {
    return BudgetCategoryEntity(
      id: id ?? this.id,
      budgetId: budgetId ?? this.budgetId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      budgetedAmount: budgetedAmount ?? this.budgetedAmount,
      spentAmount: spentAmount ?? this.spentAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      isEssential: isEssential ?? this.isEssential,
      transactions: transactions ?? this.transactions,
      subcategories: subcategories ?? this.subcategories,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        budgetId,
        name,
        icon,
        color,
        budgetedAmount,
        spentAmount,
        remainingAmount,
        isEssential,
        transactions,
        subcategories,
        createdAt,
      ];
}

class TransactionEntity extends Equatable {
  final String id;
  final String userId;
  final String? budgetId;
  final String? categoryId;
  final String type; // income, expense, transfer
  final double amount;
  final String description;
  final String? merchant;
  final String? category;
  final String? subcategory;
  final DateTime date;
  final String? location;
  
  // Payment details
  final String paymentMethod; // cash, card, bank_transfer, etc.
  final String? accountId;
  final String? cardLastFour;
  final bool isRecurring;
  final String? recurringPattern;
  
  // Verification and sync
  final bool isVerified;
  final String? bankTransactionId;
  final String? receiptUrl;
  final Map<String, dynamic> bankData;
  
  // Tags and notes
  final List<String> tags;
  final String? notes;
  final bool isBusinessExpense;
  final bool isTaxDeductible;
  
  // AI categorization
  final bool isAICategorized;
  final double? aiConfidence;
  final Map<String, dynamic> aiSuggestions;
  
  final DateTime createdAt;
  final DateTime? updatedAt;

  const TransactionEntity({
    required this.id,
    required this.userId,
    this.budgetId,
    this.categoryId,
    required this.type,
    required this.amount,
    required this.description,
    this.merchant,
    this.category,
    this.subcategory,
    required this.date,
    this.location,
    this.paymentMethod = 'unknown',
    this.accountId,
    this.cardLastFour,
    this.isRecurring = false,
    this.recurringPattern,
    this.isVerified = false,
    this.bankTransactionId,
    this.receiptUrl,
    this.bankData = const {},
    this.tags = const [],
    this.notes,
    this.isBusinessExpense = false,
    this.isTaxDeductible = false,
    this.isAICategorized = false,
    this.aiConfidence,
    this.aiSuggestions = const {},
    required this.createdAt,
    this.updatedAt,
  });

  bool get isExpense => type == 'expense';
  bool get isIncome => type == 'income';
  bool get needsCategorization => category == null || category!.isEmpty;

  TransactionEntity copyWith({
    String? id,
    String? userId,
    String? budgetId,
    String? categoryId,
    String? type,
    double? amount,
    String? description,
    String? merchant,
    String? category,
    String? subcategory,
    DateTime? date,
    String? location,
    String? paymentMethod,
    String? accountId,
    String? cardLastFour,
    bool? isRecurring,
    String? recurringPattern,
    bool? isVerified,
    String? bankTransactionId,
    String? receiptUrl,
    Map<String, dynamic>? bankData,
    List<String>? tags,
    String? notes,
    bool? isBusinessExpense,
    bool? isTaxDeductible,
    bool? isAICategorized,
    double? aiConfidence,
    Map<String, dynamic>? aiSuggestions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      budgetId: budgetId ?? this.budgetId,
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      merchant: merchant ?? this.merchant,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      date: date ?? this.date,
      location: location ?? this.location,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      accountId: accountId ?? this.accountId,
      cardLastFour: cardLastFour ?? this.cardLastFour,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringPattern: recurringPattern ?? this.recurringPattern,
      isVerified: isVerified ?? this.isVerified,
      bankTransactionId: bankTransactionId ?? this.bankTransactionId,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      bankData: bankData ?? this.bankData,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
      isBusinessExpense: isBusinessExpense ?? this.isBusinessExpense,
      isTaxDeductible: isTaxDeductible ?? this.isTaxDeductible,
      isAICategorized: isAICategorized ?? this.isAICategorized,
      aiConfidence: aiConfidence ?? this.aiConfidence,
      aiSuggestions: aiSuggestions ?? this.aiSuggestions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        budgetId,
        categoryId,
        type,
        amount,
        description,
        merchant,
        category,
        subcategory,
        date,
        location,
        paymentMethod,
        accountId,
        cardLastFour,
        isRecurring,
        recurringPattern,
        isVerified,
        bankTransactionId,
        receiptUrl,
        bankData,
        tags,
        notes,
        isBusinessExpense,
        isTaxDeductible,
        isAICategorized,
        aiConfidence,
        aiSuggestions,
        createdAt,
        updatedAt,
      ];
}

class FinancialGoalEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String description;
  final String goalType; // save_money, pay_debt, invest, emergency_fund, etc.
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;
  final String priority; // high, medium, low
  final bool isActive;
  
  // Progress tracking
  final double monthlyContribution;
  final List<ContributionEntity> contributions;
  final double progressPercentage;
  final DateTime? estimatedCompletionDate;
  final bool isOnTrack;
  
  // Goal settings
  final bool autoSave;
  final double autoSaveAmount;
  final String autoSaveFrequency; // weekly, monthly
  final List<String> linkedAccounts;
  final Map<String, dynamic> strategies;
  
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? updatedAt;

  const FinancialGoalEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.goalType,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.targetDate,
    this.priority = 'medium',
    this.isActive = true,
    this.monthlyContribution = 0.0,
    this.contributions = const [],
    this.progressPercentage = 0.0,
    this.estimatedCompletionDate,
    this.isOnTrack = true,
    this.autoSave = false,
    this.autoSaveAmount = 0.0,
    this.autoSaveFrequency = 'monthly',
    this.linkedAccounts = const [],
    this.strategies = const {},
    required this.createdAt,
    this.completedAt,
    this.updatedAt,
  });

  bool get isCompleted => currentAmount >= targetAmount;
  double get remainingAmount => targetAmount - currentAmount;
  
  int get daysRemaining {
    if (isCompleted) return 0;
    return targetDate.difference(DateTime.now()).inDays;
  }

  FinancialGoalEntity copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? goalType,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    String? priority,
    bool? isActive,
    double? monthlyContribution,
    List<ContributionEntity>? contributions,
    double? progressPercentage,
    DateTime? estimatedCompletionDate,
    bool? isOnTrack,
    bool? autoSave,
    double? autoSaveAmount,
    String? autoSaveFrequency,
    List<String>? linkedAccounts,
    Map<String, dynamic>? strategies,
    DateTime? createdAt,
    DateTime? completedAt,
    DateTime? updatedAt,
  }) {
    return FinancialGoalEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      goalType: goalType ?? this.goalType,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      priority: priority ?? this.priority,
      isActive: isActive ?? this.isActive,
      monthlyContribution: monthlyContribution ?? this.monthlyContribution,
      contributions: contributions ?? this.contributions,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      estimatedCompletionDate: estimatedCompletionDate ?? this.estimatedCompletionDate,
      isOnTrack: isOnTrack ?? this.isOnTrack,
      autoSave: autoSave ?? this.autoSave,
      autoSaveAmount: autoSaveAmount ?? this.autoSaveAmount,
      autoSaveFrequency: autoSaveFrequency ?? this.autoSaveFrequency,
      linkedAccounts: linkedAccounts ?? this.linkedAccounts,
      strategies: strategies ?? this.strategies,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        description,
        goalType,
        targetAmount,
        currentAmount,
        targetDate,
        priority,
        isActive,
        monthlyContribution,
        contributions,
        progressPercentage,
        estimatedCompletionDate,
        isOnTrack,
        autoSave,
        autoSaveAmount,
        autoSaveFrequency,
        linkedAccounts,
        strategies,
        createdAt,
        completedAt,
        updatedAt,
      ];
}

class ContributionEntity extends Equatable {
  final String id;
  final String goalId;
  final double amount;
  final DateTime date;
  final String? source; // salary, bonus, savings, etc.
  final String? notes;
  final bool isAutomatic;

  const ContributionEntity({
    required this.id,
    required this.goalId,
    required this.amount,
    required this.date,
    this.source,
    this.notes,
    this.isAutomatic = false,
  });

  ContributionEntity copyWith({
    String? id,
    String? goalId,
    double? amount,
    DateTime? date,
    String? source,
    String? notes,
    bool? isAutomatic,
  }) {
    return ContributionEntity(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      source: source ?? this.source,
      notes: notes ?? this.notes,
      isAutomatic: isAutomatic ?? this.isAutomatic,
    );
  }

  @override
  List<Object?> get props => [id, goalId, amount, date, source, notes, isAutomatic];
}
