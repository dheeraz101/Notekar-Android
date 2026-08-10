class UserRankInfo {
  UserRankInfo({
    required this.rankTitle,
    required this.rankLevel,
    required this.currentXp,
    required this.nextLevelXp,
    required this.progressPercent,
    required this.badgeIconName,
  });

  final String rankTitle;
  final int rankLevel;
  final int currentXp;
  final int nextLevelXp;
  final double progressPercent;
  final String badgeIconName;
}

class UserRankService {
  static UserRankInfo calculateRank(int streakDays, int totalMoments) {
    final xp = (streakDays * 50) + (totalMoments * 10);

    if (streakDays >= 365) {
      return UserRankInfo(
        rankTitle: 'Titan Conqueror',
        rankLevel: 5,
        currentXp: xp,
        nextLevelXp: 50000,
        progressPercent: 1.0,
        badgeIconName: 'shield_max',
      );
    } else if (streakDays >= 90) {
      return UserRankInfo(
        rankTitle: 'Master Guardian',
        rankLevel: 4,
        currentXp: xp,
        nextLevelXp: 18250,
        progressPercent: ((streakDays - 90) / (365 - 90)).clamp(0.0, 1.0),
        badgeIconName: 'shield_master',
      );
    } else if (streakDays >= 30) {
      return UserRankInfo(
        rankTitle: 'Habit Conqueror',
        rankLevel: 3,
        currentXp: xp,
        nextLevelXp: 4500,
        progressPercent: ((streakDays - 30) / (90 - 30)).clamp(0.0, 1.0),
        badgeIconName: 'shield_conqueror',
      );
    } else if (streakDays >= 7) {
      return UserRankInfo(
        rankTitle: 'Streak Guardian',
        rankLevel: 2,
        currentXp: xp,
        nextLevelXp: 1500,
        progressPercent: ((streakDays - 7) / (30 - 7)).clamp(0.0, 1.0),
        badgeIconName: 'shield_guardian',
      );
    } else {
      return UserRankInfo(
        rankTitle: 'Novice Pioneer',
        rankLevel: 1,
        currentXp: xp,
        nextLevelXp: 350,
        progressPercent: (streakDays / 7).clamp(0.0, 1.0),
        badgeIconName: 'shield_novice',
      );
    }
  }
}
