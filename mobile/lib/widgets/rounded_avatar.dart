import 'package:flutter/material.dart';

import '../models/person.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'ant/ant.dart';

/// antd `<Avatar src>` sized by Tailwind classes (`w-12 h-12` = 48px).
class ProfileImage extends StatelessWidget {
  final String url;
  final double size;

  const ProfileImage({super.key, required this.url, required this.size});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: url.isEmpty
            ? null
            : Image.network(
                displayProfileUrl(url),
                width: size,
                height: size,
                fit: BoxFit.cover,
                gaplessPlayback: true,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
      ),
    );
  }
}

enum AvatarSize { sm, lg }

/// custom-avatar.tsx: avatar in a `p-1` ring with the name below (`gap-1`).
class RoundedAvatar extends StatelessWidget {
  final Person person;
  final AvatarSize size;
  final Color ringColor;
  final VoidCallback? onTap;

  const RoundedAvatar({
    super.key,
    required this.person,
    this.size = AvatarSize.sm,
    this.ringColor = AppColors.third,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final lg = size == AvatarSize.lg;
    final inherited = DefaultTextStyle.of(context).style;
    final nameStyle =
        lg ? inherited : inherited.merge(cssText(size: 14, lineHeight: 20));

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: ringColor, shape: BoxShape.circle),
            child: ProfileImage(url: person.profile, size: lg ? 56 : 32),
          ),
          const SizedBox(height: 4),
          Text(
            person.name.isEmpty ? '-' : person.name,
            textAlign: TextAlign.center,
            style: nameStyle,
          ),
        ],
      ),
    );
  }
}

/// unknown-person.tsx: a `bg-third` circle with `QuestionOutlined`.
class UnknownPerson extends StatelessWidget {
  final AvatarSize size;
  final VoidCallback? onTap;

  const UnknownPerson({super.key, this.size = AvatarSize.sm, this.onTap});

  @override
  Widget build(BuildContext context) {
    final lg = size == AvatarSize.lg;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(lg ? 16 : 8),
        decoration: const BoxDecoration(color: AppColors.third, shape: BoxShape.circle),
        child: AntIcon(AntIconData.question, size: lg ? 30 : 20),
      ),
    );
  }
}
