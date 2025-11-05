import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:darts_scorer/models/game_type.dart';
import 'package:darts_scorer/providers/game_provider.dart';
import 'package:darts_scorer/ui/utils/responsive_layout.dart';

class GameSetupScreen extends StatefulWidget {
  const GameSetupScreen({Key? key}) : super(key: key);

  @override
  State<GameSetupScreen> createState() => _GameSetupScreenState();
}

class _GameSetupScreenState extends State<GameSetupScreen> {
  GameType _selectedGameType = GameType.fiveOhOne;
  final TextEditingController _playerNameController = TextEditingController();
  final List<String> _playerNames = [];

  @override
  void dispose() {
    _playerNameController.dispose();
    super.dispose();
  }

  void _addPlayer() {
    final name = _playerNameController.text.trim();
    if (name.isNotEmpty && !_playerNames.contains(name) && _playerNames.length < 4) {
      setState(() {
        _playerNames.add(name);
        _playerNameController.clear();
      });
    }
  }

  void _removePlayer(int index) {
    setState(() {
      _playerNames.removeAt(index);
    });
  }

  Future<void> _startGame() async {
    if (_playerNames.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one player')),
      );
      return;
    }

    final provider = context.read<GameProvider>();
    await provider.startNewGame(
      gameType: _selectedGameType,
      playerNames: _playerNames,
    );

    if (provider.hasActiveGame && mounted) {
      Navigator.pushReplacementNamed(context, '/game');
    } else if (provider.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${provider.error}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textScale = ResponsiveLayout.getTextScaleFactor(context);
    final isTablet = ResponsiveLayout.isTablet(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Game Setup'),
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: ResponsiveLayout.getMaxContentWidth(context),
          ),
          padding: ResponsiveLayout.getScreenPadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Game Type',
                style: TextStyle(
                  fontSize: 18 * textScale,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButton<GameType>(
                value: _selectedGameType,
                isExpanded: true,
                items: GameType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(
                      type.displayName,
                      style: TextStyle(fontSize: 16 * textScale),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedGameType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Players',
                style: TextStyle(
                  fontSize: 18 * textScale,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _playerNameController,
                      decoration: const InputDecoration(
                        hintText: 'Enter player name',
                        border: OutlineInputBorder(),
                      ),
                      style: TextStyle(fontSize: 16 * textScale),
                      onSubmitted: (_) => _addPlayer(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addPlayer,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 24 : 16,
                        vertical: isTablet ? 20 : 16,
                      ),
                    ),
                    child: Text(
                      'Add',
                      style: TextStyle(fontSize: 16 * textScale),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _playerNames.isEmpty
                    ? Center(
                        child: Text(
                          'No players added yet',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16 * textScale,
                          ),
                        ),
                      )
                    : GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: ResponsiveLayout.getCrossAxisCount(context),
                          childAspectRatio: isTablet ? 5 : 4,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: _playerNames.length,
                        itemBuilder: (context, index) {
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text('${index + 1}'),
                              ),
                              title: Text(
                                _playerNames[index],
                                style: TextStyle(fontSize: 16 * textScale),
                              ),
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _startGame,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(isTablet ? 20 : 16),
                  ),
                  child: Text(
                    'Start Game',
                    style: TextStyle(fontSize: 18 * textScale),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
