import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../widgets/shared_widgets.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  static const _faqs = [
    _FaqItem(
      question: 'Apa yang diperiksa saat scan?',
      answer:
          'Sistem membaca daftar komposisi dari foto kemasan dan memeriksa potensi risiko bahan berdasarkan jenis kulitmu.',
    ),
    _FaqItem(
      question: 'Apakah hasilnya merupakan diagnosis medis?',
      answer:
          'Bukan. Hasil hanya bersifat informatif dan tidak menggantikan saran dokter kulit. Selalu lakukan patch test.',
    ),
    _FaqItem(
      question: 'Apakah semua produk skincare bisa di-scan?',
      answer:
          'Bisa, selama daftar komposisi pada kemasan terlihat jelas dan dapat terbaca pada foto.',
    ),
    _FaqItem(
      question: 'Dari mana informasi bahan berasal?',
      answer:
          'Saat ini dari analisis AI berbasis pengetahuan bahan kosmetik. Versi berikutnya akan terhubung ke basis data bahan tervalidasi.',
    ),
    _FaqItem(
      question: 'Apakah riwayat scan disimpan?',
      answer:
          'Riwayat scan disimpan secara lokal di perangkatmu saja.',
    ),
    _FaqItem(
      question: 'Jenis kulit apa saja yang didukung?',
      answer:
          'Berminyak, Kering, Kombinasi, Sensitif, dan Normal. Pilih jenis kulit sebelum scan agar hasil lebih relevan.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            RevealOnAppear(
              child: Text(
                AppStrings.faqTitle,
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                  letterSpacing: -1.0,
                ),
              ),
            ),
            const SizedBox(height: 8),
            RevealOnAppear(
              delay: const Duration(milliseconds: 100),
              child: Text(
                AppStrings.faqSubtitle,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  color: AppColors.mutedText,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ...List.generate(_faqs.length, (index) {
              return RevealOnAppear(
                delay: Duration(milliseconds: 150 + index * 60),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _FaqAccordion(item: _faqs[index]),
                ),
              );
            }),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});
}

class _FaqAccordion extends StatefulWidget {
  final _FaqItem item;

  const _FaqAccordion({required this.item});

  @override
  State<_FaqAccordion> createState() => _FaqAccordionState();
}

class _FaqAccordionState extends State<_FaqAccordion>
    with SingleTickerProviderStateMixin {
  bool _open = false;
  late AnimationController _ctrl;
  late Animation<double> _expandAnim;
  late Animation<double> _rotateAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _expandAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    _rotateAnim = Tween<double>(begin: 0, end: 0.125).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _open = !_open);
    if (_open) {
      _ctrl.forward();
    } else {
      _ctrl.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.stone100),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      widget.item.question,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.darkText,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  AnimatedBuilder(
                    animation: _rotateAnim,
                    builder: (_, child) => Transform.rotate(
                      angle: _rotateAnim.value * 2 * 3.14159,
                      child: child,
                    ),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.stone100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        size: 16,
                        color: AppColors.darkText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizeTransition(
              sizeFactor: _expandAnim,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Text(
                  widget.item.answer,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: AppColors.mutedText,
                    height: 1.6,
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
