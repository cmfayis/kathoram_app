import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kathoram/features/newfeature/auth/controller/auth_controller.dart';
import '../core/app_colors.dart';
import '../widgets/curved_header.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({Key? key}) : super(key: key);

  @override
  _CreateAccountScreenState createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const CurvedHeader(
              height: 250, // Slightly smaller header per design
              showBackButton: true,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    'Create Account',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 25),
                  CustomTextField(
                    label: 'Name',
                    hint: 'Enter your name',
                    controller: authController.signupNameController,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: 'Email',
                    hint: 'Johndoe@example.com',
                    controller: authController.signupEmailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: 'Age',
                    hint: 'Enter Age here',
                    controller: authController.signupAgeController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: 'Language',
                    hint: 'Malayalam / English / Hindi',
                    controller: authController.signupLanguageController,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: 'Password',
                    hint: '*****************',
                    obscureText: true,
                    controller: authController.signupPasswordController,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: 'Confirm Password',
                    hint: '*****************',
                    obscureText: true,
                    controller: authController.signupConfirmPasswordController,
                  ),
                  const SizedBox(height: 25),
                  Obx(
                    () => Row(
                      children: [
                        Checkbox(
                          value: authController.isTermsAgreed.value,
                          onChanged: (val) {
                            authController.isTermsAgreed.value = val ?? false;
                          },
                          activeColor: AppColors.primaryBlue,
                          side: const BorderSide(color: AppColors.primaryBlue),
                        ),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 13,
                              ),
                              children: [
                                const TextSpan(text: 'Accept '),
                                TextSpan(
                                  text: 'Terms and Conditions',
                                  style: const TextStyle(
                                    color: AppColors.primaryBlue,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {},
                                ),
                                const TextSpan(text: ' and\n'),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: const TextStyle(
                                    color: AppColors.primaryBlue,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {},
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  Obx(
                    () => CustomButton(
                      text: authController.isLoading.value
                          ? 'Please wait...'
                          : 'Sign Up As Executive',
                      onPressed: authController.isLoading.value
                          ? () {}
                          : authController.signup,
                    ),
                  ),
                  const SizedBox(height: 20),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                      children: [
                        const TextSpan(text: 'Already registered? '),
                        TextSpan(
                          text: 'Sign in',
                          style: const TextStyle(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Get.back();
                            },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
