// lib/app/jobs/binding/my_jobs_binding.dart
import 'package:contractor/app/home/controller/my_jobs_controller.dart';
import 'package:get/get.dart';

class MyJobsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MyJobsController());
  }
}