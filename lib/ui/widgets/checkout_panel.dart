import 'package:flutter/material.dart';
import 'package:darts_scorer/models/checkout_suggestion.dart';

class CheckoutPanel extends StatelessWidget {
  final bool isFinishable;
  final List<CheckoutSuggestion> checkouts;
  final int remainingScore;

  const CheckoutPanel({
    super.key,
    required this.isFinishable,
    required this.checkouts,
    required this.remainingScore,
  });

  @override
  Widget build(BuildContext context) {
    if (!isFinishable || checkouts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.green.shade700,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green.shade700,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                'FINISH AVAILABLE',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Score: $remainingScore',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Checkout Options:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          ...checkouts.take(3).map((checkout) => _buildCheckoutOption(
                checkout,
                isBest: checkout == checkouts.first,
              )),
        ],
      ),
    );
  }

  Widget _buildCheckoutOption(CheckoutSuggestion checkout, {required bool isBest}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isBest ? Colors.green.shade700 : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isBest ? Colors.green.shade900 : Colors.grey.shade300,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          if (isBest)
            const Icon(
              Icons.star,
              color: Colors.white,
              size: 18,
            ),
          if (isBest) const SizedBox(width: 8),
          Expanded(
            child: Text(
              checkout.description,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isBest ? FontWeight.bold : FontWeight.w500,
                color: isBest ? Colors.white : Colors.black87,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isBest ? Colors.green.shade900 : _getDifficultyColor(checkout.difficulty),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _getDifficultyText(checkout.difficulty),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isBest ? Colors.white : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(CheckoutDifficulty difficulty) {
    switch (difficulty) {
      case CheckoutDifficulty.easy:
        return Colors.green.shade600;
      case CheckoutDifficulty.moderate:
        return Colors.orange.shade600;
      case CheckoutDifficulty.challenging:
        return Colors.deepOrange.shade600;
      case CheckoutDifficulty.hard:
        return Colors.red.shade600;
      case CheckoutDifficulty.expert:
        return Colors.purple.shade600;
    }
  }

  String _getDifficultyText(CheckoutDifficulty difficulty) {
    switch (difficulty) {
      case CheckoutDifficulty.easy:
        return 'EASY';
      case CheckoutDifficulty.moderate:
        return 'MEDIUM';
      case CheckoutDifficulty.challenging:
        return 'CHALLENGING';
      case CheckoutDifficulty.hard:
        return 'HARD';
      case CheckoutDifficulty.expert:
        return 'EXPERT';
    }
  }
}
