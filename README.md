# Nirmay --- Mobile Farmer Mock (README)

> This repo is a UI/UX prototype --- not a production app. It's built to
> demo livestock management, AMU logging, simple onboarding flows, and a
> few mock pages (Profile, Badges, Alerts, Vet contact, etc.).
> Everything is mocked; behaviour is intentionally limited and
> deterministic so you can play with UI flows.

------------------------------------------------------------------------

## Quick summary (TL;DR)

-   Flutter app (single-project mock) that simulates a farmer-facing UI.
-   Key features: Home dashboard, Livestock management, animal profiles,
    AMU logging dialog, animals-on-medicine list, sell/mark-dead flows,
    simple Login/Register stubs and role selection.
-   Mostly UI + in-memory mock data. Minimal persistence via
    `SharedPreferences` when `kEnableGroupPersistence` is enabled.
-   No backend, no auth, no real maps --- just UI and demo flows.

------------------------------------------------------------------------

## What you'll find here

-   `main.dart` + several pages and widgets (examples shown in the code
    you shared):
    -   `LoginRegisterScreen`, `_RoleSelector`, `_LoginForm`,
        `_RegisterForm`
    -   `HomeMock` (dashboard), `ProfilePage`, `BadgePage`, `AlertsPage`
    -   `LivestockManagementPage`, `GroupDetailPage`,
        `AnimalProfilePage`
    -   AMU log dialog (`openAmuLogDialog`), `_SellDialog`,
        `_MarkDeadDialog`
    -   `WithdrawalListPage`, `ContactVetPage`
-   Small models: `_Group`, `_Animal` and in-memory maps/sets for
    animals on medicine, custom animals, removed animals, manual AMU
    records.
-   Uses `SharedPreferences` optionally for group persistence (key:
    `agri_groups_v1`).

------------------------------------------------------------------------

## Design / Intent (short & honest)

This is a **mock/prototype** UI --- created to: - Show what an app for
livestock & AMU management might look like. - Let you experiment with UX
flows: create groups, add animals, log AMU, view alerts, etc. - Provide
deterministic sample data for easier testing (no randomness that changes
between runs).

Important: Several flows are intentionally dead-ends (e.g.,
veterinarian/regulator onboarding are placeholders), and many buttons
show snackbars saying `Not implemented` --- by design.

------------------------------------------------------------------------

## Features (what actually works)

-   Role selector: Farmer / Veterinarian / Regulator (vet/regulator show
    placeholder pages).
-   Login & Register forms (mock) with phone validation and an OTP
    dialog stub.
-   Home dashboard with summary tiles, auto-scrolling alert banners and
    navigation to main pages.
-   Livestock management:
    -   Create groups (add group modal).
    -   View list of groups and group details.
    -   Auto-generated animals for demo groups (`g1`, `g2`) with
        deterministic attributes.
    -   Add custom animals (persist in-memory; optional persistence to
        `SharedPreferences`).
    -   Select multiple animals, Sell dialog, Mark deceased dialog.
-   AnimalProfile: details + AMU logs UI and `openAmuLogDialog` to
    create manual AMU entries.
-   Withdrawal list: shows animals currently flagged as `on medicine`.
-   Contact Vet: a small list of mock vets with copy-to-clipboard and
    map stub.
-   Badges & Alerts pages: UI mocks for statuses and critical alerts.

------------------------------------------------------------------------

## Quick setup & run (local)

1.  Install Flutter (stable) and setup your environment:

    ``` bash
    # make sure flutter is installed and on PATH
    flutter --version
    ```

2.  In project dir:

    ``` bash
    flutter pub get
    flutter run
    ```

3.  If you want to run on a specific device:

    ``` bash
    flutter devices
    flutter run -d <device-id>
    ```

------------------------------------------------------------------------

## Important implementation notes (so you don't get lost)

-   **No backend**: everything is local/mock. AMU logs are generated or
    stored in memory.
-   **Manual AMU records**: stored in the static map
    `_LivestockManagementPageState._manualAmuRecords`.
    -   When you use the AMU log dialog, it puts records here and also
        adds the animal ID to `_animalsOnMedicine`.
-   **Animals on medicine**: tracked in
    `_LivestockManagementPageState._animalsOnMedicine` (a `Set<String>`
    of animal ids).
-   **Persistence toggle**: there's a compile-time flag
    `kEnableGroupPersistence` in the project (search in code). If
    enabled:
    -   Groups are persisted to `SharedPreferences` under
        `agri_groups_v1`.
    -   Save helper: `_saveGroupsGlobal()` / `_saveGroups()` are
        available.
-   **Generated animals**: groups like `g1` and `g2` have deterministic,
    hardcoded animals. Other groups generate animals predictably from
    group count. If you remove a generated animal, the `_removedAnimals`
    map prevents recreation.
-   **IDs**: generated animal id format is `${group.id}_a${index}`
    (e.g. `g1_a2`).
-   **Dialogs**:
    -   `_SellDialog` returns a map
        `{'ids', 'seller', 'quantity', 'price'}` when confirmed.
    -   `_MarkDeadDialog` returns `{'ids', 'reason'}`.
    -   `openAmuLogDialog(...)` returns `true` when a log is added.
-   **AMU mock logic**: `AnimalProfilePage._mockAmuLogs()` creates
    deterministic records to demo different states: Complete, Missed,
    Incomplete, and ongoing withdrawal cases.

------------------------------------------------------------------------

## File structure suggestion

    lib/
      main.dart
      constants.dart
      pages/
        login_register.dart
        home_mock.dart
        profile_page.dart
        badge_page.dart
        alerts_page.dart
        livestock/
          livestock_management_page.dart
          group_detail_page.dart
          animal_profile_page.dart
          withdrawal_list_page.dart
        contact_vet_page.dart
      widgets/
        otp_input_row.dart
        role_selector.dart
      models/
        group.dart
        animal.dart

> Tip: split large single-file code into multiple files for easier
> navigation.

------------------------------------------------------------------------

## Developer tips & quick hacks

-   Turn on persistence with `kEnableGroupPersistence = true` if you
    want groups to survive app restarts.
-   To pre-populate or change which animals are "on medicine", edit
    `_animalsOnMedicine` set in `_LivestockManagementPageState`.
-   To tweak the banner auto-scroll speed, adjust
    `_startBannerAutoScroll()` timers in `HomeMock`.
-   Want to see more logs while debugging? Add `debugPrint(...)`.

------------------------------------------------------------------------

## Known limitations / TODOs

-   No real auth; phone/OTP are mocked.
-   No real maps or external APIs.
-   Vet/Regulator onboarding is just a placeholder.
-   AMU logging is simplified.
-   UI tests / unit tests not included.
-   Accessibility improvements needed.

------------------------------------------------------------------------

## Contributing

This is a casual prototype. If you want to expand: 1. Fork / clone the
repo. 2. Keep UI behaviour intact if you want to preserve demos;
otherwise refactor into smaller widgets/files. 3. Add proper services
for persistence / backend sync. 4. If you add features, update this
README.

------------------------------------------------------------------------

## Troubleshooting

-   `flutter pub get` failing: ensure Flutter SDK & Dart SDK are
    installed.
-   iOS/macOS builds: ensure platform tooling is configured (Xcode etc).
-   Emulator/device not found: run `flutter devices`.
-   If widgets don't reflect changes: `flutter clean` then
    `flutter run`.

------------------------------------------------------------------------

## Final note

This is a neat mock --- plays well for demos and quick UX checks. It's
purposefully simple and deterministic so you won't chase flaky
behaviours.
