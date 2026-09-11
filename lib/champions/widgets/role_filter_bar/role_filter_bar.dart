import 'package:flutter/material.dart';
import '../../constants/roles.dart';
import '../../../theme/app_colors.dart';

class RoleFilterBar extends StatelessWidget {
  final String? selectedRole;
  final ValueChanged<String?> onSelect;

  const RoleFilterBar({
    super.key,
    required this.selectedRole,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _Chip(
            label: 'Tous',
            selected: selectedRole == null,
            onTap: () => onSelect(null),
          ),
          ...roleList.map((role) {
            return Padding(
              padding: const EdgeInsets.only(left: 7),
              child: _Chip(
                label: role,
                selected: selectedRole == role,
                onTap: () => onSelect(selectedRole == role ? null : role),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.accentSoft : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: selected ? AppColors.accent : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
