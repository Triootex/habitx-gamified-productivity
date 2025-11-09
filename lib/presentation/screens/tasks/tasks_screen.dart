import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/task_providers.dart';
import '../../widgets/universal_animated_widgets.dart';
import '../../widgets/page_transitions.dart';
import '../../core/animations/animation_assets.dart';
import '../../widgets/feature_gate.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Initialize tasks when screen loads
    Future.microtask(() {
      final userId = ref.read(userIdProvider);
      if (userId != null) {
        ref.read(taskProvider.notifier).setUserId(userId);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskProvider);
    final completedTasks = ref.watch(completedTasksProvider);
    final pendingTasks = ref.watch(pendingTasksProvider);
    final todayTasks = taskState.todayTasks;
    final overdueTasks = taskState.overdueTasks;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            AnimatedWidget(
              assetPath: AnimationAssets.todoList,
              width: 30,
              height: 30,
            ),
            const SizedBox(width: 12),
            const Text('Tasks'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _showSearchSheet(context),
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () => _showTaskAnalytics(context),
            icon: const Icon(Icons.analytics_outlined),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: _buildTabWithBadge(
                'All',
                taskState.tasks.length,
                AnimationAssets.todoList,
              ),
            ),
            Tab(
              child: _buildTabWithBadge(
                'Today',
                todayTasks.length,
                AnimationAssets.dailyGoal,
              ),
            ),
            Tab(
              child: _buildTabWithBadge(
                'Overdue',
                overdueTasks.length,
                AnimationAssets.deadlineWarning,
              ),
            ),
            Tab(
              child: _buildTabWithBadge(
                'Completed',
                completedTasks.length,
                AnimationAssets.successCheck,
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTaskList(taskState.tasks, 'all'),
          _buildTaskList(todayTasks, 'today'),
          _buildTaskList(overdueTasks, 'overdue'),
          _buildTaskList(completedTasks, 'completed'),
        ],
      ),
      floatingActionButton: FloatingActionAnimationButton(
        animationAsset: AnimationAssets.buttonPress,
        onPressed: () => _showCreateTaskSheet(context),
      ),
    );
  }

  Widget _buildTabWithBadge(String label, int count, String animationAsset) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedWidget(
          assetPath: animationAsset,
          width: 16,
          height: 16,
        ),
        const SizedBox(width: 4),
        Text(label),
        if (count > 0) ...[
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTaskList(List<dynamic> tasks, String type) {
    if (tasks.isEmpty) {
      return _buildEmptyState(type);
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(taskProvider.notifier).loadUserTasks();
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: tasks.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final task = tasks[index];
          return _buildTaskCard(task, type);
        },
      ),
    );
  }

  Widget _buildTaskCard(dynamic task, String type) {
    final isCompleted = task.isCompleted;
    final isOverdue = type == 'overdue';
    
    return MicroInteractionButton(
      onPressed: () => _showTaskDetails(context, task),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isOverdue
                ? Colors.red.withOpacity(0.3)
                : isCompleted
                    ? Colors.green.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => _toggleTaskCompletion(task),
                  child: Container(
                    width: 24,
                    height: 24,
                    child: isCompleted
                        ? SuccessAnimationWidget(size: 24)
                        : AnimatedWidget(
                            assetPath: AnimationAssets.checkboxTick,
                            width: 24,
                            height: 24,
                            repeat: false,
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: isCompleted
                              ? Colors.grey[600]
                              : null,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (task.description?.isNotEmpty == true) ...[
                        const SizedBox(height: 4),
                        Text(
                          task.description!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (isOverdue)
                  AnimatedWidget(
                    assetPath: AnimationAssets.deadlineWarning,
                    width: 20,
                    height: 20,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (task.category != null) ...[
                  _buildCategoryChip(task.category!),
                  const SizedBox(width: 8),
                ],
                if (task.priority != null) ...[
                  _buildPriorityChip(task.priority!),
                  const SizedBox(width: 8),
                ],
                const Spacer(),
                if (task.dueDate != null)
                  _buildDueDateChip(task.dueDate!),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CategoryIconAnimation(
            category: category,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            category,
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityChip(String priority) {
    Color color;
    switch (priority.toLowerCase()) {
      case 'high':
        color = Colors.red;
        break;
      case 'medium':
        color = Colors.orange;
        break;
      case 'low':
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        priority.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDueDateChip(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;
    final isOverdue = difference < 0;
    final isToday = difference == 0;
    
    String text;
    Color color;
    
    if (isOverdue) {
      text = '${difference.abs()}d overdue';
      color = Colors.red;
    } else if (isToday) {
      text = 'Today';
      color = Colors.orange;
    } else if (difference == 1) {
      text = 'Tomorrow';
      color = Colors.blue;
    } else {
      text = '${difference}d left';
      color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEmptyState(String type) {
    String title;
    String message;
    String animationAsset;

    switch (type) {
      case 'today':
        title = 'No tasks for today';
        message = 'Great! You\'re all caught up for today.';
        animationAsset = AnimationAssets.successCheck;
        break;
      case 'overdue':
        title = 'No overdue tasks';
        message = 'Excellent! You\'re staying on top of your deadlines.';
        animationAsset = AnimationAssets.trophy;
        break;
      case 'completed':
        title = 'No completed tasks yet';
        message = 'Complete some tasks to see your achievements here.';
        animationAsset = AnimationAssets.motivationalBoost;
        break;
      default:
        title = 'No tasks yet';
        message = 'Create your first task to get started on your productivity journey.';
        animationAsset = AnimationAssets.gettingStarted;
    }

    return EmptyStateWidget(
      title: title,
      message: message,
      action: type == 'all'
          ? ElevatedButton.icon(
              onPressed: () => _showCreateTaskSheet(context),
              icon: const Icon(Icons.add),
              label: const Text('Create Task'),
            )
          : null,
    );
  }

  void _toggleTaskCompletion(dynamic task) async {
    final success = await ref.read(taskProvider.notifier).completeTask(task.id);
    
    if (success) {
      // Show celebration animation
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CelebrationAnimationWidget(
                onComplete: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 16),
              Text(
                'Task Completed!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Great job! You\'ve completed "${task.title}"',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
  }

  void _showCreateTaskSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateTaskBottomSheet(),
    );
  }

  void _showTaskDetails(BuildContext context, dynamic task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TaskDetailsBottomSheet(task: task),
    );
  }

  void _showSearchSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const TaskSearchBottomSheet(),
    );
  }

  void _showTaskAnalytics(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const TaskAnalyticsScreen(),
      ),
    );
  }
}

// Bottom sheet components
class CreateTaskBottomSheet extends ConsumerStatefulWidget {
  const CreateTaskBottomSheet({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateTaskBottomSheet> createState() => _CreateTaskBottomSheetState();
}

class _CreateTaskBottomSheetState extends ConsumerState<CreateTaskBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedCategory = 'Personal';
  String _selectedPriority = 'Medium';
  DateTime? _selectedDueDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    AnimatedWidget(
                      assetPath: AnimationAssets.taskComplete,
                      width: 30,
                      height: 30,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Create New Task',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Task Title',
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a task title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          prefixIcon: Icon(Icons.category),
                        ),
                        items: ['Personal', 'Work', 'Health', 'Learning', 'Other']
                            .map((category) => DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedPriority,
                        decoration: const InputDecoration(
                          labelText: 'Priority',
                          prefixIcon: Icon(Icons.flag),
                        ),
                        items: ['Low', 'Medium', 'High']
                            .map((priority) => DropdownMenuItem(
                                  value: priority,
                                  child: Text(priority),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedPriority = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => _selectDueDate(),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today),
                        const SizedBox(width: 12),
                        Text(
                          _selectedDueDate != null
                              ? 'Due: ${_formatDate(_selectedDueDate!)}'
                              : 'Set Due Date (Optional)',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _createTask,
                        child: const Text('Create Task'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      setState(() {
        _selectedDueDate = date;
      });
    }
  }

  void _createTask() async {
    if (_formKey.currentState!.validate()) {
      final taskData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'category': _selectedCategory,
        'priority': _selectedPriority.toLowerCase(),
        'due_date': _selectedDueDate?.toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      };

      final success = await ref.read(taskProvider.notifier).createTask(taskData);
      
      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class TaskDetailsBottomSheet extends StatelessWidget {
  final dynamic task;

  const TaskDetailsBottomSheet({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AnimatedWidget(
                    assetPath: AnimationAssets.taskProgress,
                    width: 30,
                    height: 30,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      task.title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (task.description?.isNotEmpty == true) ...[
                Text(
                  task.description!,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
              ],
              // Add more task details here
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Edit task functionality
                        Navigator.of(context).pop();
                      },
                      child: const Text('Edit Task'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TaskSearchBottomSheet extends StatelessWidget {
  const TaskSearchBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  AnimatedWidget(
                    assetPath: AnimationAssets.dataAnalytics,
                    width: 30,
                    height: 30,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Search Tasks',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Search tasks...',
                  prefixIcon: Icon(Icons.search),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class TaskAnalyticsScreen extends ConsumerWidget {
  const TaskAnalyticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskState = ref.watch(taskProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Analytics'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AnimatedWidget(
              assetPath: AnimationAssets.progressChart,
              width: 200,
              height: 150,
            ),
            const SizedBox(height: 24),
            Text(
              'Task Analytics',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Add analytics widgets here
          ],
        ),
      ),
    );
  }
}
