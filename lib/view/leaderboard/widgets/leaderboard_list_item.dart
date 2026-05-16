import 'package:flutter/material.dart';
import 'package:green_miles_app/core/app_theme.dart';
import 'package:green_miles_app/data/models/user_model.dart';

class LeaderboardListItem extends StatelessWidget {
  final UserModel user;
  final int rank;

  const LeaderboardListItem({
    super.key,
    required this.user,
    required this.rank,
  });

  static bool _isDirectImageUrl(String url) {
    if (url.isEmpty) return false;
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) return false;
    if (uri.host.contains('google.com') && uri.path.contains('imgres')) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final avatarUrl = user.profileImageUrl.trim();
    final hasAvatar = _isDirectImageUrl(avatarUrl);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Rank
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$rank',
                style: textTheme.titleMedium?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Profile Picture
            CircleAvatar(
              radius: 24,
              child: hasAvatar
                  ? ClipOval(
                      child: Image.network(
                        avatarUrl,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.person_outline),
                      ),
                    )
                  : const Icon(Icons.person_outline),
            ),
            const SizedBox(width: 16),
            // User Name
            Expanded(
              child: Text(
                user.name,
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: AppTheme.textColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // CO2 Saved
            Text(
              '${user.totalCo2Saved.toStringAsFixed(1)} kg',
              style: textTheme.titleMedium?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

