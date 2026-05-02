# Release Checklist

This checklist assumes GitPulse is ready to publish as version 1.0 and that the source code will be hosted publicly on GitHub.

## 1. Prepare The Repository

1. Confirm the `LICENSE` file is present.
2. Confirm the README is accurate.
3. Run the full test suite:

   ```sh
   swift test
   ```

4. Tag the release commit only after the app bundle and DMG have been tested.

GitPulse currently uses the MIT License.

## 2. Create The GitHub Repository

Create a new GitHub repository, then connect this local repo:

```sh
git remote add origin git@github.com:YOUR_USERNAME/GitPulse.git
git push -u origin HEAD:main
```

If the remote already exists:

```sh
git remote -v
git push -u origin HEAD:main
```

Use GitHub repository settings to add:

- Description
- Website or download link when available
- Topics such as `macos`, `swift`, `swiftui`, `github`, `menubar`, `productivity`
- Branch protection for `main`

## 3. Create A macOS App Bundle

End users should receive a `.app` bundle, not a raw command line binary. The repository includes a release script that wraps the Swift package executable in a minimal macOS app bundle.

Build a local app and DMG:

```sh
scripts/package-release.sh 1.0.0
```

The script creates:

- `dist/GitPulse.app`
- `dist/GitPulse-1.0.0.dmg`
- `dist/GitPulse-1.0.0.dmg.sha256`

For a signed build:

```sh
SIGN_IDENTITY="Developer ID Application: YOUR NAME (TEAMID)" scripts/package-release.sh 1.0.0
```

Suggested bundle id:

```text
com.gitpulse.GitPulse
```

## 4. App Icon

`Assets/GitPulseIcon.svg` is the source logo. The release script uses `scripts/generate-app-icon.swift` to generate `Assets/GitPulse.icns`.

The required macOS icon sizes are:

- 16x16 and 32x32
- 32x32 and 64x64
- 128x128 and 256x256
- 256x256 and 512x512
- 512x512 and 1024x1024

To regenerate only the icon:

```sh
swift scripts/generate-app-icon.swift
```

## 5. Sign And Notarize

A downloadable macOS app should be signed and notarized so users do not see scary Gatekeeper warnings.

You need:

- Apple Developer account
- Developer ID Application certificate
- App-specific password or App Store Connect API key

Typical signing command:

```sh
codesign --force --deep --options runtime --sign "Developer ID Application: YOUR NAME (TEAMID)" GitPulse.app
```

Notarize with:

```sh
xcrun notarytool submit GitPulse.dmg --apple-id "you@example.com" --team-id "TEAMID" --password "APP_SPECIFIC_PASSWORD" --wait
```

Staple the notarization ticket:

```sh
xcrun stapler staple GitPulse.dmg
```

## 6. Build The DMG

The release script creates a simple DMG with the app and an Applications symlink:

```sh
scripts/package-release.sh 1.0.0
```

For a polished installer window later, add a DMG background image and layout script.

## 7. Publish The GitHub Release

Create a version tag:

```sh
git tag v1.0.0
git push origin v1.0.0
```

Create a GitHub Release with:

- Short changelog
- Supported macOS version
- Downloaded DMG attached
- SHA256 checksum

Generate checksum:

```sh
shasum -a 256 dist/GitPulse-1.0.0.dmg
```

## 8. Post Release

After the release:

1. Download the DMG from GitHub Releases.
2. Install it on a clean Mac account if possible.
3. Confirm Gatekeeper opens it without warnings.
4. Connect GitHub.
5. Turn on demo activity.
6. Verify menu bar popover, settings, shortcuts, and theme switching.

## Future Automation

Once the manual release works, automate it with GitHub Actions:

- Build
- Test
- Archive app
- Sign
- Notarize
- Create DMG
- Upload release artifact
