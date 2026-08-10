class DailyWisdomEntry {
  const DailyWisdomEntry({
    required this.quote,
    required this.author,
    required this.category,
  });

  final String quote;
  final String author;
  final String category;
}

class DailyWisdomService {
  static const List<DailyWisdomEntry> _wisdomList = [
    DailyWisdomEntry(
      quote:
          'Neuroplasticity proves that your brain reshapes itself with every clean decision you make.',
      author: 'Dr. Andrew Huberman',
      category: 'Neuroscience',
    ),
    DailyWisdomEntry(
      quote:
          'Small daily disciplines repeated consistently lead to monumental lifetime transformations.',
      author: 'John C. Maxwell',
      category: 'Psychology',
    ),
    DailyWisdomEntry(
      quote:
          'Dopamine receptors begin significant upregulation after just 14 consecutive days of abstinence.',
      author: 'Dr. Anna Lembke',
      category: 'Dopamine Nation',
    ),
    DailyWisdomEntry(
      quote:
          'You do not rise to the level of your goals. You fall to the level of your systems.',
      author: 'James Clear',
      category: 'Atomic Habits',
    ),
    DailyWisdomEntry(
      quote:
          'Prefrontal cortex self-regulation strengthens like a muscle with each resisted trigger.',
      author: 'Dr. Nora Volkow',
      category: 'Neurobiology',
    ),
    DailyWisdomEntry(
      quote:
          'Freedom is the space between stimulus and response. In that space lies your power to choose.',
      author: 'Viktor Frankl',
      category: 'Mindfulness',
    ),
    DailyWisdomEntry(
      quote: 'Every streak day is a vote for the person you wish to become.',
      author: 'Behavioural Science',
      category: 'Growth',
    ),
  ];

  static DailyWisdomEntry getTodayWisdom() {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final index = dayOfYear % _wisdomList.length;
    return _wisdomList[index];
  }
}
