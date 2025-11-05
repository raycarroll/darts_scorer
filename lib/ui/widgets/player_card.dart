import 'package:flutter/material.dart';
import 'package:darts_scorer/models/player.dart';

class PlayerCard extends StatelessWidget {
  final Player player;
  final bool isCurrentPlayer;
  final bool isFinished;
  final double? averagePerDart;
  final double? averagePerTurn;
  final int? dartsThrown;

  const PlayerCard({
    super.key,
    required this.player,
    required this.isCurrentPlayer,
    this.isFinished = false,
    this.averagePerDart,
    this.averagePerTurn,
    this.dartsThrown,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isCurrentPlayer ? 8 : 2,
      color: isCurrentPlayer
          ? Colors.blue.shade50
          : isFinished
              ? Colors.grey.shade100
              : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCurrentPlayer ? Colors.blue : Colors.grey.shade300,
          width: isCurrentPlayer ? 3 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    player.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isCurrentPlayer ? Colors.blue.shade900 : Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isCurrentPlayer)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'ACTIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (isFinished)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'FINISHED',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Score: ${player.currentScore}',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (dartsThrown != null && dartsThrown! > 0) ...[
              const Divider(),
              const SizedBox(height: 8),
              _buildStatRow('Darts Thrown', dartsThrown.toString()),
              if (averagePerDart != null)
                _buildStatRow('Avg/Dart', averagePerDart!.toStringAsFixed(2)),
              if (averagePerTurn != null)
                _buildStatRow('Avg/Turn', averagePerTurn!.toStringAsFixed(2)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
