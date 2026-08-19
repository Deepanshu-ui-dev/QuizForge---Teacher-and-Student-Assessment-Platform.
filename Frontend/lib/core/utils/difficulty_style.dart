import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../models/quiz.dart';

extension DifficultyStyle on QuizDifficulty {
  Color get dotColor => switch (this) {
        QuizDifficulty.easy => AppColors.difficultyEasy,
        QuizDifficulty.medium => AppColors.difficultyMedium,
        QuizDifficulty.hard => AppColors.difficultyHard,
      };
}
