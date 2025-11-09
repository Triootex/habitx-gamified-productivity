class ReadingConstants {
  // Book Genres
  static const List<Map<String, dynamic>> bookGenres = [
    {'name': 'Fiction', 'color': '#E74C3C', 'icon': 'auto_stories'},
    {'name': 'Non-Fiction', 'color': '#3498DB', 'icon': 'fact_check'},
    {'name': 'Mystery', 'color': '#9B59B6', 'icon': 'search'},
    {'name': 'Romance', 'color': '#E91E63', 'icon': 'favorite'},
    {'name': 'Sci-Fi', 'color': '#00BCD4', 'icon': 'rocket_launch'},
    {'name': 'Fantasy', 'color': '#4CAF50', 'icon': 'auto_fix_high'},
    {'name': 'Biography', 'color': '#FF9800', 'icon': 'person'},
    {'name': 'Self-Help', 'color': '#795548', 'icon': 'psychology'},
    {'name': 'Business', 'color': '#607D8B', 'icon': 'business'},
    {'name': 'History', 'color': '#8BC34A', 'icon': 'history'},
  ];
  
  // Reading Status
  static const String toRead = 'to_read';
  static const String currentlyReading = 'currently_reading';
  static const String finished = 'finished';
  static const String paused = 'paused';
  static const String abandoned = 'abandoned';
  
  // Book Formats
  static const String physical = 'physical';
  static const String ebook = 'ebook';
  static const String audiobook = 'audiobook';
  static const String pdf = 'pdf';
  
  // Community Shelf Types
  static const List<Map<String, dynamic>> communityShelfTypes = [
    {
      'type': 'genre_based',
      'name': 'Genre Collections',
      'description': 'Organize books by genre',
      'examples': ['Mystery Lovers', 'Sci-Fi Adventures', 'Romance Reads']
    },
    {
      'type': 'mood_based',
      'name': 'Mood Collections',
      'description': 'Books organized by reading mood',
      'examples': ['Feel Good Books', 'Rainy Day Reads', 'Beach Reads']
    },
    {
      'type': 'theme_based',
      'name': 'Thematic Collections',
      'examples': ['Leadership Books', 'Travel Stories', 'Coming of Age']
    },
    {
      'type': 'author_based',
      'name': 'Author Collections',
      'description': 'Collections focused on specific authors',
      'examples': ['Agatha Christie Collection', 'Stephen King Universe']
    },
  ];
  
  // Reading Challenges
  static const List<Map<String, dynamic>> readingChallenges = [
    {
      'name': '52 Books in a Year',
      'description': 'Read one book per week for a year',
      'target': 52,
      'duration': 365,
      'reward_xp': 1000,
      'difficulty': 'hard'
    },
    {
      'name': 'Genre Explorer',
      'description': 'Read at least one book from 10 different genres',
      'target': 10,
      'duration': 90,
      'reward_xp': 500,
      'difficulty': 'medium'
    },
    {
      'name': 'Speed Reader',
      'description': 'Read 5 books in one month',
      'target': 5,
      'duration': 30,
      'reward_xp': 300,
      'difficulty': 'hard'
    },
    {
      'name': 'Classic Literature',
      'description': 'Read 12 classic books',
      'target': 12,
      'duration': 180,
      'reward_xp': 600,
      'difficulty': 'medium'
    },
  ];
  
  // Mood-Based Recommendations
  static const Map<String, List<Map<String, dynamic>>> moodBasedBooks = {
    'happy': [
      {'mood_score': 0.9, 'genres': ['comedy', 'feel_good', 'adventure']},
      {'characteristics': ['upbeat', 'positive', 'inspiring', 'light_hearted']},
    ],
    'sad': [
      {'mood_score': 0.3, 'genres': ['drama', 'literary_fiction', 'poetry']},
      {'characteristics': ['emotional', 'cathartic', 'profound', 'healing']},
    ],
    'stressed': [
      {'mood_score': 0.4, 'genres': ['self_help', 'mindfulness', 'short_stories']},
      {'characteristics': ['calming', 'brief', 'practical', 'soothing']},
    ],
    'curious': [
      {'mood_score': 0.8, 'genres': ['non_fiction', 'science', 'biography']},
      {'characteristics': ['informative', 'educational', 'thought_provoking']},
    ],
    'adventurous': [
      {'mood_score': 0.9, 'genres': ['adventure', 'fantasy', 'thriller']},
      {'characteristics': ['exciting', 'fast_paced', 'escapist', 'immersive']},
    ],
  };
  
  // Reading Progress Timers
  static const List<Map<String, dynamic>> progressTimers = [
    {
      'type': 'session_timer',
      'name': 'Reading Session',
      'description': 'Track continuous reading time',
      'default_duration': 25, // Pomodoro technique
      'break_duration': 5,
    },
    {
      'type': 'daily_goal',
      'name': 'Daily Reading Goal',
      'description': 'Set daily reading time targets',
      'default_duration': 30,
      'flexibility': 'adjustable',
    },
    {
      'type': 'book_completion',
      'name': 'Book Completion Timer',
      'description': 'Estimate time to finish current book',
      'calculation': 'pages_remaining / reading_speed',
    },
  ];
  
  // Reading Statistics
  static const List<String> readingMetrics = [
    'books_completed',
    'pages_read',
    'reading_time_hours',
    'average_reading_speed', // pages per hour
    'genres_explored',
    'authors_discovered',
    'reading_streak_days',
    'monthly_completion_rate',
  ];
  
  // Book Discovery Methods
  static const List<Map<String, dynamic>> discoveryMethods = [
    {
      'method': 'ai_recommendations',
      'name': 'AI Recommendations',
      'description': 'Books suggested based on reading history and preferences',
      'accuracy': 0.85,
    },
    {
      'method': 'friend_recommendations',
      'name': 'Friend Suggestions',
      'description': 'Books recommended by friends with similar tastes',
      'social_aspect': true,
    },
    {
      'method': 'trending_books',
      'name': 'Trending Now',
      'description': 'Currently popular books in your preferred genres',
      'real_time': true,
    },
    {
      'method': 'award_winners',
      'name': 'Award Winners',
      'description': 'Books that have won literary awards',
      'quality_assured': true,
    },
  ];
  
  // Reading Environments
  static const List<Map<String, dynamic>> readingEnvironments = [
    {
      'name': 'Cozy Library',
      'ambiance': 'quiet',
      'lighting': 'warm',
      'sounds': ['page_turning', 'soft_whispers', 'clock_ticking'],
    },
    {
      'name': 'Coffee Shop',
      'ambiance': 'bustling',
      'lighting': 'bright',
      'sounds': ['coffee_brewing', 'chatter', 'jazz_music'],
    },
    {
      'name': 'Nature Retreat',
      'ambiance': 'peaceful',
      'lighting': 'natural',
      'sounds': ['birds_chirping', 'leaves_rustling', 'stream_flowing'],
    },
    {
      'name': 'Rainy Day',
      'ambiance': 'cozy',
      'lighting': 'dim',
      'sounds': ['rain_drops', 'thunder', 'fireplace_crackling'],
    },
  ];
  
  // Book Rating System
  static const Map<String, Map<String, dynamic>> ratingCriteria = {
    'overall': {
      'name': 'Overall Rating',
      'scale': 5,
      'description': 'General enjoyment and recommendation',
    },
    'plot': {
      'name': 'Plot/Story',
      'scale': 5,
      'description': 'Storyline engagement and pacing',
    },
    'characters': {
      'name': 'Characters',
      'scale': 5,
      'description': 'Character development and relatability',
    },
    'writing_style': {
      'name': 'Writing Style',
      'scale': 5,
      'description': 'Quality of prose and readability',
    },
    'educational_value': {
      'name': 'Educational Value',
      'scale': 5,
      'description': 'Knowledge gained from reading',
    },
  };
  
  // Reading Goals
  static const List<Map<String, dynamic>> goalTypes = [
    {
      'type': 'books_per_year',
      'name': 'Annual Book Goal',
      'description': 'Number of books to read this year',
      'default_target': 12,
      'tracking': 'count',
    },
    {
      'type': 'pages_per_day',
      'name': 'Daily Page Goal',
      'description': 'Number of pages to read daily',
      'default_target': 20,
      'tracking': 'pages',
    },
    {
      'type': 'minutes_per_day',
      'name': 'Daily Reading Time',
      'description': 'Minutes of reading per day',
      'default_target': 30,
      'tracking': 'time',
    },
    {
      'type': 'genre_diversity',
      'name': 'Genre Exploration',
      'description': 'Number of different genres to explore',
      'default_target': 5,
      'tracking': 'categories',
    },
  ];
  
  // Book Series Tracking
  static const Map<String, dynamic> seriesTracking = {
    'auto_detect': true,
    'progress_indicators': ['current_book', 'books_remaining', 'completion_percentage'],
    'notification_types': ['new_release', 'series_completion'],
  };
  
  // Social Features
  static const List<Map<String, dynamic>> socialFeatures = [
    {
      'feature': 'book_clubs',
      'name': 'Book Clubs',
      'description': 'Join or create reading groups',
      'max_members': 50,
    },
    {
      'feature': 'reading_buddies',
      'name': 'Reading Buddies',
      'description': 'Pair up with friends for accountability',
      'max_buddies': 5,
    },
    {
      'feature': 'discussion_forums',
      'name': 'Book Discussions',
      'description': 'Discuss books with other readers',
      'moderation': true,
    },
    {
      'feature': 'quotes_sharing',
      'name': 'Quote Sharing',
      'description': 'Share favorite quotes and passages',
      'character_limit': 500,
    },
  ];
  
  // Reading Speed Calculation
  static const Map<String, int> averageReadingSpeeds = {
    'elementary_student': 200, // words per minute
    'high_school_student': 250,
    'college_student': 300,
    'adult_average': 250,
    'speed_reader': 500,
    'professional_reader': 800,
  };
  
  // Book Source Integration
  static const List<Map<String, dynamic>> bookSources = [
    {'name': 'Goodreads', 'type': 'social', 'api_available': true},
    {'name': 'Open Library', 'type': 'public', 'api_available': true},
    {'name': 'Google Books', 'type': 'commercial', 'api_available': true},
    {'name': 'Amazon', 'type': 'commercial', 'api_available': false},
    {'name': 'Local Library', 'type': 'physical', 'api_available': false},
  ];
  
  // Notification Types
  static const String readingReminder = 'reading_reminder';
  static const String goalProgress = 'goal_progress';
  static const String bookRecommendation = 'book_recommendation';
  static const String friendActivity = 'friend_activity';
  static const String challengeUpdate = 'challenge_update';
  static const String newRelease = 'new_release';
  
  // Limits and Validations
  static const int maxBooksPerShelf = 1000;
  static const int maxShelvesPerUser = 50;
  static const int maxBookTitleLength = 200;
  static const int maxReviewLength = 5000;
  static const int maxQuoteLength = 1000;
  static const int maxReadingSessionHours = 12;
  static const int minReadingSessionMinutes = 1;
}
