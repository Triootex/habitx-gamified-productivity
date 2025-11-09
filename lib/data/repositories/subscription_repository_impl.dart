import 'package:injectable/injectable.dart';
import '../../domain/entities/subscription_entity.dart';
import '../datasources/local/subscription_local_data_source.dart';
import '../datasources/remote/subscription_remote_data_source.dart';
import '../../core/network/network_info.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import 'package:dartz/dartz.dart';

abstract class SubscriptionRepository {
  Future<Either<Failure, List<SubscriptionPlanEntity>>> getAvailablePlans({String? region});
  Future<Either<Failure, SubscriptionEntity>> getUserSubscription(String userId);
  Future<Either<Failure, SubscriptionEntity>> subscribe(String userId, String planId, Map<String, dynamic> paymentData);
  Future<Either<Failure, SubscriptionEntity>> upgradeSubscription(String userId, String newPlanId);
  Future<Either<Failure, bool>> cancelSubscription(String userId, {String? reason});
  Future<Either<Failure, bool>> resumeSubscription(String userId);
  Future<Either<Failure, List<InvoiceEntity>>> getUserInvoices(String userId);
  Future<Either<Failure, InvoiceEntity>> getInvoice(String invoiceId);
  Future<Either<Failure, List<PaymentMethodEntity>>> getPaymentMethods(String userId);
  Future<Either<Failure, PaymentMethodEntity>> addPaymentMethod(String userId, Map<String, dynamic> paymentData);
  Future<Either<Failure, bool>> validatePayment(String paymentMethodId, double amount);
  Future<Either<Failure, Map<String, dynamic>>> getBillingAnalytics(String userId);
  Future<Either<Failure, bool>> applyPromoCode(String userId, String promoCode);
  Future<Either<Failure, Map<String, dynamic>>> getUsageStats(String userId);
}

@LazySingleton(as: SubscriptionRepository)
class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionLocalDataSource localDataSource;
  final SubscriptionRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  SubscriptionRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<SubscriptionPlanEntity>>> getAvailablePlans({String? region}) async {
    try {
      List<SubscriptionPlanEntity> localPlans = [];
      
      try {
        localPlans = await localDataSource.getAvailablePlans(region: region);
      } on CacheException {
        // No local plans
      }
      
      if (await networkInfo.isConnected) {
        try {
          final remotePlans = await remoteDataSource.getAvailablePlans(region: region);
          // Update local cache with remote data
          await localDataSource.cachePlans(remotePlans);
          return Right(remotePlans);
        } catch (e) {
          if (localPlans.isNotEmpty) {
            return Right(localPlans);
          } else {
            return Left(ServerFailure('Failed to fetch subscription plans and no local cache available'));
          }
        }
      }
      
      return Right(localPlans);
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, SubscriptionEntity>> getUserSubscription(String userId) async {
    try {
      SubscriptionEntity? localSubscription;
      
      try {
        localSubscription = await localDataSource.getUserSubscription(userId);
      } on CacheException {
        // No local subscription
      }
      
      if (await networkInfo.isConnected) {
        try {
          final remoteSubscription = await remoteDataSource.getUserSubscription(userId);
          // Update local cache with remote data
          await localDataSource.cacheSubscription(remoteSubscription);
          return Right(remoteSubscription);
        } catch (e) {
          if (localSubscription != null) {
            return Right(localSubscription);
          } else {
            return Left(ServerFailure('Failed to fetch subscription and no local cache available'));
          }
        }
      }
      
      if (localSubscription != null) {
        return Right(localSubscription);
      } else {
        return Left(CacheFailure('No subscription found'));
      }
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, SubscriptionEntity>> subscribe(String userId, String planId, Map<String, dynamic> paymentData) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure('Internet connection required for subscription'));
      }

      // Process subscription on server
      final remoteSubscription = await remoteDataSource.subscribe(userId, planId, paymentData);
      
      // Cache subscription locally
      await localDataSource.cacheSubscription(remoteSubscription);
      
      return Right(remoteSubscription);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Subscription failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, SubscriptionEntity>> upgradeSubscription(String userId, String newPlanId) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure('Internet connection required for subscription upgrade'));
      }

      // Process upgrade on server
      final upgradedSubscription = await remoteDataSource.upgradeSubscription(userId, newPlanId);
      
      // Update local cache
      await localDataSource.cacheSubscription(upgradedSubscription);
      
      return Right(upgradedSubscription);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Subscription upgrade failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> cancelSubscription(String userId, {String? reason}) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure('Internet connection required for subscription cancellation'));
      }

      // Cancel subscription on server
      await remoteDataSource.cancelSubscription(userId, reason: reason);
      
      // Update local cache with cancellation
      await localDataSource.updateSubscriptionStatus(userId, 'cancelled');
      
      return const Right(true);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Subscription cancellation failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> resumeSubscription(String userId) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure('Internet connection required to resume subscription'));
      }

      // Resume subscription on server
      await remoteDataSource.resumeSubscription(userId);
      
      // Update local cache with active status
      await localDataSource.updateSubscriptionStatus(userId, 'active');
      
      return const Right(true);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Subscription resumption failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<InvoiceEntity>>> getUserInvoices(String userId) async {
    try {
      List<InvoiceEntity> localInvoices = [];
      
      try {
        localInvoices = await localDataSource.getUserInvoices(userId);
      } on CacheException {
        // No local invoices
      }
      
      if (await networkInfo.isConnected) {
        try {
          final remoteInvoices = await remoteDataSource.getUserInvoices(userId);
          await localDataSource.cacheInvoices(remoteInvoices);
          return Right(remoteInvoices);
        } catch (e) {
          if (localInvoices.isNotEmpty) {
            return Right(localInvoices);
          } else {
            return Left(ServerFailure('Failed to fetch invoices'));
          }
        }
      }
      
      return Right(localInvoices);
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, InvoiceEntity>> getInvoice(String invoiceId) async {
    try {
      InvoiceEntity? localInvoice;
      
      try {
        localInvoice = await localDataSource.getInvoice(invoiceId);
      } on CacheException {
        // No local invoice
      }
      
      if (await networkInfo.isConnected) {
        try {
          final remoteInvoice = await remoteDataSource.getInvoice(invoiceId);
          await localDataSource.cacheInvoice(remoteInvoice);
          return Right(remoteInvoice);
        } catch (e) {
          if (localInvoice != null) {
            return Right(localInvoice);
          } else {
            return Left(ServerFailure('Failed to fetch invoice'));
          }
        }
      }
      
      if (localInvoice != null) {
        return Right(localInvoice);
      } else {
        return Left(CacheFailure('Invoice not found'));
      }
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<PaymentMethodEntity>>> getPaymentMethods(String userId) async {
    try {
      List<PaymentMethodEntity> localMethods = [];
      
      try {
        localMethods = await localDataSource.getPaymentMethods(userId);
      } on CacheException {
        // No local payment methods
      }
      
      if (await networkInfo.isConnected) {
        try {
          final remoteMethods = await remoteDataSource.getPaymentMethods(userId);
          await localDataSource.cachePaymentMethods(remoteMethods);
          return Right(remoteMethods);
        } catch (e) {
          if (localMethods.isNotEmpty) {
            return Right(localMethods);
          } else {
            return Left(ServerFailure('Failed to fetch payment methods'));
          }
        }
      }
      
      return Right(localMethods);
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, PaymentMethodEntity>> addPaymentMethod(String userId, Map<String, dynamic> paymentData) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure('Internet connection required to add payment method'));
      }

      // Add payment method on server
      final remoteMethod = await remoteDataSource.addPaymentMethod(userId, paymentData);
      
      // Cache payment method locally
      await localDataSource.cachePaymentMethod(remoteMethod);
      
      return Right(remoteMethod);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to add payment method: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> validatePayment(String paymentMethodId, double amount) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure('Internet connection required for payment validation'));
      }

      // Validate payment on server
      final isValid = await remoteDataSource.validatePayment(paymentMethodId, amount);
      
      return Right(isValid);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Payment validation failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getBillingAnalytics(String userId) async {
    try {
      // Try to get analytics from remote for most accurate data
      if (await networkInfo.isConnected) {
        try {
          final remoteAnalytics = await remoteDataSource.getBillingAnalytics(userId);
          // Cache analytics locally
          await localDataSource.cacheBillingAnalytics(userId, remoteAnalytics);
          return Right(remoteAnalytics);
        } catch (e) {
          // Fall back to local analytics
          try {
            final localAnalytics = await localDataSource.getBillingAnalytics(userId);
            return Right(localAnalytics);
          } on CacheException {
            return Left(ServerFailure('Failed to fetch analytics and no local cache available'));
          }
        }
      } else {
        // Offline - use local analytics
        final localAnalytics = await localDataSource.getBillingAnalytics(userId);
        return Right(localAnalytics);
      }
    } on CacheException {
      return Left(CacheFailure('No analytics data available locally'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> applyPromoCode(String userId, String promoCode) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure('Internet connection required to apply promo code'));
      }

      // Apply promo code on server
      final success = await remoteDataSource.applyPromoCode(userId, promoCode);
      
      if (success) {
        // Refresh subscription data to reflect discount
        final updatedSubscription = await remoteDataSource.getUserSubscription(userId);
        await localDataSource.cacheSubscription(updatedSubscription);
      }
      
      return Right(success);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to apply promo code: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getUsageStats(String userId) async {
    try {
      // Try to get usage stats from remote for most accurate data
      if (await networkInfo.isConnected) {
        try {
          final remoteStats = await remoteDataSource.getUsageStats(userId);
          // Cache usage stats locally
          await localDataSource.cacheUsageStats(userId, remoteStats);
          return Right(remoteStats);
        } catch (e) {
          // Fall back to local stats
          try {
            final localStats = await localDataSource.getUsageStats(userId);
            return Right(localStats);
          } on CacheException {
            return Left(ServerFailure('Failed to fetch usage stats and no local cache available'));
          }
        }
      } else {
        // Offline - use local stats
        final localStats = await localDataSource.getUsageStats(userId);
        return Right(localStats);
      }
    } on CacheException {
      return Left(CacheFailure('No usage stats available locally'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }
}
