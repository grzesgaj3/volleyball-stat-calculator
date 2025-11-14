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
  int _selectedPlayerIndex = 0;
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

  void _incrementStat(String actionType, String statType) {
    setState(() {
      final player = widget.players[_selectedPlayerIndex];
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

  void _decrementStat(String actionType, String statType) {
    setState(() {
      final player = widget.players[_selectedPlayerIndex];
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
    final currentPlayer = widget.players[_selectedPlayerIndex];

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
          // Player selector
          Container(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(widget.players.length, (index) {
                  final player = widget.players[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text('#${player.number} ${player.fullName}'),
                      selected: _selectedPlayerIndex == index,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedPlayerIndex = index;
                          });
                        }
                      },
                    ),
                  );
                }),
              ),
            ),
          ),
          const Divider(),
          // Current player info
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Player: #${currentPlayer.number} ${currentPlayer.fullName} (${currentPlayer.position})',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(),
          // Action counters
          Expanded(
            child: ListView.builder(
              itemCount: _actionTypes.length,
              itemBuilder: (context, index) {
                final actionType = _actionTypes[index];
                final stats = _allStats[currentPlayer.fullName]!
                    .getStats(actionType, _currentSet);

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          actionType,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildCounter(
                              label: 'Plus (+)',
                              count: stats.plus,
                              color: Colors.green,
                              onIncrement: () =>
                                  _incrementStat(actionType, 'plus'),
                              onDecrement: () =>
                                  _decrementStat(actionType, 'plus'),
                            ),
                            _buildCounter(
                              label: 'Minus (-)',
                              count: stats.minus,
                              color: Colors.red,
                              onIncrement: () =>
                                  _incrementStat(actionType, 'minus'),
                              onDecrement: () =>
                                  _decrementStat(actionType, 'minus'),
                            ),
                            _buildCounter(
                              label: 'Star (★)',
                              count: stats.star,
                              color: Colors.orange,
                              onIncrement: () =>
                                  _incrementStat(actionType, 'star'),
                              onDecrement: () =>
                                  _decrementStat(actionType, 'star'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounter({
    required String label,
    required int count,
    required Color color,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              onPressed: onDecrement,
              icon: const Icon(Icons.remove_circle),
              color: color,
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            IconButton(
              onPressed: onIncrement,
              icon: const Icon(Icons.add_circle),
              color: color,
            ),
          ],
        ),
      ],
    );
  }
}
