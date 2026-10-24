import 'package:flutter/material.dart';
import '../models/person.dart';
import '../theme/app_colors.dart';

class RoundedAvatar extends StatelessWidget {
  final Person person;
  final AvatarSize size;
  final Color? bg;
  final VoidCallback? onTap;

  const RoundedAvatar({
    super.key,
    required this.person,
    this.size = AvatarSize.sm,
    this.bg,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final avatarSize = size == AvatarSize.lg ? 56.0 : 32.0;
    final fontSize = size == AvatarSize.lg ? 14.0 : 12.0;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: bg ?? AppColors.third,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: avatarSize / 2,
              backgroundColor: AppColors.third,
              backgroundImage: NetworkImage(person.profile),
              onBackgroundImageError: (_, __) {},
            ),
          ),
          const SizedBox(height: 4),
          Text(
            person.name.isEmpty ? '-' : person.name,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: fontSize, color: AppColors.main),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

enum AvatarSize { sm, lg }

class UnknownPerson extends StatelessWidget {
  final AvatarSize size;
  final VoidCallback? onTap;

  const UnknownPerson({
    super.key,
    this.size = AvatarSize.sm,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = size == AvatarSize.lg ? 32.0 : 20.0;
    final padding = size == AvatarSize.lg ? 16.0 : 8.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: const BoxDecoration(
          color: AppColors.third,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.help_outline,
          size: iconSize,
          color: AppColors.main,
        ),
      ),
    );
  }
}

class PersonAvatarOnly extends StatelessWidget {
  final String profileUrl;
  final double size;
  final Color ringColor;
  final VoidCallback? onTap;

  const PersonAvatarOnly({
    super.key,
    required this.profileUrl,
    this.size = 48,
    this.ringColor = AppColors.third,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: ringColor,
          shape: BoxShape.circle,
        ),
        child: CircleAvatar(
          radius: size / 2,
          backgroundColor: AppColors.third,
          backgroundImage: NetworkImage(profileUrl),
          onBackgroundImageError: (_, __) {},
        ),
      ),
    );
  }
}
