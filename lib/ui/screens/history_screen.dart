import 'package:flutter/material.dart';
import 'package:darts_scorer/models/game.dart';
import 'package:darts_scorer/models/game_status.dart';
import 'package:darts_scorer/models/player.dart';
import 'package:darts_scorer/services/persistence/game_repository.dart';
import 'package:darts_scorer/services/persistence/player_repository.dart';
import 'package:darts_scorer/services/persistence/database_service.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late GameRepository _gameRepo;
  late PlayerRepository _playerRepo;
  List<Game> _games = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeAndLoadGames();
  }

  Future<void> _initializeAndLoadGames() async {
    final dbService = DatabaseServiceImpl();
    await dbService.initialize();

    _gameRepo = GameRepositoryImpl(dbService);
    _playerRepo = PlayerRepositoryImpl(dbService);

    await _loadGames();
  }

  Future<void> _loadGames() async {
    setState(() => _isLoading = true);

    final games = await _gameRepo.getGames(
      status: GameStatus.completed,
      limit: 50,
    );

    setState(() {
      _games = games;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game History'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _games.isEmpty
              ? const Center(
                  child: Text(
                    'No completed games yet',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: _games.length,
                  itemBuilder: (context, index) {
                    final game = _games[index];
                    return _buildGameCard(game);
                  },
                ),
    );
  }

  Widget _buildGameCard(Game game) {
    return FutureBuilder<List<Player>>(
      future: _playerRepo.getPlayersByGame(game.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final players = snapshot.data!;
        final winner = players.firstWhere(
          (p) => p.id == game.winnerId,
          orElse: () => players.first,
        );

        final dateFormat = DateFormat('MMM d, yyyy - h:mm a');

        return Card(
          child: ListTile(
            leading: Icon(
              Icons.emoji_events,
              color: Colors.amber.shade700,
              size: 32,
            ),
            title: Text(
              game.gameType.displayName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Winner: ${winner.name}'),
                Text(
                  dateFormat.format(game.completedAt ?? game.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _confirmDelete(game),
            ),
            onTap: () => _showGameDetails(game, players),
          ),
        );
      },
    );
  }

  void _showGameDetails(Game game, List<Player> players) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(game.gameType.displayName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Players:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...players.map((p) => Text('${p.name}: ${p.currentScore}')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Game game) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Game?'),
        content: const Text('Are you sure you want to delete this game?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _gameRepo.deleteGame(game.id);
              Navigator.pop(context);
              _loadGames();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
