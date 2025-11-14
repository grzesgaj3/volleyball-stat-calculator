import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import '../models/player.dart';
import 'stats_tracking_screen.dart';

class PlayerEntryScreen extends StatefulWidget {
  final String matchTitle;

  const PlayerEntryScreen({super.key, required this.matchTitle});

  @override
  State<PlayerEntryScreen> createState() => _PlayerEntryScreenState();
}

class _PlayerEntryScreenState extends State<PlayerEntryScreen> {
  final List<Player> _players = [];
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _numberController = TextEditingController();
  String _selectedPosition = 'Setter';

  final List<String> _positions = [
    'Setter',
    'Outside Hitter',
    'Middle Blocker',
    'Opposite',
    'Libero',
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  void _addPlayer() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _players.add(Player(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          number: int.parse(_numberController.text),
          position: _selectedPosition,
        ));
        _firstNameController.clear();
        _lastNameController.clear();
        _numberController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Player added')),
      );
    }
  }

  void _removePlayer(int index) {
    setState(() {
      _players.removeAt(index);
    });
  }

  Future<void> _importPlayersFromCSV() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final csvString = await file.readAsString();
        
        final List<List<dynamic>> rows = const CsvToListConverter().convert(csvString);
        
        int importedCount = 0;
        List<String> errors = [];
        
        for (int i = 0; i < rows.length; i++) {
          final row = rows[i];
          
          // Skip empty rows
          if (row.isEmpty || row.every((cell) => cell.toString().trim().isEmpty)) {
            continue;
          }
          
          // Validate row format: firstname,lastname,position,number
          if (row.length < 4) {
            errors.add('Row ${i + 1}: Not enough columns (expected 4: firstname, lastname, position, number)');
            continue;
          }
          
          try {
            final firstName = row[0].toString().trim();
            final lastName = row[1].toString().trim();
            final position = row[2].toString().trim();
            final numberStr = row[3].toString().trim();
            
            if (firstName.isEmpty || lastName.isEmpty || position.isEmpty || numberStr.isEmpty) {
              errors.add('Row ${i + 1}: Empty values not allowed');
              continue;
            }
            
            final number = int.tryParse(numberStr);
            if (number == null) {
              errors.add('Row ${i + 1}: Invalid number "$numberStr"');
              continue;
            }
            
            // Validate position
            if (!_positions.contains(position)) {
              errors.add('Row ${i + 1}: Invalid position "$position". Valid positions: ${_positions.join(", ")}');
              continue;
            }
            
            setState(() {
              _players.add(Player(
                firstName: firstName,
                lastName: lastName,
                number: number,
                position: position,
              ));
            });
            importedCount++;
          } catch (e) {
            errors.add('Row ${i + 1}: Error - $e');
          }
        }
        
        // Show result dialog
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Import Complete'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Successfully imported $importedCount player(s)'),
                    if (errors.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text('Errors:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...errors.map((error) => Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text(error, style: const TextStyle(fontSize: 12, color: Colors.red)),
                      )),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error importing CSV: $e')),
        );
      }
    }
  }

  void _proceedToStats() {
    if (_players.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one player')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StatsTrackingScreen(
          matchTitle: widget.matchTitle,
          players: _players,
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
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: 'Import from CSV',
            onPressed: _importPlayersFromCSV,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Add Players',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _firstNameController,
                          decoration: const InputDecoration(
                            labelText: 'First Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _lastNameController,
                          decoration: const InputDecoration(
                            labelText: 'Last Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _numberController,
                          decoration: const InputDecoration(
                            labelText: 'Number',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Invalid number';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedPosition,
                          decoration: const InputDecoration(
                            labelText: 'Position',
                            border: OutlineInputBorder(),
                          ),
                          items: _positions.map((String position) {
                            return DropdownMenuItem<String>(
                              value: position,
                              child: Text(position),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedPosition = newValue!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _addPlayer,
                    child: const Text('Add Player'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const Text(
              'Players',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: _players.isEmpty
                  ? const Center(
                      child: Text('No players added yet'),
                    )
                  : ListView.builder(
                      itemCount: _players.length,
                      itemBuilder: (context, index) {
                        final player = _players[index];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text('${player.number}'),
                            ),
                            title: Text(player.fullName),
                            subtitle: Text(player.position),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _removePlayer(index),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _proceedToStats,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'Next - Track Statistics',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
