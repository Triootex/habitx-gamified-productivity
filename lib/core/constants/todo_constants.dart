class TodoConstants {
  // Todo Types
  static const String personal = 'personal';
  static const String work = 'work';
  static const String shopping = 'shopping';
  static const String health = 'health';
  static const String education = 'education';
  static const String finance = 'finance';
  static const String social = 'social';
  
  // Priority Levels
  static const String lowPriority = 'low';
  static const String mediumPriority = 'medium';
  static const String highPriority = 'high';
  static const String urgentPriority = 'urgent';
  
  // Status Types
  static const String pending = 'pending';
  static const String inProgress = 'in_progress';
  static const String completed = 'completed';
  static const String cancelled = 'cancelled';
  static const String overdue = 'overdue';
  
  // Kanban Columns
  static const List<String> kanbanColumns = [
    'backlog',
    'todo',
    'in_progress',
    'review',
    'done',
  ];
  
  // Default Categories
  static const List<Map<String, dynamic>> defaultCategories = [
    {'name': 'Personal', 'color': '#3498DB', 'icon': 'person'},
    {'name': 'Work', 'color': '#E74C3C', 'icon': 'work'},
    {'name': 'Shopping', 'color': '#F39C12', 'icon': 'shopping_cart'},
    {'name': 'Health', 'color': '#2ECC71', 'icon': 'health'},
    {'name': 'Education', 'color': '#9B59B6', 'icon': 'school'},
    {'name': 'Finance', 'color': '#1ABC9C', 'icon': 'money'},
    {'name': 'Social', 'color': '#E67E22', 'icon': 'people'},
  ];
  
  // XP Rewards by Priority
  static const Map<String, int> xpByPriority = {
    lowPriority: 10,
    mediumPriority: 25,
    highPriority: 50,
    urgentPriority: 100,
  };
  
  // Gmail Integration
  static const String gmailScopeReadonly = 'https://www.googleapis.com/auth/gmail.readonly';
  static const String gmailScopeModify = 'https://www.googleapis.com/auth/gmail.modify';
  
  // Subtask Limits
  static const int maxSubtasksPerTask = 20;
  static const int maxDepthLevel = 3;
  
  // Templates
  static const List<Map<String, dynamic>> taskTemplates = [
    {
      'name': 'Daily Planning',
      'tasks': [
        'Review calendar for today',
        'Check priority emails',
        'Plan 3 important tasks',
        'Review yesterday\'s progress',
      ]
    },
    {
      'name': 'Weekly Review',
      'tasks': [
        'Review completed goals',
        'Plan next week priorities',
        'Clean up task list',
        'Schedule important meetings',
      ]
    },
    {
      'name': 'Project Setup',
      'tasks': [
        'Define project scope',
        'Create task breakdown',
        'Set milestones',
        'Assign responsibilities',
      ]
    },
  ];
  
  // Reminder Types
  static const String reminderBefore = 'before';
  static const String reminderAt = 'at';
  static const String reminderAfter = 'after';
  
  // Due Date Options
  static const List<String> dueDatePresets = [
    'today',
    'tomorrow',
    'this_week',
    'next_week',
    'this_month',
    'next_month',
  ];
  
  // Auto-complete Rules
  static const Map<String, List<String>> autoCompleteRules = {
    'meeting': ['Prepare agenda', 'Send invites', 'Book room', 'Follow up'],
    'project': ['Plan scope', 'Create timeline', 'Assign tasks', 'Review progress'],
    'presentation': ['Research topic', 'Create slides', 'Practice delivery', 'Get feedback'],
  };
  
  // Collaboration Features
  static const String assigneeRole = 'assignee';
  static const String reviewerRole = 'reviewer';
  static const String observerRole = 'observer';
  
  // Time Tracking
  static const int defaultEstimateMinutes = 30;
  static const int maxEstimateHours = 24;
  
  // Recurring Patterns
  static const String daily = 'daily';
  static const String weekly = 'weekly';
  static const String monthly = 'monthly';
  static const String yearly = 'yearly';
  static const String custom = 'custom';
  
  // Attachment Types
  static const List<String> allowedFileTypes = [
    'jpg', 'jpeg', 'png', 'gif', 'bmp',
    'pdf', 'doc', 'docx', 'xls', 'xlsx',
    'ppt', 'pptx', 'txt', 'zip', 'rar',
  ];
  
  // Search Filters
  static const List<String> searchFilters = [
    'all',
    'today',
    'overdue',
    'completed',
    'high_priority',
    'assigned_to_me',
  ];
  
  // Export Formats
  static const List<String> exportFormats = [
    'json',
    'csv',
    'pdf',
    'xlsx',
  ];
  
  // Notification Types
  static const String dueDateNotification = 'due_date';
  static const String overdueNotification = 'overdue';
  static const String assignmentNotification = 'assignment';
  static const String completionNotification = 'completion';
  
  // Limits
  static const int maxTasksPerDay = 50;
  static const int maxTaskTitle = 200;
  static const int maxTaskDescription = 2000;
  static const int maxTags = 10;
}
