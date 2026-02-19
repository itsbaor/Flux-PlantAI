import 'package:flutter/material.dart';
import '../widgets/app_background.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text(
                'Privacy Policy',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              pinned: true,
            ),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildSection(
                    'Last Updated',
                    'February 17, 2026',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    'Introduction',
                    'Welcome to Plant AI ("we," "our," or "us"). We are committed to protecting your privacy and ensuring you have a positive experience when using our app. This Privacy Policy explains how we collect, use, disclose, and safeguard your information.',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    'Information We Collect',
                    '''We collect the following types of information:

• Camera and Photos: We access your camera and photo library only when you choose to identify or diagnose plants. Images are processed to provide plant identification results.

• Device Information: We collect anonymous analytics data to improve app performance and user experience.

• Local Storage: Your plant collection, reminders, and preferences are stored locally on your device.''',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    'How We Use Your Information',
                    '''We use the information we collect to:

• Provide plant identification and diagnosis services
• Store your garden collection and care reminders
• Improve our app and services
• Analyze usage patterns to enhance user experience''',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    'Data Storage and Security',
                    '''• All plant data and images are stored locally on your device
• We use industry-standard security measures to protect your information
• Plant images sent for identification are processed securely and not stored permanently on our servers''',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    'Third-Party Services',
                    '''Our app uses the following third-party services:

• Google Gemini AI: For plant identification and diagnosis
• Firebase Analytics: For anonymous usage analytics

These services have their own privacy policies governing the use of your information.''',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    'Your Rights',
                    '''You have the right to:

• Access your personal data stored in the app
• Delete your data by clearing app data or uninstalling
• Opt-out of analytics by disabling in device settings
• Request information about data processing''',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    'Children\'s Privacy',
                    'Our app is not intended for children under 13. We do not knowingly collect personal information from children under 13.',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    'Changes to This Policy',
                    'We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last Updated" date.',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    'Contact Us',
                    '''If you have any questions about this Privacy Policy, please contact us at:

Email: support@plantai.app
Website: https://plantai.app/privacy''',
                  ),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Text(
            content,
            style: TextStyle(
              color: Colors.grey.shade300,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}
