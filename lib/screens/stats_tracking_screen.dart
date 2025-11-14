import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/stats.dart';
import 'statistics_screen.dart';

class StatsTrackingScreen extends StatefulWidget {
  final String matchTitle;
  final List<Player> players;

  const StatsTrackingScreen({
    super.key,
    required this.matchTitle,
    required this.players,
  });

  @override
  State<StatsTrackingScreen> createState() => _StatsTrackingScreenState();
}

class _StatsTrackingScreenState extends State<StatsTrackingScreen> {
  int _currentSet = 1;
  final Map<String, PlayerStats> _allStats = {};

  final List<String> _actionTypes = [
    'Attack',
    'Serve',
    'Block',
    'Reception',
    'Dig',
  ];

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
          // Header row with action types
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            color: Colors.grey.shade100,
            child: Row(
              children: [
                const SizedBox(
                  width: 80,
                  child: Text(
                    'Player',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                ..._actionTypes.map((action) => Expanded(
                      child: Center(
                        child: Text(
                          action,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )),
              ],
            ),
          ),
          const Divider(height: 1),
          // Players list
          Expanded(
            child: ListView.builder(
              itemCount: widget.players.length,
              itemBuilder: (context, index) {
                final player = widget.players[index];
                return _buildPlayerRow(player);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerRow(Player player) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Player info
          SizedBox(
            width: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '#${player.number}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  player.firstName[0] + '. ' + player.lastName,
                  style: const TextStyle(fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Action counters for each action type
          ..._actionTypes.map((actionType) {
            final stats = _allStats[player.fullName]!.getStats(actionType, _currentSet);
            return Expanded(
              child: _buildCompactCounter(player, actionType, stats),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCompactCounter(Player player, String actionType, ActionStats stats) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Plus counter
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () => _decrementStat(player, actionType, 'plus'),
                child: const Icon(Icons.remove_circle_outline, size: 14, color: Colors.green),
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 16),
                child: Text(
                  '${stats.plus}',
                  style: const TextStyle(fontSize: 11, color: Colors.green),
                  textAlign: TextAlign.center,
                ),
              ),
              InkWell(
                onTap: () => _incrementStat(player, actionType, 'plus'),
                child: const Icon(Icons.add_circle_outline, size: 14, color: Colors.green),
              ),
            ],
          ),
          // Minus counter
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () => _decrementStat(player, actionType, 'minus'),
                child: const Icon(Icons.remove_circle_outline, size: 14, color: Colors.red),
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 16),
                child: Text(
                  '${stats.minus}',
                  style: const TextStyle(fontSize: 11, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
              InkWell(
                onTap: () => _incrementStat(player, actionType, 'minus'),
                child: const Icon(Icons.add_circle_outline, size: 14, color: Colors.red),
              ),
            ],
          ),
          // Star counter
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () => _decrementStat(player, actionType, 'star'),
                child: const Icon(Icons.remove_circle_outline, size: 14, color: Colors.orange),
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 16),
                child: Text(
                  '${stats.star}',
                  style: const TextStyle(fontSize: 11, color: Colors.orange),
                  textAlign: TextAlign.center,
                ),
              ),
              InkWell(
                onTap: () => _incrementStat(player, actionType, 'star'),
                child: const Icon(Icons.add_circle_outline, size: 14, color: Colors.orange),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
