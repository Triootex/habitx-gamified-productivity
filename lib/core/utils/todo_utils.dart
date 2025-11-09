import '../constants/todo_constants.dart';
import 'date_utils.dart';
import 'string_utils.dart';

class TodoUtils {
  /// Calculate priority score for sorting
  static int calculatePriorityScore(String priority, DateTime? dueDate) {
    int baseScore = _getPriorityBaseScore(priority);
    
    if (dueDate != null) {
      final daysUntilDue = dueDate.difference(DateTime.now()).inDays;
      if (daysUntilDue <= 0) {
        baseScore += 1000; // Overdue items get highest priority
      } else if (daysUntilDue <= 1) {
        baseScore += 500; // Due today/tomorrow
      } else if (daysUntilDue <= 7) {
        baseScore += 100; // Due this week
      }
    }
    
    return baseScore;
  }
  
  static int _getPriorityBaseScore(String priority) {
    switch (priority) {
      case TodoConstants.urgentPriority:
        return 400;
      case TodoConstants.highPriority:
        return 300;
      case TodoConstants.mediumPriority:
        return 200;
      case TodoConstants.lowPriority:
        return 100;
      default:
        return 100;
    }
  }
  
  /// Generate subtasks from main task description using AI-like logic
  static List<String> generateSubtasks(String taskTitle, String? description) {
    final List<String> subtasks = [];
    
    // Check for common patterns and generate appropriate subtasks
    final lowerTitle = taskTitle.toLowerCase();
    
    if (lowerTitle.contains('meeting')) {
      subtasks.addAll([
        'Prepare agenda',
        'Send calendar invite',
        'Gather materials',
        'Review previous notes',
      ]);
    } else if (lowerTitle.contains('presentation')) {
      subtasks.addAll([
        'Research topic',
        'Create outline',
        'Design slides',
        'Practice delivery',
        'Prepare for Q&A',
      ]);
    } else if (lowerTitle.contains('project')) {
      subtasks.addAll([
        'Define scope and requirements',
        'Create timeline',
        'Assign responsibilities',
        'Set up project structure',
      ]);
    } else if (lowerTitle.contains('report')) {
      subtasks.addAll([
        'Gather data and research',
        'Create outline',
        'Write draft',
        'Review and edit',
        'Format and finalize',
      ]);
    }
    
    // Add generic subtasks if description is provided
    if (description != null && description.isNotEmpty) {
      final sentences = description.split('.');
      for (final sentence in sentences) {
        if (sentence.trim().isNotEmpty && sentence.length > 10) {
          subtasks.add(StringUtils.capitalize(sentence.trim()));
        }
      }
    }
    
    return subtasks.take(5).toList(); // Limit to 5 subtasks
  }
  
  /// Calculate task completion XP based on various factors
  static int calculateTaskXP(String priority, int subtasksCompleted, int totalSubtasks, bool completedOnTime) {
    int baseXP = TodoConstants.xpByPriority[priority] ?? 10;
    
    // Subtask completion bonus
    if (totalSubtasks > 0) {
      final completionRatio = subtasksCompleted / totalSubtasks;
      baseXP = (baseXP * (0.5 + completionRatio * 0.5)).round();
    }
    
    // On-time completion bonus
    if (completedOnTime) {
      baseXP = (baseXP * 1.2).round();
    }
    
    return baseXP;
  }
  
  /// Determine if task is overdue
  static bool isTaskOverdue(DateTime? dueDate, String status) {
    if (dueDate == null || status == TodoConstants.completed) {
      return false;
    }
    
    return DateTime.now().isAfter(dueDate);
  }
  
  /// Get appropriate reminder time based on priority and due date
  static DateTime? calculateReminderTime(DateTime? dueDate, String priority) {
    if (dueDate == null) return null;
    
    Duration reminderOffset;
    
    switch (priority) {
      case TodoConstants.urgentPriority:
        reminderOffset = const Duration(hours: 1);
        break;
      case TodoConstants.highPriority:
        reminderOffset = const Duration(hours: 2);
        break;
      case TodoConstants.mediumPriority:
        reminderOffset = const Duration(hours: 4);
        break;
      default:
        reminderOffset = const Duration(hours: 8);
    }
    
    final reminderTime = dueDate.subtract(reminderOffset);
    
    // Don't set reminder in the past
    if (reminderTime.isBefore(DateTime.now())) {
      return DateTime.now().add(const Duration(minutes: 5));
    }
    
    return reminderTime;
  }
  
  /// Generate task suggestions based on existing tasks and patterns
  static List<String> generateTaskSuggestions(List<String> recentTasks, String category) {
    final suggestions = <String>[];
    
    // Category-based suggestions
    switch (category.toLowerCase()) {
      case 'work':
        suggestions.addAll([
          'Check and respond to emails',
          'Review daily schedule',
          'Update project status',
          'Prepare for upcoming meetings',
          'Organize workspace',
        ]);
        break;
      case 'personal':
        suggestions.addAll([
          'Exercise or go for a walk',
          'Call family or friends',
          'Plan meals for tomorrow',
          'Read for 30 minutes',
          'Organize personal space',
        ]);
        break;
      case 'health':
        suggestions.addAll([
          'Drink 8 glasses of water',
          'Take vitamins',
          'Schedule medical checkup',
          'Meal prep for the week',
          'Practice mindfulness',
        ]);
        break;
      case 'education':
        suggestions.addAll([
          'Review study materials',
          'Complete assignments',
          'Research topics of interest',
          'Practice new skills',
          'Join online course',
        ]);
        break;
    }
    
    return suggestions.take(3).toList();
  }
  
  /// Parse Gmail task and extract actionable items
  static Map<String, dynamic> parseGmailTask(Map<String, dynamic> emailData) {
    final subject = emailData['subject'] ?? '';
    final body = emailData['body'] ?? '';
    final sender = emailData['sender'] ?? '';
    
    return {
      'title': _extractTaskTitle(subject, body),
      'description': _extractTaskDescription(body),
      'priority': _determinePriority(subject, body, sender),
      'dueDate': _extractDueDate(body),
      'category': _determineCategory(subject, body, sender),
      'tags': _extractTags(subject, body),
    };
  }
  
  static String _extractTaskTitle(String subject, String body) {
    // Remove common email prefixes
    String title = subject.replaceAll(RegExp(r'^(Re:|Fwd?:|RE:|FWD?:)\s*', caseSensitive: false), '');
    
    // Look for action words in subject
    final actionWords = ['review', 'complete', 'send', 'prepare', 'schedule', 'follow up'];
    for (final word in actionWords) {
      if (title.toLowerCase().contains(word)) {
        return StringUtils.capitalizeWords(title);
      }
    }
    
    // If no action words, try to extract from body
    final bodyLines = body.split('\n').take(3);
    for (final line in bodyLines) {
      if (line.trim().isNotEmpty && line.length < 100) {
        for (final word in actionWords) {
          if (line.toLowerCase().contains(word)) {
            return StringUtils.capitalizeWords(line.trim());
          }
        }
      }
    }
    
    return StringUtils.capitalizeWords(title);
  }
  
  static String? _extractTaskDescription(String body) {
    // Extract first meaningful paragraph from email body
    final lines = body.split('\n');
    final meaningfulLines = <String>[];
    
    for (final line in lines) {
      final cleanLine = line.trim();
      if (cleanLine.isNotEmpty && 
          cleanLine.length > 20 && 
          !cleanLine.startsWith('>') &&
          !cleanLine.contains('@')) {
        meaningfulLines.add(cleanLine);
        if (meaningfulLines.length >= 3) break;
      }
    }
    
    return meaningfulLines.isNotEmpty ? meaningfulLines.join(' ') : null;
  }
  
  static String _determinePriority(String subject, String body, String sender) {
    final text = '$subject $body'.toLowerCase();
    
    if (text.contains(RegExp(r'\b(urgent|asap|immediately|critical|emergency)\b'))) {
      return TodoConstants.urgentPriority;
    }
    
    if (text.contains(RegExp(r'\b(important|priority|deadline|due)\b'))) {
      return TodoConstants.highPriority;
    }
    
    // Check if sender is from important domains
    if (sender.contains(RegExp(r'@(boss|manager|ceo|director)', caseSensitive: false))) {
      return TodoConstants.highPriority;
    }
    
    return TodoConstants.mediumPriority;
  }
  
  static DateTime? _extractDueDate(String body) {
    final text = body.toLowerCase();
    final now = DateTime.now();
    
    // Look for common date patterns
    if (text.contains(RegExp(r'\b(today|tod)\b'))) {
      return DateTimeUtils.endOfDay(now);
    }
    
    if (text.contains(RegExp(r'\b(tomorrow|tmrw)\b'))) {
      return DateTimeUtils.endOfDay(now.add(const Duration(days: 1)));
    }
    
    if (text.contains(RegExp(r'\bthis week\b'))) {
      return DateTimeUtils.endOfWeek(now);
    }
    
    if (text.contains(RegExp(r'\bnext week\b'))) {
      return DateTimeUtils.endOfWeek(now.add(const Duration(days: 7)));
    }
    
    // Try to parse specific dates (this would need more sophisticated date parsing)
    final dateRegex = RegExp(r'\b(\d{1,2})/(\d{1,2})/(\d{2,4})\b');
    final match = dateRegex.firstMatch(body);
    if (match != null) {
      try {
        final month = int.parse(match.group(1)!);
        final day = int.parse(match.group(2)!);
        final year = int.parse(match.group(3)!);
        final fullYear = year < 100 ? 2000 + year : year;
        return DateTime(fullYear, month, day, 23, 59, 59);
      } catch (e) {
        // Invalid date format, return null
      }
    }
    
    return null;
  }
  
  static String _determineCategory(String subject, String body, String sender) {
    final text = '$subject $body $sender'.toLowerCase();
    
    if (text.contains(RegExp(r'\b(meeting|conference|call|zoom)\b'))) {
      return 'work';
    }
    
    if (text.contains(RegExp(r'\b(doctor|appointment|health|medical)\b'))) {
      return 'health';
    }
    
    if (text.contains(RegExp(r'\b(family|personal|home)\b'))) {
      return 'personal';
    }
    
    if (text.contains(RegExp(r'\b(buy|purchase|shopping|order)\b'))) {
      return 'shopping';
    }
    
    return 'personal'; // Default category
  }
  
  static List<String> _extractTags(String subject, String body) {
    final tags = <String>[];
    final text = '$subject $body'.toLowerCase();
    
    // Extract hashtags
    final hashtagRegex = RegExp(r'#(\w+)');
    final hashtagMatches = hashtagRegex.allMatches(text);
    for (final match in hashtagMatches) {
      tags.add(match.group(1)!);
    }
    
    // Add contextual tags
    if (text.contains('meeting')) tags.add('meeting');
    if (text.contains('deadline')) tags.add('deadline');
    if (text.contains('review')) tags.add('review');
    if (text.contains('urgent')) tags.add('urgent');
    
    return tags.take(5).toList();
  }
  
  /// Format task for display
  static String formatTaskDisplay(String title, DateTime? dueDate, String priority) {
    final buffer = StringBuffer(title);
    
    if (dueDate != null) {
      buffer.write(' (Due: ${DateTimeUtils.formatDateReadable(dueDate)})');
    }
    
    if (priority == TodoConstants.urgentPriority) {
      buffer.write(' 🔥');
    } else if (priority == TodoConstants.highPriority) {
      buffer.write(' ⚡');
    }
    
    return buffer.toString();
  }
  
  /// Validate task data
  static Map<String, String?> validateTask(Map<String, dynamic> taskData) {
    final errors = <String, String?>{};
    
    final title = taskData['title'] as String?;
    if (title == null || title.trim().isEmpty) {
      errors['title'] = 'Task title is required';
    } else if (title.length > TodoConstants.maxTaskTitle) {
      errors['title'] = 'Task title is too long (max ${TodoConstants.maxTaskTitle} characters)';
    }
    
    final description = taskData['description'] as String?;
    if (description != null && description.length > TodoConstants.maxTaskDescription) {
      errors['description'] = 'Description is too long (max ${TodoConstants.maxTaskDescription} characters)';
    }
    
    final dueDate = taskData['dueDate'] as DateTime?;
    if (dueDate != null && dueDate.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      errors['dueDate'] = 'Due date cannot be in the past';
    }
    
    final tags = taskData['tags'] as List<String>?;
    if (tags != null && tags.length > TodoConstants.maxTags) {
      errors['tags'] = 'Too many tags (max ${TodoConstants.maxTags})';
    }
    
    return errors;
  }
  
  /// Get task status color
  static String getStatusColor(String status) {
    switch (status) {
      case TodoConstants.completed:
        return '#2ECC71'; // Green
      case TodoConstants.inProgress:
        return '#3498DB'; // Blue
      case TodoConstants.overdue:
        return '#E74C3C'; // Red
      case TodoConstants.cancelled:
        return '#95A5A6'; // Gray
      default:
        return '#F39C12'; // Orange for pending
    }
  }
  
  /// Get priority icon
  static String getPriorityIcon(String priority) {
    switch (priority) {
      case TodoConstants.urgentPriority:
        return '🔥';
      case TodoConstants.highPriority:
        return '⚡';
      case TodoConstants.mediumPriority:
        return '⭐';
      case TodoConstants.lowPriority:
        return '📌';
      default:
        return '📝';
    }
  }
}
