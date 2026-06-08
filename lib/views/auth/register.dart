import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:vector_academy/controllers/on_boarding/register_controller.dart';
import 'package:vector_academy/models/models.dart';
import 'package:vector_academy/components/components.dart';

class Register extends StatelessWidget {
  const Register({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller will be created by binding's lazyPut when GetBuilder accesses it
    return Scaffold(
      backgroundColor: Color(0xffefefef),
      appBar: AppBar(
        leading: const AppBackLeading(),
        title: Text('Register'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.all(20),
        child: GetBuilder<RegisterController>(
          builder: (controller) {
            return Form(
              key: controller.formKey,
              autovalidateMode: AutovalidateMode.onUnfocus,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Image.asset('assets/images/logo.png'),
                  Text(
                    'Welcome',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    'Please enter your details to register',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    child: TextFormField(
                      controller: controller.nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        prefixIcon: Icon(Icons.person),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Name is required';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    child: DropdownButtonFormField<String>(
                      initialValue: controller.selectedGrade?.name,
                      decoration: InputDecoration(
                        labelText: 'Grade',
                        prefixIcon: Icon(Icons.school),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      items: controller.gradeOptions.map((Grade grade) {
                        return DropdownMenuItem<String>(
                          value: grade.name,
                          child: Text(grade.name),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        controller.setSelectedGrade(
                          controller.gradeOptions.firstWhere(
                            (grade) => grade.name == newValue,
                          ),
                        );
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Grade is required';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    child: TextFormField(
                      controller: controller.phoneController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone),
                        prefix: Text('0'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      maxLength: 9,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Phone Number is required';
                        }
                        if (value.length != 9) {
                          return 'Phone Number must be 9 digits';
                        }
                        final pattern = RegExp(r'^(7|9)\d{8}$');
                        if (pattern.hasMatch(value)) {
                          return null;
                        }
                        return 'Phone Number must start with 7 or 9 and only digits';
                      },
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    child: TextFormField(
                      controller: controller.passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () =>
                              controller.togglePasswordVisibility(),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      obscureText: !controller.isPasswordVisible,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        if (value.length < 4) {
                          return 'Password must be at least 4 characters';
                        }

                        return null;
                      },
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    child: TextFormField(
                      controller: controller.confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isConfirmPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () =>
                              controller.toggleConfirmPasswordVisibility(),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      obscureText: !controller.isConfirmPasswordVisible,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Confirm Password is required';
                        }
                        if (value != controller.passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  SizedBox(height: 10),
                  // Privacy Policy Consent Checkbox
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: controller.hasAcceptedPrivacyPolicy,
                          onChanged: controller.togglePrivacyPolicyAcceptance,
                          activeColor: Theme.of(context).colorScheme.primary,
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                controller.togglePrivacyPolicyAcceptance(
                                  !controller.hasAcceptedPrivacyPolicy,
                                ),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: RichText(
                                text: TextSpan(
                                  style: Theme.of(context).textTheme.bodySmall,
                                  children: [
                                    TextSpan(
                                      text: 'I have read and agree to the ',
                                    ),
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        decoration: TextDecoration.underline,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () =>
                                            PrivacyPolicyDialog.show(),
                                    ),
                                    TextSpan(text: ' and '),
                                    TextSpan(
                                      text: 'Terms & Conditions',
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        decoration: TextDecoration.underline,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () =>
                                            TermsAndConditionsDialog.show(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: ElevatedButton(
                        onPressed: () => controller.register(),
                        child: controller.isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                              )
                            : Text('Register'),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Terms and Privacy Links
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                        children: [
                          TextSpan(
                            text: 'By creating an account, you agree to our ',
                          ),
                          TextSpan(
                            text: 'Terms & Conditions',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  decoration: TextDecoration.underline,
                                ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => TermsAndConditionsDialog.show(),
                          ),
                          TextSpan(
                            text: ' and our ',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.5),
                                ),
                          ),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  decoration: TextDecoration.underline,
                                ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => PrivacyPolicyDialog.show(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
