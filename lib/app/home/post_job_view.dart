import 'package:contractor/app/home/controller/post_job_controller.dart';
import 'package:contractor/app/model/job.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class PostJobView extends GetView<PostJobController> {
  const PostJobView({super.key});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = media.size.width;
    final textScale = media.textScaleFactor.clamp(0.9, 1.1);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            _buildCustomAppBar(width, textScale),

            // Form Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.05,
                  vertical: width * 0.04,
                ),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      _buildHeader(width, textScale),

                      // Form Sections
                      _buildJobDetailsSection(width, textScale),
                      SizedBox(height: width * 0.05),

                      _buildBudgetSection(width, textScale),
                      SizedBox(height: width * 0.05),

                      _buildPicturesSection(context, width, textScale),
                      SizedBox(height: width * 0.08),

                      // Submit Button
                      _buildSubmitButton(width),

                      SizedBox(height: width * 0.04),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(double width, double textScale) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.05,
        vertical: width * 0.04,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1026),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: width * 0.1,
              height: width * 0.1,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: width * 0.05,
                color: Colors.white,
              ),
            ),
          ),

          SizedBox(width: width * 0.04),

          // Title
          Expanded(
            child: Text(
              'Post a New Job',
              style: TextStyle(
                color: Colors.white,
                fontSize: width * 0.05 * textScale,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(double width, double textScale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.04,
                vertical: width * 0.01,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1026).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    size: width * 0.04,
                    color: const Color(0xFF0D1026),
                  ),
                  SizedBox(width: width * 0.01),
                  Text(
                    'New Job',
                    style: TextStyle(
                      fontSize: width * 0.035 * textScale,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0D1026),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        SizedBox(height: width * 0.02),

        Text(
          'Fill in the details to post your job',
          style: TextStyle(
            fontSize: width * 0.045 * textScale,
            color: Colors.grey[600],
          ),
        ),

        SizedBox(height: width * 0.05),
      ],
    );
  }

  Widget _buildJobDetailsSection(double width, double textScale) {
    return Container(
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            children: [
              Icon(
                Icons.description_outlined,
                size: width * 0.05,
                color: const Color(0xFF0D1026),
              ),
              SizedBox(width: width * 0.02),
              Text(
                'Job Details',
                style: TextStyle(
                  fontSize: width * 0.045 * textScale,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0D1026),
                ),
              ),
            ],
          ),

          SizedBox(height: width * 0.04),

          // Job Title
          _buildTextField(
            label: 'Job Title',
            hint: 'e.g., Fix leaking toilet',
            icon: Icons.title_outlined,
            controller: controller.titleController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Title is required';
              }
              if (value.length < 10) {
                return 'Title must be at least 10 characters';
              }
              return null;
            },
            width: width,
            textScale: textScale,
          ),

          // Description
          _buildTextArea(
            label: 'Description',
            hint: 'Describe the job in detail...',
            icon: Icons.description_outlined,
            controller: controller.descriptionController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Description is required';
              }
              if (value.length < 20) {
                return 'Description must be at least 20 characters';
              }
              return null;
            },
            width: width,
            textScale: textScale,
          ),

          // Trade Category
          _buildDropdown<TradeCategory>(
            label: 'Trade Category',
            icon: Icons.category_outlined,
            value: controller.selectedCategory.value,
            items: TradeCategory.values.map((category) {
              return DropdownMenuItem<TradeCategory>(
                value: category,
                child: Text(
                  _categoryToString(category),
                  style: TextStyle(fontSize: width * 0.038 * textScale),
                ),
              );
            }).toList(),
            onChanged: (TradeCategory? value) {
              if (value != null) {
                controller.selectedCategory.value = value;
              }
            },
            width: width,
            textScale: textScale,
          ),

          // Specific Skill
          _buildTextField(
            label: 'Specific Skill (Optional)',
            hint: 'e.g., Toilet repair, Wiring installation',
            icon: Icons.build_outlined,
            controller: controller.specificSkillController,
            width: width,
            textScale: textScale,
          ),

          // Location
          _buildTextField(
            label: 'Location',
            hint: 'e.g., Kinondoni, Dar es Salaam',
            icon: Icons.location_on_outlined,
            controller: controller.locationController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Location is required';
              }
              return null;
            },
            width: width,
            textScale: textScale,
          ),

          // Urgency Level
          _buildDropdown<UrgencyLevel>(
            label: 'Urgency Level',
            icon: Icons.access_time_outlined,
            value: controller.selectedUrgencyLevel.value,
            items: UrgencyLevel.values.map((level) {
              return DropdownMenuItem<UrgencyLevel>(
                value: level,
                child: Text(
                  _urgencyLevelToString(level),
                  style: TextStyle(fontSize: width * 0.038 * textScale),
                ),
              );
            }).toList(),
            onChanged: (UrgencyLevel? value) {
              if (value != null) {
                controller.selectedUrgencyLevel.value = value;
              }
            },
            width: width,
            textScale: textScale,
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetSection(double width, double textScale) {
    return Container(
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            children: [
              Icon(
                Icons.attach_money_outlined,
                size: width * 0.05,
                color: const Color(0xFF0D1026),
              ),
              SizedBox(width: width * 0.02),
              Text(
                'Budget Details',
                style: TextStyle(
                  fontSize: width * 0.045 * textScale,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0D1026),
                ),
              ),
            ],
          ),

          SizedBox(height: width * 0.04),

          // Budget Type
          _buildDropdown<BudgetType>(
            label: 'Budget Type',
            icon: Icons.payments_outlined,
            value: controller.selectedBudgetType.value,
            items: BudgetType.values.map((type) {
              return DropdownMenuItem<BudgetType>(
                value: type,
                child: Text(
                  _budgetTypeToString(type),
                  style: TextStyle(fontSize: width * 0.038 * textScale),
                ),
              );
            }).toList(),
            onChanged: (BudgetType? value) {
              if (value != null) {
                controller.selectedBudgetType.value = value;
              }
            },
            width: width,
            textScale: textScale,
          ),

          // Budget Range
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Budget Range (TZS)',
                style: TextStyle(
                  fontSize: width * 0.038 * textScale,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0D1026),
                ),
              ),
              SizedBox(height: width * 0.02),
              Row(
                children: [
                  Expanded(
                    child: _buildBudgetField(
                      label: 'Min',
                      hint: '10000',
                      icon: Icons.arrow_upward_outlined,
                      controller: controller.budgetMinController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final val = double.tryParse(value);
                        if (val == null || val < 0) {
                          return 'Invalid';
                        }
                        return null;
                      },
                      width: width,
                      textScale: textScale,
                    ),
                  ),
                  SizedBox(width: width * 0.03),
                  Container(
                    width: width * 0.1,
                    alignment: Alignment.center,
                    child: Text(
                      'to',
                      style: TextStyle(
                        fontSize: width * 0.035 * textScale,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: width * 0.03),
                  Expanded(
                    child: _buildBudgetField(
                      label: 'Max',
                      hint: '50000',
                      icon: Icons.arrow_downward_outlined,
                      controller: controller.budgetMaxController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final val = double.tryParse(value);
                        if (val == null || val < 0) {
                          return 'Invalid';
                        }
                        return null;
                      },
                      width: width,
                      textScale: textScale,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPicturesSection(
    BuildContext context,
    double width,
    double textScale,
  ) {
    return Container(
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            children: [
              Icon(
                Icons.photo_library_outlined,
                size: width * 0.05,
                color: const Color(0xFF0D1026),
              ),
              SizedBox(width: width * 0.02),
              Text(
                'Job Pictures (Optional)',
                style: TextStyle(
                  fontSize: width * 0.045 * textScale,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0D1026),
                ),
              ),
            ],
          ),

          SizedBox(height: width * 0.04),

          // Pictures Grid
          Obx(
            () => Wrap(
              spacing: width * 0.03,
              runSpacing: width * 0.03,
              children: [
                // Selected images
                ...controller.selectedImages.map((image) {
                  return Stack(
                    children: [
                      Container(
                        width: width * 0.25,
                        height: width * 0.25,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: FileImage(image),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: width * 0.01,
                        right: width * 0.01,
                        child: GestureDetector(
                          onTap: () => controller.removeImage(image),
                          child: Container(
                            width: width * 0.06,
                            height: width * 0.06,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.3),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.close,
                              size: width * 0.04,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),

                // Add image button
                if (controller.selectedImages.length < 4)
                  GestureDetector(
                    onTap: () => _showImagePicker(context, width),
                    child: Container(
                      width: width * 0.25,
                      height: width * 0.25,
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate,
                            size: width * 0.08,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: width * 0.02),
                          Text(
                            'Add Photo',
                            style: TextStyle(
                              fontSize: width * 0.032 * textScale,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          SizedBox(height: width * 0.02),

          // Helper Text
          Text(
            'Add up to 4 pictures of the job (optional)',
            style: TextStyle(
              fontSize: width * 0.032 * textScale,
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(double width) {
    return Obx(
      () => controller.isLoading.value
          ? Center(
              child: Container(
                padding: EdgeInsets.all(width * 0.04),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1026),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0D1026).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: width * 0.07,
                  height: width * 0.07,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
              ),
            )
          : Container(
              width: double.infinity,
              height: width * 0.14,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0D1026).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () => controller.submitJob(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D1026),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: width * 0.06,
                      color: Colors.white,
                    ),
                    SizedBox(width: width * 0.02),
                    Text(
                      'Post Job Now',
                      style: TextStyle(
                        fontSize: width * 0.045,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // Helper Widgets
  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required double width,
    required double textScale,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: width * 0.038 * textScale,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0D1026),
          ),
        ),
        SizedBox(height: width * 0.015),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(fontSize: width * 0.04 * textScale),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: width * 0.038 * textScale,
              color: Colors.grey[400],
            ),
            prefixIcon: Icon(icon, size: width * 0.05, color: Colors.grey[500]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF0D1026), width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: EdgeInsets.symmetric(
              horizontal: width * 0.04,
              vertical: width * 0.035,
            ),
          ),
          validator: validator,
        ),
        SizedBox(height: width * 0.03),
      ],
    );
  }

  Widget _buildBudgetField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required double width,
    required double textScale,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: width * 0.035 * textScale,
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: width * 0.01),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: TextStyle(fontSize: width * 0.038 * textScale),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: width * 0.038 * textScale,
              color: Colors.grey[400],
            ),
            prefixIcon: Icon(
              icon,
              size: width * 0.045,
              color: Colors.grey[500],
            ),
            prefixText: 'TZS ',
            prefixStyle: TextStyle(
              fontSize: width * 0.038 * textScale,
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF0D1026), width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: EdgeInsets.symmetric(
              horizontal: width * 0.04,
              vertical: width * 0.03,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildTextArea({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required double width,
    required double textScale,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: width * 0.038 * textScale,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0D1026),
          ),
        ),
        SizedBox(height: width * 0.015),
        TextFormField(
          controller: controller,
          maxLines: 4,
          style: TextStyle(fontSize: width * 0.04 * textScale),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: width * 0.038 * textScale,
              color: Colors.grey[400],
            ),
            alignLabelWithHint: true,
            prefixIcon: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: width * 0.02),
                Icon(icon, size: width * 0.05, color: Colors.grey[500]),
              ],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF0D1026), width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: EdgeInsets.symmetric(
              horizontal: width * 0.04,
              vertical: width * 0.04,
            ),
          ),
          validator: validator,
        ),
        SizedBox(height: width * 0.03),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required IconData icon,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
    required double width,
    required double textScale,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: width * 0.038 * textScale,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0D1026),
          ),
        ),
        SizedBox(height: width * 0.015),
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          style: TextStyle(
            fontSize: width * 0.04 * textScale,
            color: Colors.grey[800],
          ),
          decoration: InputDecoration(
            hintText: 'Select $label',
            hintStyle: TextStyle(
              fontSize: width * 0.038 * textScale,
              color: Colors.grey[400],
            ),
            prefixIcon: Icon(icon, size: width * 0.05, color: Colors.grey[500]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF0D1026), width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: EdgeInsets.symmetric(
              horizontal: width * 0.04,
              vertical: width * 0.035,
            ),
          ),
          validator: (value) {
            if (value == null) {
              return 'Please select a $label';
            }
            return null;
          },
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          isExpanded: true,
          icon: Icon(
            Icons.arrow_drop_down_rounded,
            size: width * 0.06,
            color: const Color(0xFF0D1026),
          ),
        ),
        SizedBox(height: width * 0.03),
      ],
    );
  }

  void _showImagePicker(BuildContext context, double width) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: EdgeInsets.all(width * 0.04),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: width * 0.03),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1026),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Add Photo',
                      style: TextStyle(
                        fontSize: width * 0.045,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                ListTile(
                  leading: Container(
                    width: width * 0.1,
                    height: width * 0.1,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D1026).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.camera_alt_outlined,
                      color: const Color(0xFF0D1026),
                      size: width * 0.05,
                    ),
                  ),
                  title: Text(
                    'Take Photo',
                    style: TextStyle(
                      fontSize: width * 0.04,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    controller.pickImage(ImageSource.camera);
                  },
                ),
                Divider(height: 0, indent: width * 0.15),
                ListTile(
                  leading: Container(
                    width: width * 0.1,
                    height: width * 0.1,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D1026).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.photo_library_outlined,
                      color: const Color(0xFF0D1026),
                      size: width * 0.05,
                    ),
                  ),
                  title: Text(
                    'Choose from Gallery',
                    style: TextStyle(
                      fontSize: width * 0.04,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    controller.pickImage(ImageSource.gallery);
                  },
                ),
                SizedBox(height: width * 0.02),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: width * 0.04,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper methods for enum to string conversion
  String _categoryToString(TradeCategory category) {
    switch (category) {
      case TradeCategory.AIR_CONDITIONING:
        return 'Air Conditioning';
      case TradeCategory.CARPENTRY:
        return 'Carpentry';
      case TradeCategory.CLEANING:
        return 'Cleaning';
      case TradeCategory.ELECTRICAL:
        return 'Electrical';
      case TradeCategory.GARDENING:
        return 'Gardening';
      case TradeCategory.GENERATOR_REPAIR:
        return 'Generator Repair';
      case TradeCategory.MASONRY:
        return 'Masonry';
      case TradeCategory.OTHER:
        return 'Other';
      case TradeCategory.PAINTING:
        return 'Painting';
      case TradeCategory.PLUMBING:
        return 'Plumbing';
      case TradeCategory.TILING:
        return 'Tiling';
      case TradeCategory.WELDING:
        return 'Welding';
    }
  }

  String _budgetTypeToString(BudgetType type) {
    switch (type) {
      case BudgetType.DAILY:
        return 'Daily';
      case BudgetType.FIXED:
        return 'Fixed';
      case BudgetType.HOURLY:
        return 'Hourly';
      case BudgetType.RANGE:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  String _urgencyLevelToString(UrgencyLevel level) {
    switch (level) {
      case UrgencyLevel.HIGH:
        return 'High';
      case UrgencyLevel.LOW:
        return 'Low';
      case UrgencyLevel.MEDIUM:
        return 'Medium';
      case UrgencyLevel.URGENT:
        return 'Urgent';
    }
  }
}
