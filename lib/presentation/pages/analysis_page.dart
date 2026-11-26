import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../domain/entities/skin_type.dart';
import '../controllers/scan_controller.dart';
import '../widgets/api_key_sheet.dart';
import '../widgets/shared_widgets.dart';
import 'result_page.dart';

class AnalysisPage extends StatefulWidget {
  final ScanController controller;
  final SkinType skinType;

  const AnalysisPage({
    super.key,
    required this.controller,
    required this.skinType,
  });

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _dotCtrl;
  int _stepIndex = 0;
  bool _navigated = false;

  static const _steps = [
    AppStrings.readingIngredients,
    AppStrings.checkingCompatibility,
    AppStrings.almostThere,
  ];

  @override
  void initState() {
    super.initState();
    _dotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    widget.controller.addListener(_onControllerChange);
    _startStepCycle();
  }

  void _startStepCycle() async {
    for (var i = 0; i < _steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 900));
      if (mounted && widget.controller.state != ScanState.error) {
        setState(() => _stepIndex = i);
      }
    }
  }

  void _onControllerChange() {
    if (!mounted) return;
    setState(() {});

    final state = widget.controller.state;
    if (state == ScanState.done && !_navigated && widget.controller.result != null) {
      _navigated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.controller.result != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => ResultPage(
                result: widget.controller.result!,
                skinType: widget.skinType,
                rawIngredients: widget.controller.rawIngredients,
              ),
            ),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChange);
    _dotCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isError = widget.controller.state == ScanState.error;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: isError
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            )
          : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: isError ? _buildErrorState() : _buildLoadingState(),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.coral,
              backgroundColor: AppColors.stone200,
            ),
          ),
          const SizedBox(height: 32),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Text(
              _steps[_stepIndex],
              key: ValueKey(_stepIndex),
              style: GoogleFonts.outfit(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: AppColors.darkText,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Kulit ${widget.skinType.label.toLowerCase()}',
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: AppColors.mutedText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    final message =
        widget.controller.errorMessage ?? AppStrings.errorUnavailable;
    final isKeyError = widget.controller.isApiKeyError;

    return Center(
      child: RevealOnAppear(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFFFECE8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 30,
                color: Color(0xFFB94040),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppStrings.analysisFailedTitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 15,
                color: AppColors.mutedText,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              AppStrings.errorClearerPhoto,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: AppColors.mutedText,
              ),
            ),
            const SizedBox(height: 32),
            if (isKeyError) ...[
              SoftButton(
                onPressed: () async {
                  final saved = await showApiKeySheet(context);
                  if (saved && mounted) {
                    widget.controller.analyze();
                  }
                },
                child: Center(
                  child: Text(
                    AppStrings.configureApiKey,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            SoftButton(
              onPressed: () => widget.controller.analyze(),
              outlined: isKeyError,
              child: Center(
                child: Text(
                  AppStrings.retry,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isKeyError ? AppColors.darkText : AppColors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SoftButton(
              onPressed: () => Navigator.of(context).pop(),
              outlined: true,
              child: Center(
                child: Text(
                  AppStrings.chooseAnotherPhoto,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkText,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
