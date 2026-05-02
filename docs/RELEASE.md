# Release Checklist

This checklist assumes GitPulse is ready to publish as version 1.0 and that the source code will be hosted publicly on GitHub.

## 1. Prepare The Repository

1. Add a `LICENSE` file.
2. Confirm the README is accurate.
3. Run the full test suite:

   ```sh
   swift test
   ```

4. Tag the release commit only after the app bundle and DMG have been tested.

Recommended first license for a permissive open source app: MIT. If you want stronger patent language, use Apache 2.0.

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

## 3. Create A Real macOS App Bundle

The current project is a Swift package executable. End users should receive a `.app` bundle, not a raw command line binary.

Recommended path:

1. Add an Xcode app target named `GitPulse`.
2. Keep `GitPulseCore` as the reusable library target.
3. Point the app target at the existing app bootstrap.
4. Add `Assets/GitPulseIcon.svg` as the source for the AppIcon asset set.
5. Configure bundle id, version, build number, signing team, and hardened runtime.

Suggested bundle id:

```text
com.gitpulse.GitPulse
```

## 4. App Icon

Convert `Assets/GitPulseIcon.svg` into a macOS AppIcon asset set or `.icns`.

The required macOS icon sizes are:

- 16x16 and 32x32
- 32x32 and 64x64
- 128x128 and 256x256
- 256x256 and 512x512
- 512x512 and 1024x1024

Once an `.iconset` folder exists, create an `.icns` file with:

```sh
iconutil -c icns GitPulse.iconset -o GitPulse.icns
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

A simple first DMG can be created with `hdiutil`:

```sh
mkdir -p dist/dmg-root
cp -R GitPulse.app dist/dmg-root/
ln -s /Applications dist/dmg-root/Applications
hdiutil create -volname "GitPulse" -srcfolder dist/dmg-root -ov -format UDZO dist/GitPulse-1.0.0.dmg
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
