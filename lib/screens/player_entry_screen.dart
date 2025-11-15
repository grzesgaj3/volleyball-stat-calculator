import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'dart:convert';

import '../models/player.dart';
import '../i18n.dart';
import 'stats_tracking_screen.dart';

class PlayerEntryScreen extends StatefulWidget {
	final String matchTitle;
	final String language;

	const PlayerEntryScreen({super.key, required this.matchTitle, required this.language});

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
					firstName: _firstNameController.text.trim(),
					lastName: _lastNameController.text.trim(),
					number: int.parse(_numberController.text.trim()),
					position: _selectedPosition,
				));
				_firstNameController.clear();
				_lastNameController.clear();
				_numberController.clear();
			});
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(content: Text(I18n.t(widget.language, 'player_added'))),
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

			if (result != null) {
				final picked = result.files.single;

				String csvString;

				if (kIsWeb) {
					final bytes = picked.bytes;
					if (bytes == null) throw Exception('No file bytes available');
					csvString = const Utf8Decoder().convert(bytes);
				} else {
					if (picked.path == null) throw Exception('Selected file has no path');
					final file = File(picked.path!);
					csvString = await file.readAsString();
				}

				final List<List<dynamic>> rows = const CsvToListConverter().convert(csvString);

				int importedCount = 0;
				List<String> errors = [];

				for (int i = 0; i < rows.length; i++) {
					final row = rows[i];

					if (row.isEmpty || row.every((cell) => cell.toString().trim().isEmpty)) continue;

					if (row.length < 4) {
						errors.add('Row ${i + 1}: Not enough columns (expected 4)');
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

						if (!_positions.contains(position)) {
							errors.add('Row ${i + 1}: Invalid position "$position"');
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

				if (!mounted) return;

				showDialog(
					context: context,
					builder: (context) => AlertDialog(
						title: Text(I18n.t(widget.language, 'import_complete')),
						content: SingleChildScrollView(
							child: Column(
								mainAxisSize: MainAxisSize.min,
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(I18n.t(widget.language, 'successfully_imported').replaceFirst('{count}', '$importedCount')),
									if (errors.isNotEmpty) ...[
										const SizedBox(height: 12),
										Text(I18n.t(widget.language, 'errors'), style: const TextStyle(fontWeight: FontWeight.bold)),
										const SizedBox(height: 8),
										...errors.map((e) => Padding(
													padding: const EdgeInsets.only(bottom: 4.0),
													child: Text(e, style: const TextStyle(fontSize: 12, color: Colors.red)),
												)),
									],
								],
							),
						),
						actions: [
							TextButton(
								onPressed: () => Navigator.pop(context),
								child: Text(I18n.t(widget.language, 'ok')),
							),
						],
					),
				);
			}
		} catch (e) {
			if (!mounted) return;
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(content: Text(I18n.t(widget.language, 'error_importing_csv').replaceFirst('{error}', '$e'))),
			);
		}
	}

	void _proceedToStats() {
		if (_players.isEmpty) {
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(content: Text(I18n.t(widget.language, 'please_add_player'))),
			);
			return;
		}
		Navigator.push(
			context,
			MaterialPageRoute(
				builder: (context) => StatsTrackingScreen(
					matchTitle: widget.matchTitle,
					players: _players,
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
					IconButton(
						icon: const Icon(Icons.upload_file),
						tooltip: I18n.t(widget.language, 'import_from_csv'),
						onPressed: _importPlayersFromCSV,
					),
				],
			),
			body: Padding(
				padding: const EdgeInsets.all(16.0),
				child: Column(
					children: [
						Text(
							I18n.t(widget.language, 'add_players'),
							style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
													decoration: InputDecoration(
														labelText: I18n.t(widget.language, 'first_name'),
														border: const OutlineInputBorder(),
													),
													validator: (value) {
														if (value == null || value.isEmpty) {
															return I18n.t(widget.language, 'required');
														}
														return null;
													},
												),
											),
											const SizedBox(width: 8),
											Expanded(
												child: TextFormField(
													controller: _lastNameController,
													decoration: InputDecoration(
														labelText: I18n.t(widget.language, 'last_name'),
														border: const OutlineInputBorder(),
													),
													validator: (value) {
														if (value == null || value.isEmpty) {
															return I18n.t(widget.language, 'required');
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
													decoration: InputDecoration(
														labelText: I18n.t(widget.language, 'number'),
														border: const OutlineInputBorder(),
													),
													keyboardType: TextInputType.number,
													validator: (value) {
														if (value == null || value.isEmpty) {
															return I18n.t(widget.language, 'required');
														}
														if (int.tryParse(value) == null) {
															return I18n.t(widget.language, 'invalid_number');
														}
														return null;
													},
												),
											),
											const SizedBox(width: 8),
											Expanded(
												child: DropdownButtonFormField<String>(
													value: _selectedPosition,
													decoration: InputDecoration(
														labelText: I18n.t(widget.language, 'position'),
														border: const OutlineInputBorder(),
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
										child: Text(I18n.t(widget.language, 'add_player')),
									),
								],
							),
						),
						const SizedBox(height: 16),
						const Divider(),
						Text(
							I18n.t(widget.language, 'players'),
							style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
						),
						Expanded(
							child: _players.isEmpty
									? Center(
											child: Text(I18n.t(widget.language, 'no_players')),
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
														subtitle: Text(I18n.t(widget.language, 'position_' + player.position.toLowerCase().replaceAll(RegExp(r"[^a-z0-9]+"), '_'))),
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
														backgroundColor: Colors.teal,
														foregroundColor: Colors.white,
													),
													child: Text(
														I18n.t(widget.language, 'next_track_stats'),
														style: const TextStyle(fontSize: 18),
													),
												),
					],
				),
			),
		);
	}
}
