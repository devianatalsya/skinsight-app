# Softly — Skincare & Cosmetic Ingredient Safety Checker

Softly is a Flutter + Dart mobile application that helps users evaluate skincare and cosmetic ingredient lists based on their skin type by scanning product packaging with OCR and analyzing ingredients through an abstracted AI layer.

---

## 1. Project Overview

Softly provides a calm, minimalist mobile experience ("digital wellness") to scan product ingredient labels, extract ingredient names, and surface non-medical, informational insights tailored to a user's skin type (`Oily`, `Dry`, `Combination`, `Sensitive`, `Normal`).

## 2. Problem Statement

Many consumers purchase skincare or cosmetic products based on viral reviews without understanding the ingredient list printed on the packaging. This can lead to:

- Skin irritation or sensitization
- Breakouts and clogged pores (comedogenicity)
- Excessive dryness or compromised skin barrier
- Unintended reactions from active ingredient combinations

Additionally, international cosmetic databases often lack coverage for newer or local Indonesian and Asian skincare products. Users also find manual typing of long INCI ingredient lists tedious.

## 3. Solution

Softly streamlines ingredient checking into a simple flow:

1. Select your skin type.
2. Take or pick a photo of the product's ingredient list.
3. Extract text via an abstracted OCR service.
4. Normalize ingredients and analyze compatibility via an abstracted AI service.
5. View a clear summary (`Looks good` or `Needs attention`), flagged ingredients, and educational details.

Softly intentionally avoids medical diagnoses and absolute safety claims, using informative, cautious phrasing instead.

## 4. Main Features

- **Home**: Minimalist hero screen with animated organic blobs and quick entry to scanning or FAQ.
- **Skin Type Selection**: Choose from Oily, Dry, Combination, Sensitive, or Normal skin.
- **Scanner**: Large rounded image picker supporting photo selection/capture, image preview, retake, and analysis trigger.
- **OCR & Analysis Progress**: Calm step-by-step progress indicators (`Reading ingredients...`, `Checking compatibility...`, `Almost there...`).
- **Analysis Result**: Clear status summary, skin type context, flagged ingredient cards, non-medical disclaimers, and expandable raw ingredient list.
- **Ingredient Details**: Category, potential concern, why it matters, skin compatibility, and knowledge source reference.
- **Scan History**: Locally persisted scan records with relative timestamps and quick revisit/delete actions.
- **Interactive FAQ**: Smooth animated accordion answering common questions.
- **Offline/Development Mock Mode**: Works out of the box without an API key via `MockAIService` and `MockOcrService`.

## 5. User Flow

```text
Home -> Select Skin Type -> Scanner (Pick/Capture Image) -> OCR & AI Analysis -> Result -> Ingredient Details
                                                                                   |
                                                                            Local History
```

## 6. Technology Stack

- **Framework**: Flutter (Material 3)
- **Language**: Dart
- **AI Provider (Initial)**: Google Gemini 1.5 Flash REST API (Free Tier) + `MockAIService` fallback
- **OCR Provider (Initial)**: Gemini Vision multimodal OCR + `MockOcrService` fallback
- **Persistence**: Local JSON file storage via `path_provider`

## 7. Flutter / Dart Version

- **Dart SDK constraint**: `^3.13.4` (matching existing workspace configuration)

## 8. Existing Dependencies

Softly uses only the pre-existing dependencies from the project environment without adding or modifying versions:

- `flutter` (SDK)
- `cupertino_icons: ^1.0.8`
- `http: ^1.6.0`
- `file_picker: ^8.1.2`
- `path_provider: ^2.1.6`
- `google_fonts: ^9.0.0`
- `flutter_test` (dev)
- `flutter_lints: ^6.0.0` (dev)

## 9. Project Structure

```text
assets/
  data/
    ingredients_knowledge.json   # Local seed ingredient knowledge base
lib/
  core/
    constants/
      app_colors.dart            # Pastel digital wellness color palette
      app_strings.dart           # Concise UI copy & error messages
    theme/
      app_theme.dart             # Material 3 theme (Outfit + Reenie Beanie)
    utils/
      animation_utils.dart       # Organic blob painter & animation constants
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
      blob_background.dart
      floating_nav_bar.dart
      shared_widgets.dart
  services/
    ai/
      ai_service.dart
      gemini_ai_service.dart
      mock_ai_service.dart
    ocr/
      ocr_service.dart
    service_locator.dart
  main.dart
```

## 10. Architecture

Softly follows a layered Clean Architecture pattern:

```text
Presentation (Pages & Widgets)
   -> Controllers (ChangeNotifier: ScanController, HistoryController)
      -> Services & Repositories (AIService, OcrService, IngredientRepository, HistoryRepository)
         -> Data Sources / External APIs (Gemini REST API, Local JSON, Local Storage)
```

- **UI Independence**: Pages never import `GeminiAIService` or `MockAIService` directly. They communicate only through `ScanController` and `ServiceLocator`.
- **Separated Concerns**: OCR extraction, ingredient normalization, ingredient knowledge lookup, skin profile selection, AI analysis, and explanation presentation are cleanly decoupled.

## 11. AI Architecture

```text
UI
 |
ScanController
 |
AIService (abstract interface)
 |--- MockAIService (offline / no API key)
 |--- GeminiAIService (Gemini 1.5 Flash REST API)
 |--- [Future] RAGAIService
 |--- [Future] FineTunedAIService
```

To swap AI providers, implement `AIService` and update `ServiceLocator.aiService` in `lib/services/service_locator.dart`. No UI code needs to change.

## 12. OCR Flow

1. User selects an image in `ScannerPage` using `file_picker`.
2. `ScanController.analyze()` passes the image path to `OcrService.extractText(imagePath)`.
3. If `GEMINI_API_KEY` is configured, `GeminiOcrService` sends the base64-encoded image to Gemini Vision. Otherwise, `MockOcrService` returns sample INCI text for development.
4. `IngredientNormalizer.normalize(rawText)` strips common label prefixes (`Ingredients:`, `INCI Name:`), normalizes separators (`,`, `;`, `/`, bullets, newlines), and produces a clean `List<String>`.

## 13. Ingredient Analysis Flow

1. `ScanController` sends the normalized `List<String>` and selected `SkinType` to `AIService.analyzeIngredients()`.
2. `AIService` returns a validated `AnalysisResult` containing `overallStatus`, `summary`, `flaggedIngredients`, and `warnings`.
3. When a user taps a flagged ingredient, `IngredientDetailPage` queries `IngredientRepository` to enrich the view with category, skin compatibility, and reference source from `assets/data/ingredients_knowledge.json`.

## 14. Gemini Integration

`GeminiAIService` and `GeminiOcrService` use Google's Gemini 2.5 Flash (`generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent`, configurable via `--dart-define=GEMINI_MODEL=...`) via `package:http`:

- Enforces `responseMimeType: "application/json"` and low temperature (`0.2`) for deterministic structured Indonesian JSON output.
- Applies a 30-second timeout and strips accidental markdown fences before parsing.
- Validates JSON fields into `AnalysisResult` and `FlaggedIngredient`.
- Instructs Gemini Vision OCR to return `NO_INGREDIENTS_FOUND` when a photo does not show a readable ingredient list, triggering an explicit error state instead of hallucinating results.

## 15. API Key & Vercel Proxy Configuration

**Never hard-code API keys in source code or commit them to Git.**

Softly supports three modes (configured automatically in `ServiceLocator`):

### Option A — Vercel Functions Proxy (Recommended for Sharing / Public APK)
Users do **not** need to enter any API key. Your `GEMINI_API_KEY` stays safely on Vercel:

1. Deploy the `proxy/` folder to [Vercel](https://vercel.com) (free tier):
   ```bash
   cd proxy
   npx vercel
   ```
2. In Vercel Project Settings -> **Environment Variables**, add:
   - `GEMINI_API_KEY` = your free-tier key from [Google AI Studio](https://aistudio.google.com)
   - (Optional) `GEMINI_MODEL` = `gemini-2.5-flash`
3. Build or run Flutter pointing to your Vercel URL:
   ```bash
   flutter run --dart-define=API_BASE_URL=https://your-project.vercel.app
   flutter build apk --dart-define=API_BASE_URL=https://your-project.vercel.app
   ```

### Option B — Direct Gemini Mode (No Backend Needed)
1. Pass the key at build/run time via `--dart-define=GEMINI_API_KEY=...`, OR
2. Tap the key icon on the Home screen or `"Atur API Key"` on the error screen to save a personal free Gemini API key locally on-device (`api_config.json`).

### Option C — Explicit Mock Mode (Offline Development / Testing)
```bash
flutter run --dart-define=USE_MOCK_AI=true
```
By default (`USE_MOCK_AI=false`), Softly **never** silently falls back to fake mock results when OCR or AI fails—instead it displays a clear error state so you always know whether the AI scan succeeded or failed.

## 16. Error Handling

`ScanController` and service classes handle and sanitize errors into short, user-friendly messages without exposing stack traces:

- Missing API key -> `"API key not configured."` (or automatic Mock fallback via `ServiceLocator`)
- Unreadable/empty ingredients -> `"Couldn't read the ingredients."`
- Permission denied -> `"Permission denied."`
- Network unavailable -> `"No internet connection."`
- Request timeout -> `"Request timed out."`
- Invalid AI JSON response -> `"Received an invalid response."`
- General API failure -> `"Analysis is unavailable right now."`

## 17. Data Models

- **`SkinType`**: Enum (`oily`, `dry`, `combination`, `sensitive`, `normal`) with label and short description.
- **`Ingredient`**: `name`, `normalizedName`, `category`, `potentialRisks`, `skinTypes`, `compatibility`, `whyItMatters`, `source`.
- **`FlaggedIngredient`**: `name`, `risk`, `reason`.
- **`AnalysisResult`**: `overallStatus` (`safe`, `warning`, `caution`), `summary`, `flaggedIngredients`, `detectedIngredients`, `warnings`, `confidence`, `rawOcrText`, `analyzedAt`.
- **`ScanRecord`**: `id`, `productLabel`, `skinType`, `result`, `imagePath`, `scannedAt`.

## 18. AI Response Schema

### Input Concept
```json
{
  "skin_type": "sensitive",
  "ingredients": [
    "Water",
    "Niacinamide",
    "Alcohol Denat.",
    "Fragrance"
  ]
}
```

### Expected Output JSON Schema
```json
{
  "overall_status": "warning",
  "summary": "Some ingredients may require attention for sensitive skin.",
  "flagged_ingredients": [
    {
      "name": "Alcohol Denat.",
      "risk": "Potential irritation",
      "reason": "May be irritating on sensitive or dry skin."
    }
  ],
  "warnings": [
    "This is not a medical diagnosis. Patch test recommended."
  ],
  "confidence": 0.85
}
```

## 19. Current Limitations

- **Mock Mode Without Key**: Without `GEMINI_API_KEY`, OCR and AI analysis use deterministic mock data for development/demo purposes.
- **On-Device OCR**: No dedicated on-device ML Kit OCR dependency was added to honor strict dependency constraints; OCR uses Gemini Vision or mock fallback.
- **Image Cropping**: Image preview and retake are supported; manual cropping is omitted to avoid adding external cropping dependencies.
- **Local Knowledge Seed**: `assets/data/ingredients_knowledge.json` contains an initial sample dataset rather than a complete BPOM/CosIng database.

## 20. RAG Readiness

The codebase separates:
1. OCR extraction (`OcrService`)
2. Ingredient normalization (`IngredientNormalizer`)
3. Knowledge retrieval (`IngredientKnowledgeDataSource` & `IngredientRepository`)
4. User skin profile (`SkinType`)
5. AI reasoning (`AIService`)

### Future RAG Architecture

```text
User Image
  -> OCR (OcrService)
  -> Ingredient Normalization (IngredientNormalizer)
  -> Retrieval (Vector DB / BPOM / CosIng API via IngredientKnowledgeDataSource)
  -> Ingredient Knowledge Base (Validated Sources)
  -> Context Injection (Prompt + Retrieved Ingredient Facts)
  -> AI Model (RAGAIService implements AIService)
  -> Structured Analysis (AnalysisResult)
  -> UI (ResultPage & IngredientDetailPage)
```

Using a Retrieval-Augmented Generation (RAG) pipeline ensures that ingredient assessments are grounded in validated cosmetic safety databases (such as BPOM, CIR, or CosIng) rather than relying solely on generic LLM pre-training memory—especially important for local Indonesian and Asian skincare products.

## 21. Fine-Tuning Readiness

### Future Fine-Tuning Architecture

Because the presentation layer depends only on `AIService` and `AnalysisResult`, a domain-specific fine-tuned model (e.g., a fine-tuned Gemma, Llama, or Gemini tuned model specialized in INCI nomenclature and Indonesian skincare formulations) can be integrated by creating:

```dart
class FineTunedAIService implements AIService {
  // Calls fine-tuned model endpoint or local inference runtime
}
```

Registering it in `ServiceLocator.aiService` replaces the active provider without modifying any page, widget, or controller.

## 22. Future Development

- Integrate a vector database / RAG backend for Indonesian BPOM and Asian cosmetic ingredient coverage.
- Add on-device OCR support for offline ingredient scanning.
- Expand `ingredients_knowledge.json` or sync with a validated cosmetic ingredient dataset.
- Support active-ingredient combination conflict warnings across multiple scanned products in a user's routine.

## 23. How to Run

### Development / Mock Mode (No API Key Required)
```bash
flutter pub get
flutter run
```

### With Gemini API (Free Tier)
```bash
flutter pub get
flutter run --dart-define=GEMINI_API_KEY=your_gemini_api_key_here
```

## 24. How to Build

```bash
# Android APK
flutter build apk --dart-define=GEMINI_API_KEY=your_gemini_api_key_here

# Android App Bundle
flutter build appbundle --dart-define=GEMINI_API_KEY=your_gemini_api_key_here
```

## 25. Security Considerations

- **No Hard-Coded Secrets**: API keys are injected at compile/run time via `--dart-define`.
- **Git Hygiene**: `.gitignore` blocks `.env` and secret files from version control.
- **No UI Exposure**: API keys are never displayed in the UI or error messages.
- **Strict Response Parsing**: Raw AI responses are stripped, JSON-decoded, and validated into strongly typed entities (`AnalysisResult`) before rendering.
- **Non-Medical Disclaimer**: Outputs are strictly informational and never claim medical certainty.
