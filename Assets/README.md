# Assets

`GitPulseIcon.svg` is the source logo for GitPulse.

The mark combines a Git-style branch with a pulse line:

- Branch nodes represent GitHub workflow activity.
- The pulse line represents live status changes.
- Green, blue, and purple match the app's status palette.

For a production macOS release, convert this source into an `.icns` file and attach it to the signed `.app` bundle. The current repository is still a Swift package executable, so the icon is stored as source artwork until app bundling is added.
