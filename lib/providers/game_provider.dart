import 'package:flutter/foundation.dart';
import 'package:darts_scorer/models/game_type.dart';
import 'package:darts_scorer/models/multiplier.dart';
import 'package:darts_scorer/services/game_engine/game_engine.dart';

class GameProvider with ChangeNotifier {
  final GameEngine _gameEngine;

  GameState? _currentState;
  bool _isLoading = false;
  String? _error;

  GameProvider({required GameEngine gameEngine}) : _gameEngine = gameEngine;

  GameState? get currentState => _currentState;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get hasActiveGame => _currentState != null;
  bool get isGameComplete => _currentState?.game.status.name == 'completed';

  Future<void> startNewGame({
    required GameType gameType,
    required List<String> playerNames,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final game = await _gameEngine.createGame(
        gameType: gameType,
        playerNames: playerNames,
      );

      _currentState = await _gameEngine.getGameState(game.id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> recordDart({
    required int zone,
    required Multiplier multiplier,
  }) async {
    if (_currentState == null) return;

    _setLoading(true);
    _error = null;

    try {
      _currentState = await _gameEngine.recordDart(
        gameId: _currentState!.game.id,
        zone: zone,
        multiplier: multiplier,
      );

      // Auto-complete turn after 3 darts
      if (_currentState!.currentTurnDarts.length >= 3) {
        _currentState = await _gameEngine.completeTurn(_currentState!.game.id);
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> undoLastDart() async {
    if (_currentState == null) return;

    _setLoading(true);
    _error = null;

    try {
      _currentState = await _gameEngine.undoLastDart(_currentState!.game.id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> completeTurn() async {
    if (_currentState == null) return;

    _setLoading(true);
    _error = null;

    try {
      _currentState = await _gameEngine.completeTurn(_currentState!.game.id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> abandonGame() async {
    if (_currentState == null) return;

    _setLoading(true);
    _error = null;

    try {
      _currentState = await _gameEngine.abandonGame(_currentState!.game.id);
      _currentState = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
