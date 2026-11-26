import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../services/service_locator.dart';
import 'shared_widgets.dart';

/// Bottom sheet allowing the user to configure their own free Gemini API key
/// locally on-device if no compile-time key was bundled.
Future<bool> showApiKeySheet(BuildContext context) async {
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => const _ApiKeySheet(),
  );
  return saved ?? false;
}

class _ApiKeySheet extends StatefulWidget {
  const _ApiKeySheet();

  @override
  State<_ApiKeySheet> createState() => _ApiKeySheetState();
}

class _ApiKeySheetState extends State<_ApiKeySheet> {
  final _textCtrl = TextEditingController();
  bool _hasExistingKey = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _checkExisting();
  }

  Future<void> _checkExisting() async {
    final key = await ServiceLocator.apiKeyStore.getApiKey();
    if (mounted) {
      setState(() => _hasExistingKey = key.isNotEmpty);
    }
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final val = _textCtrl.text.trim();
    if (val.isEmpty) return;
    setState(() => _saving = true);
    await ServiceLocator.apiKeyStore.saveApiKey(val);
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.stone200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Konfigurasi Gemini API',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _hasExistingKey
                ? 'API key sudah tersimpan di perangkat. Masukkan key baru jika ingin mengganti.'
                : 'Masukkan API key gratis dari Google AI Studio. Key hanya disimpan di perangkatmu.',
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: AppColors.mutedText,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _textCtrl,
            obscureText: true,
            style: GoogleFonts.outfit(fontSize: 14, color: AppColors.darkText),
            decoration: InputDecoration(
              hintText: 'Tempel Gemini API key...',
              hintStyle: GoogleFonts.outfit(color: AppColors.mutedText),
              filled: true,
              fillColor: AppColors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.stone200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.stone200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.darkText),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SoftButton(
            onPressed: _saving ? null : _save,
            child: Center(
              child: Text(
                _saving ? 'Menyimpan...' : 'Simpan API Key',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
