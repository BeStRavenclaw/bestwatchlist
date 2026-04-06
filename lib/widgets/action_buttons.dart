import 'package:flutter/material.dart';
import '../constants/app_icons.dart';

/// Data class for popup menu item configuration
class MenuItemData {
  final String value;
  final IconData icon;
  final String label;
  final Color? iconColor;

  const MenuItemData({
    required this.value,
    required this.icon,
    required this.label,
    this.iconColor,
  });
}

/// Reusable popup menu item widget with consistent styling
class ActionMenuItem extends PopupMenuItem<String> {
  ActionMenuItem({
    super.key,
    required String value,
    required IconData icon,
    required String label,
    Color? iconColor,
  }) : super(
          value: value,
          child: Row(
            children: [
              Icon(icon, size: AppIcons.actionSize, color: iconColor),
              const SizedBox(width: 8),
              Text(label),
            ],
          ),
        );

  /// Create from MenuItemData
  factory ActionMenuItem.fromData(MenuItemData data) {
    return ActionMenuItem(
      value: data.value,
      icon: data.icon,
      label: data.label,
      iconColor: data.iconColor,
    );
  }
}

/// Standardized popup menu button with consistent icon sizing
class ActionPopupMenu extends StatelessWidget {
  final List<PopupMenuEntry<String>> items;
  final void Function(String) onSelected;
  final String? tooltip;
  final IconData icon;
  final double? iconSize;

  const ActionPopupMenu({
    super.key,
    required this.items,
    required this.onSelected,
    this.tooltip,
    this.icon = AppIcons.moreActions,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(icon, size: iconSize ?? AppIcons.actionSize),
      tooltip: tooltip ?? 'More actions',
      onSelected: onSelected,
      itemBuilder: (context) => items,
    );
  }
}

/// Wrapper for IconButton with consistent sizing
class ActionIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? color;
  final double? size;

  const ActionIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: size ?? AppIcons.actionSize, color: color),
      onPressed: onPressed,
      tooltip: tooltip,
    );
  }
}

/// Empty state widget with icon and message
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? iconColor;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: AppIcons.emptyStateSize,
            color: iconColor ?? Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
