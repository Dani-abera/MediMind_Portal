import 'package:flutter/material.dart';
import 'package:medimind_portal/core/utils/fa_compat.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import 'bloc/shell_state.dart';

class BreadcrumbBar extends StatelessWidget {
  final List<BreadcrumbSegment> segments;

  const BreadcrumbBar({super.key, required this.segments});

  @override
  Widget build(BuildContext context) {
    if (segments.isEmpty) return const SizedBox.shrink();

    final items = <Widget>[];
    for (var i = 0; i < segments.length; i++) {
      final seg = segments[i];
      final isLast = i == segments.length - 1;
      items.add(_Crumb(label: seg.label, route: isLast ? null : seg.route, isLast: isLast));
      if (!isLast) {
        items.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Icon(FontAwesomeIcons.chevronRight, size: 10, color: AppColors.neutral300),
          ),
        );
      }
    }
    return Row(children: items);
  }
}

class _Crumb extends StatelessWidget {
  final String label;
  final String? route;
  final bool isLast;

  const _Crumb({required this.label, this.route, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final style = AppTypography.bodySmall.copyWith(
      color: isLast ? Theme.of(context).colorScheme.onSurface : AppColors.neutral400,
      fontWeight: isLast ? FontWeight.w600 : FontWeight.w400,
    );
    if (route == null) return Text(label, style: style);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.go(route!),
        child: Text(label, style: style),
      ),
    );
  }
}
