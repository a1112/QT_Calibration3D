# Version management: QT_Calibration3D

## Current authorities

Versions belong to the release units below. Equal numbers do not imply a shared release. Adoption preserves every existing version value; this document does not announce a release.

- `calibration-ui`: `0.1` from `CMakeLists.txt` (native read-only check). Preserve the exact native CMake project version; Qt/QML module and SDK versions are independent.

## Safe local commands

Python 3.11 or newer is required. Both tools use only the standard library. They do not import the application, access devices or networks, install dependencies, run npm lifecycle hooks, build packages, commit, tag, publish, upload, or deploy.

```sh
python scripts/version_manager.py show
python scripts/version_manager.py check
python scripts/check_version_sources.py check
python -m unittest discover -s tests -p test_version_manager.py -v
python -m unittest discover -s tests -p test_version_sources.py -v
```

This repository has no unit eligible for generic automated bumps. Native authorities are checked read-only, or the repository uses source-revision identity. A nonexistent unit or unsafe write request is refused; no synthetic application version is created.

## Native and unversioned boundaries

The read-only native checker uses static parsing for CMake, setuptools INI, Python tuple-derived versions, C++ constants, and Windows resources. It never runs setup.py or evaluates arbitrary Python. For these sources, make a reviewed ecosystem-specific edit to the canonical field and its listed mirrors, then run both checks and the native build/package tests. Qt/QML import versions, database migrations, SDK/dependency versions, vendor trees, binaries, backups and Gitlinks are excluded.

- `calibration-ui`: Read-only native authority checked by scripts/check_version_sources.py. Preserve the exact native CMake project version; Qt/QML module and SDK versions are independent.
  Scope: `CMakeLists.txt`.

## Source revision identity

Use `git rev-parse --verify HEAD` to record an immutable source revision for deployments. For unversioned components and datasets, include that revision with the component path and the reviewed configuration/data provenance. It is not a claim of a numbered product release.

## Release procedure

1. Select the actual release unit and inspect its existing version authority. Use source commit identity for unversioned operational components until an intentional baseline is agreed; do not label mature code 0.1.0 by guesswork.
2. Preview changes, apply only reviewed owned version fields, and run the read-only checks plus the component's normal tests/build. Review lockfile and native mirrors; keep unrelated versions unchanged.
3. Write truthful changes under `Unreleased` in `CHANGELOG.md`. Move entries into a dated release section only when a release actually occurs.
4. Review release artifacts, environment-specific configuration, compatibility, existing signing/SBOM policies and deployment approvals separately. Tags, releases, distribution and deployment are manual decisions outside this tooling.

## Adoption provenance

- Source base: [`64b8ce99758b78c836de5a239b0ece97f2394f6c`](https://github.com/a1112/QT_Calibration3D/commit/64b8ce99758b78c836de5a239b0ece97f2394f6c) from `fix/macos-selected-file-recovery-20261012`.
- Observed default head: `ffc3c88839e77a9db3e2da5099e7fb111d841880` on `main`. The default branch and prior repair refs are not changed.
- Review branch: `chore/version-management-20261012`.
- Repository tags/releases and the central R-Box-Releases identity map were checked during adoption. No central release was verified as this repository's application history. Existing source versions remain authoritative; absence of a GitHub release does not prove an application has never been delivered.
- Only version metadata, documentation, local tooling/tests and a read-only metadata CI workflow are introduced. Full native/runtime/device builds were not run for this adoption; local version-tool checks are not a product acceptance test.
