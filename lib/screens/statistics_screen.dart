import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/stats.dart';

class StatisticsScreen extends StatelessWidget {
  final String matchTitle;
  final List<Player> players;
  final Map<String, PlayerStats> allStats;

  const StatisticsScreen({
    super.key,
    required this.matchTitle,
    required this.players,
    required this.allStats,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                matchTitle,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Player Effectiveness Statistics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              ...players.map((player) {
                final stats = allStats[player.fullName]!;
                return _buildPlayerCard(player, stats);
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerCard(Player player, PlayerStats stats) {
    final overallEffectiveness = stats.getOverallEffectiveness();

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  child: Text(
                    '${player.number}',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        player.fullName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        player.position,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _getEffectivenessColor(overallEffectiveness),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${overallEffectiveness.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Action Breakdown:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...stats.actionStatsBySet.keys.map((actionType) {
              final effectiveness = stats.getActionEffectiveness(actionType);
              int totalPlus = 0;
              int totalMinus = 0;
              int totalStar = 0;

              for (var actionStats in stats.actionStatsBySet[actionType]!.values) {
                totalPlus += actionStats.plus;
                totalMinus += actionStats.minus;
                totalStar += actionStats.star;
              }

              final total = totalPlus + totalMinus + totalStar;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        actionType,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          Text(
                            '+$totalPlus',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '-$totalMinus',
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '★$totalStar',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '${effectiveness.toStringAsFixed(1)}% ($total)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _getEffectivenessColor(effectiveness),
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Color _getEffectivenessColor(double effectiveness) {
    if (effectiveness >= 70) {
      return Colors.green;
    } else if (effectiveness >= 50) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
