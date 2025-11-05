import 'package:flutter/material.dart';
import 'package:darts_scorer/services/game_engine/rules/cricket_rule.dart';

class CricketScoreDisplay extends StatelessWidget {
  final Map<String, CricketPlayerState> playerStates;
  final List<String> playerIds;
  final List<String> playerNames;

  const CricketScoreDisplay({
    super.key,
    required this.playerStates,
    required this.playerIds,
    required this.playerNames,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Cricket Scorecard',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildScoreTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreTable() {
    final zones = [20, 19, 18, 17, 16, 15, 25]; // Standard Cricket order

    return Table(
      border: TableBorder.all(color: Colors.grey.shade300),
      children: [
        // Header row
        TableRow(
          decoration: BoxDecoration(color: Colors.grey.shade200),
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  'Number',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            ...playerNames.map((name) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                )),
          ],
        ),
        // Number rows
        ...zones.map((zone) => TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      zone == 25 ? 'Bull' : zone.toString(),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                ...playerIds.map((playerId) {
                  final state = playerStates[playerId];
                  final marks = state?.getMarks(zone) ?? 0;
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: _buildMarksIndicator(marks),
                    ),
                  );
                }),
              ],
            )),
        // Points row
        TableRow(
          decoration: BoxDecoration(color: Colors.blue.shade50),
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  'Points',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            ...playerIds.map((playerId) {
              final state = playerStates[playerId];
              final points = state?.points ?? 0;
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    points.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildMarksIndicator(int marks) {
    if (marks == 0) {
      return const Text('-');
    } else if (marks == 1) {
      return const Text(
        '/',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      );
    } else if (marks == 2) {
      return const Text(
        'X',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      );
    } else {
      // 3 marks - closed
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.shade600,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text(
          '⊗',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }
}
