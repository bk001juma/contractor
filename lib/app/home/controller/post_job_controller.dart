import 'dart:io';
import 'package:contractor/app/model/job.dart';
import 'package:contractor/core/services/job_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class PostJobController extends GetxController {
  final JobService _jobService = JobService();
  final ImagePicker _picker = ImagePicker();
  
  // Form key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  
  // Controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController specificSkillController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController budgetMinController = TextEditingController();
  final TextEditingController budgetMaxController = TextEditingController();
  
  // Dropdown values
  var selectedCategory = TradeCategory.OTHER.obs;
  var selectedBudgetType = BudgetType.FIXED.obs;
  var selectedUrgencyLevel = UrgencyLevel.MEDIUM.obs;
  
  // Images
  final RxList<File> selectedImages = <File>[].obs;
  
  // Loading state
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  
  // Submit job
  Future<void> submitJob() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      // Create job request
      final jobRequest = JobRequest(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        tradeCategory: selectedCategory.value,
        specificSkill: specificSkillController.text.trim().isNotEmpty 
            ? specificSkillController.text.trim() 
            : null,
        location: locationController.text.trim(),
        budgetType: selectedBudgetType.value,
        budgetMin: double.parse(budgetMinController.text),
        budgetMax: double.parse(budgetMaxController.text),
        urgencyLevel: selectedUrgencyLevel.value,
      );
      
      // Create job
      final createdJob = await _jobService.createJob(jobRequest);
      
      // Upload images if any
      if (selectedImages.isNotEmpty) {
        await _uploadJobImages(createdJob.id);
      }
      
      // Show success message
      Get.snackbar(
        'Success',
        'Job posted successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      // Clear form
      _clearForm();
      
      // Navigate back or to job details
      Get.back();
      
    } catch (e) {
      errorMessage.value = 'Failed to post job: $e';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> _uploadJobImages(int jobId) async {
    try {
      if (selectedImages.isEmpty) return;
      
      if (selectedImages.length == 1) {
        // Single image upload
        await _jobService.uploadJobPicture(jobId, selectedImages.first);
      } else {
        // Multiple images upload
        await _jobService.uploadMultipleJobPictures(jobId, selectedImages);
      }
    } catch (e) {
      print('Error uploading images: $e');
      // Don't fail the entire job creation if image upload fails
    }
  }
  
  // Image picker
  Future<void> pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        selectedImages.add(File(pickedFile.path));
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  void removeImage(File image) {
    selectedImages.remove(image);
  }
  
  void _clearForm() {
    titleController.clear();
    descriptionController.clear();
    specificSkillController.clear();
    locationController.clear();
    budgetMinController.clear();
    budgetMaxController.clear();
    selectedCategory.value = TradeCategory.OTHER;
    selectedBudgetType.value = BudgetType.FIXED;
    selectedUrgencyLevel.value = UrgencyLevel.MEDIUM;
    selectedImages.clear();
  }
  
  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    specificSkillController.dispose();
    locationController.dispose();
    budgetMinController.dispose();
    budgetMaxController.dispose();
    super.onClose();
  }
}