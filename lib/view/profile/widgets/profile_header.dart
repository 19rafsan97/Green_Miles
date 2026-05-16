import 'package:flutter/material.dart';
import 'package:green_miles_app/core/app_theme.dart';
import 'package:green_miles_app/data/models/user_model.dart';

class ProfileHeader extends StatelessWidget {
  final UserModel user;

  const ProfileHeader({super.key, required this.user});

  /// Returns true only if [url] looks like a direct image resource.
  static bool _isDirectImageUrl(String url) {
    if (url.isEmpty) return false;
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) return false;
    // Reject obvious non-image pages (e.g. Google image search results)
    if (uri.host.contains('google.com') && uri.path.contains('imgres')) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final avatarUrl = user.profileImageUrl.trim();
    final hasAvatar = _isDirectImageUrl(avatarUrl);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppTheme.primaryGradient,
            boxShadow: AppTheme.softShadow,
          ),
          child: CircleAvatar(
            radius: 46,
            backgroundColor: AppTheme.backgroundColor,
            child: hasAvatar
                ? ClipOval(
                    child: Image.network(
                      avatarUrl,
                      width: 92,
                      height: 92,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.person_outline, size: 36),
                    ),
                  )
                : const Icon(Icons.person_outline, size: 36),
          ),
        ),
        const SizedBox(height: 16),
        Text(user.name, style: textTheme.headlineSmall?.copyWith(color: AppTheme.textColor)),
        const SizedBox(height: 4),
        Text(user.email, style: textTheme.bodyLarge?.copyWith(color: AppTheme.subtitleTextColor)),
      ],
    );
  }
}

