param([switch]$ExportPassword)
$ErrorActionPreference = 'Stop'
$project = $PSScriptRoot
$privateDir = Join-Path $project 'private-signing'
$passwordFile = Join-Path $privateDir 'upload-password.txt'
$keyFile = Join-Path $privateDir 'stbrittos-upload.jks'
$signingFile = Join-Path $project 'signing.properties'
New-Item -ItemType Directory -Force $privateDir | Out-Null
if ((Test-Path $keyFile) -and !(Test-Path $passwordFile)) { throw 'Existing key has no protected password. Restore its password; do not replace the key.' }
if (!(Test-Path $passwordFile)) {
    $bytes = [byte[]]::new(32)
    [System.Security.Cryptography.RandomNumberGenerator]::Fill($bytes)
    $password = [Convert]::ToBase64String($bytes)
    $password | Set-Content $passwordFile
}
$password = (Get-Content $passwordFile -Raw).Trim()
if ($ExportPassword) {
    Write-Host 'Upload key password (keep this with an offline backup of the JKS):'
    Write-Host $password
    exit
}
$env:STBRITTOS_KEY_PASSWORD = $password
if (!$env:GRADLE_USER_HOME) { $env:GRADLE_USER_HOME = Join-Path $project 'work/gradle-cache' }
$env:ANDROID_USER_HOME = Join-Path $project 'work/android-user'
try {
    if (!(Test-Path $keyFile)) {
        & keytool -genkeypair -keystore $keyFile -storetype JKS -storepass:env STBRITTOS_KEY_PASSWORD -keypass:env STBRITTOS_KEY_PASSWORD -alias stbrittos-upload -keyalg RSA -keysize 3072 -validity 10000 -dname "CN=St. Britto's School, OU=Android Upload, O=St. Britto's School, C=IN"
        if ($LASTEXITCODE -ne 0) { throw 'Upload key generation failed.' }
    }
    @("storeFile=private-signing/stbrittos-upload.jks", "storePassword=$password", 'keyAlias=stbrittos-upload', "keyPassword=$password") | Set-Content $signingFile
    Push-Location $project
    try {
        & .\gradlew.bat --no-daemon bundleRelease assembleRelease lintRelease
        if ($LASTEXITCODE -ne 0) { throw 'Android release build failed.' }
    } finally { Pop-Location }
    $release = Join-Path $project 'release'
    New-Item -ItemType Directory -Force $release | Out-Null
    Copy-Item (Join-Path $project 'app/build/outputs/bundle/release/app-release.aab') (Join-Path $release 'StBrittos-1.0.0.aab')
    Copy-Item (Join-Path $project 'app/build/outputs/apk/release/app-release.apk') (Join-Path $release 'StBrittos-1.0.0.apk')
    & keytool -exportcert -rfc -keystore $keyFile -storepass:env STBRITTOS_KEY_PASSWORD -alias stbrittos-upload -file (Join-Path $release 'upload-certificate.pem')
    Write-Host 'Signed Android bundle and test APK are in release/.'
} finally {
    if (Test-Path $signingFile) { Remove-Item -LiteralPath $signingFile }
    Remove-Item Env:STBRITTOS_KEY_PASSWORD -ErrorAction SilentlyContinue
    $password = $null
}
