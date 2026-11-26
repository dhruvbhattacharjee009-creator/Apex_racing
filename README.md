# APEX RACING

An Android-first native 3D racing game prototype. The target is a fully offline-capable APK with no WebView, Trusted Web Activity, browser game shell, or remote game runtime.

## Current milestone: Phase 1 foundation

This repository contains a Godot 4 project scaffold with:

- A procedural closed-loop 3D test circuit and collision barriers.
- A basic player car controller with acceleration, braking, steering, grip and collision response.
- A smooth chase camera.
- On-screen touch controls plus keyboard controls for desktop testing.
- A native Android export preset targeting arm64.
- GitHub Actions automation to export and upload a debug APK.

The first milestone is a playable foundation, not a finished simulator. The car uses a deliberately simplified controller; it is not yet a validated tyre/suspension simulation.

## Open in Godot

Open this repository as a Godot 4.4.1 project. The entry scene is `scenes/main.tscn`. Press Play to run the test circuit. On desktop use W/A/S/D or arrow keys; Space applies handbrake and R restarts. On a touchscreen use the on-screen steering, brake and throttle buttons.

## Android build

The workflow **Build APEX RACING Android APK** runs on pushes affecting game/project files and can also be started manually from the Actions tab. When it succeeds, download the artifact named `APEX-RACING-Android-APK`.

The exported APK is a debug development build. A release signing key is not stored in this repository.

## Planned development

1. Validate the first native APK on a physical Android device.
2. Improve handling, suspension, tyre forces and vehicle telemetry.
3. Replace the greybox test circuit with original 3D circuit environments.
4. Build Monaco and Monza-inspired street/road circuit layouts using independently created or appropriately licensed assets.
5. Add opponents, race sessions, lap timing, damage and replay systems.

## LibreCorsa source acknowledgement

The separate LibreCorsa source repository is being used as a technical reference for simulation research. It is a web simulator, and its existing Android wrapper is a Trusted Web Activity. This APEX project does not embed or wrap that web runtime. Any source code or assets adapted from LibreCorsa or third parties must be reviewed for licence compatibility and attributed as required.

APEX RACING is an independent project and is not affiliated with Formula 1, the FIA, any team, manufacturer or circuit owner.
