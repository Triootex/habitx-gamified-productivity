import 'package:injectable/injectable.dart';

abstract class ValidationEngine {
  Map<String, String> validateUserRegistration(Map<String, dynamic> userData);
  Map<String, String> validateTaskData(Map<String, dynamic> taskData);
  Map<String, String> validateHabitData(Map<String, dynamic> habitData);
  Map<String, String> validateEmailFormat(String email);
  Map<String, String> validatePasswordStrength(String password);
  Map<String, String> validatePhoneNumber(String phoneNumber);
  Map<String, String> validateSubscriptionData(Map<String, dynamic> subscriptionData);
  Map<String, String> validatePaymentData(Map<String, dynamic> paymentData);
  bool isValidDate(String dateString);
  bool isValidUrl(String url);
  bool isValidUsername(String username);
  Map<String, String> validateBudgetData(Map<String, dynamic> budgetData);
  Map<String, String> validateMealPlanData(Map<String, dynamic> mealPlanData);
  Map<String, String> validateJournalEntry(Map<String, dynamic> entryData);
}

@LazySingleton(as: ValidationEngine)
class ValidationEngineImpl implements ValidationEngine {
  @override
  Map<String, String> validateUserRegistration(Map<String, dynamic> userData) {
    final errors = <String, String>{};
    
    // Email validation
    final email = userData['email'] as String?;
    if (email == null || email.isEmpty) {
      errors['email'] = 'Email is required';
    } else {
      final emailErrors = validateEmailFormat(email);
      if (emailErrors.isNotEmpty) {
        errors.addAll(emailErrors);
      }
    }
    
    // Password validation
    final password = userData['password'] as String?;
    if (password == null || password.isEmpty) {
      errors['password'] = 'Password is required';
    } else {
      final passwordErrors = validatePasswordStrength(password);
      if (passwordErrors.isNotEmpty) {
        errors.addAll(passwordErrors);
      }
    }
    
    // Display name validation
    final displayName = userData['display_name'] as String?;
    if (displayName == null || displayName.trim().isEmpty) {
      errors['display_name'] = 'Display name is required';
    } else if (displayName.trim().length < 2) {
      errors['display_name'] = 'Display name must be at least 2 characters';
    } else if (displayName.trim().length > 50) {
      errors['display_name'] = 'Display name must be less than 50 characters';
    }
    
    // Username validation (if provided)
    final username = userData['username'] as String?;
    if (username != null && username.isNotEmpty) {
      if (!isValidUsername(username)) {
        errors['username'] = 'Username can only contain letters, numbers, and underscores';
      }
    }
    
    // Phone number validation (if provided)
    final phoneNumber = userData['phone_number'] as String?;
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      final phoneErrors = validatePhoneNumber(phoneNumber);
      if (phoneErrors.isNotEmpty) {
        errors.addAll(phoneErrors);
      }
    }
    
    // Age validation
    final birthDate = userData['birth_date'] as String?;
    if (birthDate != null && birthDate.isNotEmpty) {
      if (!isValidDate(birthDate)) {
        errors['birth_date'] = 'Invalid birth date format';
      } else {
        final age = _calculateAge(DateTime.parse(birthDate));
        if (age < 13) {
          errors['birth_date'] = 'Must be at least 13 years old';
        } else if (age > 120) {
          errors['birth_date'] = 'Invalid birth date';
        }
      }
    }
    
    return errors;
  }

  @override
  Map<String, String> validateTaskData(Map<String, dynamic> taskData) {
    final errors = <String, String>{};
    
    // Title validation
    final title = taskData['title'] as String?;
    if (title == null || title.trim().isEmpty) {
      errors['title'] = 'Task title is required';
    } else if (title.trim().length > 200) {
      errors['title'] = 'Task title must be less than 200 characters';
    }
    
    // Priority validation
    final priority = taskData['priority'] as String?;
    if (priority != null && !['low', 'medium', 'high', 'urgent'].contains(priority)) {
      errors['priority'] = 'Invalid priority level';
    }
    
    // Due date validation
    final dueDate = taskData['due_date'] as String?;
    if (dueDate != null && dueDate.isNotEmpty) {
      if (!isValidDate(dueDate)) {
        errors['due_date'] = 'Invalid due date format';
      } else {
        final due = DateTime.parse(dueDate);
        if (due.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
          errors['due_date'] = 'Due date cannot be in the past';
        }
      }
    }
    
    // Estimated minutes validation
    final estimatedMinutes = taskData['estimated_minutes'] as int?;
    if (estimatedMinutes != null) {
      if (estimatedMinutes < 1) {
        errors['estimated_minutes'] = 'Estimated time must be at least 1 minute';
      } else if (estimatedMinutes > 1440) { // 24 hours
        errors['estimated_minutes'] = 'Estimated time cannot exceed 24 hours';
      }
    }
    
    // Category validation
    final category = taskData['category'] as String?;
    if (category != null && category.length > 50) {
      errors['category'] = 'Category name must be less than 50 characters';
    }
    
    return errors;
  }

  @override
  Map<String, String> validateHabitData(Map<String, dynamic> habitData) {
    final errors = <String, String>{};
    
    // Name validation
    final name = habitData['name'] as String?;
    if (name == null || name.trim().isEmpty) {
      errors['name'] = 'Habit name is required';
    } else if (name.trim().length < 3) {
      errors['name'] = 'Habit name must be at least 3 characters';
    } else if (name.trim().length > 100) {
      errors['name'] = 'Habit name must be less than 100 characters';
    }
    
    // Category validation
    final category = habitData['category'] as String?;
    if (category == null || category.trim().isEmpty) {
      errors['category'] = 'Category is required';
    }
    
    // Frequency validation
    final frequency = habitData['frequency'] as String?;
    if (frequency != null && !['daily', 'weekly', 'monthly', 'custom'].contains(frequency)) {
      errors['frequency'] = 'Invalid frequency';
    }
    
    // Target value validation for numeric habits
    final trackingType = habitData['tracking_type'] as String?;
    if (trackingType == 'numeric' || trackingType == 'duration') {
      final targetValue = habitData['target_value'] as double?;
      if (targetValue == null || targetValue <= 0) {
        errors['target_value'] = 'Target value must be greater than 0';
      } else if (targetValue > 10000) {
        errors['target_value'] = 'Target value is too large';
      }
      
      final unit = habitData['unit'] as String?;
      if (unit == null || unit.trim().isEmpty) {
        errors['unit'] = 'Unit is required for numeric/duration habits';
      }
    }
    
    // Scheduled days validation
    final scheduledDays = habitData['scheduled_days'] as List<dynamic>?;
    if (scheduledDays != null) {
      for (final day in scheduledDays) {
        if (day is! int || day < 1 || day > 7) {
          errors['scheduled_days'] = 'Invalid day of week (1-7)';
          break;
        }
      }
    }
    
    return errors;
  }

  @override
  Map<String, String> validateEmailFormat(String email) {
    final errors = <String, String>{};
    
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    
    if (!emailRegex.hasMatch(email)) {
      errors['email'] = 'Invalid email format';
    } else if (email.length > 254) {
      errors['email'] = 'Email address is too long';
    }
    
    return errors;
  }

  @override
  Map<String, String> validatePasswordStrength(String password) {
    final errors = <String, String>{};
    
    if (password.length < 8) {
      errors['password'] = 'Password must be at least 8 characters';
    }
    
    if (password.length > 128) {
      errors['password'] = 'Password must be less than 128 characters';
    }
    
    if (!password.contains(RegExp(r'[A-Z]'))) {
      errors['password'] = 'Password must contain at least one uppercase letter';
    }
    
    if (!password.contains(RegExp(r'[a-z]'))) {
      errors['password'] = 'Password must contain at least one lowercase letter';
    }
    
    if (!password.contains(RegExp(r'[0-9]'))) {
      errors['password'] = 'Password must contain at least one number';
    }
    
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      errors['password'] = 'Password must contain at least one special character';
    }
    
    // Check for common weak passwords
    final commonPasswords = [
      'password', '123456', 'qwerty', 'abc123', 'password123',
      'admin', 'letmein', 'welcome', 'monkey', '1234567890'
    ];
    
    if (commonPasswords.contains(password.toLowerCase())) {
      errors['password'] = 'This password is too common';
    }
    
    return errors;
  }

  @override
  Map<String, String> validatePhoneNumber(String phoneNumber) {
    final errors = <String, String>{};
    
    // Remove common formatting characters
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    if (cleaned.isEmpty) {
      errors['phone_number'] = 'Phone number cannot be empty';
      return errors;
    }
    
    // Check for valid international format
    if (cleaned.startsWith('+')) {
      if (cleaned.length < 8 || cleaned.length > 15) {
        errors['phone_number'] = 'Invalid international phone number format';
      }
    } else {
      // Check for valid local format (assuming 10-digit format)
      if (cleaned.length != 10) {
        errors['phone_number'] = 'Phone number must be 10 digits';
      }
    }
    
    // Check if it's all the same digit (invalid)
    if (cleaned.replaceAll(cleaned[0], '').isEmpty) {
      errors['phone_number'] = 'Phone number cannot be all the same digit';
    }
    
    return errors;
  }

  @override
  Map<String, String> validateSubscriptionData(Map<String, dynamic> subscriptionData) {
    final errors = <String, String>{};
    
    // Plan ID validation
    final planId = subscriptionData['plan_id'] as String?;
    if (planId == null || planId.trim().isEmpty) {
      errors['plan_id'] = 'Plan ID is required';
    }
    
    // Billing cycle validation
    final billingCycle = subscriptionData['billing_cycle'] as String?;
    if (billingCycle != null && !['monthly', 'yearly', 'quarterly'].contains(billingCycle)) {
      errors['billing_cycle'] = 'Invalid billing cycle';
    }
    
    // Payment method validation
    final paymentMethodId = subscriptionData['payment_method_id'] as String?;
    if (paymentMethodId == null || paymentMethodId.trim().isEmpty) {
      errors['payment_method_id'] = 'Payment method is required';
    }
    
    return errors;
  }

  @override
  Map<String, String> validatePaymentData(Map<String, dynamic> paymentData) {
    final errors = <String, String>{};
    
    final type = paymentData['type'] as String?;
    if (type == null || !['card', 'upi', 'wallet', 'netbanking'].contains(type)) {
      errors['type'] = 'Invalid payment type';
    }
    
    if (type == 'card') {
      final details = paymentData['details'] as Map<String, dynamic>?;
      if (details == null) {
        errors['details'] = 'Card details are required';
      } else {
        // Validate card number (simplified)
        final cardNumber = details['card_number'] as String?;
        if (cardNumber == null || cardNumber.replaceAll(' ', '').length < 13) {
          errors['card_number'] = 'Invalid card number';
        }
        
        // Validate expiry
        final expMonth = details['exp_month'] as int?;
        final expYear = details['exp_year'] as int?;
        if (expMonth == null || expMonth < 1 || expMonth > 12) {
          errors['exp_month'] = 'Invalid expiry month';
        }
        if (expYear == null || expYear < DateTime.now().year) {
          errors['exp_year'] = 'Card has expired';
        }
        
        // Validate CVV
        final cvv = details['cvv'] as String?;
        if (cvv == null || cvv.length < 3 || cvv.length > 4) {
          errors['cvv'] = 'Invalid CVV';
        }
      }
    }
    
    return errors;
  }

  @override
  bool isValidDate(String dateString) {
    try {
      DateTime.parse(dateString);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  bool isValidUrl(String url) {
    final urlRegex = RegExp(
      r'^https?:\/\/(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_\+.~#?&=]*)$'
    );
    return urlRegex.hasMatch(url);
  }

  @override
  bool isValidUsername(String username) {
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]{3,20}$');
    return usernameRegex.hasMatch(username);
  }

  @override
  Map<String, String> validateBudgetData(Map<String, dynamic> budgetData) {
    final errors = <String, String>{};
    
    // Name validation
    final name = budgetData['name'] as String?;
    if (name == null || name.trim().isEmpty) {
      errors['name'] = 'Budget name is required';
    } else if (name.trim().length > 100) {
      errors['name'] = 'Budget name must be less than 100 characters';
    }
    
    // Amount validations
    final totalIncome = budgetData['total_income'] as double?;
    if (totalIncome != null && totalIncome < 0) {
      errors['total_income'] = 'Income cannot be negative';
    }
    
    final savingsGoal = budgetData['savings_goal'] as double?;
    if (savingsGoal != null && savingsGoal < 0) {
      errors['savings_goal'] = 'Savings goal cannot be negative';
    }
    
    // Date validations
    final startDate = budgetData['start_date'] as String?;
    final endDate = budgetData['end_date'] as String?;
    
    if (startDate != null && !isValidDate(startDate)) {
      errors['start_date'] = 'Invalid start date format';
    }
    
    if (endDate != null && !isValidDate(endDate)) {
      errors['end_date'] = 'Invalid end date format';
    }
    
    if (startDate != null && endDate != null && 
        isValidDate(startDate) && isValidDate(endDate)) {
      final start = DateTime.parse(startDate);
      final end = DateTime.parse(endDate);
      
      if (end.isBefore(start)) {
        errors['end_date'] = 'End date cannot be before start date';
      }
    }
    
    return errors;
  }

  @override
  Map<String, String> validateMealPlanData(Map<String, dynamic> mealPlanData) {
    final errors = <String, String>{};
    
    // Name validation
    final name = mealPlanData['name'] as String?;
    if (name == null || name.trim().isEmpty) {
      errors['name'] = 'Meal plan name is required';
    } else if (name.trim().length > 100) {
      errors['name'] = 'Meal plan name must be less than 100 characters';
    }
    
    // Serving size validation
    final servingSize = mealPlanData['serving_size'] as int?;
    if (servingSize != null && (servingSize < 1 || servingSize > 20)) {
      errors['serving_size'] = 'Serving size must be between 1 and 20';
    }
    
    // Nutrition goals validation
    final nutritionGoals = mealPlanData['nutrition_goals'] as Map<String, dynamic>?;
    if (nutritionGoals != null) {
      final calories = nutritionGoals['calories'] as double?;
      if (calories != null && (calories < 800 || calories > 5000)) {
        errors['calories'] = 'Daily calories should be between 800 and 5000';
      }
      
      final protein = nutritionGoals['protein'] as double?;
      if (protein != null && protein < 0) {
        errors['protein'] = 'Protein cannot be negative';
      }
      
      final carbs = nutritionGoals['carbs'] as double?;
      if (carbs != null && carbs < 0) {
        errors['carbs'] = 'Carbohydrates cannot be negative';
      }
      
      final fat = nutritionGoals['fat'] as double?;
      if (fat != null && fat < 0) {
        errors['fat'] = 'Fat cannot be negative';
      }
    }
    
    return errors;
  }

  @override
  Map<String, String> validateJournalEntry(Map<String, dynamic> entryData) {
    final errors = <String, String>{};
    
    // Title validation
    final title = entryData['title'] as String?;
    if (title == null || title.trim().isEmpty) {
      errors['title'] = 'Entry title is required';
    } else if (title.trim().length > 200) {
      errors['title'] = 'Title must be less than 200 characters';
    }
    
    // Content validation
    final content = entryData['content'] as String?;
    if (content == null || content.trim().isEmpty) {
      errors['content'] = 'Entry content is required';
    } else if (content.trim().length < 10) {
      errors['content'] = 'Entry content must be at least 10 characters';
    } else if (content.trim().length > 10000) {
      errors['content'] = 'Entry content must be less than 10,000 characters';
    }
    
    // Mood rating validation
    final moodRating = entryData['mood_rating'] as int?;
    if (moodRating != null && (moodRating < 1 || moodRating > 10)) {
      errors['mood_rating'] = 'Mood rating must be between 1 and 10';
    }
    
    // Entry type validation
    final entryType = entryData['entry_type'] as String?;
    if (entryType != null && !['daily', 'gratitude', 'reflection', 'dream', 'goal'].contains(entryType)) {
      errors['entry_type'] = 'Invalid entry type';
    }
    
    // Privacy validation
    final privacy = entryData['privacy'] as String?;
    if (privacy != null && !['private', 'public', 'friends'].contains(privacy)) {
      errors['privacy'] = 'Invalid privacy setting';
    }
    
    return errors;
  }

  // Private helper methods
  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    
    if (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    
    return age;
  }
}
