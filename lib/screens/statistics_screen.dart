import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'dart:typed_data';
import '../utils/file_saver.dart';
import '../models/player.dart';
import '../models/stats.dart';
import '../i18n.dart';

class StatisticsScreen extends StatefulWidget {
  final String matchTitle;
  final List<Player> players;
  final Map<String, PlayerStats> allStats;
  final String language;

  const StatisticsScreen({
    super.key,
    required this.matchTitle,
    required this.players,
    required this.allStats,
    required this.language,
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

      // Build header row to match the provided form (grouped columns flattened)
      sheetObject.appendRow([
        TextCellValue('Zawodnik'), // Player
        TextCellValue('Suma punktów'),
        TextCellValue('Przyjęcie - Perfekcyjne'),
        TextCellValue('Przyjęcie - %'),
        TextCellValue('Przyjęcie - Pozytywne'),
        TextCellValue('Przyjęcie - %'),
        TextCellValue('Przyjęcie - Negatywne'),
        TextCellValue('Przyjęcie - Ilość prób'),
        TextCellValue('Atak - Punktowy'),
        TextCellValue('Atak - %'),
        TextCellValue('Atak - Ilość prób'),
        TextCellValue('Zagrywka - As'),
        TextCellValue('Zagrywka - Błąd'),
        TextCellValue('Zagrywka - Ilość prób'),
        TextCellValue('Blok - Punktowy'),
        TextCellValue('Blok - Pasywny'),
        TextCellValue('Obrona'),
        TextCellValue('Asekuracja'),
      ]);

      // Accumulators for summary row
      final totals = List<int>.filled(18, 0);

      // Helper to sum stats across sets for an action
      int sumPlus(PlayerStats s, String action) {
        int acc = 0;
        if (s.actionStatsBySet.containsKey(action)) {
          for (var st in s.actionStatsBySet[action]!.values) acc += st.plus;
        }
        return acc;
      }

      int sumMinus(PlayerStats s, String action) {
        int acc = 0;
        if (s.actionStatsBySet.containsKey(action)) {
          for (var st in s.actionStatsBySet[action]!.values) acc += st.minus;
        }
        return acc;
      }

      int sumStar(PlayerStats s, String action) {
        int acc = 0;
        if (s.actionStatsBySet.containsKey(action)) {
          for (var st in s.actionStatsBySet[action]!.values) acc += st.star;
        }
        return acc;
      }

      for (var player in widget.players) {
        final stats = widget.allStats[player.fullName]!;

        // Map action names used in app -> columns
        final receptionTotalPlus = sumPlus(stats, 'Reception'); // treated as 'Perfekcyjne'
        final receptionTotalStar = sumStar(stats, 'Reception'); // treated as 'Pozytywne'
        final receptionTotalMinus = sumMinus(stats, 'Reception'); // 'Negatywne'
        final receptionAttempts = receptionTotalPlus + receptionTotalStar + receptionTotalMinus;

        final attackPoints = sumPlus(stats, 'Attack');
        final attackStar = sumStar(stats, 'Attack');
        final attackMinus = sumMinus(stats, 'Attack');
        final attackAttempts = attackPoints + attackStar + attackMinus;
        final attackEffectiveness = attackAttempts == 0 ? 0.0 : ((attackPoints + attackStar) / attackAttempts) * 100;

        final serveAces = sumPlus(stats, 'Serve');
        final serveErrors = sumMinus(stats, 'Serve');
        final serveAttempts = serveAces + serveErrors + sumStar(stats, 'Serve');

        final blockPoints = sumPlus(stats, 'Block');
        final blockPassive = sumStar(stats, 'Block');

        final defense = sumPlus(stats, 'Dig');
        final coverage = sumStar(stats, 'Dig');

        // Suma punktów: approximate as attack points + serve aces + block points
        final totalPoints = attackPoints + serveAces + blockPoints;

        // Reception percent and positive percent: compute as (plus/attempts)*100 etc.
        final receptionPercent = receptionAttempts == 0 ? 0.0 : (receptionTotalPlus / receptionAttempts) * 100;
        final receptionPositivePercent = receptionAttempts == 0 ? 0.0 : (receptionTotalStar / receptionAttempts) * 100;

        // Append the row
        sheetObject.appendRow([
          TextCellValue(player.fullName),
          IntCellValue(totalPoints),
          IntCellValue(receptionTotalPlus),
          DoubleCellValue(receptionPercent),
          IntCellValue(receptionTotalStar),
          DoubleCellValue(receptionPositivePercent),
          IntCellValue(receptionTotalMinus),
          IntCellValue(receptionAttempts),
          IntCellValue(attackPoints),
          DoubleCellValue(attackEffectiveness),
          IntCellValue(attackAttempts),
          IntCellValue(serveAces),
          IntCellValue(serveErrors),
          IntCellValue(serveAttempts),
          IntCellValue(blockPoints),
          IntCellValue(blockPassive),
          IntCellValue(defense),
          IntCellValue(coverage),
        ]);

        // Update totals (indices correspond to header columns)
        totals[0] += 0; // placeholder for player name (not numeric)
        totals[1] += totalPoints;
        totals[2] += receptionTotalPlus;
        // 3 is percent - not aggregated as sum; we'll compute later
        totals[4] += receptionTotalStar;
        // 5 percent skip
        totals[6] += receptionTotalMinus;
        totals[7] += receptionAttempts;
        totals[8] += attackPoints;
        // 9 percent skip
        totals[10] += attackAttempts;
        totals[11] += serveAces;
        totals[12] += serveErrors;
        totals[13] += serveAttempts;
        totals[14] += blockPoints;
        totals[15] += blockPassive;
        totals[16] += defense;
        totals[17] += coverage;
      }

      // Build summary/footer row (compute percents where appropriate)
      final summaryReceptionPercent = totals[7] == 0 ? 0.0 : (totals[2] / totals[7]) * 100;
      final summaryReceptionPositivePercent = totals[7] == 0 ? 0.0 : (totals[4] / totals[7]) * 100;
      final summaryAttackPercent = totals[10] == 0 ? 0.0 : (totals[8] + 0 /*stars unknown aggregated separately*/ ) / totals[10] * 100;

      sheetObject.appendRow([
        TextCellValue('Podsumowanie'),
        IntCellValue(totals[1]),
        IntCellValue(totals[2]),
        DoubleCellValue(summaryReceptionPercent),
        IntCellValue(totals[4]),
        DoubleCellValue(summaryReceptionPositivePercent),
        IntCellValue(totals[6]),
        IntCellValue(totals[7]),
        IntCellValue(totals[8]),
        DoubleCellValue(summaryAttackPercent),
        IntCellValue(totals[10]),
        IntCellValue(totals[11]),
        IntCellValue(totals[12]),
        IntCellValue(totals[13]),
        IntCellValue(totals[14]),
        IntCellValue(totals[15]),
        IntCellValue(totals[16]),
        IntCellValue(totals[17]),
      ]);

      // Save file (platform-aware)
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${widget.matchTitle.replaceAll(' ', '_')}_stats_$timestamp.xlsx';

      final fileBytes = excel.save();
      if (fileBytes != null) {
        final bytes = Uint8List.fromList(fileBytes);
        final savedPath = await saveFile(bytes, fileName);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(savedPath != null
                  ? 'Statistics exported to:\n$savedPath'
                  : 'Statistics exported (download started)'),
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
                        // localized position
                        I18n.t(widget.language, 'position_' + player.position.toLowerCase().replaceAll(RegExp(r"[^a-z0-9]+"), '_')),
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
                        // localized action name
                        I18n.t(widget.language, 'action_' + actionType.toLowerCase().replaceAll(RegExp(r"[^a-z0-9]+"), '_')),
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
