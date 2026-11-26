import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../domain/entities/skin_type.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/blob_background.dart';
import 'scanner_page.dart';

class SkinTypePage extends StatefulWidget {
  final void Function(SkinType) onContinue;
  final bool isEmbedded;

  const SkinTypePage({
    super.key,
    required this.onContinue,
    this.isEmbedded = false,
  });

  @override
  State<SkinTypePage> createState() => _SkinTypePageState();
}

class _SkinTypePageState extends State<SkinTypePage> {
  SkinType? _selected;

  static const _skinColors = {
    SkinType.oily: AppColors.lavender,
    SkinType.dry: AppColors.peach,
    SkinType.combination: AppColors.sage,
    SkinType.sensitive: Color(0xFFF8E8F0),
    SkinType.normal: AppColors.stone100,
  };

  void _onContinue() {
    if (_selected == null) return;
    final selected = _selected!;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ScannerPage(skinType: selected),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlobBackground(
      blobColor1: AppColors.lavender,
      blobColor2: AppColors.sage,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              if (!widget.isEmbedded)
                const BackButton(color: AppColors.darkText),
              RevealOnAppear(
                child: Text(
                  AppStrings.skinTypeTitle,
                  style: GoogleFonts.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                    letterSpacing: -1.0,
                    height: 1.15,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              RevealOnAppear(
                delay: const Duration(milliseconds: 100),
                child: Text(
                  AppStrings.skinTypeSubtitle,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    color: AppColors.mutedText,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.separated(
                  itemCount: SkinType.values.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, index) {
                    final type = SkinType.values[index];
                    return RevealOnAppear(
                      delay: Duration(milliseconds: 150 + index * 60),
                      child: SkinTypePill(
                        label: type.label,
                        description: type.description,
                        selected: _selected == type,
                        color: _skinColors[type] ?? AppColors.stone100,
                        onTap: () => setState(() => _selected = type),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              RevealOnAppear(
                delay: const Duration(milliseconds: 500),
                child: SoftButton(
                  onPressed: _selected == null ? null : _onContinue,
                  backgroundColor: _selected == null
                      ? AppColors.stone200
                      : AppColors.darkText,
                  child: Center(
                    child: Text(
                      AppStrings.skinTypeCta,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: _selected == null
                            ? AppColors.mutedText
                            : AppColors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
