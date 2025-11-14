import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/stats.dart';
import '../i18n.dart';
import 'statistics_screen.dart';

class StatsTrackingScreen extends StatefulWidget {
  final String matchTitle;
  final List<Player> players;
  final String language;

  const StatsTrackingScreen({
    super.key,
    required this.matchTitle,
    required this.players,
    required this.language,
  });

  @override
  State<StatsTrackingScreen> createState() => _StatsTrackingScreenState();
}

class _StatsTrackingScreenState extends State<StatsTrackingScreen> {
  int _currentSet = 1;
  final Map<String, PlayerStats> _allStats = {};

  // Actions available per position. Adjust as needed.
  final Map<String, List<String>> _positionActionMap = {
    'Setter': ['Serve', 'Set', 'Reception', 'Dig'],
    'Outside Hitter': ['Serve', 'Attack', 'Reception', 'Dig'],
    'Middle Blocker': ['Serve', 'Block', 'Attack'],
    'Opposite': ['Serve', 'Attack', 'Block'],
    'Libero': ['Reception', 'Dig'],
  };

  List<String> _getActionsForPosition(String position) {
    return _positionActionMap[position] ?? ['Attack', 'Serve', 'Block', 'Reception', 'Dig'];
  }

  // Helper to make a stable key for lookup in I18n (e.g., "Outside Hitter" -> "outside_hitter")
  String _keyFromLabel(String label) {
    return label.toLowerCase().replaceAll(RegExp(r"[^a-z0-9]+"), '_');
  }

  String _localizedPosition(String position) {
    final key = 'position_' + _keyFromLabel(position);
    return I18n.t(widget.language, key);
  }

  String _localizedAction(String action) {
    final key = 'action_' + _keyFromLabel(action);
    return I18n.t(widget.language, key);
  }

  @override
  void initState() {
    super.initState();
    for (var player in widget.players) {
      _allStats[player.fullName] = PlayerStats(playerId: player.fullName);
    }
  }

  void _incrementStat(Player player, String actionType, String statType) {
    setState(() {
      final stats = _allStats[player.fullName]!.getStats(actionType, _currentSet);
      
      switch (statType) {
        case 'plus':
          stats.plus++;
          break;
        case 'minus':
          stats.minus++;
          break;
        case 'star':
          stats.star++;
          break;
      }
    });
  }

  void _decrementStat(Player player, String actionType, String statType) {
    setState(() {
      final stats = _allStats[player.fullName]!.getStats(actionType, _currentSet);
      
      switch (statType) {
        case 'plus':
          if (stats.plus > 0) stats.plus--;
          break;
        case 'minus':
          if (stats.minus > 0) stats.minus--;
          break;
        case 'star':
          if (stats.star > 0) stats.star--;
          break;
      }
    });
  }

  void _proceedToStatistics() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StatisticsScreen(
          matchTitle: widget.matchTitle,
          players: widget.players,
          allStats: _allStats,
          language: widget.language,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.matchTitle),
        actions: [
          TextButton(
            onPressed: _proceedToStatistics,
            child: const Text(
              'View Statistics',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Set selector
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.blue.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Set: ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ...List.generate(5, (index) {
                  final setNum = index + 1;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text('$setNum'),
                      selected: _currentSet == setNum,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _currentSet = setNum;
                          });
                        }
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          const Divider(height: 1),
          // Players grid
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                int crossAxisCount = 1;
                if (width >= 1400) {
                  crossAxisCount = 4;
                } else if (width >= 1000) {
                  crossAxisCount = 3;
                } else if (width >= 600) {
                  crossAxisCount = 2;
                } else {
                  crossAxisCount = 1;
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 1.0,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: widget.players.length,
                  itemBuilder: (context, index) {
                    final player = widget.players[index];
                    return _buildPlayerCard(player);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCard(Player player) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Player header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.blue,
                  child: Text(
                    '${player.number}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${player.firstName} ${player.lastName}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Text(
                  _localizedPosition(player.position),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Action boxes — show all actions (no internal scrolling)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _getActionsForPosition(player.position).map((actionType) {
                  final stats = _allStats[player.fullName]!.getStats(actionType, _currentSet);
                  return _buildActionTile(player, actionType, stats);
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Color _actionColor(String actionType) {
    final key = actionType.toLowerCase();
    if (key.contains('recept') || key.contains('przyj')) return Colors.green.shade100;
    if (key.contains('block') || key.contains('blok')) return Colors.red.shade100;
    if (key.contains('attack') || key.contains('atak')) return Colors.orange.shade100;
    if (key.contains('serve') || key.contains('zagryw') || key.contains('zagr')) return Colors.blue.shade100;
    if (key.contains('set') || key.contains('rozeg')) return Colors.purple.shade100;
    return Colors.grey.shade100;
  }

  Widget _buildActionTile(Player player, String actionType, ActionStats stats) {
    final bg = _actionColor(actionType);
    return Container(
      constraints: const BoxConstraints(minWidth: 140, maxWidth: 220),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _localizedAction(actionType),
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[800]),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => _decrementStat(player, actionType, 'plus'),
                        child: const Icon(Icons.remove_circle, size: 18, color: Colors.green),
                      ),
                      const SizedBox(width: 6),
                      Text('${stats.plus}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green)),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => _incrementStat(player, actionType, 'plus'),
                        child: const Icon(Icons.add_circle, size: 18, color: Colors.green),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => _decrementStat(player, actionType, 'minus'),
                        child: const Icon(Icons.remove_circle, size: 18, color: Colors.red),
                      ),
                      const SizedBox(width: 6),
                      Text('${stats.minus}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red)),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => _incrementStat(player, actionType, 'minus'),
                        child: const Icon(Icons.add_circle, size: 18, color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => _decrementStat(player, actionType, 'star'),
                        child: const Icon(Icons.remove_circle, size: 18, color: Colors.orange),
                      ),
                      const SizedBox(width: 6),
                      Text('${stats.star}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.orange)),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => _incrementStat(player, actionType, 'star'),
                        child: const Icon(Icons.star, size: 18, color: Colors.orange),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
 
}
