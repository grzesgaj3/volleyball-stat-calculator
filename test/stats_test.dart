// Simple test for stats calculation logic without Flutter dependencies
import '../lib/models/stats.dart';

void main() {
  print('Testing volleyball statistics calculation...\n');

  // Test 1: ActionStats effectiveness calculation
  print('Test 1: ActionStats effectiveness calculation');
  final stats1 = ActionStats(plus: 10, minus: 5, star: 5);
  final effectiveness1 = stats1.effectiveness;
  assert(effectiveness1 == 75.0, 'Expected 75% effectiveness');
  print('  ✓ Effectiveness: ${effectiveness1.toStringAsFixed(1)}%');

  // Test 2: Zero stats should return 0% effectiveness
  print('\nTest 2: Zero stats effectiveness');
  final stats2 = ActionStats();
  final effectiveness2 = stats2.effectiveness;
  assert(effectiveness2 == 0.0, 'Expected 0% effectiveness');
  print('  ✓ Effectiveness: ${effectiveness2.toStringAsFixed(1)}%');

  // Test 3: PlayerStats tracking across sets
  print('\nTest 3: PlayerStats tracking across sets');
  final playerStats = PlayerStats(playerId: 'John Doe');
  
  // Add stats for Attack in set 1
  final attackSet1 = playerStats.getStats('Attack', 1);
  attackSet1.plus = 8;
  attackSet1.minus = 2;
  attackSet1.star = 2;
  
  // Add stats for Attack in set 2
  final attackSet2 = playerStats.getStats('Attack', 2);
  attackSet2.plus = 6;
  attackSet2.minus = 3;
  attackSet2.star = 1;
  
  // Calculate overall effectiveness for Attack
  final attackEffectiveness = playerStats.getActionEffectiveness('Attack');
  final expectedAttackEff = ((8 + 2 + 6 + 1) / (8 + 2 + 2 + 6 + 3 + 1)) * 100;
  assert((attackEffectiveness - expectedAttackEff).abs() < 0.01, 
         'Expected ${expectedAttackEff.toStringAsFixed(1)}% effectiveness');
  print('  ✓ Attack effectiveness across sets: ${attackEffectiveness.toStringAsFixed(1)}%');

  // Test 4: Overall player effectiveness
  print('\nTest 4: Overall player effectiveness');
  final serveSet1 = playerStats.getStats('Serve', 1);
  serveSet1.plus = 5;
  serveSet1.minus = 5;
  serveSet1.star = 0;
  
  final overallEff = playerStats.getOverallEffectiveness();
  final totalPlus = 8 + 6 + 5;
  final totalStar = 2 + 1 + 0;
  final totalAll = 8 + 2 + 2 + 6 + 3 + 1 + 5 + 5 + 0;
  final expectedOverallEff = ((totalPlus + totalStar) / totalAll) * 100;
  assert((overallEff - expectedOverallEff).abs() < 0.01,
         'Expected ${expectedOverallEff.toStringAsFixed(1)}% effectiveness');
  print('  ✓ Overall effectiveness: ${overallEff.toStringAsFixed(1)}%');

  // Test 5: Player with no stats
  print('\nTest 5: Player with no stats');
  final emptyPlayerStats = PlayerStats(playerId: 'Jane Doe');
  final emptyEff = emptyPlayerStats.getOverallEffectiveness();
  assert(emptyEff == 0.0, 'Expected 0% effectiveness');
  print('  ✓ Empty player effectiveness: ${emptyEff.toStringAsFixed(1)}%');

  print('\n✓ All tests passed!');
}
