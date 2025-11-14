import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/player.dart';
import '../models/stats.dart';

class StatisticsScreen extends StatefulWidget {
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
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool _isExporting = false;

  Future<void> _exportToExcel() async {
    setState(() {
      _isExporting = true;
    });

    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Statistics'];

      // Add header row
      sheetObject.appendRow([
        const TextCellValue('Player'),
        const TextCellValue('Number'),
        const TextCellValue('Position'),
        const TextCellValue('Action Type'),
        const TextCellValue('Plus (+)'),
        const TextCellValue('Minus (-)'),
        const TextCellValue('Star (★)'),
        const TextCellValue('Total'),
        const TextCellValue('Effectiveness %'),
      ]);

      // Add data for each player and action
      for (var player in widget.players) {
        final stats = widget.allStats[player.fullName]!;
        final actionTypes = ['Attack', 'Serve', 'Block', 'Reception', 'Dig'];

        for (var actionType in actionTypes) {
          int totalPlus = 0;
          int totalMinus = 0;
          int totalStar = 0;

          if (stats.actionStatsBySet.containsKey(actionType)) {
            for (var actionStats in stats.actionStatsBySet[actionType]!.values) {
              totalPlus += actionStats.plus;
              totalMinus += actionStats.minus;
              totalStar += actionStats.star;
            }
          }

          final total = totalPlus + totalMinus + totalStar;
          final effectiveness = stats.getActionEffectiveness(actionType);

          sheetObject.appendRow([
            TextCellValue(player.fullName),
            IntCellValue(player.number),
            TextCellValue(player.position),
            TextCellValue(actionType),
            IntCellValue(totalPlus),
            IntCellValue(totalMinus),
            IntCellValue(totalStar),
            IntCellValue(total),
            DoubleCellValue(effectiveness),
          ]);
        }

        // Add overall effectiveness row
        final overallEff = stats.getOverallEffectiveness();
        int totalPlus = 0;
        int totalMinus = 0;
        int totalStar = 0;

        for (var actionMap in stats.actionStatsBySet.values) {
          for (var actionStats in actionMap.values) {
            totalPlus += actionStats.plus;
            totalMinus += actionStats.minus;
            totalStar += actionStats.star;
          }
        }

        sheetObject.appendRow([
          TextCellValue(player.fullName),
          IntCellValue(player.number),
          TextCellValue(player.position),
          const TextCellValue('OVERALL'),
          IntCellValue(totalPlus),
          IntCellValue(totalMinus),
          IntCellValue(totalStar),
          IntCellValue(totalPlus + totalMinus + totalStar),
          DoubleCellValue(overallEff),
        ]);
      }

      // Save file
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${widget.matchTitle.replaceAll(' ', '_')}_stats_$timestamp.xlsx';
      final filePath = '${directory.path}/$fileName';
      
      final fileBytes = excel.save();
      if (fileBytes != null) {
        File(filePath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(fileBytes);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Statistics exported to:\n$filePath'),
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'OK',
                onPressed: () {},
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        actions: [
          if (_isExporting)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.file_download),
              tooltip: 'Export to Excel',
              onPressed: _exportToExcel,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.matchTitle,
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
              ...widget.players.map((player) {
                final stats = widget.allStats[player.fullName]!;
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
