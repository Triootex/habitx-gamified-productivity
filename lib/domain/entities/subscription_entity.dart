import 'package:equatable/equatable.dart';

class SubscriptionEntity extends Equatable {
  final String id;
  final String userId;
  final String planId;
  final String status; // active, cancelled, expired, past_due, pending
  final String tier; // free, premium, pro, enterprise
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final bool autoRenew;
  final DateTime nextBillingDate;
  final String billingCycle; // monthly, yearly, lifetime
  
  // Pricing
  final double amount;
  final String currency;
  final double? discountAmount;
  final String? discountCode;
  final double? taxAmount;
  final double totalAmount;
  
  // Payment
  final String paymentMethod; // card, upi, wallet, etc.
  final String? paymentProviderId;
  final Map<String, dynamic> paymentData;
  final List<String> invoiceIds;
  
  // Features and limits
  final Map<String, dynamic> features;
  final Map<String, int> limits;
  final Map<String, bool> permissions;
  
  // Trial information
  final bool isTrialPeriod;
  final DateTime? trialStartDate;
  final DateTime? trialEndDate;
  final int trialDaysRemaining;
  
  // Grace period
  final bool isInGracePeriod;
  final DateTime? gracePeriodEnd;
  
  final DateTime createdAt;
  final DateTime? updatedAt;

  const SubscriptionEntity({
    required this.id,
    required this.userId,
    required this.planId,
    this.status = 'active',
    this.tier = 'free',
    required this.startDate,
    this.endDate,
    this.cancelledAt,
    this.cancellationReason,
    this.autoRenew = true,
    required this.nextBillingDate,
    this.billingCycle = 'monthly',
    this.amount = 0.0,
    this.currency = 'INR',
    this.discountAmount,
    this.discountCode,
    this.taxAmount,
    this.totalAmount = 0.0,
    this.paymentMethod = 'card',
    this.paymentProviderId,
    this.paymentData = const {},
    this.invoiceIds = const [],
    this.features = const {},
    this.limits = const {},
    this.permissions = const {},
    this.isTrialPeriod = false,
    this.trialStartDate,
    this.trialEndDate,
    this.trialDaysRemaining = 0,
    this.isInGracePeriod = false,
    this.gracePeriodEnd,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isActive => status == 'active';
  bool get isCancelled => status == 'cancelled';
  bool get isExpired => status == 'expired';
  bool get isPremium => tier != 'free';
  bool get needsPayment => status == 'past_due';

  SubscriptionEntity copyWith({
    String? id,
    String? userId,
    String? planId,
    String? status,
    String? tier,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? cancelledAt,
    String? cancellationReason,
    bool? autoRenew,
    DateTime? nextBillingDate,
    String? billingCycle,
    double? amount,
    String? currency,
    double? discountAmount,
    String? discountCode,
    double? taxAmount,
    double? totalAmount,
    String? paymentMethod,
    String? paymentProviderId,
    Map<String, dynamic>? paymentData,
    List<String>? invoiceIds,
    Map<String, dynamic>? features,
    Map<String, int>? limits,
    Map<String, bool>? permissions,
    bool? isTrialPeriod,
    DateTime? trialStartDate,
    DateTime? trialEndDate,
    int? trialDaysRemaining,
    bool? isInGracePeriod,
    DateTime? gracePeriodEnd,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SubscriptionEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      planId: planId ?? this.planId,
      status: status ?? this.status,
      tier: tier ?? this.tier,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      autoRenew: autoRenew ?? this.autoRenew,
      nextBillingDate: nextBillingDate ?? this.nextBillingDate,
      billingCycle: billingCycle ?? this.billingCycle,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      discountAmount: discountAmount ?? this.discountAmount,
      discountCode: discountCode ?? this.discountCode,
      taxAmount: taxAmount ?? this.taxAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentProviderId: paymentProviderId ?? this.paymentProviderId,
      paymentData: paymentData ?? this.paymentData,
      invoiceIds: invoiceIds ?? this.invoiceIds,
      features: features ?? this.features,
      limits: limits ?? this.limits,
      permissions: permissions ?? this.permissions,
      isTrialPeriod: isTrialPeriod ?? this.isTrialPeriod,
      trialStartDate: trialStartDate ?? this.trialStartDate,
      trialEndDate: trialEndDate ?? this.trialEndDate,
      trialDaysRemaining: trialDaysRemaining ?? this.trialDaysRemaining,
      isInGracePeriod: isInGracePeriod ?? this.isInGracePeriod,
      gracePeriodEnd: gracePeriodEnd ?? this.gracePeriodEnd,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        planId,
        status,
        tier,
        startDate,
        endDate,
        cancelledAt,
        cancellationReason,
        autoRenew,
        nextBillingDate,
        billingCycle,
        amount,
        currency,
        discountAmount,
        discountCode,
        taxAmount,
        totalAmount,
        paymentMethod,
        paymentProviderId,
        paymentData,
        invoiceIds,
        features,
        limits,
        permissions,
        isTrialPeriod,
        trialStartDate,
        trialEndDate,
        trialDaysRemaining,
        isInGracePeriod,
        gracePeriodEnd,
        createdAt,
        updatedAt,
      ];
}

class SubscriptionPlanEntity extends Equatable {
  final String id;
  final String name;
  final String displayName;
  final String description;
  final String tier; // free, premium, pro, enterprise
  final bool isActive;
  final bool isPopular;
  final bool isFeatured;
  
  // Pricing
  final Map<String, PricingTierEntity> pricing; // billing_cycle -> pricing
  final List<String> availableCurrencies;
  final String defaultCurrency;
  
  // Features and limits
  final Map<String, dynamic> features;
  final Map<String, int> limits;
  final Map<String, bool> permissions;
  final List<String> featureList;
  final List<String> limitationList;
  
  // Trial settings
  final bool hasFreeTrial;
  final int trialDays;
  final bool requiresPaymentMethod;
  
  // Discounts and promotions
  final List<String> applicableDiscounts;
  final Map<String, dynamic> promotionalOffers;
  
  // Market targeting
  final List<String> targetMarkets;
  final Map<String, dynamic> localizations;
  
  final DateTime createdAt;
  final DateTime? updatedAt;

  const SubscriptionPlanEntity({
    required this.id,
    required this.name,
    required this.displayName,
    required this.description,
    required this.tier,
    this.isActive = true,
    this.isPopular = false,
    this.isFeatured = false,
    this.pricing = const {},
    this.availableCurrencies = const ['INR', 'USD'],
    this.defaultCurrency = 'INR',
    this.features = const {},
    this.limits = const {},
    this.permissions = const {},
    this.featureList = const [],
    this.limitationList = const [],
    this.hasFreeTrial = false,
    this.trialDays = 0,
    this.requiresPaymentMethod = true,
    this.applicableDiscounts = const [],
    this.promotionalOffers = const {},
    this.targetMarkets = const [],
    this.localizations = const {},
    required this.createdAt,
    this.updatedAt,
  });

  double? getPriceForCycle(String cycle, String currency) {
    return pricing[cycle]?.getPriceForCurrency(currency);
  }

  SubscriptionPlanEntity copyWith({
    String? id,
    String? name,
    String? displayName,
    String? description,
    String? tier,
    bool? isActive,
    bool? isPopular,
    bool? isFeatured,
    Map<String, PricingTierEntity>? pricing,
    List<String>? availableCurrencies,
    String? defaultCurrency,
    Map<String, dynamic>? features,
    Map<String, int>? limits,
    Map<String, bool>? permissions,
    List<String>? featureList,
    List<String>? limitationList,
    bool? hasFreeTrial,
    int? trialDays,
    bool? requiresPaymentMethod,
    List<String>? applicableDiscounts,
    Map<String, dynamic>? promotionalOffers,
    List<String>? targetMarkets,
    Map<String, dynamic>? localizations,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SubscriptionPlanEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      description: description ?? this.description,
      tier: tier ?? this.tier,
      isActive: isActive ?? this.isActive,
      isPopular: isPopular ?? this.isPopular,
      isFeatured: isFeatured ?? this.isFeatured,
      pricing: pricing ?? this.pricing,
      availableCurrencies: availableCurrencies ?? this.availableCurrencies,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      features: features ?? this.features,
      limits: limits ?? this.limits,
      permissions: permissions ?? this.permissions,
      featureList: featureList ?? this.featureList,
      limitationList: limitationList ?? this.limitationList,
      hasFreeTrial: hasFreeTrial ?? this.hasFreeTrial,
      trialDays: trialDays ?? this.trialDays,
      requiresPaymentMethod: requiresPaymentMethod ?? this.requiresPaymentMethod,
      applicableDiscounts: applicableDiscounts ?? this.applicableDiscounts,
      promotionalOffers: promotionalOffers ?? this.promotionalOffers,
      targetMarkets: targetMarkets ?? this.targetMarkets,
      localizations: localizations ?? this.localizations,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        displayName,
        description,
        tier,
        isActive,
        isPopular,
        isFeatured,
        pricing,
        availableCurrencies,
        defaultCurrency,
        features,
        limits,
        permissions,
        featureList,
        limitationList,
        hasFreeTrial,
        trialDays,
        requiresPaymentMethod,
        applicableDiscounts,
        promotionalOffers,
        targetMarkets,
        localizations,
        createdAt,
        updatedAt,
      ];
}

class PricingTierEntity extends Equatable {
  final String billingCycle; // monthly, yearly, lifetime
  final Map<String, double> prices; // currency -> price
  final Map<String, double> originalPrices; // Before discounts
  final Map<String, double> discounts; // currency -> discount percentage
  final bool isPromotional;
  final DateTime? promotionEnd;

  const PricingTierEntity({
    required this.billingCycle,
    this.prices = const {},
    this.originalPrices = const {},
    this.discounts = const {},
    this.isPromotional = false,
    this.promotionEnd,
  });

  double? getPriceForCurrency(String currency) => prices[currency];
  double? getDiscountForCurrency(String currency) => discounts[currency];
  bool get hasDiscount => discounts.isNotEmpty;

  PricingTierEntity copyWith({
    String? billingCycle,
    Map<String, double>? prices,
    Map<String, double>? originalPrices,
    Map<String, double>? discounts,
    bool? isPromotional,
    DateTime? promotionEnd,
  }) {
    return PricingTierEntity(
      billingCycle: billingCycle ?? this.billingCycle,
      prices: prices ?? this.prices,
      originalPrices: originalPrices ?? this.originalPrices,
      discounts: discounts ?? this.discounts,
      isPromotional: isPromotional ?? this.isPromotional,
      promotionEnd: promotionEnd ?? this.promotionEnd,
    );
  }

  @override
  List<Object?> get props => [billingCycle, prices, originalPrices, discounts, isPromotional, promotionEnd];
}

class InvoiceEntity extends Equatable {
  final String id;
  final String subscriptionId;
  final String userId;
  final String invoiceNumber;
  final DateTime invoiceDate;
  final DateTime dueDate;
  final String status; // draft, sent, paid, overdue, cancelled
  
  // Amounts
  final double subtotal;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final String currency;
  
  // Line items
  final List<InvoiceLineItemEntity> lineItems;
  
  // Payment
  final String? paymentId;
  final DateTime? paidAt;
  final String? paymentMethod;
  final Map<String, dynamic> paymentData;
  
  // Billing details
  final Map<String, dynamic> billingAddress;
  final Map<String, dynamic> customerDetails;
  
  // PDF and documents
  final String? pdfUrl;
  final bool isPdfGenerated;
  
  // Communication
  final bool isEmailSent;
  final DateTime? emailSentAt;
  final List<String> remindersSent;
  
  final DateTime createdAt;
  final DateTime? updatedAt;

  const InvoiceEntity({
    required this.id,
    required this.subscriptionId,
    required this.userId,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.dueDate,
    this.status = 'draft',
    this.subtotal = 0.0,
    this.taxAmount = 0.0,
    this.discountAmount = 0.0,
    this.totalAmount = 0.0,
    this.currency = 'INR',
    this.lineItems = const [],
    this.paymentId,
    this.paidAt,
    this.paymentMethod,
    this.paymentData = const {},
    this.billingAddress = const {},
    this.customerDetails = const {},
    this.pdfUrl,
    this.isPdfGenerated = false,
    this.isEmailSent = false,
    this.emailSentAt,
    this.remindersSent = const [],
    required this.createdAt,
    this.updatedAt,
  });

  bool get isPaid => status == 'paid';
  bool get isOverdue => status == 'overdue' || (DateTime.now().isAfter(dueDate) && !isPaid);

  InvoiceEntity copyWith({
    String? id,
    String? subscriptionId,
    String? userId,
    String? invoiceNumber,
    DateTime? invoiceDate,
    DateTime? dueDate,
    String? status,
    double? subtotal,
    double? taxAmount,
    double? discountAmount,
    double? totalAmount,
    String? currency,
    List<InvoiceLineItemEntity>? lineItems,
    String? paymentId,
    DateTime? paidAt,
    String? paymentMethod,
    Map<String, dynamic>? paymentData,
    Map<String, dynamic>? billingAddress,
    Map<String, dynamic>? customerDetails,
    String? pdfUrl,
    bool? isPdfGenerated,
    bool? isEmailSent,
    DateTime? emailSentAt,
    List<String>? remindersSent,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InvoiceEntity(
      id: id ?? this.id,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      userId: userId ?? this.userId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      lineItems: lineItems ?? this.lineItems,
      paymentId: paymentId ?? this.paymentId,
      paidAt: paidAt ?? this.paidAt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentData: paymentData ?? this.paymentData,
      billingAddress: billingAddress ?? this.billingAddress,
      customerDetails: customerDetails ?? this.customerDetails,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      isPdfGenerated: isPdfGenerated ?? this.isPdfGenerated,
      isEmailSent: isEmailSent ?? this.isEmailSent,
      emailSentAt: emailSentAt ?? this.emailSentAt,
      remindersSent: remindersSent ?? this.remindersSent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        subscriptionId,
        userId,
        invoiceNumber,
        invoiceDate,
        dueDate,
        status,
        subtotal,
        taxAmount,
        discountAmount,
        totalAmount,
        currency,
        lineItems,
        paymentId,
        paidAt,
        paymentMethod,
        paymentData,
        billingAddress,
        customerDetails,
        pdfUrl,
        isPdfGenerated,
        isEmailSent,
        emailSentAt,
        remindersSent,
        createdAt,
        updatedAt,
      ];
}

class InvoiceLineItemEntity extends Equatable {
  final String id;
  final String description;
  final int quantity;
  final double unitPrice;
  final double amount;
  final String? productId;
  final DateTime? periodStart;
  final DateTime? periodEnd;

  const InvoiceLineItemEntity({
    required this.id,
    required this.description,
    this.quantity = 1,
    required this.unitPrice,
    required this.amount,
    this.productId,
    this.periodStart,
    this.periodEnd,
  });

  InvoiceLineItemEntity copyWith({
    String? id,
    String? description,
    int? quantity,
    double? unitPrice,
    double? amount,
    String? productId,
    DateTime? periodStart,
    DateTime? periodEnd,
  }) {
    return InvoiceLineItemEntity(
      id: id ?? this.id,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      amount: amount ?? this.amount,
      productId: productId ?? this.productId,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
    );
  }

  @override
  List<Object?> get props => [id, description, quantity, unitPrice, amount, productId, periodStart, periodEnd];
}

class PaymentMethodEntity extends Equatable {
  final String id;
  final String userId;
  final String type; // card, upi, wallet, netbanking
  final Map<String, dynamic> details; // Card last 4, UPI ID, etc.
  final bool isDefault;
  final bool isActive;
  final DateTime? expiryDate;
  final String? fingerprint; // For duplicate detection
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const PaymentMethodEntity({
    required this.id,
    required this.userId,
    required this.type,
    this.details = const {},
    this.isDefault = false,
    this.isActive = true,
    this.expiryDate,
    this.fingerprint,
    this.metadata = const {},
    required this.createdAt,
    this.updatedAt,
  });

  bool get isExpired => expiryDate != null && DateTime.now().isAfter(expiryDate!);

  PaymentMethodEntity copyWith({
    String? id,
    String? userId,
    String? type,
    Map<String, dynamic>? details,
    bool? isDefault,
    bool? isActive,
    DateTime? expiryDate,
    String? fingerprint,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentMethodEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      details: details ?? this.details,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
      expiryDate: expiryDate ?? this.expiryDate,
      fingerprint: fingerprint ?? this.fingerprint,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        details,
        isDefault,
        isActive,
        expiryDate,
        fingerprint,
        metadata,
        createdAt,
        updatedAt,
      ];
}
