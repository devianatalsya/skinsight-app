import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../services/service_locator.dart';
import '../widgets/api_key_sheet.dart';
import '../widgets/blob_background.dart';
import '../widgets/floating_nav_bar.dart';
import '../widgets/shared_widgets.dart';
import 'skin_type_page.dart';
import 'history_page.dart';
import 'faq_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _navIndex,
        children: [
          _HomeContent(
            onScanTap: () => setState(() => _navIndex = 1),
            onHowItWorksTap: () => setState(() => _navIndex = 3),
          ),
          SkinTypePage(
            onContinue: (_) {},
            isEmbedded: true,
          ),
          const HistoryPageContent(),
          const FaqPage(),
        ],
      ),
      bottomNavigationBar: FloatingNavBar(
        currentIndex: _navIndex,
        onTap: (index) => setState(() => _navIndex = index),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final VoidCallback onScanTap;
  final VoidCallback onHowItWorksTap;

  const _HomeContent({
    required this.onScanTap,
    required this.onHowItWorksTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlobBackground(
      blobColor1: AppColors.coral,
      blobColor2: AppColors.lavender,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              // Brand mark & optional API key setup button
              RevealOnAppear(
                delay: const Duration(milliseconds: 100),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: AppColors.coral,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 8,
                          height: 8,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'softly',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.darkText,
                      ),
                    ),
                    const Spacer(),
                    if (!ServiceLocator.isUsingProxy)
                      IconButton(
                        onPressed: () => showApiKeySheet(context),
                        icon: const Icon(
                          Icons.key_outlined,
                          size: 20,
                          color: AppColors.mutedText,
                        ),
                        tooltip: AppStrings.configureApiKey,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 64),
              // Hero headline
              RevealOnAppear(
                delay: const Duration(milliseconds: 200),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: AppStrings.homeHeadline1,
                        style: GoogleFonts.outfit(
                          fontSize: 44,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkText,
                          letterSpacing: -1.5,
                          height: 1.12,
                        ),
                      ),
                      TextSpan(
                        text: AppStrings.homeHeadlineAccent,
                        style: GoogleFonts.reenieBeanie(
                          fontSize: 52,
                          color: AppColors.darkText,
                          height: 1.05,
                        ),
                      ),
                      TextSpan(
                        text: AppStrings.homeHeadline2,
                        style: GoogleFonts.outfit(
                          fontSize: 44,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkText,
                          letterSpacing: -1.5,
                          height: 1.12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              RevealOnAppear(
                delay: const Duration(milliseconds: 350),
                child: Text(
                  AppStrings.homeSubheadline,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    color: AppColors.mutedText,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 44),
              RevealOnAppear(
                delay: const Duration(milliseconds: 450),
                child: SoftButton(
                  onPressed: onScanTap,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.document_scanner_outlined,
                          size: 18, color: AppColors.white),
                      const SizedBox(width: 10),
                      Text(
                        AppStrings.homeCta,
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              RevealOnAppear(
                delay: const Duration(milliseconds: 500),
                child: SoftButton(
                  onPressed: onHowItWorksTap,
                  outlined: true,
                  child: Text(
                    AppStrings.homeCtaSecondary,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.darkText,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              const RevealOnAppear(
                delay: Duration(milliseconds: 600),
                child: Row(
                  children: [
                    _InfoPill(
                      icon: Icons.shield_outlined,
                      text: 'Cek keamanan bahan',
                      color: AppColors.sage,
                    ),
                    SizedBox(width: 10),
                    _InfoPill(
                      icon: Icons.face_outlined,
                      text: 'Sesuai jenis kulit',
                      color: AppColors.lavender,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _InfoPill({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.darkText),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                text,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
