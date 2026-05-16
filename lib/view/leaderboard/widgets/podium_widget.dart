import 'package:flutter/material.dart';
import 'package:green_miles_app/core/app_theme.dart';
import 'package:green_miles_app/data/models/user_model.dart';

class PodiumWidget extends StatelessWidget {
  final List<UserModel> topUsers; // Expects a list of 3 users, sorted by rank

  const PodiumWidget({super.key, required this.topUsers});

  @override
  Widget build(BuildContext context) {
    if (topUsers.length < 3) return const SizedBox.shrink();

    final user1 = topUsers[0];
    final user2 = topUsers[1];
    final user3 = topUsers[2];

    return SizedBox(
      height: 250,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 2nd Place
          _buildPodiumStep(context, user2, 2, 65, const Color(0xFFC0C0C0), const Color(0xFFC0C0C0)),
          const SizedBox(width: 12),
          // 1st Place
          _buildPodiumStep(context, user1, 1, 100, const Color(0xFFFFD700), const Color(0xFFFFD700)),
          const SizedBox(width: 12),
          // 3rd Place
          _buildPodiumStep(context, user3, 3, 35, const Color(0xFFCD7F32), const Color(0xFFCD7F32)),
        ],
      ),
    );
  }

  Widget _buildPodiumStep(BuildContext context, UserModel user, int rank, double barHeight, Color borderColor, Color barColor) {
    final textTheme = Theme.of(context).textTheme;
    final avatarUrl = user.profileImageUrl.trim();
    final hasAvatar = avatarUrl.isNotEmpty &&
        !(Uri.tryParse(avatarUrl)?.host.contains('google.com') ?? false);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: borderColor.withValues(alpha: 0.5),
          child: CircleAvatar(
            radius: 21,
            child: hasAvatar
                ? ClipOval(
                    child: Image.network(
                      avatarUrl,
                      width: 42,
                      height: 42,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.person_outline),
                    ),
                  )
                : const Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 80,
          child: Text(
            user.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          width: 80,
          child: Text(
            '${user.totalCo2Saved.toStringAsFixed(1)} kg',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: AppTheme.subtitleTextColor),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: barHeight,
          child: Container(
            width: 80,
            decoration: BoxDecoration(
              color: barColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border.all(color: borderColor, width: 2),
              boxShadow: [
                BoxShadow(
                  color: borderColor.withValues(alpha: 0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Center(
              child: Text(
                '$rank',
                style: textTheme.displayMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 34,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

