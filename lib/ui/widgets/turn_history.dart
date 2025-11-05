import 'package:flutter/material.dart';
import 'package:darts_scorer/models/dart.dart';

class TurnHistory extends StatelessWidget {
  final List<Dart> currentDarts;
  final VoidCallback? onUndo;

  const TurnHistory({
    Key? key,
    required this.currentDarts,
    this.onUndo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Current Turn',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (currentDarts.isNotEmpty && onUndo != null)
                  IconButton(
                    icon: const Icon(Icons.undo),
                    onPressed: onUndo,
                    tooltip: 'Undo last dart',
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (currentDarts.isEmpty)
              const Text(
                'No darts thrown yet',
                style: TextStyle(color: Colors.grey),
              )
            else
              Wrap(
                spacing: 8,
                children: currentDarts.map((dart) {
                  return Chip(
                    label: Text(
                      '${_getMultiplierLabel(dart.multiplier.name)}${dart.zone} (${dart.points})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: Colors.blue[100],
                  );
                }).toList(),
              ),
            const SizedBox(height: 8),
            Text(
              'Total: ${currentDarts.fold(0, (sum, dart) => sum + dart.points)} points',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMultiplierLabel(String multiplier) {
    switch (multiplier) {
      case 'single':
        return '';
      case 'double':
        return 'D';
      case 'triple':
        return 'T';
      case 'innerBull':
        return 'Bull';
      case 'outerBull':
        return '25';
      default:
        return '';
    }
  }
}
