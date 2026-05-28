# GitHub Actions App Store Upload

This repository includes `.github/workflows/app-store-build.yml` to archive the iOS/iPad app on a macOS GitHub runner and upload the resulting IPA to App Store Connect.

## What It Builds

- Project: `TactiCoreAI.xcodeproj`
- Scheme: `TactiCoreAI`
- Bundle ID: `com.tacticoreai.app`
- Platform: iOS/iPadOS
- Marketing version: `1.0`
- Build number: GitHub run number by default, or the manual workflow input

The current Xcode target is configured for iOS/iPadOS. A native visionOS build still needs a visionOS/xros target or platform configuration before GitHub can upload a visionOS binary.

## Required GitHub Secrets

Add these in GitHub under `Settings > Secrets and variables > Actions`:

| Secret | Value |
| --- | --- |
| `APPLE_TEAM_ID` | Apple Developer Team ID |
| `ASC_KEY_ID` | App Store Connect API key ID |
| `ASC_ISSUER_ID` | App Store Connect API issuer ID |
| `ASC_API_KEY_P8` | Contents of `AuthKey_<KEY_ID>.p8`, either raw text or base64 encoded |

Do not commit API keys, certificates, provisioning profiles, or `.p8` files to the repository.

## How To Run

The workflow runs automatically after pushes to `main` that touch the app project or workflow file.

You can also run it manually:

1. Open the GitHub repository.
2. Go to `Actions`.
3. Choose `Build and Upload iOS App`.
4. Select `Run workflow`.
5. Leave `upload_to_app_store` enabled.

After upload, the build appears in App Store Connect after Apple finishes processing it. Processing can take several minutes.

## If Signing Fails

Check these first:

- The App Store Connect API key has permission to manage builds and signing.
- `APPLE_TEAM_ID` matches the team that owns `com.tacticoreai.app`.
- The bundle ID exists in Apple Developer/App Store Connect.
- Automatic signing is enabled for the target.
- The App Store Connect app record has the same bundle ID.
