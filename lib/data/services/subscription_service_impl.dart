import 'package:injectable/injectable.dart';
import '../../domain/entities/subscription_entity.dart';
import '../../core/utils/subscription_utils.dart';
import '../../core/utils/date_utils.dart';

abstract class SubscriptionService {
  Future<List<SubscriptionPlanEntity>> getAvailablePlans({String? region});
  Future<SubscriptionEntity> getUserSubscription(String userId);
  Future<SubscriptionEntity> subscribe(String userId, String planId, Map<String, dynamic> paymentData);
  Future<SubscriptionEntity> upgradeSubscription(String userId, String newPlanId);
  Future<bool> cancelSubscription(String userId, {String? reason});
  Future<bool> resumeSubscription(String userId);
  Future<List<InvoiceEntity>> getUserInvoices(String userId);
  Future<InvoiceEntity> getInvoice(String invoiceId);
  Future<List<PaymentMethodEntity>> getPaymentMethods(String userId);
  Future<PaymentMethodEntity> addPaymentMethod(String userId, Map<String, dynamic> paymentData);
  Future<bool> validatePayment(String paymentMethodId, double amount);
  Future<Map<String, dynamic>> getBillingAnalytics(String userId);
  Future<bool> applyPromoCode(String userId, String promoCode);
  Future<Map<String, dynamic>> getUsageStats(String userId);
}

@LazySingleton(as: SubscriptionService)
class SubscriptionServiceImpl implements SubscriptionService {
  @override
  Future<List<SubscriptionPlanEntity>> getAvailablePlans({String? region}) async {
    try {
      await Future.delayed(const Duration(milliseconds: 150));
      return _generateMockPlans(region ?? 'IN');
    } catch (e) {
      throw Exception('Failed to get available plans: ${e.toString()}');
    }
  }

  @override
  Future<SubscriptionEntity> getUserSubscription(String userId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      return _generateMockSubscription(userId);
    } catch (e) {
      throw Exception('Failed to get user subscription: ${e.toString()}');
    }
  }

  @override
  Future<SubscriptionEntity> subscribe(String userId, String planId, Map<String, dynamic> paymentData) async {
    try {
      final plan = await _getPlanById(planId);
      if (plan == null) {
        throw Exception('Plan not found');
      }
      
      // Validate payment method
      final paymentValid = await validatePayment(
        paymentData['payment_method_id'] as String,
        plan.pricing['monthly']?.getPriceForCurrency('INR') ?? 0.0,
      );
      
      if (!paymentValid) {
        throw Exception('Payment validation failed');
      }
      
      final now = DateTime.now();
      final subscriptionId = 'sub_${now.millisecondsSinceEpoch}';
      
      final subscription = SubscriptionEntity(
        id: subscriptionId,
        userId: userId,
        planId: planId,
        status: 'active',
        tier: plan.tier,
        startDate: now,
        billingCycle: paymentData['billing_cycle'] as String? ?? 'monthly',
        amount: plan.pricing[paymentData['billing_cycle'] ?? 'monthly']?.getPriceForCurrency('INR') ?? 0.0,
        currency: 'INR',
        paymentMethod: paymentData['payment_method'] as String? ?? 'card',
        paymentProviderId: paymentData['payment_provider_id'] as String?,
        features: plan.features,
        limits: plan.limits,
        permissions: plan.permissions,
        nextBillingDate: _calculateNextBillingDate(now, paymentData['billing_cycle'] as String? ?? 'monthly'),
        isTrialPeriod: plan.hasFreeTrial && paymentData['use_trial'] == true,
        trialStartDate: plan.hasFreeTrial && paymentData['use_trial'] == true ? now : null,
        trialEndDate: plan.hasFreeTrial && paymentData['use_trial'] == true 
            ? now.add(Duration(days: plan.trialDays))
            : null,
        trialDaysRemaining: plan.hasFreeTrial && paymentData['use_trial'] == true ? plan.trialDays : 0,
        createdAt: now,
      );
      
      // Generate first invoice
      await _generateInvoice(subscription);
      
      return subscription;
    } catch (e) {
      throw Exception('Failed to subscribe: ${e.toString()}');
    }
  }

  @override
  Future<SubscriptionEntity> upgradeSubscription(String userId, String newPlanId) async {
    try {
      final currentSub = await getUserSubscription(userId);
      final newPlan = await _getPlanById(newPlanId);
      
      if (newPlan == null) {
        throw Exception('New plan not found');
      }
      
      final now = DateTime.now();
      
      // Calculate prorated amount
      final proratedAmount = _calculateProratedUpgrade(currentSub, newPlan);
      
      final upgradedSub = currentSub.copyWith(
        planId: newPlanId,
        tier: newPlan.tier,
        amount: newPlan.pricing[currentSub.billingCycle]?.getPriceForCurrency(currentSub.currency) ?? 0.0,
        features: newPlan.features,
        limits: newPlan.limits,
        permissions: newPlan.permissions,
        updatedAt: now,
      );
      
      // Generate prorated invoice if applicable
      if (proratedAmount > 0) {
        await _generateProratedInvoice(upgradedSub, proratedAmount);
      }
      
      return upgradedSub;
    } catch (e) {
      throw Exception('Failed to upgrade subscription: ${e.toString()}');
    }
  }

  @override
  Future<bool> cancelSubscription(String userId, {String? reason}) async {
    try {
      final subscription = await getUserSubscription(userId);
      
      final now = DateTime.now();
      final cancelledSub = subscription.copyWith(
        status: 'cancelled',
        autoRenew: false,
        cancelledAt: now,
        cancellationReason: reason,
        endDate: subscription.nextBillingDate, // Cancel at end of current period
        updatedAt: now,
      );
      
      return true;
    } catch (e) {
      throw Exception('Failed to cancel subscription: ${e.toString()}');
    }
  }

  @override
  Future<bool> resumeSubscription(String userId) async {
    try {
      final subscription = await getUserSubscription(userId);
      
      if (subscription.status != 'cancelled') {
        throw Exception('Subscription is not cancelled');
      }
      
      final now = DateTime.now();
      final resumedSub = subscription.copyWith(
        status: 'active',
        autoRenew: true,
        cancelledAt: null,
        cancellationReason: null,
        endDate: null,
        updatedAt: now,
      );
      
      return true;
    } catch (e) {
      throw Exception('Failed to resume subscription: ${e.toString()}');
    }
  }

  @override
  Future<List<InvoiceEntity>> getUserInvoices(String userId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      return _generateMockInvoices(userId);
    } catch (e) {
      throw Exception('Failed to get user invoices: ${e.toString()}');
    }
  }

  @override
  Future<InvoiceEntity> getInvoice(String invoiceId) async {
    try {
      final invoices = await getUserInvoices('user_id'); // Mock user
      return invoices.firstWhere(
        (invoice) => invoice.id == invoiceId,
        orElse: () => throw Exception('Invoice not found'),
      );
    } catch (e) {
      throw Exception('Failed to get invoice: ${e.toString()}');
    }
  }

  @override
  Future<List<PaymentMethodEntity>> getPaymentMethods(String userId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      return _generateMockPaymentMethods(userId);
    } catch (e) {
      throw Exception('Failed to get payment methods: ${e.toString()}');
    }
  }

  @override
  Future<PaymentMethodEntity> addPaymentMethod(String userId, Map<String, dynamic> paymentData) async {
    try {
      final now = DateTime.now();
      final methodId = 'pm_${now.millisecondsSinceEpoch}';
      
      final paymentMethod = PaymentMethodEntity(
        id: methodId,
        userId: userId,
        type: paymentData['type'] as String,
        details: Map<String, dynamic>.from(paymentData['details'] ?? {}),
        isDefault: paymentData['is_default'] as bool? ?? false,
        expiryDate: paymentData['expiry_date'] != null
            ? DateTime.parse(paymentData['expiry_date'] as String)
            : null,
        fingerprint: paymentData['fingerprint'] as String?,
        metadata: Map<String, dynamic>.from(paymentData['metadata'] ?? {}),
        createdAt: now,
      );
      
      return paymentMethod;
    } catch (e) {
      throw Exception('Failed to add payment method: ${e.toString()}');
    }
  }

  @override
  Future<bool> validatePayment(String paymentMethodId, double amount) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300)); // Simulate payment processing
      
      // Mock payment validation
      final paymentMethods = await getPaymentMethods('user_id');
      final paymentMethod = paymentMethods.firstWhere(
        (method) => method.id == paymentMethodId,
        orElse: () => throw Exception('Payment method not found'),
      );
      
      // Check if payment method is expired
      if (paymentMethod.isExpired) {
        return false;
      }
      
      // Mock validation logic
      if (amount <= 0) {
        return false;
      }
      
      // Simulate different payment scenarios
      final success = DateTime.now().millisecond % 10 != 0; // 90% success rate
      
      return success;
    } catch (e) {
      throw Exception('Failed to validate payment: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getBillingAnalytics(String userId) async {
    try {
      final subscription = await getUserSubscription(userId);
      final invoices = await getUserInvoices(userId);
      
      final totalPaid = invoices
          .where((invoice) => invoice.isPaid)
          .fold<double>(0, (sum, invoice) => sum + invoice.totalAmount);
      
      final overdue = invoices
          .where((invoice) => invoice.isOverdue)
          .length;
      
      return {
        'subscription_info': {
          'current_plan': subscription.tier,
          'status': subscription.status,
          'next_billing_date': subscription.nextBillingDate.toIso8601String(),
          'monthly_amount': subscription.amount,
        },
        'billing_history': {
          'total_invoices': invoices.length,
          'total_paid': totalPaid,
          'overdue_count': overdue,
          'payment_success_rate': invoices.isNotEmpty 
              ? invoices.where((i) => i.isPaid).length / invoices.length
              : 0.0,
        },
        'usage_stats': await getUsageStats(userId),
      };
    } catch (e) {
      throw Exception('Failed to get billing analytics: ${e.toString()}');
    }
  }

  @override
  Future<bool> applyPromoCode(String userId, String promoCode) async {
    try {
      // Mock promo code validation
      final validPromoCodes = {
        'WELCOME10': {'discount': 0.10, 'type': 'percentage'},
        'SAVE20': {'discount': 20.0, 'type': 'fixed'},
        'STUDENT50': {'discount': 0.50, 'type': 'percentage'},
      };
      
      final promoData = validPromoCodes[promoCode.toUpperCase()];
      if (promoData == null) {
        throw Exception('Invalid promo code');
      }
      
      final subscription = await getUserSubscription(userId);
      
      // Apply discount to next billing
      final discountAmount = promoData['type'] == 'percentage'
          ? subscription.amount * (promoData['discount'] as double)
          : promoData['discount'] as double;
      
      // In real implementation, would update subscription with discount
      return true;
    } catch (e) {
      throw Exception('Failed to apply promo code: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getUsageStats(String userId) async {
    try {
      final subscription = await getUserSubscription(userId);
      
      // Mock usage statistics
      return {
        'current_period': {
          'start': DateUtils.formatDate(DateTime.now().subtract(const Duration(days: 30)), 'yyyy-MM-dd'),
          'end': DateUtils.formatDate(DateTime.now(), 'yyyy-MM-dd'),
        },
        'feature_usage': {
          'api_calls': {'used': 850, 'limit': 1000},
          'storage_gb': {'used': 2.3, 'limit': 5.0},
          'team_members': {'used': 3, 'limit': 5},
          'projects': {'used': 8, 'limit': 10},
        },
        'limits': subscription.limits,
        'permissions': subscription.permissions,
        'usage_percentage': 0.75, // 75% of limits used
      };
    } catch (e) {
      throw Exception('Failed to get usage stats: ${e.toString()}');
    }
  }

  // Private helper methods
  List<SubscriptionPlanEntity> _generateMockPlans(String region) {
    final now = DateTime.now();
    
    final pricing = {
      'monthly': PricingTierEntity(
        billingCycle: 'monthly',
        prices: {'INR': 299.0, 'USD': 3.99},
        originalPrices: {'INR': 399.0, 'USD': 4.99},
        discounts: {'INR': 0.25, 'USD': 0.20},
      ),
      'yearly': PricingTierEntity(
        billingCycle: 'yearly',
        prices: {'INR': 2990.0, 'USD': 39.99},
        originalPrices: {'INR': 4788.0, 'USD': 59.88},
        discounts: {'INR': 0.375, 'USD': 0.33},
      ),
    };
    
    return [
      SubscriptionPlanEntity(
        id: 'plan_free',
        name: 'free',
        displayName: 'Free Plan',
        description: 'Perfect for getting started with basic productivity features',
        tier: 'free',
        pricing: {},
        features: {
          'task_management': true,
          'basic_habits': true,
          'limited_analytics': true,
        },
        limits: {
          'tasks_per_month': 100,
          'habits': 5,
          'storage_mb': 100,
        },
        permissions: {
          'export_data': false,
          'advanced_analytics': false,
          'premium_themes': false,
        },
        featureList: [
          'Up to 100 tasks per month',
          'Track up to 5 habits',
          'Basic analytics',
          'Community support',
        ],
        createdAt: now.subtract(const Duration(days: 365)),
      ),
      SubscriptionPlanEntity(
        id: 'plan_premium',
        name: 'premium',
        displayName: 'Premium Plan',
        description: 'Unlock advanced features and unlimited productivity',
        tier: 'premium',
        isPopular: true,
        pricing: pricing,
        features: {
          'unlimited_tasks': true,
          'unlimited_habits': true,
          'advanced_analytics': true,
          'ai_insights': true,
          'premium_themes': true,
          'export_data': true,
        },
        limits: {
          'tasks_per_month': -1, // Unlimited
          'habits': -1, // Unlimited
          'storage_mb': 1000,
        },
        permissions: {
          'export_data': true,
          'advanced_analytics': true,
          'premium_themes': true,
          'priority_support': true,
        },
        featureList: [
          'Unlimited tasks and habits',
          'Advanced analytics and insights',
          'AI-powered recommendations',
          'Premium themes and customization',
          'Data export and backup',
          'Priority customer support',
        ],
        hasFreeTrial: true,
        trialDays: 14,
        createdAt: now.subtract(const Duration(days: 300)),
      ),
    ];
  }

  SubscriptionEntity _generateMockSubscription(String userId) {
    final now = DateTime.now();
    
    return SubscriptionEntity(
      id: 'sub_$userId',
      userId: userId,
      planId: 'plan_premium',
      status: 'active',
      tier: 'premium',
      startDate: now.subtract(const Duration(days: 30)),
      billingCycle: 'monthly',
      amount: 299.0,
      currency: 'INR',
      totalAmount: 299.0,
      paymentMethod: 'card',
      nextBillingDate: now.add(const Duration(days: 30)),
      features: {
        'unlimited_tasks': true,
        'unlimited_habits': true,
        'advanced_analytics': true,
      },
      limits: {
        'tasks_per_month': -1,
        'habits': -1,
        'storage_mb': 1000,
      },
      permissions: {
        'export_data': true,
        'advanced_analytics': true,
        'premium_themes': true,
      },
      createdAt: now.subtract(const Duration(days: 30)),
    );
  }

  List<InvoiceEntity> _generateMockInvoices(String userId) {
    final now = DateTime.now();
    
    return [
      InvoiceEntity(
        id: 'inv_1',
        subscriptionId: 'sub_$userId',
        userId: userId,
        invoiceNumber: 'INV-2024-001',
        invoiceDate: now.subtract(const Duration(days: 30)),
        dueDate: now.subtract(const Duration(days: 23)),
        status: 'paid',
        subtotal: 299.0,
        taxAmount: 53.82,
        totalAmount: 352.82,
        currency: 'INR',
        lineItems: [
          InvoiceLineItemEntity(
            id: 'item_1',
            description: 'Premium Plan - Monthly',
            unitPrice: 299.0,
            amount: 299.0,
            periodStart: now.subtract(const Duration(days: 30)),
            periodEnd: now,
          ),
        ],
        paidAt: now.subtract(const Duration(days: 29)),
        paymentMethod: 'card',
        isPdfGenerated: true,
        isEmailSent: true,
        createdAt: now.subtract(const Duration(days: 30)),
      ),
    ];
  }

  List<PaymentMethodEntity> _generateMockPaymentMethods(String userId) {
    final now = DateTime.now();
    
    return [
      PaymentMethodEntity(
        id: 'pm_1',
        userId: userId,
        type: 'card',
        details: {
          'last4': '4242',
          'brand': 'visa',
          'exp_month': 12,
          'exp_year': 2025,
        },
        isDefault: true,
        expiryDate: DateTime(2025, 12, 31),
        fingerprint: 'card_fingerprint_123',
        createdAt: now.subtract(const Duration(days: 60)),
      ),
    ];
  }

  Future<SubscriptionPlanEntity?> _getPlanById(String planId) async {
    final plans = await getAvailablePlans();
    try {
      return plans.firstWhere((plan) => plan.id == planId);
    } catch (e) {
      return null;
    }
  }

  DateTime _calculateNextBillingDate(DateTime startDate, String billingCycle) {
    switch (billingCycle) {
      case 'monthly':
        return DateTime(startDate.year, startDate.month + 1, startDate.day);
      case 'yearly':
        return DateTime(startDate.year + 1, startDate.month, startDate.day);
      case 'quarterly':
        return DateTime(startDate.year, startDate.month + 3, startDate.day);
      default:
        return DateTime(startDate.year, startDate.month + 1, startDate.day);
    }
  }

  double _calculateProratedUpgrade(SubscriptionEntity currentSub, SubscriptionPlanEntity newPlan) {
    final daysRemaining = currentSub.nextBillingDate.difference(DateTime.now()).inDays;
    final totalDays = currentSub.billingCycle == 'monthly' ? 30 : 365;
    
    final currentAmount = currentSub.amount;
    final newAmount = newPlan.pricing[currentSub.billingCycle]?.getPriceForCurrency(currentSub.currency) ?? 0.0;
    
    final proratedCurrent = currentAmount * (daysRemaining / totalDays);
    final proratedNew = newAmount * (daysRemaining / totalDays);
    
    return (proratedNew - proratedCurrent).clamp(0.0, double.infinity);
  }

  Future<void> _generateInvoice(SubscriptionEntity subscription) async {
    // Mock invoice generation
    print('Generated invoice for subscription: ${subscription.id}');
  }

  Future<void> _generateProratedInvoice(SubscriptionEntity subscription, double amount) async {
    // Mock prorated invoice generation
    print('Generated prorated invoice for subscription: ${subscription.id}, amount: $amount');
  }
}
