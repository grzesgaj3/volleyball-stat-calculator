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
              children: [
                CircleAvatar(
                  radius: 16,
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
                      Text(
                        player.position,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Action counters in grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _actionTypes.length,
              itemBuilder: (context, index) {
                final actionType = _actionTypes[index];
                final stats = _allStats[player.fullName]!.getStats(actionType, _currentSet);
                return _buildActionCard(player, actionType, stats);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(Player player, String actionType, ActionStats stats) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Action type label
          Text(
            actionType,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Plus counter with icon
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () => _decrementStat(player, actionType, 'plus'),
                child: const Icon(Icons.remove_circle, size: 18, color: Colors.green),
              ),
              const SizedBox(width: 4),
              Container(
                constraints: const BoxConstraints(minWidth: 20),
                child: Text(
                  '${stats.plus}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: () => _incrementStat(player, actionType, 'plus'),
                child: const Icon(Icons.add_circle, size: 18, color: Colors.green),
              ),
            ],
          ),
          // Minus counter with icon
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () => _decrementStat(player, actionType, 'minus'),
                child: const Icon(Icons.remove_circle, size: 18, color: Colors.red),
              ),
              const SizedBox(width: 4),
              Container(
                constraints: const BoxConstraints(minWidth: 20),
                child: Text(
                  '${stats.minus}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: () => _incrementStat(player, actionType, 'minus'),
                child: const Icon(Icons.add_circle, size: 18, color: Colors.red),
              ),
            ],
          ),
          // Star counter with icon
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () => _decrementStat(player, actionType, 'star'),
                child: const Icon(Icons.remove_circle, size: 18, color: Colors.orange),
              ),
              const SizedBox(width: 4),
              Container(
                constraints: const BoxConstraints(minWidth: 20),
                child: Text(
                  '${stats.star}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: () => _incrementStat(player, actionType, 'star'),
                child: const Icon(Icons.star, size: 18, color: Colors.orange),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
