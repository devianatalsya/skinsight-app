import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../domain/entities/skin_type.dart';
import '../controllers/scan_controller.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/blob_background.dart';
import 'analysis_page.dart';

class ScannerPage extends StatefulWidget {
  final SkinType skinType;

  const ScannerPage({super.key, required this.skinType});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  late final ScanController _controller;
  String? _pickedImagePath;

  @override
  void initState() {
    super.initState();
    _controller = ScanController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _pickedImagePath = result.files.single.path;
        });
        _controller.setImagePath(_pickedImagePath!);
      }
    } catch (_) {
      _showError(AppStrings.errorPermission);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.outfit()),
        backgroundColor: AppColors.darkText,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _analyze() {
    if (_pickedImagePath == null) return;
    _controller.setSkinType(widget.skinType);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AnalysisPage(
          controller: _controller,
          skinType: widget.skinType,
        ),
      ),
    );
    _controller.analyze();
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
          AppStrings.scannerAppBar,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
      ),
      body: BlobBackground(
        blobColor1: AppColors.peach,
        blobColor2: AppColors.sage,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                RevealOnAppear(
                  child: Text(
                    AppStrings.scannerTitle,
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                      letterSpacing: -0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                RevealOnAppear(
                  delay: const Duration(milliseconds: 100),
                  child: Text(
                    AppStrings.scannerHint,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: AppColors.mutedText,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                RevealOnAppear(
                  delay: const Duration(milliseconds: 150),
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: double.infinity,
                      height: 240,
                      decoration: BoxDecoration(
                        color: _pickedImagePath == null
                            ? AppColors.stone100
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: _pickedImagePath == null
                              ? AppColors.stone200
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: _pickedImagePath == null
                          ? _EmptyPickerContent()
                          : _ImagePreview(path: _pickedImagePath!),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (_pickedImagePath == null) ...[
                  RevealOnAppear(
                    delay: const Duration(milliseconds: 200),
                    child: Row(
                      children: [
                        Expanded(
                          child: SoftButton(
                            onPressed: _pickImage,
                            outlined: true,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.camera_alt_outlined, size: 17),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    AppStrings.takePhoto,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.outfit(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SoftButton(
                            onPressed: _pickImage,
                            outlined: true,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.photo_library_outlined,
                                    size: 17),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    AppStrings.chooseGallery,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.outfit(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  RevealOnAppear(
                    child: Row(
                      children: [
                        Expanded(
                          child: SoftButton(
                            onPressed: () {
                              setState(() => _pickedImagePath = null);
                              _controller.clearImage();
                            },
                            outlined: true,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.refresh_rounded, size: 17),
                                const SizedBox(width: 8),
                                Text(AppStrings.retake,
                                    style: GoogleFonts.outfit(fontSize: 14)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SoftButton(
                            onPressed: _analyze,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.search_rounded,
                                    size: 17, color: AppColors.white),
                                const SizedBox(width: 8),
                                Text(
                                  AppStrings.analyze,
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    color: AppColors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                RevealOnAppear(
                  delay: const Duration(milliseconds: 300),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.sage,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.face_outlined,
                            size: 15, color: AppColors.darkText),
                        const SizedBox(width: 6),
                        Text(
                          'Kulit ${widget.skinType.label.toLowerCase()}',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.darkText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyPickerContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.stone200,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.add_photo_alternate_outlined,
            size: 26,
            color: AppColors.mutedText,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          AppStrings.tapToSelect,
          style: GoogleFonts.outfit(
            fontSize: 14,
            color: AppColors.mutedText,
          ),
        ),
      ],
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final String path;

  const _ImagePreview({required this.path});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: Image.file(
        File(path),
        fit: BoxFit.cover,
        width: double.infinity,
        height: 240,
        errorBuilder: (_, _, _) => const Center(
          child: Icon(Icons.broken_image_outlined,
              color: AppColors.mutedText, size: 32),
        ),
      ),
    );
  }
}
