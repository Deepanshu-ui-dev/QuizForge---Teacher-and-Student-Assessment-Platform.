import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/providers/core_providers.dart';
import '../core/utils/app_role.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/onboarding/presentation/auth_choice_screen.dart';
import '../features/onboarding/presentation/onboarding_carousel_screen.dart';
import '../features/onboarding/presentation/splash_screen.dart';
import '../features/student/presentation/join_quiz_screen.dart';
import '../features/student/presentation/quiz_instructions_screen.dart';
import '../features/student/presentation/student_shell.dart';
import '../features/student/presentation/take_quiz_screen.dart';
import '../features/teacher/presentation/analytics_screen.dart';
import '../features/teacher/presentation/attempts_results_screen.dart';
import '../features/teacher/presentation/create_edit_quiz_screen.dart';
import '../features/teacher/presentation/edit_quiz_loader.dart';
import '../features/teacher/presentation/question_builder_screen.dart';
import '../features/teacher/presentation/quiz_detail_screen.dart';
import '../features/teacher/presentation/teacher_shell.dart';

class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const onboarding = '/onboarding';
  static const authChoice = '/auth';
  static const login = '/auth/login';
  static const register = '/auth/register';

  static const teacherHome = '/teacher';
  static const createQuiz = '/teacher/quizzes/create';
  static const quizDetail = '/teacher/quizzes';

  static const studentHome = '/student';
  static const joinQuiz = '/student/join';
  static const quizInstructions = '/student/quizzes/instructions';
  static const takeQuiz = '/student/quizzes/take';
}

class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(Ref ref) {
    ref.listen(sessionProvider, (_, __) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _RouterRefreshNotifier(ref);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refreshNotifier,
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingCarouselScreen(),
      ),
      GoRoute(path: AppRoutes.authChoice, builder: (context, state) => const AuthChoiceScreen()),
      GoRoute(path: AppRoutes.login, builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) {
          final roleParam = state.uri.queryParameters['role'];
          final initialRole = roleParam == 'teacher' ? AppRole.teacher : AppRole.student;
          return RegisterScreen(initialRole: initialRole);
        },
      ),

      GoRoute(path: AppRoutes.teacherHome, builder: (context, state) => const TeacherShell()),
      GoRoute(
        path: AppRoutes.createQuiz,
        builder: (context, state) => const CreateEditQuizScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.quizDetail}/:id',
        builder: (context, state) =>
            QuizDetailScreen(quizId: int.parse(state.pathParameters['id']!)),
        routes: [
          GoRoute(
            path: 'questions',
            builder: (context, state) =>
                QuestionBuilderScreen(quizId: int.parse(state.pathParameters['id']!)),
          ),
          GoRoute(
            path: 'results',
            builder: (context, state) =>
                AttemptsResultsScreen(quizId: int.parse(state.pathParameters['id']!)),
          ),
          GoRoute(
            path: 'analytics',
            builder: (context, state) =>
                AnalyticsScreen(quizId: int.parse(state.pathParameters['id']!)),
          ),
        ],
      ),
      GoRoute(
        path: '${AppRoutes.quizDetail}/:id/edit',
        builder: (context, state) =>
            EditQuizLoader(quizId: int.parse(state.pathParameters['id']!)),
      ),

      GoRoute(path: AppRoutes.studentHome, builder: (context, state) => const StudentShell()),
      GoRoute(path: AppRoutes.joinQuiz, builder: (context, state) => const JoinQuizScreen()),
      GoRoute(
        path: '${AppRoutes.quizInstructions}/:id',
        builder: (context, state) =>
            QuizInstructionsScreen(quizId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '${AppRoutes.takeQuiz}/:id',
        builder: (context, state) =>
            TakeQuizScreen(quizId: int.parse(state.pathParameters['id']!)),
      ),
    ],
    redirect: (context, state) {

      final sessionAsync = ref.read(sessionProvider);

      if (!sessionAsync.hasValue) {
        return state.matchedLocation == AppRoutes.splash ? null : AppRoutes.splash;
      }

      final session = sessionAsync.value!;
      final location = state.matchedLocation;
      final onSplash = location == AppRoutes.splash;
      final onOnboarding = location == AppRoutes.onboarding;
      final onAuthFlow = location == AppRoutes.authChoice ||
          location == AppRoutes.login ||
          location == AppRoutes.register;

      if (session.isAuthenticated) {
        final roleHome =
            session.role == AppRole.teacher ? AppRoutes.teacherHome : AppRoutes.studentHome;
        final isOnTeacherRoute = location.startsWith('/teacher');
        final isOnStudentRoute = location.startsWith('/student');
        final onOtherRoleRoute = session.role == AppRole.teacher ? isOnStudentRoute : isOnTeacherRoute;

        if (onSplash || onOnboarding || onAuthFlow || onOtherRoleRoute) {
          return roleHome;
        }
        return null;
      }

      if (!session.onboardingSeen) {
        return onOnboarding ? null : AppRoutes.onboarding;
      }

      if (onSplash || onOnboarding) {
        return AppRoutes.authChoice;
      }

      if (location.startsWith('/teacher') || location.startsWith('/student')) {
        return AppRoutes.authChoice;
      }

      return null;
    },
  );
});
