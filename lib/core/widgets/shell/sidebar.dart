import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

class SidebarItem {
  final String label;
  final IconData icon;
  final String route;
  final int? badgeCount;
  final List<SidebarItem>? children;
  final bool isDivider;

  const SidebarItem({
    required this.label,
    required this.icon,
    required this.route,
    this.badgeCount,
    this.children,
    this.isDivider = false,
  });
}

class Sidebar extends StatefulWidget {
  final List<SidebarItem> items;
  final bool collapsed;
  final VoidCallback onToggleCollapse;
  final String workspaceName;
  final Color accentColor;
  final Color? backgroundTint;
  final String? userName;
  final String? userRole;
  final String? userAvatarUrl;

  const Sidebar({
    super.key,
    required this.items,
    required this.collapsed,
    required this.onToggleCollapse,
    required this.workspaceName,
    required this.accentColor,
    this.backgroundTint,
    this.userName,
    this.userRole,
    this.userAvatarUrl,
  });

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  final Set<String> _expandedGroups = {};

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isCollapsed = widget.collapsed;
    final width = isCollapsed
        ? AppSpacing.sidebarCollapsedWidth
        : AppSpacing.sidebarWidth;
    final tint = widget.backgroundTint;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: width,
      decoration: BoxDecoration(
        gradient: tint != null
            ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [tint.withAlpha(22), colors.surface],
              )
            : null,
        color: tint == null ? colors.surface : null,
        border: Border(right: BorderSide(color: AppColors.neutral200)),
      ),
      child: Column(
        children: [
          _buildLogo(colors, isCollapsed),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: widget.items
                  .map((item) => _buildItem(context, item, isCollapsed))
                  .toList(),
            ),
          ),
          const Divider(height: 1),
          _buildUserCard(colors, isCollapsed),
          _buildCollapseToggle(isCollapsed),
        ],
      ),
    );
  }

  Widget _buildLogo(ColorScheme colors, bool isCollapsed) {
    return SizedBox(
      height: AppSpacing.topBarHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: widget.accentColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(FontAwesomeIcons.heartPulse,
                  color: Colors.white, size: 16),
            ),
            if (!isCollapsed) ...[
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.workspaceName,
                  style: AppTypography.bodyMedium.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, SidebarItem item, bool isCollapsed) {
    if (item.isDivider) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Divider(height: 1, color: AppColors.neutral200),
      );
    }

    final loc = GoRouterState.of(context).matchedLocation;
    final isSelected = loc == item.route ||
        (item.children?.any((c) => c.route == loc) ?? false);
    final hasChildren = item.children != null && item.children!.isNotEmpty;
    final isExpanded = _expandedGroups.contains(item.route);

    if (hasChildren && !isCollapsed) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNavTile(
            context,
            item,
            isSelected: isSelected,
            isCollapsed: false,
            trailing: FaIcon(
              isExpanded
                  ? FontAwesomeIcons.chevronDown
                  : FontAwesomeIcons.chevronRight,
              size: 10,
              color: AppColors.neutral400,
            ),
            onTap: () => setState(() => isExpanded
                ? _expandedGroups.remove(item.route)
                : _expandedGroups.add(item.route)),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                children: item.children!
                    .map((c) => _buildNavTile(context, c,
                        isSelected: loc == c.route, isCollapsed: false))
                    .toList(),
              ),
            ),
        ],
      );
    }

    return _buildNavTile(context, item,
        isSelected: isSelected, isCollapsed: isCollapsed);
  }

  Widget _buildNavTile(
    BuildContext context,
    SidebarItem item, {
    required bool isSelected,
    required bool isCollapsed,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      child: Material(
        color: isSelected ? widget.accentColor : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          hoverColor: isSelected
              ? widget.accentColor.withAlpha(200)
              : AppColors.neutral100,
          onTap: onTap ?? () => context.go(item.route),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isCollapsed ? 0 : 10,
              vertical: 8,
            ),
            child: isCollapsed
                ? Center(child: _itemIcon(item, isSelected))
                : Row(
                    children: [
                      _itemIcon(item, isSelected),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.label,
                          style: AppTypography.bodySmall.copyWith(
                            color: isSelected
                                ? Colors.white
                                : colors.onSurface,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (item.badgeCount != null && item.badgeCount! > 0)
                        _badge(item.badgeCount!),
                      if (trailing != null) trailing,
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _itemIcon(SidebarItem item, bool isSelected) {
    return FaIcon(
      item.icon,
      size: 15,
      color: isSelected ? Colors.white : AppColors.neutral500,
    );
  }

  Widget _badge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: AppTypography.caption.copyWith(color: Colors.white, fontSize: 10),
      ),
    );
  }

  Widget _buildUserCard(ColorScheme colors, bool isCollapsed) {
    if (isCollapsed) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.primaryLight,
          child: Text(
            widget.userName?.isNotEmpty == true
                ? widget.userName![0].toUpperCase()
                : 'U',
            style: AppTypography.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primaryLight,
            backgroundImage: widget.userAvatarUrl != null
                ? NetworkImage(widget.userAvatarUrl!)
                : null,
            child: widget.userAvatarUrl == null
                ? Text(
                    widget.userName?.isNotEmpty == true
                        ? widget.userName![0].toUpperCase()
                        : 'U',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userName ?? 'User',
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.userRole != null)
                  Text(
                    widget.userRole!,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.neutral500,
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapseToggle(bool isCollapsed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: IconButton(
        icon: FaIcon(
          isCollapsed
              ? FontAwesomeIcons.anglesRight
              : FontAwesomeIcons.anglesLeft,
          size: 14,
          color: AppColors.neutral400,
        ),
        tooltip: isCollapsed ? 'Expand sidebar' : 'Collapse sidebar',
        onPressed: widget.onToggleCollapse,
      ),
    );
  }
}
