# Play Store Content Rating Questionnaire Readiness

Updated: 2026-02-16 23:46 CST (America/Monterrey)

## Planned app classification inputs (draft)
- **App category intent:** Education / Entertainment (final category to be selected in Play Console).
- **Primary functionality:** Interactive fractal exploration and visualization.
- **User-generated content:** No social posting or public UGC feed.
- **Online interaction:** No public chat, no direct user-to-user communication.
- **Location sharing:** No.
- **Personal data collection for advertising:** No ad SDK configured in app module.

## Potentially sensitive capability declarations
- **Camera permission present** (`android.permission.CAMERA`), used for AR mode experiments.
  - Questionnaire answer should reflect optional camera usage and no mature/violent content.
- **Media read permissions present** (`READ_MEDIA_IMAGES`, `READ_MEDIA_VIDEO`) for local media workflows.

## Suggested pre-submit checklist
1. Confirm final Play Console category.
2. Verify camera/AR flow is clearly explained in store listing privacy text.
3. Complete IARC questionnaire with the exact capabilities above.
4. Save questionnaire confirmation screenshot to `store_listing/` for release audit trail.

## Blockers
- None technical. Final content rating answers require Play Console submission context.