# Claude Code Instructions — bestwatchlist

## Version Numbering

Versions follow the format **vX.Y.Z**:

- **X** (major): Only incremented when explicitly instructed by the user.
- **Y** (minor): Incremented on every commit.
- **Z** (patch): Incremented on every prompt sent by the user for the bestwatchlist project.

The version is tracked in `pubspec.yaml` (e.g., `version: 1.0.0+1`). The build number after `+` mirrors the Z value or can be kept in sync separately.

### Examples
- User sends a prompt → bump Z: `v1.0.0` → `v1.0.1`
- Commit made → bump Y (reset Z to 0): `v1.0.1` → `v1.1.0`
- User says "bump major version" → bump X (reset Y and Z to 0): `v1.1.0` → `v2.0.0`
