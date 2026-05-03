# Assets

`GitPulseIcon.svg` is the source logo for GitPulse.

The mark combines a Git-style branch with a pulse line:

- Branch nodes represent GitHub workflow activity.
- The pulse line represents live status changes.
- Green, blue, and purple match the app's status palette.

`GitPulse.icns` is generated from the icon script and is used by local SwiftPM runs and release packaging. Regenerate it with:

```sh
swift scripts/generate-app-icon.swift
```
