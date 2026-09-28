class DummyData {
  static final List<Map<String, dynamic>> stories = [
    {'username': 'elonmusk', 'unseen': true},
    {'username': 'spacex', 'unseen': true},
    {'username': 'nasa', 'unseen': false},
    {'username': 'flutterdev', 'unseen': true},
    {'username': 'google', 'unseen': true},
    {'username': 'apple', 'unseen': false},
    {'username': 'tesla', 'unseen': true},
  ];

  static final List<Map<String, dynamic>> posts = [
    {
      'username': 'everydayastronaut',
      'location': 'Starbase, TX',
      'likes': '44.6K',
      'comments': 1284,
      'caption': 'Watch the FIRST Orbital Starship Mission!!! 🚀',
      'time': '2 hours ago',
    },
    {
      'username': 'nasaspaceflight',
      'location': null,
      'likes': '51.3K',
      'comments': 2103,
      'caption': 'SpaceX Starship Flight 14 - Launch & Booster Splashdown',
      'time': '5 hours ago',
    },
    {
      'username': 'spacex',
      'location': 'Boca Chica',
      'likes': '1.2M',
      'comments': 45210,
      'caption': 'Starship is ready for the next flight test',
      'time': '1 day ago',
    },
    {
      'username': 'flutterdev',
      'location': null,
      'likes': '8.9K',
      'comments': 342,
      'caption': 'Building beautiful UIs with Flutter 💙',
      'time': '2 days ago',
    },
  ];

  static final List<Map<String, dynamic>> reels = [
    {
      'username': 'everydayastronaut',
      'caption': '[4K] Watch the FIRST Orbital Starship Mission!!!',
      'likes': '44.6K',
      'comments': '1.2K',
    },
    {
      'username': 'nasaspaceflight',
      'caption': 'SpaceX Starship Flight 14 - LAUNCH STREAM',
      'likes': '51.3K',
      'comments': '2.1K',
    },
    {
      'username': 'spacex',
      'caption': 'Starship static fire test',
      'likes': '890K',
      'comments': '12K',
    },
    {
      'username': 'tesla',
      'caption': 'Cybertruck delivery event',
      'likes': '1.1M',
      'comments': '34K',
    },
  ];

  static final List<Map<String, dynamic>> chats = [
    {
      'username': 'elonmusk',
      'lastMessage': 'Want to hop on a call?',
      'time': '2m',
      'unread': true,
      'avatar': null,
    },
    {
      'username': 'flutterdev',
      'lastMessage': 'Check the new Riverpod update',
      'time': '1h',
      'unread': false,
      'avatar': null,
    },
    {
      'username': 'spacex',
      'lastMessage': 'Launch window is open',
      'time': '3h',
      'unread': true,
      'avatar': null,
    },
    {
      'username': 'nasa',
      'lastMessage': 'Thanks for the collaboration!',
      'time': '1d',
      'unread': false,
      'avatar': null,
    },
  ];
}
