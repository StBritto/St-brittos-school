# St. Britto's Android app

Separate Trusted Web Activity project for the existing school app at https://app.stbrittosschool.in/#home. The GitHub school website's HTML, CSS and scripts are unchanged.

Application ID: `com.robjord.stbrittos`. Version: `1.0.0` (version code 1). Target and compile API: 36. Minimum Android API: 21.

## Notifications

The existing app retains OneSignal web SDK v16, app ID `a466375d-0d07-491e-bad1-f54f8dbf407f`, and `/push/onesignal/OneSignalSDKWorker.js`. Android Browser Helper's notification delegation service and Android notification permission are enabled. The browser remains responsible for the web push subscription. No OneSignal REST API key or Firebase server credential is stored here.

Do not replace this with a plain WebView: the existing web push setup needs a supporting browser. Subscription and delivery still need a real-device test using the installed app and an actual OneSignal notification.

## Build

Install JDK 17 and Android SDK platform 36. Set `JAVA_HOME`, put its `bin` directory on PATH, and configure the SDK path in local.properties (example: `sdk.dir=C:/Android/Sdk`).

Run `./Build-Release.ps1` from PowerShell. It generates an upload key only when one does not already exist, builds a signed AAB and APK, runs release lint, exports the public certificate, and removes the temporary signing.properties file even on build failure. Reuse the same key for future releases and increase versionCode each time.

On this PC, `Build-on-this-PC.ps1` configures the installed JDK and a short Java temporary directory. The GitHub workflow explicitly uses `-PunsignedReleaseForVerification` to compile and lint unsigned release artifacts without a private key. Those artifacts must be signed locally before uploading to Play or installing as a release build. The default release command still requires signing configuration.

The signed AAB belongs in Google Play Console. The APK is for direct device testing. This project does not upload or publish to Google Play automatically.

## Signing backup

The prepared upload key is in `private-signing/stbrittos-upload.jks`, alias `stbrittos-upload`. Its generated password is in `private-signing/upload-password.txt`. Both are confidential local files, excluded from source control; do not upload them to GitHub. Keep a secure offline backup of the entire private-signing folder. This password file is not encrypted by Windows. `Build-Release.ps1 -ExportPassword` displays the password only when you explicitly run that option.

The public upload certificate is `release/upload-certificate.pem`. This is an upload key: Google Play App Signing will normally use a different app signing certificate for Play-installed builds.

## Required domain association

Publish `domain-verification/assetlinks.json` at `https://app.stbrittosschool.in/.well-known/assetlinks.json`, with HTTP 200, JSON content type, and no redirect or authentication. The supplied fingerprint matches the locally generated upload key and is suitable for a directly installed signed APK. Add the SHA-256 fingerprint from Play Console > App integrity > App signing key certificate before testing a Play-installed build. Keep the upload fingerprint alongside it if direct APK testing is still needed.

This file belongs to the separately hosted school app, not the main school website. Without a matching association, the browser shows its toolbar and notification delegation cannot be considered verified.

## Before the Play release

1. Enroll in Play App Signing and add its app signing fingerprint to the domain association.
2. Install the Play internal-test build. Confirm launch without browser toolbar, school pages and links, notification permission, OneSignal subscription, delivery with the app closed, and notification tap behavior.
3. Complete the store listing, privacy policy, Data safety, target audience and content rating based on the actual app behavior. Review the privacy disclosures for OneSignal subscriptions. Obtain any required school authorization and complete account verification/testing requirements shown in your Play Console.
4. Upload a verified signed AAB. A build or domain setup alone is not Google Play approval.

Reference: https://developer.chrome.com/docs/android/trusted-web-activity/quick-start and https://chromium.googlesource.com/chromium/src/+/HEAD/chrome/android/java/src/org/chromium/chrome/browser/browserservices/permissiondelegation/README.md
