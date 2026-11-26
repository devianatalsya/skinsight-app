import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../domain/entities/analysis_result.dart';
import '../../domain/entities/skin_type.dart';
import '../widgets/shared_widgets.dart';
import 'ingredient_detail_page.dart';

class ResultPage extends StatelessWidget {
  final AnalysisResult result;
  final SkinType skinType;
  final List<String> rawIngredients;

  const ResultPage({
    super.key,
    required this.result,
    required this.skinType,
    required this.rawIngredients,
  });

  Color get _statusColor {
    return switch (result.overallStatus) {
      OverallStatus.safe => AppColors.sage,
      OverallStatus.warning => const Color(0xFFFFECE8),
      OverallStatus.caution => const Color(0xFFFFF8E6),
    };
  }

  Color get _statusTextColor {
    return switch (result.overallStatus) {
      OverallStatus.safe => const Color(0xFF2D6A4F),
      OverallStatus.warning => const Color(0xFFB94040),
      OverallStatus.caution => const Color(0xFF7A5C00),
    };
  }

  IconData get _statusIcon {
    return switch (result.overallStatus) {
      OverallStatus.safe => Icons.check_circle_outline_rounded,
      OverallStatus.warning => Icons.warning_amber_rounded,
      OverallStatus.caution => Icons.info_outline_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          AppStrings.resultTitle,
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 17),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            RevealOnAppear(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: _statusColor,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(_statusIcon, size: 32, color: _statusTextColor),
                    const SizedBox(height: 12),
                    Text(
                      result.overallStatus.label,
                      style: GoogleFonts.outfit(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: _statusTextColor,
                        letterSpacing: -1.0,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      result.summary,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        color: _statusTextColor.withValues(alpha: 0.8),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            RevealOnAppear(
              delay: const Duration(milliseconds: 100),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.lavender,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Kulit ${skinType.label.toLowerCase()}',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkText,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            if (result.flaggedIngredients.isNotEmpty) ...[
              RevealOnAppear(
                delay: const Duration(milliseconds: 150),
                child: Text(
                  AppStrings.ingredientsToNotice,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ...result.flaggedIngredients.asMap().entries.map((entry) {
                final i = entry.key;
                final flagged = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: RevealOnAppear(
                    delay: Duration(milliseconds: 200 + i * 60),
                    child: FlaggedIngredientCard(
                      name: flagged.name,
                      risk: flagged.risk,
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => IngredientDetailPage(
                            flaggedIngredient: flagged,
                          ),
                        ));
                      },
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),
            ],
            if (result.warnings.isNotEmpty) ...[
              RevealOnAppear(
                delay: const Duration(milliseconds: 300),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.stone100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.stone200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          size: 16, color: AppColors.mutedText),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          result.warnings.first,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: AppColors.mutedText,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
            if (rawIngredients.isNotEmpty) ...[
              RevealOnAppear(
                delay: const Duration(milliseconds: 350),
                child: _IngredientsSection(ingredients: rawIngredients),
              ),
            ],
            const SizedBox(height: 32),
            RevealOnAppear(
              delay: const Duration(milliseconds: 400),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.document_scanner_outlined,
                          size: 16),
                      label: Text(AppStrings.scanAgain,
                          style: GoogleFonts.outfit()),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

class _IngredientsSection extends StatefulWidget {
  final List<String> ingredients;

  const _IngredientsSection({required this.ingredients});

  @override
  State<_IngredientsSection> createState() => _IngredientsSectionState();
}

class _IngredientsSectionState extends State<_IngredientsSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Row(
            children: [
              Text(
                AppStrings.viewIngredients,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(width: 6),
              AnimatedRotation(
                turns: _expanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(Icons.expand_more_rounded,
                    color: AppColors.mutedText, size: 20),
              ),
            ],
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          crossFadeState: _expanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.stone100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                widget.ingredients.join(', '),
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: AppColors.mutedText,
                  height: 1.6,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
