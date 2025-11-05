import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:darts_scorer/services/persistence/database_service.dart';
import 'package:darts_scorer/services/persistence/game_repository.dart';
import 'package:darts_scorer/services/persistence/player_repository.dart';
import 'package:darts_scorer/services/persistence/turn_repository.dart';
import 'package:darts_scorer/services/checkout_calculator/checkout_calculator.dart';
import 'package:darts_scorer/services/game_engine/game_engine.dart';
import 'package:darts_scorer/providers/game_provider.dart';
import 'package:darts_scorer/providers/settings_provider.dart';
import 'package:darts_scorer/ui/screens/home_screen.dart';
import 'package:darts_scorer/ui/screens/game_setup_screen.dart';
import 'package:darts_scorer/ui/screens/game_screen.dart';
import 'package:darts_scorer/ui/screens/settings_screen.dart';
import 'package:darts_scorer/ui/screens/history_screen.dart';
import 'package:darts_scorer/ui/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database
  final dbService = DatabaseServiceImpl();
  await dbService.initialize();

  // Create repositories
  final gameRepo = GameRepositoryImpl(dbService);
  final playerRepo = PlayerRepositoryImpl(dbService);
  final turnRepo = TurnRepositoryImpl(dbService);

  // Create services
  final checkoutCalc = CheckoutCalculatorImpl();

  // Create game engine
  final gameEngine = GameEngineImpl(
    gameRepository: gameRepo,
    playerRepository: playerRepo,
    turnRepository: turnRepo,
    checkoutCalculator: checkoutCalc,
  );

  // Initialize settings
  final settingsProvider = SettingsProvider();
  await settingsProvider.initialize();

  runApp(DartsScorerApp(
    gameEngine: gameEngine,
    settingsProvider: settingsProvider,
  ));
}

class DartsScorerApp extends StatelessWidget {
  final GameEngine gameEngine;
  final SettingsProvider settingsProvider;

  const DartsScorerApp({
    Key? key,
    required this.gameEngine,
    required this.settingsProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => GameProvider(gameEngine: gameEngine),
        ),
        ChangeNotifierProvider.value(
          value: settingsProvider,
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'Darts Scorer',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.themeMode,
            initialRoute: '/',
            routes: {
              '/': (context) => const HomeScreen(),
              '/game-setup': (context) => const GameSetupScreen(),
              '/game': (context) => const GameScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/history': (context) => const HistoryScreen(),
            },
          );
        },
      ),
    );
  }
}
