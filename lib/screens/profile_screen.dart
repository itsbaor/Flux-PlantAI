import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'language_selection_screen.dart';
import 'privacy_policy_screen.dart' as privacy;
import 'terms_of_service_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'English (US)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // TODO: V2 - Uncomment to enable Upgrade to Pro feature
                  // // Upgrade to Pro Card
                  // Container(
                  //   padding: const EdgeInsets.all(20),
                  //   decoration: BoxDecoration(
                  //     color: Colors.white,
                  //     borderRadius: BorderRadius.circular(16),
                  //   ),
                  //   child: Row(
                  //     children: [
                  //       Expanded(
                  //         child: Column(
                  //           crossAxisAlignment: CrossAxisAlignment.start,
                  //           children: [
                  //             const Text(
                  //               'Upgrade to Pro',
                  //               style: TextStyle(
                  //                 fontSize: 18,
                  //                 fontWeight: FontWeight.bold,
                  //                 color: Colors.black,
                  //               ),
                  //             ),
                  //             const SizedBox(height: 8),
                  //             const Text(
                  //               'Identify variety of plants and diagnose plants status',
                  //               style: TextStyle(
                  //                 fontSize: 12,
                  //                 color: Colors.black54,
                  //               ),
                  //             ),
                  //             const SizedBox(height: 12),
                  //             ElevatedButton(
                  //               onPressed: () {},
                  //               style: ElevatedButton.styleFrom(
                  //                 backgroundColor: const Color(0xFF90EE90),
                  //                 foregroundColor: Colors.black,
                  //                 padding: const EdgeInsets.symmetric(
                  //                   horizontal: 20,
                  //                   vertical: 8,
                  //                 ),
                  //                 shape: RoundedRectangleBorder(
                  //                   borderRadius: BorderRadius.circular(20),
                  //                 ),
                  //               ),
                  //               child: const Text(
                  //                 'Upgrade now',
                  //                 style: TextStyle(
                  //                   fontSize: 12,
                  //                   fontWeight: FontWeight.bold,
                  //                 ),
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //       const SizedBox(width: 12),
                  //       Image.asset(
                  //         'assets/images/plant_upgrade.png',
                  //         width: 100,
                  //         height: 120,
                  //         errorBuilder: (context, error, stackTrace) {
                  //           return Container(
                  //             width: 100,
                  //             height: 120,
                  //             decoration: BoxDecoration(
                  //               color: Colors.grey[300],
                  //               borderRadius: BorderRadius.circular(8),
                  //             ),
                  //             child: const Icon(
                  //               Icons.local_florist,
                  //               size: 40,
                  //               color: Colors.grey,
                  //             ),
                  //           );
                  //         },
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  //
                  // const SizedBox(height: 24),

                  // Manage garden section
                  _buildSectionHeader('Manage garden'),
                  const SizedBox(height: 12),

                  // General section
                  _buildSectionHeader('General'),
                  const SizedBox(height: 12),

                  // Security
                  _buildMenuItem(
                    icon: Icons.shield_outlined,
                    title: 'Security',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SecurityScreen(),
                        ),
                      );
                    },
                  ),

                  // Privacy Policy
                  _buildMenuItem(
                    icon: Icons.lock_outline,
                    title: 'Privacy Policy',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const privacy.PrivacyPolicyScreen(),
                        ),
                      );
                    },
                  ),

                  // Terms of Service
                  _buildMenuItem(
                    icon: Icons.description_outlined,
                    title: 'Terms of Service',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TermsOfServiceScreen(),
                        ),
                      );
                    },
                  ),

                  // Reminder Notification
                  _buildMenuItemWithSwitch(
                    icon: Icons.notifications_outlined,
                    title: 'Reminder Notification',
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                  ),

                  // Language
                  _buildMenuItem(
                    icon: Icons.language,
                    title: 'Language',
                    trailing: Text(
                      _selectedLanguage,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LanguageSelectionScreen(),
                        ),
                      );

                      if (result != null) {
                        setState(() {
                          _selectedLanguage = result;
                        });
                      }
                    },
                  ),

                  // About us
                  _buildMenuItem(
                    icon: Icons.info_outline,
                    title: 'About us',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AboutUsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey[800]!,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            if (trailing != null)
              trailing
            else
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItemWithSwitch({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[800]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF90EE90),
            activeTrackColor: const Color(0xFF90EE90).withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}

// Placeholder screens
class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Security',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: const Center(
        child: Text(
          'Security Settings',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}


class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@plantai.app',
      queryParameters: {
        'subject': 'Plant AI App Feedback',
      },
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchWebsite() async {
    final Uri url = Uri.parse('https://plantai.app');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'About Us',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // App Logo and Name
          Center(
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF90EE90), Color(0xFF5DBB63)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF90EE90).withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.eco_rounded,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Plant AI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Description
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Text(
              'Plant AI helps you identify plants, diagnose plant health issues, and manage your garden with AI-powered technology. Take care of your plants with smart reminders and personalized care guides.',
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 15,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),

          // Contact Section
          const Text(
            'Contact Us',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Email
          _buildContactItem(
            icon: Icons.email_outlined,
            title: 'Email',
            subtitle: 'support@plantai.app',
            onTap: _launchEmail,
          ),

          // Website
          _buildContactItem(
            icon: Icons.language,
            title: 'Website',
            subtitle: 'https://plantai.app',
            onTap: _launchWebsite,
          ),

          const SizedBox(height: 32),

          // Social Links
          const Text(
            'Follow Us',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialButton(Icons.facebook, 'Facebook', 'https://facebook.com/plantaiapp'),
              const SizedBox(width: 16),
              _buildSocialButton(Icons.camera_alt, 'Instagram', 'https://instagram.com/plantaiapp'),
              const SizedBox(width: 16),
              _buildSocialButton(Icons.alternate_email, 'Twitter', 'https://twitter.com/plantaiapp'),
            ],
          ),

          const SizedBox(height: 32),

          // Copyright
          Center(
            child: Text(
              '\u00a9 2026 Plant AI. All rights reserved.',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF90EE90).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF90EE90), size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, String label, String url) {
    return InkWell(
      onTap: () async {
        final Uri uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}
