import 'package:flutter/material.dart';
import 'package:darts_scorer/ui/utils/responsive_layout.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textScale = ResponsiveLayout.getTextScaleFactor(context);
    final iconSize = ResponsiveLayout.isTablet(context) ? 120.0 : 100.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Darts Scorer'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.pushNamed(context, '/history'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: ResponsiveLayout.getMaxContentWidth(context),
          ),
          padding: ResponsiveLayout.getScreenPadding(context),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.sports_score,
                size: iconSize,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              Text(
                'Darts Score Tracker',
                style: TextStyle(
                  fontSize: 32 * textScale,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: ResponsiveLayout.isTablet(context) ? 300 : double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/game-setup');
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('New Game'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    textStyle: TextStyle(fontSize: 18 * textScale),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: ResponsiveLayout.isTablet(context) ? 300 : double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Resume game functionality (TODO: implement)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No active game found')),
                    );
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Resume Game'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    textStyle: TextStyle(fontSize: 18 * textScale),
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
