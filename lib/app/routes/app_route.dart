import 'package:contractor/app/home/binding/my_jobs_binding.dart';
import 'package:contractor/app/home/controller/post_job_controller.dart';
import 'package:contractor/app/home/my_jobs_view.dart';
import 'package:contractor/app/home/post_job_view.dart';
import 'package:contractor/app/profile/binding/profile_binding.dart';
import 'package:contractor/app/profile/profile_view.dart';
import 'package:get/get.dart';

import 'package:contractor/app/splash_screen/binding/splash_binding.dart';
import 'package:contractor/app/splash_screen/splash_view.dart';

import 'package:contractor/app/onboarding/binding/onboarding_binding.dart';
import 'package:contractor/app/onboarding/onboarding_view.dart';

import 'package:contractor/app/auth/login/binding/login_binding.dart';
import 'package:contractor/app/auth/login/login_view.dart';

import 'package:contractor/app/auth/register/binding/register_binding.dart';
import 'package:contractor/app/auth/register/register_view.dart';

import 'package:contractor/app/home/binding/home_binding.dart';
import 'package:contractor/app/home/home_view.dart';

class AppRoutes {
  // ─────────────────────────────────────────────
  // Route Names
  // ─────────────────────────────────────────────
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const loginScreen = '/login';
  static const register = '/register';
  static const home = '/home';
  static const job = '/post-job';
  static const String myJobs = '/my-jobs';

  // (Keep future routes declared but unused if planned)
  static const transactions = '/transactions';
  static const transactionDetail = '/transaction_detail';
  static const manualEntry = '/manual_entry';
  static const commissions = '/commissions';
  static const settings = '/settings';
  static const profile = '/profile';

  // ─────────────────────────────────────────────
  // Initial Route
  // ─────────────────────────────────────────────
  static const initial = splash;

  // ─────────────────────────────────────────────
  // Pages
  // ─────────────────────────────────────────────
  static final List<GetPage> pages = [
    GetPage(
      name: splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),

    GetPage(
      name: onboarding,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),

    GetPage(
      name: loginScreen,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),

    GetPage(
      name: register,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),

    GetPage(
      name: job,
      page: () => const PostJobView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => PostJobController());
      }),
    ),
    GetPage(
      name: myJobs,
      page: () => MyJobsView(),
      binding: MyJobsBinding(), // Create binding below
    ),
    GetPage(
      name: profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),

    GetPage(name: home, page: () => const HomeView(), binding: HomeBinding()),
  ];
}
