import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../widgets/curved_header.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import 'upload_profile_picture_screen.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({Key? key}) : super(key: key);

  @override
  _CreateAccountScreenState createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  bool _acceptedTerms = false;

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
                  const CustomTextField(
                    label: 'Name',
                    hint: 'Enter your name',
                  ),
                  const SizedBox(height: 20),
                  const CustomTextField(
                    label: 'Email',
                    hint: 'Johndoe@example.com',
                  ),
                  const SizedBox(height: 20),
                  const CustomTextField(
                    label: 'Age',
                    hint: 'Enter Age here',
                  ),
                  const SizedBox(height: 20),
                  const CustomTextField(
                    label: 'Password',
                    hint: '*****************',
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  const CustomTextField(
                    label: 'Confirm Password',
                    hint: '*****************',
                    obscureText: true,
                  ),
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      Checkbox(
                        value: _acceptedTerms,
                        onChanged: (val) {
                          setState(() {
                            _acceptedTerms = val ?? false;
                          });
                        },
                        activeColor: AppColors.primaryBlue,
                        side: const BorderSide(color: AppColors.primaryBlue),
                      ),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(color: Colors.black87, fontSize: 13),
                            children: [
                              const TextSpan(text: 'Accept '),
                              TextSpan(
                                text: 'Terms and Conditions',
                                style: const TextStyle(
                                  color: AppColors.primaryBlue,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()..onTap = () {},
                              ),
                              const TextSpan(text: ' and\n'),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: const TextStyle(
                                  color: AppColors.primaryBlue,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()..onTap = () {},
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  CustomButton(
                    text: 'Sign Up As Executive',
                    onPressed: () {
                      // Navigate to profile upload
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const UploadProfilePictureScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black87, fontSize: 14),
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
                              Navigator.pop(context); // Go back to login
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
