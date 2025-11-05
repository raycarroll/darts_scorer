import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:darts_scorer/providers/game_provider.dart';
import 'package:darts_scorer/services/game_engine/game_engine.dart';
import 'package:darts_scorer/ui/widgets/dartboard/dartboard_widget.dart';
import 'package:darts_scorer/ui/widgets/score_display.dart';
import 'package:darts_scorer/ui/widgets/turn_history.dart';
import 'package:darts_scorer/ui/widgets/checkout_panel.dart';
import 'package:darts_scorer/ui/utils/responsive_layout.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, child) {
        final state = provider.currentState;

        if (state == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Game')),
            body: const Center(child: Text('No active game')),
          );
        }

        // Check if game is complete
        if (provider.isGameComplete) {
          return _buildWinScreen(context, provider);
        }

        final isLandscape = ResponsiveLayout.isLandscape(context);

        return Scaffold(
          appBar: AppBar(
            title: Text('${state.game.gameType.displayName} - Round ${state.currentRound}'),
            actions: [
              IconButton(
                icon: const Icon(Icons.exit_to_app),
                onPressed: () => _showAbandonDialog(context, provider),
              ),
            ],
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : isLandscape
                  ? _buildLandscapeLayout(context, provider, state)
                  : _buildPortraitLayout(context, provider, state),
        );
      },
    );
  }

  Widget _buildPortraitLayout(
    BuildContext context,
    GameProvider provider,
    GameState state,
  ) {
    return SingleChildScrollView(
      padding: ResponsiveLayout.getScreenPadding(context),
      child: Column(
        children: [
          if (provider.error != null) _buildErrorBanner(provider),
          const SizedBox(height: 16),
          Text(
            state.currentPlayer.name,
            style: TextStyle(
              fontSize: 24 * ResponsiveLayout.getTextScaleFactor(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ScoreDisplay(
            currentScore: state.currentPlayer.currentScore,
            startingScore: state.game.startingScore,
            dartsThrown: state.currentTurnDarts.length,
            currentRound: state.currentRound,
          ),
          const SizedBox(height: 16),
          CheckoutPanel(
            isFinishable: state.isFinishable,
            checkouts: state.checkouts,
            remainingScore: state.currentPlayer.currentScore,
          ),
          const SizedBox(height: 16),
          Center(
            child: DartboardWidget(
              onDartThrown: (dartThrow) {
                provider.recordDart(
                  zone: dartThrow.zone,
                  multiplier: dartThrow.multiplier,
                );
              },
              size: ResponsiveLayout.getDartboardSize(context),
            ),
          ),
          const SizedBox(height: 16),
          TurnHistory(
            currentDarts: state.currentTurnDarts,
            onUndo: state.currentTurnDarts.isNotEmpty
                ? () => provider.undoLastDart()
                : null,
          ),
          const SizedBox(height: 16),
          _buildCompleteTurnButton(state, provider),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout(
    BuildContext context,
    GameProvider provider,
    GameState state,
  ) {
    final dartboardSize = ResponsiveLayout.getDartboardSize(context);

    return Row(
      children: [
        // Left side: Dartboard
        Expanded(
          flex: ResponsiveLayout.isTablet(context) ? 2 : 1,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: DartboardWidget(
                onDartThrown: (dartThrow) {
                  provider.recordDart(
                    zone: dartThrow.zone,
                    multiplier: dartThrow.multiplier,
                  );
                },
                size: dartboardSize,
              ),
            ),
          ),
        ),
        // Right side: Info and controls
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            padding: ResponsiveLayout.getScreenPadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (provider.error != null) _buildErrorBanner(provider),
                const SizedBox(height: 16),
                Text(
                  state.currentPlayer.name,
                  style: TextStyle(
                    fontSize: 24 * ResponsiveLayout.getTextScaleFactor(context),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ScoreDisplay(
                  currentScore: state.currentPlayer.currentScore,
                  startingScore: state.game.startingScore,
                  dartsThrown: state.currentTurnDarts.length,
                  currentRound: state.currentRound,
                ),
                const SizedBox(height: 16),
                CheckoutPanel(
                  isFinishable: state.isFinishable,
                  checkouts: state.checkouts,
                  remainingScore: state.currentPlayer.currentScore,
                ),
                const SizedBox(height: 16),
                TurnHistory(
                  currentDarts: state.currentTurnDarts,
                  onUndo: state.currentTurnDarts.isNotEmpty
                      ? () => provider.undoLastDart()
                      : null,
                ),
                const SizedBox(height: 16),
                _buildCompleteTurnButton(state, provider),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBanner(GameProvider provider) {
    return Card(
      color: Colors.red[100],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                provider.error!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => provider.clearError(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompleteTurnButton(GameState state, GameProvider provider) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: state.currentTurnDarts.isNotEmpty
                ? () => provider.completeTurn()
                : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
            child: const Text(
              'Complete Turn',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWinScreen(BuildContext context, GameProvider provider) {
    final state = provider.currentState!;
    final winner = state.players.firstWhere(
      (p) => p.id == state.game.winnerId,
      orElse: () => state.players.first,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Game Complete')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.emoji_events,
              size: 100,
              color: Colors.amber,
            ),
            const SizedBox(height: 24),
            const Text(
              'Winner!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              winner.name,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/game-setup',
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text(
                'New Game',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text(
                'Home',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAbandonDialog(BuildContext context, GameProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Abandon Game?'),
        content: const Text('Are you sure you want to abandon this game?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.abandonGame();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/',
                (route) => false,
              );
            },
            child: const Text('Abandon'),
          ),
        ],
      ),
    );
  }
}
