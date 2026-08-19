import 'package:flutter/material.dart';
import '../../app/theme/app_radii.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/models/question.dart';

class QuestionCard extends StatelessWidget {
  const QuestionCard({
    super.key,
    required this.question,
    required this.index,
    this.onEdit,
    this.onDelete,
  });

  final Question question;
  final int index;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadii.lgRadius,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Q$index', style: theme.textTheme.labelLarge),
              const Spacer(),
              Text('${question.marks} marks', style: theme.textTheme.bodySmall),
              if (onEdit != null)
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  onPressed: onEdit,
                  visualDensity: VisualDensity.compact,
                ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  onPressed: onDelete,
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(question.text, style: theme.textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: ['A', 'B', 'C', 'D'].map((k) {
              final isCorrect = question.correctAnswer == k;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isCorrect ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
                    width: isCorrect ? 1.4 : 1,
                  ),
                  borderRadius: AppRadii.smRadius,
                ),
                child: Text(
                  '$k. ${question.options.forKey(k)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: isCorrect ? FontWeight.w700 : FontWeight.w400,
                    color: isCorrect ? theme.colorScheme.onSurface : null,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
