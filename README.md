# SkinSight — Pemeriksa Keamanan Komposisi Skincare & Kosmetik

**SkinSight** adalah aplikasi mobile berbasis Flutter & Dart yang membantu pengguna mengevaluasi daftar komposisi produk _skincare_ dan kosmetik sesuai jenis kulit mereka dengan memindai foto kemasan menggunakan OCR dan menganalisis bahan melalui lapisan AI yang terabstraksi.

---

## 1. Gambaran Umum

SkinSight menghadirkan pengalaman mobile yang tenang dan minimalis (_digital wellness_) untuk memindai label komposisi produk, mengekstrak nama bahan, serta menyajikan informasi edukatif non-medis yang disesuaikan dengan jenis kulit pengguna (`Berminyak`, `Kering`, `Kombinasi`, `Sensitif`, dan `Normal`).

## 2. Latar Belakang Masalah

Banyak konsumen membeli produk _skincare_ atau kosmetik hanya berdasarkan ulasan viral tanpa memahami daftar komposisi (_ingredients_) pada kemasan. Hal ini berisiko menimbulkan:

- Iritasi atau sensitivitas kulit
- Jerawat dan pori-pori tersumbat (_comedogenic_)
- Kulit terlalu kering atau rusaknya _skin barrier_
- Reaksi yang tidak diinginkan akibat kombinasi bahan aktif

Selain itu, basis data kosmetik internasional sering kali belum mencakup produk lokal Indonesia maupun Asia terbaru, dan mengetik daftar komposisi INCI yang panjang secara manual sangat merepotkan.

## 3. Solusi

SkinSight menyederhanakan pengecekan komposisi menjadi alur yang ringkas:

1. Pilih jenis kulitmu.
2. Ambil atau pilih foto daftar komposisi pada kemasan produk.
3. Ekstrak teks komposisi melalui layanan OCR (`OcrService`).
4. Normalisasi nama bahan dan analisis kecocokannya melalui layanan AI (`AIService`).
5. Lihat ringkasan hasil (`Aman dicoba`, `Waspada`, atau `Perlu diperhatikan`), daftar bahan yang disorot, serta detail edukatif tiap bahan.

SkinSight tidak memberikan diagnosis medis maupun klaim keamanan mutlak, melainkan informasi yang bersifat edukatif dan berhati-hati.

## 4. Fitur Utama

- **Beranda (_Home_)**: Tampilan minimalis dengan animasi _organic blob_, logo SkinSight, serta akses cepat ke pemindaian atau halaman FAQ.
- **Pemilihan Jenis Kulit**: Mendukung pilihan kulit **Berminyak**, **Kering**, **Kombinasi**, **Sensitif**, dan **Normal**.
- **Pemindai (_Scanner_)**: Pemilihan foto dari galeri/file beserta pratinjau gambar, tombol ulangi, dan pemicu analisis.
- **Progres OCR & Analisis**: Indikator progres bertahap (`Membaca komposisi...`, `Memeriksa kecocokan...`, `Sebentar lagi...`).
- **Hasil Analisis**: Ringkasan status (`Aman dicoba`, `Waspada`, `Perlu diperhatikan`), konteks jenis kulit, kartu bahan yang perlu diperhatikan, disclaimer non-medis, serta daftar seluruh bahan yang terdeteksi.
- **Detail Bahan**: Menampilkan kategori, potensi perhatian, alasan pentingnya bahan, kecocokan kulit, catatan, dan sumber referensi dari basis pengetahuan lokal.
- **Riwayat Scan**: Menyimpan riwayat pemindaian secara lokal di perangkat dengan waktu relatif, serta aksi lihat ulang atau hapus.
- **FAQ Interaktif**: Akordeon animasi yang menjawab pertanyaan umum seputar SkinSight.
- **Mode Fleksibel**: Mendukung mode Proxy Vercel (bawaan), mode Gemini langsung (dengan _API key_ via `--dart-define` atau disimpan lokal melalui dialog _Atur API Key_), serta mode Mock untuk pengembangan/pengujian offline.

## 5. Alur Pengguna

```text
Beranda -> Pilih Jenis Kulit -> Pemindai (Pilih Foto) -> OCR & Analisis AI -> Hasil -> Detail Bahan
                                                                                |
                                                                          Riwayat Lokal
```

## 6. Teknologi yang Digunakan

- **Framework**: Flutter (Material 3)
- **Bahasa**: Dart
- **AI & OCR Provider**:
  - **Proxy Vercel** (`ProxyAIService` & `ProxyOcrService`) ke backend serverless (`api/` / `proxy/`)
  - **Google Gemini REST API** (`GeminiAIService` & `GeminiOcrService`, default model `gemini-2.5-flash`)
  - **Mode Mock** (`MockAIService` & `MockOcrService`) untuk pengembangan/pengujian offline
- **Penyimpanan Lokal**: File JSON lokal menggunakan `path_provider`

## 7. Versi Flutter / Dart & Dependensi

- **Dart SDK constraint**: `^3.13.4`

Dependensi pada `pubspec.yaml`:

- `flutter` (SDK)
- `cupertino_icons: ^1.0.8`
- `http: ^1.6.0`
- `file_picker: ^8.1.2`
- `path_provider: ^2.1.6`
- `google_fonts: ^9.0.0`
- `flutter_test` (dev)
- `flutter_lints: ^6.0.0` (dev)

## 8. Struktur Proyek

```text
api/                               # Endpoint serverless Vercel (index.js, ocr.js, analyze.js)
proxy/                             # Paket proxy Vercel terpisah (api/ocr.js, api/analyze.js, vercel.json)
assets/
  data/
    ingredients_knowledge.json     # Basis pengetahuan bahan lokal
  images/
    skinsight_logo.png             # Logo resmi SkinSight
lib/
  core/
    constants/
      app_colors.dart              # Palet warna pastel digital wellness
      app_strings.dart             # Teks UI & pesan error berbahasa Indonesia
    theme/
      app_theme.dart               # Tema Material 3 (Outfit & Reenie Beanie)
    utils/
      animation_utils.dart         # Utilitas animasi & organic blob painter
  data/
    datasources/
      history_local_datasource.dart
      ingredient_knowledge_datasource.dart
    models/
      scan_record.dart
    repositories/
      history_repository.dart
      ingredient_repository.dart
  domain/
    entities/
      analysis_result.dart
      ingredient.dart
      skin_type.dart
  presentation/
    controllers/
      history_controller.dart
      scan_controller.dart
    pages/
      analysis_page.dart
      faq_page.dart
      history_page.dart
      home_page.dart
      ingredient_detail_page.dart
      result_page.dart
      scanner_page.dart
      skin_type_page.dart
    widgets/
      api_key_sheet.dart           # Bottom sheet pengaturan API key Gemini lokal
      blob_background.dart
      floating_nav_bar.dart
      shared_widgets.dart
  services/
    ai/
      ai_service.dart
      gemini_ai_service.dart
      mock_ai_service.dart
      proxy_ai_service.dart
    config/
      api_key_store.dart           # Penyimpanan API key lokal (api_config.json)
    ocr/
      ocr_service.dart
      proxy_ocr_service.dart
    service_locator.dart           # Pemilihan provider AI & OCR
  main.dart
```

## 9. Arsitektur Aplikasi

SkinSight menerapkan pola _layered Clean Architecture_:

```text
Presentation (Pages & Widgets)
   -> Controllers (ChangeNotifier: ScanController, HistoryController)
      -> Services & Repositories (AIService, OcrService, IngredientRepository, HistoryRepository)
         -> Data Sources / External APIs (Vercel Proxy / Gemini REST API / Local JSON / Local Storage)
```

- **UI Independen**: Halaman UI tidak mengimpor implementasi spesifik seperti `GeminiAIService` atau `MockAIService`, melainkan berkomunikasi melalui `ScanController` dan `ServiceLocator`.
- **Pemisahan Tanggung Jawab**: Ekstraksi OCR, normalisasi bahan (`IngredientNormalizer`), pencarian pengetahuan bahan, pemilihan profil kulit, analisis AI, dan tampilan hasil dipisahkan secara modular.

## 10. Alur OCR & Analisis Bahan

1. Pengguna memilih foto komposisi pada `ScannerPage` menggunakan `file_picker`.
2. `ScanController.analyze()` mengirim path gambar ke `OcrService.extractText(imagePath)`.
3. `IngredientNormalizer.normalize(rawText)` membersihkan awalan umum (seperti `Ingredients:`, `INCI Name:`, `Komposisi:`), menormalisasi pemisah (`,`, `;`, `/`, bullet, baris baru), dan menghasilkan `List<String>`.
4. `ScanController` mengirim daftar bahan yang telah dinormalisasi beserta `SkinType` ke `AIService.analyzeIngredients()`.
5. `AIService` mengembalikan `AnalysisResult` tervalidasi (`overallStatus`, `summary`, `flaggedIngredients`, `detectedIngredients`, `warnings`).
6. Saat pengguna mengetuk bahan yang disorot, `IngredientDetailPage` mengambil detail tambahan dari `IngredientRepository` berdasarkan `assets/data/ingredients_knowledge.json`.

## 11. Konfigurasi Mode Layanan (`ServiceLocator`)

`ServiceLocator` (`lib/services/service_locator.dart`) menentukan provider AI dan OCR berdasarkan urutan prioritas berikut:

1. **Mode Mock (`USE_MOCK_AI=true`)**
   Menggunakan `MockAIService` dan `MockOcrService` untuk pengembangan/pengujian offline:

   ```bash
   flutter run --dart-define=USE_MOCK_AI=true
   ```

   Secara default (`USE_MOCK_AI=false`), aplikasi **tidak** diam-diam menampilkan hasil palsu jika OCR atau AI gagal, melainkan menampilkan layar error yang jelas.

2. **Mode Proxy Vercel (`API_BASE_URL` terisi, bawaan aktif)**
   Pengguna tidak perlu memasukkan API key apa pun karena `GEMINI_API_KEY` disimpan di sisi server (Vercel). Secara default `API_BASE_URL` mengarah ke URL proxy bawaan, atau dapat diarahkan ke deployment milik sendiri:

   ```bash
   flutter run --dart-define=API_BASE_URL=https://project-anda.vercel.app
   flutter build apk --dart-define=API_BASE_URL=https://project-anda.vercel.app
   ```

   Untuk men-deploy proxy sendiri:

   ```bash
   cd proxy
   npx vercel
   ```

   Lalu tambahkan _Environment Variable_ `GEMINI_API_KEY` (dan opsional `GEMINI_MODEL`, default `gemini-2.5-flash`) di pengaturan proyek Vercel.

3. **Mode Gemini Langsung (Tanpa Proxy)**
   Kosongkan `API_BASE_URL` dan masukkan API key Gemini melalui `--dart-define` atau melalui ikon kunci di Beranda / tombol `"Atur API Key"` di halaman error (tersimpan lokal di `api_config.json`):
   ```bash
   flutter run --dart-define=API_BASE_URL="" --dart-define=GEMINI_API_KEY=api_key_anda
   ```

## 12. Penanganan Error

`ScanController` dan lapisan layanan mengubah error menjadi pesan singkat berbahasa Indonesia tanpa mengekspos _stack trace_:

- Daftar komposisi tidak terbaca -> `"Daftar komposisi tidak terbaca pada foto."`
- Tidak ada koneksi internet -> `"Tidak ada koneksi internet."`
- API key belum diatur -> `"API key Gemini belum dikonfigurasi."`
- API key ditolak -> `"API key Gemini tidak valid atau ditolak."`
- Batas kuota API tercapai -> `"Batas penggunaan API tercapai. Coba lagi nanti."`
- Izin akses foto ditolak -> `"Izin akses foto ditolak."`
- Waktu permintaan habis -> `"Waktu permintaan habis. Coba lagi."`
- Format respons AI tidak valid -> `"Format respons AI tidak valid."`
- Layanan AI tidak tersedia -> `"Analisis AI sedang tidak tersedia saat ini."`

## 13. Model Data

- **`SkinType`**: Enum (`oily`, `dry`, `combination`, `sensitive`, `normal`) beserta label dan deskripsi singkat berbahasa Indonesia.
- **`Ingredient`**: `name`, `normalizedName`, `category`, `potentialRisks`, `skinTypes`, `compatibility`, `whyItMatters`, `source`.
- **`FlaggedIngredient`**: `name`, `risk`, `reason`.
- **`AnalysisResult`**: `overallStatus` (`safe`, `warning`, `caution`), `summary`, `flaggedIngredients`, `detectedIngredients`, `warnings`, `confidence`, `rawOcrText`, `analyzedAt`.
- **`ScanRecord`**: `id`, `productLabel`, `skinType`, `result`, `imagePath`, `scannedAt`.

## 14. Menjalankan & Mem-build Aplikasi

### Menjalankan Aplikasi

```bash
flutter pub get

# Mode bawaan (Proxy)
flutter run

# Mode Mock (Offline / Testing)
flutter run --dart-define=USE_MOCK_AI=true

# Mode Gemini Langsung
flutter run --dart-define=API_BASE_URL="" --dart-define=GEMINI_API_KEY=api_key_anda
```

### Build Android

```bash
# Android APK
flutter build apk

# Android App Bundle
flutter build appbundle
```

### Menjalankan Pengujian

```bash
flutter test
```

## 15. Keamanan & Privasi

- **Tanpa Secret Hardcoded**: API key tidak pernah ditulis langsung di dalam kode sumber; diinjeksi lewat `--dart-define`, environment variable Vercel, atau disimpan lokal di perangkat (`api_config.json`).
- **Validasi Respons Ketat**: Respons mentah dari AI dibersihkan dari _markdown fence_, di-decode, dan divalidasi menjadi entitas bertipe kuat (`AnalysisResult`) sebelum ditampilkan.
- **Disclaimer Non-Medis**: Seluruh hasil analisis bersifat edukatif dan tidak menggantikan konsultasi atau diagnosis dokter kulit.
