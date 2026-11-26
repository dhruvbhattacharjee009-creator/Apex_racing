# APEX RACING — Phase 0 Architecture & Source Audit

Status: Phase 0 source audit (2026-11-26)
Target: Android-first, fully native 3D racing game. No WebView, Trusted Web Activity, browser game shell, or remote game runtime.

## Repositories

- APEX RACING target: https://github.com/dhruvbhattacharjee009-creator/Apex_racing
- LibreCorsa source/fork: https://github.com/dhruvbhattacharjee009-creator/APEX-librecorsa

## Verified source findings

The LibreCorsa source is a Next.js 16 / React 19 / Three.js web simulator. Its product specification explicitly identifies the platform as web. The existing Android project is a Bubblewrap-generated Trusted Web Activity that launches https://librecorsa.org/play; it is not a native racing engine.

The source README describes substantial simulation systems, including a fixed-step 500 Hz vehicle model, tyre and suspension systems, aero, surface/weather effects, vehicle data, AI, replay and multiplayer features. These are useful references for a port, but they are not automatically reusable as Godot nodes or Android-native code.

The APEX RACING target repository currently contains only its README on main and has no Actions workflow runs. The linked GitHub integration reports push permission, but an earlier write attempt returned HTTP 403. No successful code commit is claimed in this document.

## Architecture direction

Use Godot 4 as the native game runtime and Android export pipeline. The Android APK must package the game engine, scenes, scripts, and required assets locally. Gameplay must not depend on opening a website.

Keep the source simulator as a reference implementation. Port and validate simulation systems incrementally rather than copying the web app or wrapping it.

### Runtime layers

1. Godot application shell: boot, profile, settings, menus, pause and results.
2. Rendering: mobile-oriented 3D renderer, track environment, vehicle visuals, lighting and camera.
3. Vehicle simulation: fixed-step physics loop, chassis state, suspension, tyre forces, drivetrain, brakes and aero.
4. Input: touch steering, throttle/brake, optional tilt steering and gamepad support.
5. Track system: track centreline/spline, road mesh, kerbs, collision surface, pit lane, barriers, timing sectors and spawn grid.
6. Race systems: lap timing, checkpoints, penalties, opponents and session state.
7. Android integration: orientation, lifecycle, safe-area handling, performance settings and offline operation.

## First playable milestone

Build a small native vertical slice before attempting a complete simulator:

- One locally bundled 3D car.
- One test track with a closed loop.
- Chase camera.
- Touch steering, throttle and brake.
- Fixed-step vehicle controller with stable acceleration, braking, steering and collision response.
- Lap timer and restart.
- Android debug APK produced by GitHub Actions.

This milestone is a proof of the native runtime, not a claim of full LibreCorsa physics parity.

## Circuit plan

After the vertical slice is stable, implement two separate circuit packages:

- Monaco: street-circuit layout, narrow road envelope, barriers, elevation changes, tunnel lighting transition, start/finish and timing sectors.
- Monza: road course layout, long straights, chicanes, kerbs, barriers, start/finish and timing sectors.

Track geometry and assets must be independently created or sourced with compatible licences. Do not assume official circuit CAD or proprietary assets are available.

## Porting order

1. Extract and document source simulation data structures and units.
2. Establish coordinate conventions, mass units, time step and deterministic test cases.
3. Port basic chassis and drivetrain behaviour.
4. Port tyre slip/combined-force model and validate against reference scenarios.
5. Add suspension, brakes, differential and aero in separate testable steps.
6. Add surface grip, kerbs and weather only after baseline handling is stable.
7. Add AI, race sessions, replay and online features only after the offline core is reliable.

## Android performance and quality gates

- Target landscape orientation.
- Keep all gameplay assets local; offline launch must work.
- Provide scalable render quality and a low-end preset.
- Avoid per-frame allocations in the vehicle simulation.
- Profile on a physical Android device before raising visual settings.
- Validate touch target sizes and ensure controls do not cover essential track visibility.
- CI must build a debug APK on every relevant push and publish it as an artifact.
- Do not describe an APK as tested on-device unless it has actually been installed and tested.

## Licensing and attribution

The LibreCorsa source repository declares AGPL-3.0. Any copied or adapted source code must retain required notices and comply with the applicable licence obligations, including source-distribution requirements where triggered. Audit each third-party model, sound, texture, font and other asset independently; a repository licence does not automatically grant rights to every bundled asset.

## Explicit non-goals for Phase 0

- No WebView/TWA wrapper presented as a native game.
- No claim that a Godot project already exists.
- No claim that Monaco or Monza assets are complete.
- No claim of realistic full-simulator physics until validated.
- No secrets, signing keys or private credentials committed to the repository.

## Exit criteria

Phase 0 is complete when the architecture and source/licensing audit are reviewed. Phase 1 begins with the native Godot project scaffold, Android export configuration, CI build, and first playable test-track prototype.
