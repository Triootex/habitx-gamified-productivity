import '../constants/budget_constants.dart';
import 'string_utils.dart';
import 'math_utils.dart';

class BudgetUtils {
  /// Calculate budget allocation using different methods
  static Map<String, double> calculateBudgetAllocation(
    double totalIncome,
    String budgetMethod,
    Map<String, double> customPercentages,
  ) {
    final allocation = <String, double>{};
    
    switch (budgetMethod) {
      case BudgetConstants.zeroBasedBudgeting:
        allocation.addAll(_calculateZeroBasedAllocation(totalIncome, customPercentages));
        break;
      case BudgetConstants.envelopeBudgeting:
        allocation.addAll(_calculateEnvelopeAllocation(totalIncome));
        break;
      case BudgetConstants.percentageBudgeting:
        allocation.addAll(_calculatePercentageAllocation(totalIncome));
        break;
      default:
        allocation.addAll(_calculate50_30_20Allocation(totalIncome));
    }
    
    return allocation;
  }
  
  static Map<String, double> _calculateZeroBasedAllocation(
    double income,
    Map<String, double> customPercentages,
  ) {
    final allocation = <String, double>{};
    
    // Start with essentials
    allocation['housing'] = customPercentages['housing'] ?? (income * 0.30);
    allocation['utilities'] = customPercentages['utilities'] ?? (income * 0.05);
    allocation['groceries'] = customPercentages['groceries'] ?? (income * 0.10);
    allocation['transportation'] = customPercentages['transportation'] ?? (income * 0.15);
    allocation['insurance'] = customPercentages['insurance'] ?? (income * 0.05);
    
    // Calculate remaining for discretionary spending
    final essentialTotal = allocation.values.fold<double>(0, (sum, amount) => sum + amount);
    final remaining = income - essentialTotal;
    
    allocation['savings'] = remaining * 0.20;
    allocation['entertainment'] = remaining * 0.30;
    allocation['dining_out'] = remaining * 0.25;
    allocation['miscellaneous'] = remaining * 0.25;
    
    return allocation;
  }
  
  static Map<String, double> _calculateEnvelopeAllocation(double income) {
    final allocation = <String, double>{};
    
    for (final category in BudgetConstants.envelopeCategories) {
      final envelopes = category['envelopes'] as List<String>;
      final priority = category['priority'] as int;
      
      double categoryAmount;
      switch (priority) {
        case 1: // Necessities - 50%
          categoryAmount = income * 0.50;
          break;
        case 2: // Savings & Debt - 25%
          categoryAmount = income * 0.25;
          break;
        case 3: // Lifestyle - 15%
          categoryAmount = income * 0.15;
          break;
        case 4: // Irregular - 10%
          categoryAmount = income * 0.10;
          break;
        default:
          categoryAmount = income * 0.05;
      }
      
      // Distribute equally among envelopes in category
      final amountPerEnvelope = categoryAmount / envelopes.length;
      for (final envelope in envelopes) {
        allocation[envelope] = amountPerEnvelope;
      }
    }
    
    return allocation;
  }
  
  static Map<String, double> _calculatePercentageAllocation(double income) {
    return {
      'housing': income * 0.30,
      'transportation': income * 0.15,
      'food': income * 0.12,
      'utilities': income * 0.08,
      'savings': income * 0.20,
      'entertainment': income * 0.05,
      'healthcare': income * 0.05,
      'miscellaneous': income * 0.05,
    };
  }
  
  static Map<String, double> _calculate50_30_20Allocation(double income) {
    return {
      'needs': income * 0.50,
      'wants': income * 0.30,
      'savings_debt': income * 0.20,
    };
  }
  
  /// Calculate net worth from assets and liabilities
  static Map<String, dynamic> calculateNetWorth(
    Map<String, double> assets,
    Map<String, double> liabilities,
  ) {
    final totalAssets = assets.values.fold<double>(0, (sum, value) => sum + value);
    final totalLiabilities = liabilities.values.fold<double>(0, (sum, value) => sum + value);
    final netWorth = totalAssets - totalLiabilities;
    
    // Calculate debt-to-asset ratio
    final debtToAssetRatio = totalAssets > 0 ? totalLiabilities / totalAssets : 0.0;
    
    // Calculate liquidity ratio (liquid assets / monthly expenses)
    final liquidAssets = _calculateLiquidAssets(assets);
    final monthlyExpenses = _estimateMonthlyExpenses(liabilities);
    final liquidityRatio = monthlyExpenses > 0 ? liquidAssets / monthlyExpenses : 0.0;
    
    return {
      'net_worth': netWorth,
      'total_assets': totalAssets,
      'total_liabilities': totalLiabilities,
      'debt_to_asset_ratio': debtToAssetRatio,
      'liquidity_ratio': liquidityRatio,
      'financial_health_score': _calculateFinancialHealthScore(debtToAssetRatio, liquidityRatio, netWorth),
    };
  }
  
  static double _calculateLiquidAssets(Map<String, double> assets) {
    final liquidCategories = ['cash', 'savings', 'checking', 'money_market'];
    return assets.entries
        .where((entry) => liquidCategories.any((cat) => entry.key.contains(cat)))
        .fold<double>(0, (sum, entry) => sum + entry.value);
  }
  
  static double _estimateMonthlyExpenses(Map<String, double> liabilities) {
    // Estimate monthly expenses from debt payments (rough calculation)
    return liabilities.values.fold<double>(0, (sum, debt) => sum + (debt * 0.03)); // Assume 3% monthly payment
  }
  
  static int _calculateFinancialHealthScore(double debtRatio, double liquidityRatio, double netWorth) {
    int score = 50; // Base score
    
    // Debt ratio scoring (lower is better)
    if (debtRatio < 0.2) score += 20;
    else if (debtRatio < 0.4) score += 10;
    else if (debtRatio > 0.8) score -= 20;
    
    // Liquidity scoring (higher is better)
    if (liquidityRatio > 6) score += 20; // 6 months expenses
    else if (liquidityRatio > 3) score += 10; // 3 months expenses
    else if (liquidityRatio < 1) score -= 15;
    
    // Net worth scoring
    if (netWorth > 100000) score += 15;
    else if (netWorth > 50000) score += 10;
    else if (netWorth < 0) score -= 25;
    
    return score.clamp(0, 100);
  }
  
  /// Auto-generate grocery lists from meal plans
  static List<Map<String, dynamic>> generateGroceryList(
    List<Map<String, dynamic>> mealPlan,
    Map<String, dynamic> pantryInventory,
  ) {
    final groceryList = <Map<String, dynamic>>[];
    final ingredientCounts = <String, double>{};
    
    // Extract ingredients from all meals
    for (final meal in mealPlan) {
      final ingredients = meal['ingredients'] as List<Map<String, dynamic>>? ?? [];
      for (final ingredient in ingredients) {
        final name = ingredient['name'] as String;
        final quantity = ingredient['quantity'] as double? ?? 1.0;
        final unit = ingredient['unit'] as String? ?? 'item';
        
        final key = '${name}_$unit';
        ingredientCounts[key] = (ingredientCounts[key] ?? 0) + quantity;
      }
    }
    
    // Check against pantry and create shopping list
    for (final entry in ingredientCounts.entries) {
      final parts = entry.key.split('_');
      final name = parts[0];
      final unit = parts.length > 1 ? parts[1] : 'item';
      final neededQuantity = entry.value;
      
      final availableQuantity = pantryInventory[name] as double? ?? 0.0;
      final quantityToBuy = neededQuantity - availableQuantity;
      
      if (quantityToBuy > 0) {
        groceryList.add({
          'name': name,
          'quantity': quantityToBuy,
          'unit': unit,
          'category': _categorizeGroceryItem(name),
          'estimated_cost': _estimateItemCost(name, quantityToBuy, unit),
          'priority': _getItemPriority(name),
        });
      }
    }
    
    // Sort by category and priority
    groceryList.sort((a, b) {
      final categoryA = a['category'] as String;
      final categoryB = b['category'] as String;
      if (categoryA != categoryB) {
        return categoryA.compareTo(categoryB);
      }
      return (b['priority'] as int).compareTo(a['priority'] as int);
    });
    
    return groceryList;
  }
  
  static String _categorizeGroceryItem(String item) {
    final categories = BudgetConstants.groceryCategories;
    final itemLower = item.toLowerCase();
    
    for (final category in categories) {
      final items = category['items'] as List<String>;
      if (items.any((cat) => itemLower.contains(cat))) {
        return category['name'] as String;
      }
    }
    
    return 'Miscellaneous';
  }
  
  static double _estimateItemCost(String name, double quantity, String unit) {
    // Mock cost estimation - in real app, would use price database
    final baseCosts = {
      'milk': 3.50,
      'bread': 2.00,
      'eggs': 4.00,
      'chicken': 8.00,
      'rice': 2.50,
      'onions': 1.50,
      'tomatoes': 3.00,
    };
    
    final baseCost = baseCosts[name.toLowerCase()] ?? 2.00;
    final quantityMultiplier = unit == 'kg' ? quantity : (unit == 'lb' ? quantity * 0.45 : quantity);
    
    return baseCost * quantityMultiplier;
  }
  
  static int _getItemPriority(String item) {
    final essentials = ['milk', 'bread', 'eggs', 'rice', 'chicken'];
    return essentials.contains(item.toLowerCase()) ? 3 : 1;
  }
  
  /// Bill negotiation helper
  static Map<String, dynamic> generateNegotiationStrategy(
    String serviceType,
    Map<String, dynamic> currentBill,
    Map<String, dynamic> userProfile,
  ) {
    final template = BudgetConstants.billNegotiationTemplates
        .firstWhere((t) => t['service'] == serviceType, 
            orElse: () => BudgetConstants.billNegotiationTemplates.first);
    
    final scripts = template['scripts'] as List<String>;
    final averageSavings = template['average_savings'] as int;
    
    final currentAmount = currentBill['monthly_amount'] as double? ?? 0.0;
    final customerYears = userProfile['years_with_service'] as int? ?? 1;
    final paymentHistory = userProfile['payment_history'] as String? ?? 'good';
    
    // Calculate leverage score
    int leverageScore = 0;
    if (customerYears >= 2) leverageScore += 20;
    if (paymentHistory == 'excellent') leverageScore += 15;
    if (currentAmount > 100) leverageScore += 10; // Higher value customer
    
    // Personalize scripts
    final personalizedScripts = scripts.map((script) => 
        script.replaceAll('{years}', customerYears.toString())).toList();
    
    final potentialSavings = currentAmount * (averageSavings / 100.0);
    
    return {
      'service_type': serviceType,
      'leverage_score': leverageScore,
      'scripts': personalizedScripts,
      'potential_monthly_savings': potentialSavings,
      'potential_annual_savings': potentialSavings * 12,
      'best_time_to_call': _getBestCallTime(serviceType),
      'preparation_tips': _getPreparationTips(serviceType, leverageScore),
      'success_probability': _calculateSuccessProbability(leverageScore, serviceType),
    };
  }
  
  static String _getBestCallTime(String serviceType) {
    // Different services have different optimal times
    switch (serviceType) {
      case 'Internet/Cable':
        return 'Tuesday-Thursday, 10 AM - 2 PM';
      case 'Phone':
        return 'Monday-Wednesday, 9 AM - 11 AM';
      case 'Insurance':
        return 'Wednesday-Friday, 2 PM - 4 PM';
      default:
        return 'Weekdays, 10 AM - 3 PM';
    }
  }
  
  static List<String> _getPreparationTips(String serviceType, int leverageScore) {
    final baseTips = [
      'Research competitor rates beforehand',
      'Have your account information ready',
      'Be polite but firm',
      'Ask to speak with retention department',
    ];
    
    if (leverageScore > 30) {
      baseTips.add('Mention your loyalty as a long-term customer');
    }
    
    if (serviceType == 'Internet/Cable') {
      baseTips.add('Know your current speed and usage patterns');
    }
    
    return baseTips;
  }
  
  static double _calculateSuccessProbability(int leverageScore, String serviceType) {
    double baseRate = 0.6; // 60% base success rate
    
    // Adjust based on leverage
    baseRate += leverageScore * 0.01; // 1% per leverage point
    
    // Service-specific adjustments
    switch (serviceType) {
      case 'Internet/Cable':
        baseRate += 0.1; // Higher success rate for cable
        break;
      case 'Insurance':
        baseRate -= 0.05; // Slightly lower for insurance
        break;
    }
    
    return baseRate.clamp(0.1, 0.9);
  }
  
  /// Debt payoff calculator
  static Map<String, dynamic> calculateDebtPayoff(
    List<Map<String, dynamic>> debts,
    double extraPayment,
    String strategy,
  ) {
    final debtList = List<Map<String, dynamic>>.from(debts);
    
    // Sort based on strategy
    switch (strategy) {
      case 'snowball':
        debtList.sort((a, b) => (a['balance'] as double).compareTo(b['balance'] as double));
        break;
      case 'avalanche':
        debtList.sort((a, b) => (b['interest_rate'] as double).compareTo(a['interest_rate'] as double));
        break;
      case 'highest_payment':
        debtList.sort((a, b) => (b['minimum_payment'] as double).compareTo(a['minimum_payment'] as double));
        break;
    }
    
    final payoffSchedule = <Map<String, dynamic>>[];
    double totalInterestSaved = 0;
    int monthsToPayoff = 0;
    double remainingExtra = extraPayment;
    
    // Calculate payoff timeline
    for (int month = 1; month <= 360; month++) { // Max 30 years
      monthsToPayoff = month;
      bool allPaidOff = true;
      
      for (final debt in debtList) {
        final balance = debt['balance'] as double;
        if (balance <= 0) continue;
        
        allPaidOff = false;
        final minPayment = debt['minimum_payment'] as double;
        final interestRate = (debt['interest_rate'] as double) / 100 / 12; // Monthly rate
        
        // Calculate payment for this debt
        double payment = minPayment;
        if (debt == debtList.first && remainingExtra > 0) {
          payment += remainingExtra; // Apply extra payment to priority debt
        }
        
        payment = math.min(payment, balance); // Don't overpay
        
        final interestPayment = balance * interestRate;
        final principalPayment = payment - interestPayment;
        
        debt['balance'] = math.max(0, balance - principalPayment);
        totalInterestSaved += interestPayment;
      }
      
      if (allPaidOff) break;
    }
    
    return {
      'strategy': strategy,
      'months_to_payoff': monthsToPayoff,
      'years_to_payoff': (monthsToPayoff / 12.0).toStringAsFixed(1),
      'total_interest_paid': totalInterestSaved,
      'monthly_extra_payment': extraPayment,
      'payoff_order': debtList.map((d) => d['name']).toList(),
      'total_debt': debts.fold<double>(0, (sum, debt) => sum + (debt['balance'] as double)),
    };
  }
  
  /// Validate budget data
  static Map<String, String?> validateBudgetData(Map<String, dynamic> data) {
    final errors = <String, String?>{};
    
    final income = data['monthly_income'] as double?;
    if (income == null || income <= 0) {
      errors['monthly_income'] = 'Monthly income must be greater than 0';
    } else if (income > BudgetConstants.maxBudgetAmount) {
      errors['monthly_income'] = 'Income amount is too high';
    }
    
    final expenses = data['total_expenses'] as double?;
    if (expenses != null && income != null && expenses > income * 1.5) {
      errors['total_expenses'] = 'Expenses seem unusually high compared to income';
    }
    
    final categories = data['categories'] as List<Map<String, dynamic>>?;
    if (categories != null && categories.length > BudgetConstants.maxCategoriesPerBudget) {
      errors['categories'] = 'Too many budget categories';
    }
    
    return errors;
  }
  
  /// Format currency for display
  static String formatCurrency(double amount, {String currency = 'INR'}) {
    return StringUtils.formatCurrency(amount);
  }
  
  /// Calculate budget variance
  static Map<String, dynamic> calculateBudgetVariance(
    Map<String, double> budgeted,
    Map<String, double> actual,
  ) {
    final variance = <String, dynamic>{};
    double totalBudgeted = 0;
    double totalActual = 0;
    int overBudgetCount = 0;
    
    for (final category in budgeted.keys) {
      final budgetAmount = budgeted[category] ?? 0;
      final actualAmount = actual[category] ?? 0;
      final difference = actualAmount - budgetAmount;
      final percentageVariance = budgetAmount > 0 ? (difference / budgetAmount) * 100 : 0;
      
      variance[category] = {
        'budgeted': budgetAmount,
        'actual': actualAmount,
        'difference': difference,
        'percentage': percentageVariance,
        'status': difference > 0 ? 'over' : (difference < 0 ? 'under' : 'on_target'),
      };
      
      totalBudgeted += budgetAmount;
      totalActual += actualAmount;
      
      if (difference > budgetAmount * 0.1) { // 10% over budget threshold
        overBudgetCount++;
      }
    }
    
    variance['summary'] = {
      'total_budgeted': totalBudgeted,
      'total_actual': totalActual,
      'total_difference': totalActual - totalBudgeted,
      'overall_percentage': totalBudgeted > 0 ? ((totalActual - totalBudgeted) / totalBudgeted) * 100 : 0,
      'categories_over_budget': overBudgetCount,
      'budget_performance': _getBudgetPerformanceRating(totalActual, totalBudgeted, overBudgetCount),
    };
    
    return variance;
  }
  
  static String _getBudgetPerformanceRating(double actual, double budgeted, int overBudgetCount) {
    final variance = budgeted > 0 ? ((actual - budgeted) / budgeted).abs() : 0;
    
    if (variance < 0.05 && overBudgetCount == 0) return 'Excellent';
    if (variance < 0.10 && overBudgetCount <= 1) return 'Good';
    if (variance < 0.20 && overBudgetCount <= 2) return 'Fair';
    return 'Needs Improvement';
  }
}
