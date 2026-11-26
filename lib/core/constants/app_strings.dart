class AppStrings {
  AppStrings._();

  static const String appName = 'SkinSight';

  // Home
  static const String homeHeadline1 = 'Kenali ';
  static const String homeHeadlineAccent = 'apa\n';
  static const String homeHeadline2 = 'yang kamu pakai\ndi kulitmu.';
  static const String homeSubheadline =
      'Scan komposisi. Pahami potensi risikonya.';
  static const String homeCta = 'Scan komposisi';
  static const String homeCtaSecondary = 'Cara kerja';

  // Skin type
  static const String skinTypeTitle = 'Mulai dari kulitmu.';
  static const String skinTypeSubtitle =
      'Membantu menyesuaikan hasil analisis.';
  static const String skinTypeCta = 'Lanjutkan';

  // Scanner
  static const String scannerAppBar = 'Pemindai';
  static const String scannerTitle = 'Scan komposisi.';
  static const String scannerHint =
      'Pastikan daftar komposisi terlihat jelas.';
  static const String tapToSelect = 'Ketuk untuk memilih foto';
  static const String takePhoto = 'Ambil foto';
  static const String chooseGallery = 'Pilih dari galeri';
  static const String analyze = 'Analisis';
  static const String retake = 'Ulangi';

  // Analysis
  static const String readingIngredients = 'Membaca komposisi...';
  static const String checkingCompatibility = 'Memeriksa kecocokan...';
  static const String almostThere = 'Sebentar lagi...';
  static const String analysisFailedTitle = 'Scan belum berhasil';
  static const String retry = 'Coba lagi';
  static const String chooseAnotherPhoto = 'Pilih foto lain';
  static const String configureApiKey = 'Atur API Key';

  // Result
  static const String resultTitle = 'Hasil analisis';
  static const String looksGood = 'Aman dicoba';
  static const String needsAttention = 'Waspada';
  static const String proceedWithCare = 'Perlu diperhatikan';
  static const String ingredientsToNotice = 'Bahan yang perlu diperhatikan';
  static const String scanAgain = 'Scan lagi';
  static const String viewIngredients = 'Lihat semua bahan';
  static const String potentialConcern = 'Potensi perhatian';

  // Ingredient detail
  static const String ingredientDetailTitle = 'Detail bahan';
  static const String whyItMatters = 'Mengapa ini penting';
  static const String skinCompatibility = 'Kecocokan kulit';
  static const String sourceReference = 'Sumber referensi';
  static const String noteLabel = 'Catatan';
  static const String medicalDisclaimer =
      'Informasi ini bersifat edukatif dan bukan diagnosis medis. '
      'Reaksi tiap orang berbeda. Selalu lakukan patch test.';

  // History
  static const String historyTitle = 'Riwayat';
  static const String noHistory = 'Belum ada riwayat scan.';
  static const String historyEmptyHint =
      'Hasil scan produkmu akan muncul di sini.';

  // FAQ
  static const String faqTitle = 'Pertanyaan';
  static const String faqSubtitle = 'Pertanyaan umum tentang SkinSight.';

  // Navigation
  static const String navHome = 'Beranda';
  static const String navScan = 'Scan';
  static const String navHistory = 'Riwayat';
  static const String navFaq = 'Tanya';

  // Error messages
  static const String errorCantRead =
      'Daftar komposisi tidak terbaca pada foto.';
  static const String errorClearerPhoto =
      'Coba ambil foto bagian komposisi yang lebih jelas.';
  static const String errorUnavailable =
      'Analisis AI sedang tidak tersedia saat ini.';
  static const String errorNoInternet = 'Tidak ada koneksi internet.';
  static const String errorApiKey =
      'API key Gemini belum dikonfigurasi.';
  static const String errorInvalidApiKey =
      'API key Gemini tidak valid atau ditolak.';
  static const String errorQuotaExceeded =
      'Batas penggunaan API tercapai. Coba lagi nanti.';
  static const String errorPermission = 'Izin akses foto ditolak.';
  static const String errorTimeout = 'Waktu permintaan habis. Coba lagi.';
  static const String errorInvalidResponse =
      'Format respons AI tidak valid.';
}
