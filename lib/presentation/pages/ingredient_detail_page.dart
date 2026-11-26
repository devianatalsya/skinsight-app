import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../domain/entities/analysis_result.dart';
import '../../domain/entities/ingredient.dart';
import '../../services/service_locator.dart';
import '../widgets/shared_widgets.dart';

class IngredientDetailPage extends StatefulWidget {
  final FlaggedIngredient flaggedIngredient;

  const IngredientDetailPage({
    super.key,
    required this.flaggedIngredient,
  });

  @override
  State<IngredientDetailPage> createState() => _IngredientDetailPageState();
}

class _IngredientDetailPageState extends State<IngredientDetailPage> {
  Ingredient? _knowledge;

  @override
  void initState() {
    super.initState();
    _loadKnowledge();
  }

  Future<void> _loadKnowledge() async {
    final info = await ServiceLocator.ingredientRepository
        .getIngredientInfo(widget.flaggedIngredient.name);
    if (mounted && info != null) {
      setState(() => _knowledge = info);
    }
  }

  @override
  Widget build(BuildContext context) {
    final category = _knowledge?.category;
    final compatibility = _knowledge?.compatibility;
    final whyItMatters =
        _knowledge?.whyItMatters ?? widget.flaggedIngredient.reason;
    final source = _knowledge?.source;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          AppStrings.ingredientDetailTitle,
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 17),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RevealOnAppear(
              child: Text(
                widget.flaggedIngredient.name,
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                  letterSpacing: -0.8,
                  height: 1.2,
                ),
              ),
            ),
            if (category != null && category.isNotEmpty) ...[
              const SizedBox(height: 10),
              RevealOnAppear(
                delay: const Duration(milliseconds: 60),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.stone100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    category,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.mutedText,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            RevealOnAppear(
              delay: const Duration(milliseconds: 100),
              child: _DetailCard(
                label: AppStrings.potentialConcern,
                value: widget.flaggedIngredient.risk,
                icon: Icons.warning_amber_outlined,
                color: const Color(0xFFFFECE8),
              ),
            ),
            const SizedBox(height: 10),
            RevealOnAppear(
              delay: const Duration(milliseconds: 160),
              child: _DetailCard(
                label: AppStrings.whyItMatters,
                value: whyItMatters,
                icon: Icons.info_outline_rounded,
                color: AppColors.lavender,
              ),
            ),
            if (compatibility != null && compatibility.isNotEmpty) ...[
              const SizedBox(height: 10),
              RevealOnAppear(
                delay: const Duration(milliseconds: 200),
                child: _DetailCard(
                  label: AppStrings.skinCompatibility,
                  value: compatibility,
                  icon: Icons.face_outlined,
                  color: AppColors.sage,
                ),
              ),
            ],
            if (source != null && source.isNotEmpty) ...[
              const SizedBox(height: 10),
              RevealOnAppear(
                delay: const Duration(milliseconds: 240),
                child: _DetailCard(
                  label: AppStrings.sourceReference,
                  value: source,
                  icon: Icons.menu_book_outlined,
                  color: AppColors.stone100,
                ),
              ),
            ],
            const SizedBox(height: 10),
            const RevealOnAppear(
              delay: Duration(milliseconds: 280),
              child: _DetailCard(
                label: AppStrings.noteLabel,
                value: AppStrings.medicalDisclaimer,
                icon: Icons.shield_outlined,
                color: AppColors.sage,
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _DetailCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.mutedText),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.mutedText,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 15,
              color: AppColors.darkText,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
