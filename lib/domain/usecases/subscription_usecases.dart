import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../entities/subscription_entity.dart';
import '../../data/repositories/subscription_repository_impl.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';

// Get Available Subscription Plans Use Case
@injectable
class GetAvailableSubscriptionPlansUseCase implements UseCase<List<SubscriptionPlanEntity>, GetAvailableSubscriptionPlansParams> {
  final SubscriptionRepository repository;

  GetAvailableSubscriptionPlansUseCase(this.repository);

  @override
  Future<Either<Failure, List<SubscriptionPlanEntity>>> call(GetAvailableSubscriptionPlansParams params) async {
    return await repository.getAvailablePlans(region: params.region);
  }
}

class GetAvailableSubscriptionPlansParams {
  final String? region;

  GetAvailableSubscriptionPlansParams({this.region});
}

// Get User Subscription Use Case
@injectable
class GetUserSubscriptionUseCase implements UseCase<SubscriptionEntity, String> {
  final SubscriptionRepository repository;

  GetUserSubscriptionUseCase(this.repository);

  @override
  Future<Either<Failure, SubscriptionEntity>> call(String userId) async {
    return await repository.getUserSubscription(userId);
  }
}

// Subscribe Use Case
@injectable
class SubscribeUseCase implements UseCase<SubscriptionEntity, SubscribeParams> {
  final SubscriptionRepository repository;

  SubscribeUseCase(this.repository);

  @override
  Future<Either<Failure, SubscriptionEntity>> call(SubscribeParams params) async {
    return await repository.subscribe(params.userId, params.planId, params.paymentData);
  }
}

class SubscribeParams {
  final String userId;
  final String planId;
  final Map<String, dynamic> paymentData;

  SubscribeParams({
    required this.userId,
    required this.planId,
    required this.paymentData,
  });
}

// Upgrade Subscription Use Case
@injectable
class UpgradeSubscriptionUseCase implements UseCase<SubscriptionEntity, UpgradeSubscriptionParams> {
  final SubscriptionRepository repository;

  UpgradeSubscriptionUseCase(this.repository);

  @override
  Future<Either<Failure, SubscriptionEntity>> call(UpgradeSubscriptionParams params) async {
    return await repository.upgradeSubscription(params.userId, params.newPlanId);
  }
}

class UpgradeSubscriptionParams {
  final String userId;
  final String newPlanId;

  UpgradeSubscriptionParams({required this.userId, required this.newPlanId});
}

// Cancel Subscription Use Case
@injectable
class CancelSubscriptionUseCase implements UseCase<bool, CancelSubscriptionParams> {
  final SubscriptionRepository repository;

  CancelSubscriptionUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(CancelSubscriptionParams params) async {
    return await repository.cancelSubscription(params.userId, reason: params.reason);
  }
}

class CancelSubscriptionParams {
  final String userId;
  final String? reason;

  CancelSubscriptionParams({required this.userId, this.reason});
}

// Resume Subscription Use Case
@injectable
class ResumeSubscriptionUseCase implements UseCase<bool, String> {
  final SubscriptionRepository repository;

  ResumeSubscriptionUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(String userId) async {
    return await repository.resumeSubscription(userId);
  }
}

// Get User Invoices Use Case
@injectable
class GetUserInvoicesUseCase implements UseCase<List<InvoiceEntity>, String> {
  final SubscriptionRepository repository;

  GetUserInvoicesUseCase(this.repository);

  @override
  Future<Either<Failure, List<InvoiceEntity>>> call(String userId) async {
    return await repository.getUserInvoices(userId);
  }
}

// Get Invoice Use Case
@injectable
class GetInvoiceUseCase implements UseCase<InvoiceEntity, String> {
  final SubscriptionRepository repository;

  GetInvoiceUseCase(this.repository);

  @override
  Future<Either<Failure, InvoiceEntity>> call(String invoiceId) async {
    return await repository.getInvoice(invoiceId);
  }
}

// Get Payment Methods Use Case
@injectable
class GetPaymentMethodsUseCase implements UseCase<List<PaymentMethodEntity>, String> {
  final SubscriptionRepository repository;

  GetPaymentMethodsUseCase(this.repository);

  @override
  Future<Either<Failure, List<PaymentMethodEntity>>> call(String userId) async {
    return await repository.getPaymentMethods(userId);
  }
}

// Add Payment Method Use Case
@injectable
class AddPaymentMethodUseCase implements UseCase<PaymentMethodEntity, AddPaymentMethodParams> {
  final SubscriptionRepository repository;

  AddPaymentMethodUseCase(this.repository);

  @override
  Future<Either<Failure, PaymentMethodEntity>> call(AddPaymentMethodParams params) async {
    return await repository.addPaymentMethod(params.userId, params.paymentData);
  }
}

class AddPaymentMethodParams {
  final String userId;
  final Map<String, dynamic> paymentData;

  AddPaymentMethodParams({required this.userId, required this.paymentData});
}

// Validate Payment Use Case
@injectable
class ValidatePaymentUseCase implements UseCase<bool, ValidatePaymentParams> {
  final SubscriptionRepository repository;

  ValidatePaymentUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(ValidatePaymentParams params) async {
    return await repository.validatePayment(params.paymentMethodId, params.amount);
  }
}

class ValidatePaymentParams {
  final String paymentMethodId;
  final double amount;

  ValidatePaymentParams({required this.paymentMethodId, required this.amount});
}

// Get Billing Analytics Use Case
@injectable
class GetBillingAnalyticsUseCase implements UseCase<Map<String, dynamic>, String> {
  final SubscriptionRepository repository;

  GetBillingAnalyticsUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(String userId) async {
    return await repository.getBillingAnalytics(userId);
  }
}

// Apply Promo Code Use Case
@injectable
class ApplyPromoCodeUseCase implements UseCase<bool, ApplyPromoCodeParams> {
  final SubscriptionRepository repository;

  ApplyPromoCodeUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(ApplyPromoCodeParams params) async {
    return await repository.applyPromoCode(params.userId, params.promoCode);
  }
}

class ApplyPromoCodeParams {
  final String userId;
  final String promoCode;

  ApplyPromoCodeParams({required this.userId, required this.promoCode});
}

// Get Usage Stats Use Case
@injectable
class GetUsageStatsUseCase implements UseCase<Map<String, dynamic>, String> {
  final SubscriptionRepository repository;

  GetUsageStatsUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(String userId) async {
    return await repository.getUsageStats(userId);
  }
}

// Calculate Subscription Value Use Case
@injectable
class CalculateSubscriptionValueUseCase implements UseCase<Map<String, dynamic>, String> {
  final SubscriptionRepository repository;

  CalculateSubscriptionValueUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(String userId) async {
    try {
      final subscriptionResult = await repository.getUserSubscription(userId);
      final usageStatsResult = await repository.getUsageStats(userId);
      final invoicesResult = await repository.getUserInvoices(userId);
      
      return subscriptionResult.fold(
        (failure) => Left(failure),
        (subscription) async {
          final usageStats = await usageStatsResult.fold(
            (failure) => <String, dynamic>{},
            (stats) => stats,
          );
          
          final invoices = await invoicesResult.fold(
            (failure) => <InvoiceEntity>[],
            (list) => list,
          );
          
          final valueData = _calculateSubscriptionValue(subscription, usageStats, invoices);
          return Right(valueData);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to calculate subscription value: ${e.toString()}'));
    }
  }

  Map<String, dynamic> _calculateSubscriptionValue(
    SubscriptionEntity subscription,
    Map<String, dynamic> usageStats,
    List<InvoiceEntity> invoices,
  ) {
    if (subscription.status != 'active') {
      return {
        'value_score': 0,
        'usage_efficiency': 0.0,
        'cost_per_use': 0.0,
        'feature_utilization': 0.0,
        'recommendation': 'No active subscription',
        'potential_savings': 0.0,
      };
    }
    
    // Calculate usage metrics
    final dailyUsage = usageStats['daily_active_days'] as int? ?? 0;
    final featuresUsed = usageStats['features_used'] as List? ?? [];
    final totalFeatures = usageStats['total_features'] as int? ?? 10;
    final sessionsPerWeek = usageStats['weekly_sessions'] as int? ?? 0;
    
    // Calculate financial metrics
    final monthlyPrice = subscription.currentPrice ?? 0.0;
    final totalPaid = invoices.fold<double>(0.0, (sum, invoice) => 
        sum + (invoice.totalAmount ?? 0.0));
    
    // Calculate efficiency scores
    final usageEfficiency = _calculateUsageEfficiency(dailyUsage, sessionsPerWeek);
    final featureUtilization = totalFeatures > 0 ? (featuresUsed.length / totalFeatures) * 100 : 0.0;
    final costPerUse = dailyUsage > 0 ? monthlyPrice / (dailyUsage * 4) : monthlyPrice; // Approximate monthly uses
    
    // Calculate overall value score (0-100)
    final valueScore = (
      (usageEfficiency * 0.4) + // 40% usage frequency
      (featureUtilization * 0.3) + // 30% feature utilization
      (_calculateCostEfficiencyScore(costPerUse) * 0.3) // 30% cost efficiency
    ).round();
    
    final recommendation = _generateValueRecommendation(
      valueScore, usageEfficiency, featureUtilization, costPerUse
    );
    
    final potentialSavings = _calculatePotentialSavings(
      subscription, usageStats, monthlyPrice
    );
    
    return {
      'value_score': valueScore,
      'usage_efficiency': double.parse(usageEfficiency.toStringAsFixed(1)),
      'feature_utilization': double.parse(featureUtilization.toStringAsFixed(1)),
      'cost_per_use': double.parse(costPerUse.toStringAsFixed(2)),
      'monthly_price': monthlyPrice,
      'total_paid': totalPaid,
      'daily_usage_days': dailyUsage,
      'features_used_count': featuresUsed.length,
      'sessions_per_week': sessionsPerWeek,
      'subscription_duration_months': _calculateSubscriptionDuration(subscription),
      'recommendation': recommendation,
      'potential_savings': double.parse(potentialSavings.toStringAsFixed(2)),
    };
  }

  double _calculateUsageEfficiency(int dailyUsage, int sessionsPerWeek) {
    // Ideal usage: 5-7 days per week, 7-14 sessions per week
    final weeklyDays = (dailyUsage / 4.0).clamp(0, 7); // Convert monthly to weekly
    
    double dayScore = 0;
    if (weeklyDays >= 5) {
      dayScore = 100;
    } else if (weeklyDays >= 3) {
      dayScore = weeklyDays * 20; // 20 points per day
    } else {
      dayScore = weeklyDays * 10; // Lower score for low usage
    }
    
    double sessionScore = 0;
    if (sessionsPerWeek >= 7 && sessionsPerWeek <= 14) {
      sessionScore = 100;
    } else if (sessionsPerWeek > 0) {
      sessionScore = (sessionsPerWeek / 10.0 * 100).clamp(0, 100);
    }
    
    return (dayScore * 0.6 + sessionScore * 0.4); // Weight days more than sessions
  }

  double _calculateCostEfficiencyScore(double costPerUse) {
    // Lower cost per use = higher score
    if (costPerUse <= 1.0) return 100;
    if (costPerUse <= 2.0) return 80;
    if (costPerUse <= 5.0) return 60;
    if (costPerUse <= 10.0) return 40;
    return 20;
  }

  int _calculateSubscriptionDuration(SubscriptionEntity subscription) {
    if (subscription.startDate == null) return 0;
    
    final now = DateTime.now();
    final duration = now.difference(subscription.startDate!);
    return (duration.inDays / 30.0).round();
  }

  String _generateValueRecommendation(
    int valueScore,
    double usageEfficiency,
    double featureUtilization,
    double costPerUse,
  ) {
    if (valueScore >= 80) {
      return 'Excellent value! You\'re making great use of your subscription';
    } else if (usageEfficiency < 50) {
      return 'Consider using the app more regularly to get better value';
    } else if (featureUtilization < 30) {
      return 'Explore more features to maximize your subscription value';
    } else if (costPerUse > 10) {
      return 'Consider downgrading to a lower tier or increasing usage';
    } else if (valueScore < 40) {
      return 'Your subscription may not be cost-effective for your usage pattern';
    }
    return 'Good value! Consider exploring unused features';
  }

  double _calculatePotentialSavings(
    SubscriptionEntity subscription,
    Map<String, dynamic> usageStats,
    double monthlyPrice,
  ) {
    final usageLevel = usageStats['usage_level'] as String? ?? 'medium';
    
    // Suggest savings based on usage patterns
    if (usageLevel == 'low' && monthlyPrice > 5) {
      return monthlyPrice * 0.5; // 50% potential savings with lower tier
    } else if (usageLevel == 'very_low' && monthlyPrice > 0) {
      return monthlyPrice * 0.8; // 80% potential savings (consider free tier)
    }
    
    return 0.0;
  }
}

// Get Subscription Recommendations Use Case
@injectable
class GetSubscriptionRecommendationsUseCase implements UseCase<Map<String, dynamic>, String> {
  final SubscriptionRepository repository;

  GetSubscriptionRecommendationsUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(String userId) async {
    try {
      final plansResult = await repository.getAvailablePlans();
      final currentSubscriptionResult = await repository.getUserSubscription(userId);
      final usageStatsResult = await repository.getUsageStats(userId);
      
      return plansResult.fold(
        (failure) => Left(failure),
        (plans) async {
          final currentSubscription = await currentSubscriptionResult.fold(
            (failure) => null,
            (subscription) => subscription,
          );
          
          final usageStats = await usageStatsResult.fold(
            (failure) => <String, dynamic>{},
            (stats) => stats,
          );
          
          final recommendations = _generateSubscriptionRecommendations(
            plans, currentSubscription, usageStats
          );
          return Right(recommendations);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to generate recommendations: ${e.toString()}'));
    }
  }

  Map<String, dynamic> _generateSubscriptionRecommendations(
    List<SubscriptionPlanEntity> plans,
    SubscriptionEntity? currentSubscription,
    Map<String, dynamic> usageStats,
  ) {
    final recommendations = <Map<String, dynamic>>[];
    
    if (plans.isEmpty) {
      return {
        'recommendations': [
          {
            'type': 'no_plans',
            'message': 'No subscription plans available at the moment',
          }
        ],
      };
    }
    
    final dailyUsage = usageStats['daily_active_days'] as int? ?? 0;
    final featuresUsed = usageStats['features_used'] as List? ?? [];
    final usageLevel = _determineUsageLevel(dailyUsage, featuresUsed.length);
    
    if (currentSubscription == null || currentSubscription.status != 'active') {
      // Recommend initial subscription based on usage
      final recommendedPlan = _selectPlanForUsage(plans, usageLevel);
      
      recommendations.add({
        'type': 'subscribe',
        'plan': recommendedPlan?.toJson(),
        'reason': 'Based on your usage pattern, this plan offers the best value',
        'benefits': _getPlanBenefits(recommendedPlan),
      });
    } else {
      // Analyze current subscription and suggest optimizations
      final currentPlan = plans.firstWhere(
        (plan) => plan.id == currentSubscription.planId,
        orElse: () => plans.first,
      );
      
      // Check if user should upgrade
      if (usageLevel == 'high' && currentPlan.tier == 'basic') {
        final upgradePlan = plans.firstWhere(
          (plan) => plan.tier == 'premium',
          orElse: () => currentPlan,
        );
        
        recommendations.add({
          'type': 'upgrade',
          'current_plan': currentPlan.toJson(),
          'recommended_plan': upgradePlan.toJson(),
          'reason': 'High usage detected - upgrade for better features and value',
          'benefits': _getUpgradeBenefits(upgradePlan, currentPlan),
        });
      }
      
      // Check if user should downgrade
      if (usageLevel == 'low' && currentPlan.tier == 'premium') {
        final downgradePlan = plans.firstWhere(
          (plan) => plan.tier == 'basic',
          orElse: () => currentPlan,
        );
        
        recommendations.add({
          'type': 'downgrade',
          'current_plan': currentPlan.toJson(),
          'recommended_plan': downgradePlan.toJson(),
          'reason': 'Low usage detected - save money with a basic plan',
          'potential_savings': (currentPlan.price - downgradePlan.price) * 12, // Annual savings
        });
      }
    }
    
    // Always suggest trying premium features if on basic
    if (currentSubscription?.planId != null) {
      final currentPlan = plans.firstWhere(
        (plan) => plan.id == currentSubscription!.planId,
        orElse: () => plans.first,
      );
      
      if (currentPlan.tier == 'basic') {
        recommendations.add({
          'type': 'trial',
          'message': 'Try premium features with a free trial',
          'features': ['Advanced analytics', 'AI insights', 'Priority support'],
        });
      }
    }
    
    return {
      'recommendations': recommendations,
      'usage_level': usageLevel,
      'current_subscription': currentSubscription?.toJson(),
    };
  }

  String _determineUsageLevel(int dailyUsage, int featuresUsed) {
    final weeklyDays = dailyUsage / 4.0; // Convert monthly to weekly average
    
    if (weeklyDays >= 5 && featuresUsed >= 8) return 'high';
    if (weeklyDays >= 3 && featuresUsed >= 5) return 'medium';
    if (weeklyDays >= 1) return 'low';
    return 'very_low';
  }

  SubscriptionPlanEntity? _selectPlanForUsage(List<SubscriptionPlanEntity> plans, String usageLevel) {
    switch (usageLevel) {
      case 'high':
        return plans.firstWhere((p) => p.tier == 'premium', orElse: () => plans.first);
      case 'medium':
        return plans.firstWhere((p) => p.tier == 'standard', orElse: () => plans.first);
      case 'low':
      case 'very_low':
        return plans.firstWhere((p) => p.tier == 'basic', orElse: () => plans.first);
      default:
        return plans.first;
    }
  }

  List<String> _getPlanBenefits(SubscriptionPlanEntity? plan) {
    if (plan == null) return [];
    
    return plan.features ?? [
      'Access to all productivity tools',
      'Advanced analytics and insights',
      'Priority customer support',
      'Unlimited data sync',
    ];
  }

  List<String> _getUpgradeBenefits(SubscriptionPlanEntity upgradePlan, SubscriptionPlanEntity currentPlan) {
    final upgradeFeatures = upgradePlan.features ?? [];
    final currentFeatures = currentPlan.features ?? [];
    
    return upgradeFeatures.where((feature) => !currentFeatures.contains(feature)).toList();
  }
}
