import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/widgets/remote_image/remote_image.dart';
import '../../../recommendations/models/role_recommendation.dart';
import '../../../runes/models/rune.dart';
import '../../../runes/services/rune_service.dart';
import '../../../theme/app_colors.dart';

class RunePlanSection extends StatelessWidget {
  final RunePlan plan;

  const RunePlanSection({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final primaryTree = RuneService.treeByKey(plan.primaryTreeKey);
    final keystone = RuneService.runeByKey(plan.keystoneKey);
    final primaryRunes = plan.primaryRuneKeys
        .map(RuneService.runeByKey)
        .whereType<Rune>()
        .toList();

    final secondaryTree = RuneService.treeByKey(plan.secondaryTreeKey);
    final secondaryRunes = plan.secondaryRuneKeys
        .map(RuneService.runeByKey)
        .whereType<Rune>()
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RuneTreeGroup(
          tree: primaryTree,
          keystone: keystone,
          minorRunes: primaryRunes,
        ),
        if (secondaryTree != null || secondaryRunes.isNotEmpty) ...[
          const SizedBox(height: 14),
          _RuneTreeGroup(tree: secondaryTree, minorRunes: secondaryRunes),
        ],
      ],
    );
  }
}

class _RuneTreeGroup extends StatelessWidget {
  final RuneTree? tree;
  final Rune? keystone;
  final List<Rune> minorRunes;

  const _RuneTreeGroup({this.tree, this.keystone, required this.minorRunes});

  @override
  Widget build(BuildContext context) {
    if (tree == null && keystone == null && minorRunes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (tree != null) _RuneTreeHeader(tree: tree!),
          if (tree != null) const SizedBox(height: 10),
          Wrap(
            spacing: 14,
            runSpacing: 10,
            children: [
              if (keystone != null) _RuneChip(rune: keystone!, emphasize: true),
              ...minorRunes.map((rune) => _RuneChip(rune: rune)),
            ],
          ),
        ],
      ),
    );
  }
}

class _RuneTreeHeader extends StatelessWidget {
  final RuneTree tree;

  const _RuneTreeHeader({required this.tree});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: RemoteImage(
            url: tree.iconUrl,
            width: 20,
            height: 20,
            errorWidget: const SizedBox(width: 20, height: 20),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          tree.name,
          style: GoogleFonts.instrumentSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _RuneChip extends StatelessWidget {
  final Rune rune;
  final bool emphasize;

  const _RuneChip({required this.rune, this.emphasize = false});

  @override
  Widget build(BuildContext context) {
    final size = emphasize ? 40.0 : 32.0;

    return SizedBox(
      width: 64,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            padding: EdgeInsets.all(emphasize ? 4 : 5),
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
              border: Border.all(
                color: emphasize ? AppColors.accent : AppColors.border,
                width: emphasize ? 1.5 : 1,
              ),
            ),
            child: RemoteImage(
              url: rune.iconUrl,
              errorWidget: const Icon(
                Icons.circle_outlined,
                size: 14,
                color: AppColors.textMuted,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            rune.name,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.instrumentSans(
              fontSize: 10,
              fontWeight: emphasize ? FontWeight.w600 : FontWeight.w500,
              height: 1.25,
              color: emphasize ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
