class ActionStats {
  int plus;
  int minus;
  int star;
  
  ActionStats({
    this.plus = 0,
    this.minus = 0,
    this.star = 0,
  });
  
  int get total => plus + minus + star;
  
  double get effectiveness {
    if (total == 0) return 0.0;
    return ((plus + star) / total) * 100;
  }
}

class PlayerStats {
  final String playerId;
  final Map<String, Map<int, ActionStats>> actionStatsBySet; // actionType -> set -> stats
  
  PlayerStats({
    required this.playerId,
  }) : actionStatsBySet = {};
  
  ActionStats getStats(String actionType, int set) {
    if (!actionStatsBySet.containsKey(actionType)) {
      actionStatsBySet[actionType] = {};
    }
    if (!actionStatsBySet[actionType]!.containsKey(set)) {
      actionStatsBySet[actionType]![set] = ActionStats();
    }
    return actionStatsBySet[actionType]![set]!;
  }
  
  double getActionEffectiveness(String actionType) {
    int totalPlus = 0;
    int totalMinus = 0;
    int totalStar = 0;
    
    if (actionStatsBySet.containsKey(actionType)) {
      for (var stats in actionStatsBySet[actionType]!.values) {
        totalPlus += stats.plus;
        totalMinus += stats.minus;
        totalStar += stats.star;
      }
    }
    
    int total = totalPlus + totalMinus + totalStar;
    if (total == 0) return 0.0;
    return ((totalPlus + totalStar) / total) * 100;
  }
  
  double getOverallEffectiveness() {
    int totalPlus = 0;
    int totalMinus = 0;
    int totalStar = 0;
    
    for (var actionMap in actionStatsBySet.values) {
      for (var stats in actionMap.values) {
        totalPlus += stats.plus;
        totalMinus += stats.minus;
        totalStar += stats.star;
      }
    }
    
    int total = totalPlus + totalMinus + totalStar;
    if (total == 0) return 0.0;
    return ((totalPlus + totalStar) / total) * 100;
  }
}
