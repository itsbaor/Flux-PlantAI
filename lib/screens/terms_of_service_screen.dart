import 'package:flutter/material.dart';
import '../widgets/app_background.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

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
                'Terms of Service',
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
                    'Agreement to Terms',
                    'By accessing or using Plant AI, you agree to be bound by these Terms of Service. If you disagree with any part of the terms, you may not access the app.',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    'Description of Service',
                    '''Plant AI provides:

• Plant identification using AI technology
• Plant health diagnosis and recommendations
• Garden management and care reminders
• Plant care guides and information

The service is provided "as is" for informational purposes only.''',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    'Disclaimer',
                    '''IMPORTANT: Plant AI is intended for informational and educational purposes only.

• Plant identifications may not always be 100% accurate
• Health diagnoses are suggestions and not professional advice
• Some plants may be toxic - always verify before consumption
• We are not liable for any harm resulting from misidentification
• Consult professionals for serious plant health issues''',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    'User Responsibilities',
                    '''By using Plant AI, you agree to:

• Use the app for lawful purposes only
• Not rely solely on AI identification for edible plants
• Verify plant identification with multiple sources
• Not use the service for commercial purposes without permission
• Report any bugs or inaccuracies you find''',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    'Intellectual Property',
                    '''• The app and its content are owned by Plant AI
• You may not copy, modify, or distribute app content
• User-generated content (photos) remains your property
• By using the app, you grant us license to process your photos for identification''',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    'Limitation of Liability',
                    '''To the maximum extent permitted by law:

• We are not liable for any indirect, incidental, or consequential damages
• We do not guarantee the accuracy of plant identifications
• We are not responsible for actions taken based on app information
• Our total liability is limited to the amount you paid for the app''',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    'Changes to Terms',
                    'We reserve the right to modify these terms at any time. Continued use of the app after changes constitutes acceptance of the new terms.',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    'Termination',
                    'We may terminate or suspend your access to the app immediately, without prior notice, for any reason, including breach of these Terms.',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    'Governing Law',
                    'These Terms shall be governed by and construed in accordance with the laws of the jurisdiction in which the app operates.',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    'Contact Us',
                    '''For questions about these Terms of Service:

Email: support@plantai.app
Website: https://plantai.app/terms''',
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
