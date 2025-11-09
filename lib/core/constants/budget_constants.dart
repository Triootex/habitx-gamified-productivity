class BudgetConstants {
  // Budget Methods
  static const String zeroBasedBudgeting = 'zero_based';
  static const String envelopeBudgeting = 'envelope';
  static const String percentageBudgeting = 'percentage';
  static const String priorityBudgeting = 'priority';
  
  // Default Budget Categories
  static const List<Map<String, dynamic>> defaultCategories = [
    {
      'name': 'Housing',
      'type': 'fixed_expense',
      'color': '#3498DB',
      'icon': 'home',
      'recommended_percentage': 30,
      'subcategories': ['rent_mortgage', 'utilities', 'maintenance', 'insurance']
    },
    {
      'name': 'Transportation',
      'type': 'variable_expense',
      'color': '#E74C3C',
      'icon': 'directions_car',
      'recommended_percentage': 15,
      'subcategories': ['fuel', 'maintenance', 'insurance', 'public_transport']
    },
    {
      'name': 'Food & Dining',
      'type': 'variable_expense',
      'color': '#F39C12',
      'icon': 'restaurant',
      'recommended_percentage': 12,
      'subcategories': ['groceries', 'restaurants', 'takeout', 'drinks']
    },
    {
      'name': 'Entertainment',
      'type': 'variable_expense',
      'color': '#9B59B6',
      'icon': 'movie',
      'recommended_percentage': 5,
      'subcategories': ['movies', 'games', 'subscriptions', 'hobbies']
    },
    {
      'name': 'Savings',
      'type': 'savings',
      'color': '#2ECC71',
      'icon': 'savings',
      'recommended_percentage': 20,
      'subcategories': ['emergency_fund', 'retirement', 'investments', 'goals']
    },
    {
      'name': 'Health & Fitness',
      'type': 'variable_expense',
      'color': '#1ABC9C',
      'icon': 'fitness_center',
      'recommended_percentage': 5,
      'subcategories': ['medical', 'dental', 'gym', 'supplements']
    },
  ];
  
  // Envelope Categories
  static const List<Map<String, dynamic>> envelopeCategories = [
    {
      'name': 'Necessities',
      'envelopes': ['rent', 'utilities', 'groceries', 'insurance'],
      'priority': 1,
      'color': '#E74C3C'
    },
    {
      'name': 'Savings & Debt',
      'envelopes': ['emergency_fund', 'retirement', 'debt_payment'],
      'priority': 2,
      'color': '#2ECC71'
    },
    {
      'name': 'Lifestyle',
      'envelopes': ['entertainment', 'dining_out', 'hobbies', 'clothing'],
      'priority': 3,
      'color': '#3498DB'
    },
    {
      'name': 'Irregular',
      'envelopes': ['car_maintenance', 'gifts', 'vacation', 'medical'],
      'priority': 4,
      'color': '#F39C12'
    },
  ];
  
  // Transaction Categories
  static const List<String> transactionTypes = [
    'income',
    'fixed_expense',
    'variable_expense',
    'transfer',
    'investment',
    'loan_payment',
    'refund',
  ];
  
  // Bill Negotiation Templates
  static const List<Map<String, dynamic>> billNegotiationTemplates = [
    {
      'service': 'Internet/Cable',
      'scripts': [
        'I\'ve been a loyal customer for {years} years and would like to discuss my current plan',
        'I\'ve received competing offers and would like to see if you can match them',
        'I\'m looking to reduce my monthly expenses. What discounts are available?'
      ],
      'average_savings': 25 // percentage
    },
    {
      'service': 'Phone',
      'scripts': [
        'I\'m reviewing my phone bill and notice I\'m not using all my data',
        'Can you help me find a plan that better fits my usage?',
        'I\'d like to explore options to reduce my monthly phone costs'
      ],
      'average_savings': 20
    },
    {
      'service': 'Insurance',
      'scripts': [
        'I\'m shopping around for insurance and want to ensure I have the best rate',
        'Can you review my policy for potential discounts I might be missing?',
        'I\'d like to discuss adjusting my coverage to better fit my needs'
      ],
      'average_savings': 15
    },
  ];
  
  // Net Worth Categories
  static const List<Map<String, dynamic>> netWorthCategories = [
    {
      'category': 'Assets',
      'subcategories': [
        {'name': 'Cash & Savings', 'type': 'liquid', 'icon': 'account_balance'},
        {'name': 'Investments', 'type': 'investment', 'icon': 'trending_up'},
        {'name': 'Real Estate', 'type': 'property', 'icon': 'home'},
        {'name': 'Vehicles', 'type': 'personal_property', 'icon': 'directions_car'},
        {'name': 'Personal Items', 'type': 'personal_property', 'icon': 'inventory'},
      ]
    },
    {
      'category': 'Liabilities',
      'subcategories': [
        {'name': 'Credit Cards', 'type': 'revolving_debt', 'icon': 'credit_card'},
        {'name': 'Student Loans', 'type': 'installment_debt', 'icon': 'school'},
        {'name': 'Mortgage', 'type': 'secured_debt', 'icon': 'home'},
        {'name': 'Auto Loans', 'type': 'secured_debt', 'icon': 'directions_car'},
        {'name': 'Personal Loans', 'type': 'unsecured_debt', 'icon': 'person'},
      ]
    },
  ];
  
  // Dashboard Widgets
  static const List<Map<String, dynamic>> dashboardWidgets = [
    {
      'name': 'Monthly Budget Overview',
      'type': 'budget_summary',
      'size': 'large',
      'data_points': ['income', 'expenses', 'remaining', 'saved']
    },
    {
      'name': 'Spending by Category',
      'type': 'pie_chart',
      'size': 'medium',
      'data_points': ['category_percentages']
    },
    {
      'name': 'Net Worth Trend',
      'type': 'line_chart',
      'size': 'medium',
      'data_points': ['monthly_net_worth']
    },
    {
      'name': 'Goal Progress',
      'type': 'progress_bars',
      'size': 'medium',
      'data_points': ['savings_goals', 'debt_payoff']
    },
    {
      'name': 'Recent Transactions',
      'type': 'transaction_list',
      'size': 'small',
      'data_points': ['latest_transactions']
    },
  ];
  
  // Financial Goals
  static const List<Map<String, dynamic>> financialGoals = [
    {
      'type': 'emergency_fund',
      'name': 'Emergency Fund',
      'description': 'Save 3-6 months of expenses',
      'calculation': 'monthly_expenses * 6',
      'priority': 'high'
    },
    {
      'type': 'debt_payoff',
      'name': 'Debt Free',
      'description': 'Pay off all consumer debt',
      'calculation': 'total_debt',
      'priority': 'high'
    },
    {
      'type': 'down_payment',
      'name': 'House Down Payment',
      'description': 'Save for home purchase',
      'calculation': 'house_price * 0.2',
      'priority': 'medium'
    },
    {
      'type': 'retirement',
      'name': 'Retirement',
      'description': 'Build retirement nest egg',
      'calculation': 'annual_income * 25',
      'priority': 'medium'
    },
  ];
  
  // Investment Categories
  static const List<Map<String, dynamic>> investmentTypes = [
    {'name': 'Stocks', 'risk': 'high', 'liquidity': 'high', 'icon': 'show_chart'},
    {'name': 'Bonds', 'risk': 'low', 'liquidity': 'medium', 'icon': 'attach_money'},
    {'name': 'Mutual Funds', 'risk': 'medium', 'liquidity': 'high', 'icon': 'pie_chart'},
    {'name': 'Real Estate', 'risk': 'medium', 'liquidity': 'low', 'icon': 'home'},
    {'name': 'Cryptocurrency', 'risk': 'very_high', 'liquidity': 'high', 'icon': 'currency_bitcoin'},
    {'name': 'Fixed Deposits', 'risk': 'very_low', 'liquidity': 'low', 'icon': 'account_balance'},
  ];
  
  // Budget Rules & Formulas
  static const Map<String, String> budgetRules = {
    '50_30_20': '50% needs, 30% wants, 20% savings',
    '60_20_20': '60% fixed expenses, 20% savings, 20% discretionary',
    '80_20': '80% expenses, 20% savings',
    'zero_based': 'Income - Expenses = 0',
  };
  
  // Debt Payoff Strategies
  static const List<Map<String, dynamic>> debtStrategies = [
    {
      'name': 'Debt Snowball',
      'description': 'Pay minimums on all debts, extra on smallest balance',
      'psychological_benefit': 'Quick wins build momentum',
      'mathematical_benefit': 'Lower'
    },
    {
      'name': 'Debt Avalanche',
      'description': 'Pay minimums on all debts, extra on highest interest rate',
      'psychological_benefit': 'Lower',
      'mathematical_benefit': 'Saves most money'
    },
    {
      'name': 'Debt Consolidation',
      'description': 'Combine multiple debts into single payment',
      'psychological_benefit': 'Simplifies payments',
      'mathematical_benefit': 'May reduce interest rate'
    },
  ];
  
  // Bank Account Integration
  static const List<Map<String, dynamic>> supportedBanks = [
    {'name': 'State Bank of India', 'code': 'SBI', 'country': 'India'},
    {'name': 'HDFC Bank', 'code': 'HDFC', 'country': 'India'},
    {'name': 'ICICI Bank', 'code': 'ICICI', 'country': 'India'},
    {'name': 'Axis Bank', 'code': 'AXIS', 'country': 'India'},
    {'name': 'Kotak Mahindra Bank', 'code': 'KOTAK', 'country': 'India'},
  ];
  
  // Currency Support
  static const Map<String, Map<String, dynamic>> supportedCurrencies = {
    'INR': {'symbol': '₹', 'name': 'Indian Rupee', 'decimal_places': 2},
    'USD': {'symbol': '\$', 'name': 'US Dollar', 'decimal_places': 2},
    'EUR': {'symbol': '€', 'name': 'Euro', 'decimal_places': 2},
    'GBP': {'symbol': '£', 'name': 'British Pound', 'decimal_places': 2},
    'JPY': {'symbol': '¥', 'name': 'Japanese Yen', 'decimal_places': 0},
  };
  
  // Bill Reminders
  static const List<Map<String, dynamic>> billReminderTypes = [
    {'type': 'monthly', 'description': 'Every month on the same date'},
    {'type': 'weekly', 'description': 'Every week on the same day'},
    {'type': 'quarterly', 'description': 'Every 3 months'},
    {'type': 'annually', 'description': 'Once per year'},
    {'type': 'custom', 'description': 'Custom frequency'},
  ];
  
  // Financial Health Score
  static const Map<String, Map<String, dynamic>> healthScoreFactors = {
    'debt_to_income_ratio': {
      'weight': 25,
      'thresholds': {'excellent': 0.2, 'good': 0.36, 'fair': 0.5, 'poor': 1.0}
    },
    'emergency_fund_months': {
      'weight': 20,
      'thresholds': {'excellent': 6, 'good': 3, 'fair': 1, 'poor': 0}
    },
    'savings_rate': {
      'weight': 20,
      'thresholds': {'excellent': 0.2, 'good': 0.15, 'fair': 0.1, 'poor': 0.05}
    },
    'credit_utilization': {
      'weight': 15,
      'thresholds': {'excellent': 0.1, 'good': 0.3, 'fair': 0.5, 'poor': 0.9}
    },
    'investment_diversification': {
      'weight': 20,
      'thresholds': {'excellent': 0.8, 'good': 0.6, 'fair': 0.4, 'poor': 0.2}
    }
  };
  
  // Notification Types
  static const String billReminder = 'bill_reminder';
  static const String budgetOverspend = 'budget_overspend';
  static const String goalProgress = 'goal_progress';
  static const String unusualSpending = 'unusual_spending';
  static const String savingsOpportunity = 'savings_opportunity';
  
  // Limits and Validations
  static const double maxBudgetAmount = 10000000.0; // 1 crore
  static const double minBudgetAmount = 1.0;
  static const int maxCategoriesPerBudget = 50;
  static const int maxTransactionsPerMonth = 10000;
  static const int maxGoalsPerUser = 20;
  static const int maxBillReminders = 100;
}
