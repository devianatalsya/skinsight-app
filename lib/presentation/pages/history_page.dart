import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/scan_record.dart';
import '../../domain/entities/analysis_result.dart';
import '../controllers/history_controller.dart';
import '../widgets/shared_widgets.dart';
import 'result_page.dart';

class HistoryPageContent extends StatefulWidget {
  const HistoryPageContent({super.key});

  @override
  State<HistoryPageContent> createState() => _HistoryPageContentState();
}

class _HistoryPageContentState extends State<HistoryPageContent> {
  late final HistoryController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HistoryController();
    _controller.load();
    _controller.addListener(_rebuild);
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_rebuild);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            RevealOnAppear(
              child: Text(
                AppStrings.historyTitle,
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                  letterSpacing: -1.0,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _controller.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.coral,
                        strokeWidth: 2.5,
                      ),
                    )
                  : _controller.records.isEmpty
                      ? _EmptyState()
                      : _HistoryList(
                          records: _controller.records,
                          onDelete: (id) => _controller.delete(id),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.stone100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.history_rounded,
              size: 28,
              color: AppColors.mutedText,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.noHistory,
            style: GoogleFonts.outfit(
              fontSize: 15,
              color: AppColors.mutedText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppStrings.historyEmptyHint,
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: AppColors.mutedText,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  final List<ScanRecord> records;
  final void Function(String) onDelete;

  const _HistoryList({required this.records, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: records.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, index) {
        final record = records[index];
        return RevealOnAppear(
          delay: Duration(milliseconds: index * 60),
          child: _HistoryCard(
            record: record,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ResultPage(
                  result: record.result,
                  skinType: record.skinType,
                  rawIngredients: record.result.flaggedIngredients
                      .map((f) => f.name)
                      .toList(),
                ),
              ));
            },
            onDelete: () => onDelete(record.id),
          ),
        );
      },
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final ScanRecord record;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _HistoryCard({
    required this.record,
    required this.onTap,
    required this.onDelete,
  });

  Color get _statusColor {
    return switch (record.result.overallStatus) {
      OverallStatus.safe => AppColors.sage,
      OverallStatus.warning => const Color(0xFFFFECE8),
      OverallStatus.caution => const Color(0xFFFFF8E6),
    };
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.stone100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _statusColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                record.result.overallStatus == OverallStatus.safe
                    ? Icons.check_circle_outline_rounded
                    : Icons.warning_amber_rounded,
                size: 20,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.productLabel,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${record.relativeDate} · ${record.skinType.label}',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: AppColors.mutedText,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  record.result.overallStatus.label,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: onDelete,
                  child: const Icon(Icons.close_rounded,
                      size: 16, color: AppColors.mutedText),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
