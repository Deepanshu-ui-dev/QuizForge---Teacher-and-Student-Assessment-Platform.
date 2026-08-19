import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/providers/core_providers.dart';
import '../../../shared/widgets/onboarding_slide.dart';

class _SlideData {
  const _SlideData(this.icon, this.headline, this.supporting);
  final IconData icon;
  final String headline;
  final String supporting;
}

const _slides = [
  _SlideData(Icons.bolt_rounded, 'Build quizzes in minutes',
      'Create structured quizzes with MCQs, marks, and difficulty in a few taps.'),
  _SlideData(Icons.verified_rounded, 'Get instant, backend-graded results',
      'Every score comes straight from the server — real grading, not a gimmick.'),
  _SlideData(Icons.trending_up_rounded, 'Track progress over every attempt',
      'See how you or your students improve, quiz after quiz.'),
];

class OnboardingCarouselScreen extends ConsumerStatefulWidget {
  const OnboardingCarouselScreen({super.key});

  @override
  ConsumerState<OnboardingCarouselScreen> createState() => _OnboardingCarouselScreenState();
}

class _OnboardingCarouselScreenState extends ConsumerState<OnboardingCarouselScreen> {
  final _controller = PageController();
  int _index = 0;

  Future<void> _finish() async {
    final storage = ref.read(secureStorageServiceProvider);
    await storage.setOnboardingSeen();
    ref.invalidate(sessionProvider);
    if (mounted) context.go(AppRoutes.authChoice);
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _index == _slides.length - 1;
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _slides.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) => OnboardingSlide(
              icon: _slides[i].icon,
              headline: _slides[i].headline,
              supportingText: _slides[i].supporting,
            ),
          ),
          Positioned(
            top: AppSpacing.lg,
            right: AppSpacing.lg,
            child: SafeArea(
              child: TextButton(
                onPressed: _finish,
                style: TextButton.styleFrom(foregroundColor: AppColors.pureWhite),
                child: const Text('Skip'),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_slides.length, (i) {
                        final active = i == _index;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                          width: active ? 20 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: active
                                ? AppColors.pureWhite
                                : AppColors.pureWhite.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.pureWhite,
                          foregroundColor: AppColors.ink,
                        ),
                        onPressed: () {
                          if (isLast) {
                            _finish();
                          } else {
                            _controller.nextPage(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOut,
                            );
                          }
                        },
                        child: Text(isLast ? 'Get Started' : 'Next'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
