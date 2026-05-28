# TactiCore AI App Store Connect Submission Pack

Use this as the source of truth when filling App Store Connect for the first iOS submission.

## App Record

| Field | Value |
| --- | --- |
| Platform | iOS |
| Name | TactiCore AI |
| Primary language | English (U.K.) |
| Bundle ID | com.tacticore.ai |
| SKU | TACTICORE-AI-IOS-001 |
| User Access | Full Access |

## App Information

| Field | Value |
| --- | --- |
| Subtitle | Elite football coaching OS |
| Primary Category | Sports |
| Secondary Category | Education |
| Content Rights | Yes, the app only includes original UI, original text, generated placeholder visuals, and no third-party club, league, player, or broadcast marks. |
| Age Category | Not Made for Kids |
| Privacy Policy URL | TODO: use a public URL for `AppStoreConnect/PRIVACY_POLICY.md` before submitting. |

## iOS Version 1.0 Metadata

### Promotional Text

Train like a professional club with AI-powered session planning, tactical boards, voice notes, player development and premium exports.

### Description

TactiCore AI is a premium football coaching operating system for coaches, academies, grassroots teams, semi-professional clubs, schools and private football trainers.

Plan sessions, shape tactical identity and create modern coaching experiences with an elite, cinematic football workflow.

Core tools:

- AI session generation for warm-ups, activations, technical drills, tactical drills, conditioned games, coaching points and recovery notes
- Tactical board with player movement placeholders, pressing triggers, transition patterns and set-piece planning
- Voice coach notes with speech-to-text, live transcription and AI coaching summaries
- Match analysis notes that turn tactical observations into training priorities
- Player development tracking across passing, positioning, pace, strength, confidence, discipline, tactical awareness and stamina placeholders
- Session library for generated plans, custom drills, tactical plans and weekly schedules
- Animated drill engine placeholder with moving players, ball movement, tactical zones and transition arrows
- Analytics dashboard for training intensity, tactical focus distribution, session completion and player development trends
- Premium PDF export and shareable coaching graphics placeholders
- StoreKit subscription scaffolding for Pro Coach and Elite Club plans

TactiCore AI is designed to help coaches prepare more clearly, communicate more professionally and deliver training sessions that feel modern, structured and human.

Important: TactiCore AI is a coaching and educational planning tool only. It is not medical advice, sports science advice, safeguarding advice, scouting certification or a guarantee of player outcomes. Coaches should review all AI recommendations and adapt them to their players, environment and club policies.

### Keywords

football,coaching,soccer,training,tactics,drills,academy,coach,analysis,players

### Support URL

TODO: use a public support page before submitting. Recommended fallback: a public GitHub `SUPPORT.md` page or a dedicated website with contact details.

### Marketing URL

https://github.com/lanray07/TactiCore-AI

### Version

1.0

### Copyright

2026 Lanray07

## App Review Information

| Field | Value |
| --- | --- |
| Sign-in required | No |
| Demo account | Not required |
| Contact first name | TODO |
| Contact last name | TODO |
| Contact phone | TODO |
| Contact email | TODO |

### Review Notes

TactiCore AI runs with mock AI enabled by default and does not require an API key, user account, or external backend for review.

The app uses SwiftData for offline local persistence. Voice notes require microphone and speech-recognition permissions; these are optional and only needed when testing the Voice Coach Notes feature. The remote AI endpoint is a placeholder and is not required for the default review flow.

Subscriptions are scaffolded with StoreKit 2. The paywall includes mock activation controls for local testing, and App Store Connect subscription product IDs should match:

- tacticore.pro.monthly
- tacticore.pro.yearly
- tacticore.elite.monthly

The app includes a coaching disclaimer in onboarding, settings, AI assistant and PDF export flows. AI recommendations are presented as educational coaching support only and do not claim medical, sports science, scouting or guaranteed performance outcomes.

## Age Rating Questionnaire

Recommended answers for the current build:

| Category | Answer |
| --- | --- |
| Cartoon or Fantasy Violence | None |
| Realistic Violence | None |
| Prolonged Graphic or Sadistic Realistic Violence | None |
| Profanity or Crude Humor | None |
| Mature or Suggestive Themes | None |
| Horror/Fear Themes | None |
| Medical/Treatment Information | None |
| Alcohol, Tobacco, Drug Use or References | None |
| Simulated Gambling | None |
| Sexual Content or Nudity | None |
| Contests | No |
| Gambling | No |
| Loot Boxes | No |
| Unrestricted Web Access | No |
| User-Generated Content or Social Networking | No public sharing or user-to-user content |
| Kids Category | Not Made for Kids |
| Override Rating | Not applicable |

If App Store Connect asks about generative AI, disclose that the app includes AI-generated coaching and planning text, constrained to football coaching education, with coach review required.

## App Privacy

Recommended answers for the current mock-enabled local build:

| Field | Answer |
| --- | --- |
| Data Used to Track Users | No |
| Tracking Permission / ATT | Not used |
| Third-party advertising | No |
| Third-party analytics SDKs | No |
| Data collected by developer | No, current build stores coaching data locally on device |
| Account creation | No |
| Purchases | Handled by Apple StoreKit/App Store |

Important conditional disclosure:

If a production backend is enabled and voice transcripts, session prompts, player notes or match notes are sent to your server, update App Privacy to disclose collected User Content and any identifiers/diagnostics you collect, including whether the data is linked to the user.

## Export Compliance

The Xcode project now sets:

`ITSAppUsesNonExemptEncryption = NO`

Recommended App Store Connect answer: the app does not use non-exempt encryption. It relies only on standard Apple system frameworks and HTTPS networking if a backend is configured.

## Pricing and Availability

| Field | Value |
| --- | --- |
| App price | Free |
| Availability | All territories unless the business needs restrictions |
| Release option | Manual release after approval |

## Subscriptions

Create one subscription group:

| Field | Value |
| --- | --- |
| Subscription Group Reference Name | TactiCore AI Coaching OS |

Products:

| Reference Name | Product ID | Duration | Price Placeholder | Level | Display Name | Description |
| --- | --- | --- | --- | --- | --- | --- |
| Pro Coach Monthly | tacticore.pro.monthly | 1 Month | GBP 14.99 | Level 2 | Pro Coach Monthly | Unlimited coaching tools monthly |
| Pro Coach Yearly | tacticore.pro.yearly | 1 Year | GBP 119.99 | Level 2 | Pro Coach Yearly | Unlimited coaching tools yearly |
| Elite Club Monthly | tacticore.elite.monthly | 1 Month | GBP 49.99 | Level 1 | Elite Club Monthly | Club-level coaching OS monthly |

Set Elite Club as the higher level than Pro Coach because it includes the broader club and academy placeholder feature set.

## App Store Review Attachments

Generated screenshot assets are available in:

- `AppStoreConnect/Screenshots/iPhone_6_5_Display`
- `AppStoreConnect/Screenshots/iPad_13_Display`
- `AppStoreConnect/Screenshots/Apple_Vision_Pro`
- `AppStoreConnect/SubscriptionReviewScreenshots`
- `AppStoreConnect/SubscriptionImages`

The iPad set is exported at 2048 x 2732 for 13-inch iPad screenshots. The Apple Vision Pro set is exported at 3840 x 2160. Subscription product images are exported at 1024 x 1024. All use the app's premium humanized football imagery placeholders, including footballers, coaches, sideline officials, training-ground photography, tactical overlays, and cinematic pitch atmosphere.

Use screenshots that cover:

1. Onboarding identity setup
2. Dashboard
3. AI Session Generator
4. Voice Coach Notes
5. Tactical Board
6. Player Development
7. Analytics or Paywall

Avoid using third-party club badges, identifiable real-player likenesses, league marks, or UEFA/EA-style names in screenshots.

## Source References

- Apple App Information reference: https://developer.apple.com/help/app-store-connect/reference/app-information/
- Apple Platform Version Information reference: https://developer.apple.com/help/app-store-connect/reference/platform-version-information
- Apple App Privacy details: https://developer.apple.com/app-store/app-privacy-details/
- Apple age rating setup: https://developer.apple.com/help/app-store-connect/manage-app-information/set-an-app-age-rating
- Apple export compliance overview: https://developer.apple.com/help/app-store-connect/manage-app-information/overview-of-export-compliance/
- Apple auto-renewable subscriptions: https://developer.apple.com/help/app-store-connect/manage-subscriptions/offer-auto-renewable-subscriptions/
