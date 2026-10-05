param([Parameter(Mandatory=$true)][string]$UnsignedFolder)
$ErrorActionPreference = 'Stop'
$project = $PSScriptRoot
$unsignedAab = Join-Path $UnsignedFolder 'outputs/bundle/release/app-release.aab'
$unsignedApk = Join-Path $UnsignedFolder 'outputs/apk/release/app-release-unsigned.apk'
$privateDir = Join-Path $project 'private-signing'
$keyFile = Join-Path $privateDir 'stbrittos-upload.jks'
if (!(Test-Path $unsignedAab) -or !(Test-Path $unsignedApk) -or !(Test-Path $keyFile)) { throw 'Verified unsigned release files and the existing upload key are required.' }
$release = Join-Path $project 'release'
New-Item -ItemType Directory -Force $release | Out-Null
$env:STBRITTOS_KEY_PASSWORD = (Get-Content (Join-Path $privateDir 'upload-password.txt') -Raw).Trim()
$sdk = 'C:\Android\Sdk\build-tools\36.1.0'
$alignedApk = Join-Path $release 'aligned-unsigned.apk'
try {
    & jarsigner -keystore $keyFile -storepass:env STBRITTOS_KEY_PASSWORD -keypass:env STBRITTOS_KEY_PASSWORD -sigalg SHA256withRSA -digestalg SHA-256 -signedjar (Join-Path $release 'StBrittos-1.0.0.aab') $unsignedAab stbrittos-upload
    if ($LASTEXITCODE -ne 0) { throw 'AAB signing failed.' }
    & (Join-Path $sdk 'zipalign.exe') -P 16 -f 4 $unsignedApk $alignedApk
    if ($LASTEXITCODE -ne 0) { throw 'APK alignment failed.' }
    & java -jar (Join-Path $sdk 'lib/apksigner.jar') sign --ks $keyFile --ks-key-alias stbrittos-upload --ks-pass env:STBRITTOS_KEY_PASSWORD --key-pass env:STBRITTOS_KEY_PASSWORD --out (Join-Path $release 'StBrittos-1.0.0.apk') $alignedApk
    if ($LASTEXITCODE -ne 0) { throw 'APK signing failed.' }
    & jarsigner -verify (Join-Path $release 'StBrittos-1.0.0.aab')
    if ($LASTEXITCODE -ne 0) { throw 'AAB signature verification failed.' }
    & java -jar (Join-Path $sdk 'lib/apksigner.jar') verify --verbose --print-certs (Join-Path $release 'StBrittos-1.0.0.apk')
    if ($LASTEXITCODE -ne 0) { throw 'APK signature verification failed.' }
    & (Join-Path $sdk 'zipalign.exe') -c -P 16 4 (Join-Path $release 'StBrittos-1.0.0.apk')
    if ($LASTEXITCODE -ne 0) { throw 'APK alignment verification failed.' }
    Get-ChildItem (Join-Path $UnsignedFolder 'reports') -Filter 'lint-results-release.*' | Copy-Item -Destination $release
    Get-FileHash (Join-Path $release 'StBrittos-1.0.0.aab'),(Join-Path $release 'StBrittos-1.0.0.apk') -Algorithm SHA256 | Format-Table -AutoSize
} finally {
    if (Test-Path $alignedApk) { Remove-Item -LiteralPath $alignedApk }
    Remove-Item Env:STBRITTOS_KEY_PASSWORD -ErrorAction SilentlyContinue
}
