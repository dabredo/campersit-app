# Campersit Mobile — Master Plan

> **Purpose:** This document is the source of truth for the product, requirements, architecture decisions, scope and current state of the project.
>
> **Important:** This document is a living document. It must be updated when an agreed product or architecture decision changes.

---

# 1. Project Overview

## 1.1 Project

**Campersit Mobile**

A Flutter mobile application connected to Firebase that allows users to manage IoT gateways and sensors.

The application is being developed both as:

- A functional prototype for the Campersit IoT ecosystem.
- A public portfolio project.
- A learning project for Flutter, Firebase and modern AI-assisted software development.
- A potentially reusable foundation for other IoT projects.

---

# 2. Product Vision

The application should allow a user to:

1. Create an account.
2. Log in securely.
3. Manage their IoT gateways.
4. Manage sensors connected to those gateways.
5. Configure supported sensor types.
6. Monitor sensor and gateway state.
7. View relevant telemetry from sensors and videos from cameras.
8. Run actions on actuators depending on telemetry recibed from sensors.
9. Configure notifications.
10. Receive notifications when configured events occur.
11. Configure and manage the system from a mobile device.

The initial sensor types are:

- Air
- LED
- Buzzer
- Camera
- Motion

The architecture should make it possible to add new sensor types without redesigning the entire application.

---

# 3. Core Product Model

The conceptual model is:

```text
User
 └── Gateways
      └── Sensors
           ├── Telemetry
           ├── State
           └── Events
                └── Notifications
```

Firebase acts as the backend between the mobile application and the IoT infrastructure.

The mobile application must NOT communicate directly with MQTT infrastructure.

```text
IoT Devices
     │
     │
     ▼
IoT Backend / Gateway Infrastructure
     │
     ▼
Firebase
     │
     ├── Authentication
     ├── Firestore
     ├── Cloud Functions
     ├── Cloud Storage
     └── Cloud Messaging
     │
     ▼
Flutter Mobile App
```

---

# 4. MVP Scope

## 4.1 Included in MVP

### Authentication

- User registration.
- Login.
- Logout.
- Password reset.
- Persistent authentication state.
- Protected application screens.

Social login may be added later.

---

### Users

A user can manage their own IoT infrastructure.

The application must ensure that users cannot access gateways, sensors, telemetry or media belonging to other users unless explicit sharing functionality is introduced.

---

### Gateways

Users can:

- View gateways.
- Add a gateway.
- View gateway details.
- Edit gateway configuration where applicable.
- Delete a gateway.
- View gateway state.
- View gateway connectivity.
- View gateway battery information when available.
- View gateway location when available.

The gateway should be able to determine or provide its location.

The exact mechanism for obtaining the location is still an architectural decision and must not be invented without confirmation.

Possible future mechanisms include:

- GPS.
- Mobile-assisted location.
- Manually configured location.
- Backend-derived location.

---

### Sensors

Users can:

- View sensors.
- Add sensors.
- Configure sensors.
- Edit sensors.
- Delete sensors.
- View sensor state.
- View sensor telemetry when available.
- View sensor events.

Initial sensor types:

```text
AIR
LED
SOUND
CAMERA
MOTION
```

The implementation should use an extensible sensor model.

Avoid creating completely independent application architectures for every sensor type.

---

# 5. Sensor Types

## 5.1 Air Sensor

Potential information:

- Temperature.
- Humidity.

Exact telemetry fields must be defined when the real sensor protocol is finalized.

---

## 5.2 LED

The LED is an actuator rather than a traditional measurement sensor.

The application may eventually allow:

- On/off.
- State.
- Configuration.

---

## 5.3 Buzzer

The buzzer device may represent:

- Buzzer.

Exact capabilities must be defined by the IoT protocol.

---

## 5.4 Camera

The camera may eventually support:

- Camera state.
- Images.
- Videos.
- Events.
- Media history.

The initial MVP should not assume live video streaming unless explicitly approved.

---

## 5.5 Motion

Potential information:

- Motion detected.
- Motion state.
- Motion events.

---

# 6. Notifications

Users should be able to configure notifications for relevant IoT events.

Potential events include:

- Motion detected.
- Intrusion detected.
- Gateway offline.
- Low battery.
- Critical battery.
- New camera media.
- Sensor failure.
- Other future sensor events.

The notification system should be extensible.

Notifications should eventually support:

```text
Event
  ↓
Notification Rule
  ↓
User Preference
  ↓
Firebase Cloud Messaging
  ↓
Mobile App
```

The exact notification-rule data model must be defined before implementation.

---

# 7. Firebase Architecture

The application will use Firebase as its backend platform.

Expected services:

### Firebase Authentication

Responsible for:

- Registration.
- Login.
- Logout.
- Password reset.
- Authentication state.

---

### Cloud Firestore

Responsible for:

- Users.
- Gateways.
- Sensors.
- Sensor state.
- Telemetry.
- Events.
- Notification configuration.

The exact Firestore schema must be designed before implementing complex features.

---

### Cloud Functions

Cloud Functions may be responsible for:

- Processing IoT events.
- Creating notifications.
- Validating backend operations.
- Processing asynchronous workflows.
- Connecting IoT backend events with Firebase.
- Other backend-only operations.

The mobile application should not contain secrets or privileged backend credentials.

---

### Firebase Cloud Messaging

Used for push notifications.

Potential notification categories:

```text
INTRUSION
MOTION
LOW_BATTERY
GATEWAY_OFFLINE
NEW_VIDEO
SENSOR_ERROR
```

---

### Cloud Storage

Used for media such as:

- JPEG images.
- MP4 videos.

Storage paths and security rules must be designed so that users can only access authorized media.

---

# 8. Mobile Architecture

The Flutter application should follow a clear separation between:

```text
Presentation
    ↓
Application / State
    ↓
Domain
    ↓
Data
    ↓
Firebase / External Services
```

The architecture should prevent Firebase-specific implementation details from spreading throughout UI code.

---

# 9. State Management

Use a consistent state-management approach across the application.

Preferred approach:

**Riverpod**

Do not introduce multiple competing state-management solutions without a strong architectural reason.

State should represent:

- Authentication.
- Gateways.
- Sensors.
- Sensor telemetry.
- Events.
- Notifications.
- Connectivity.
- Loading states.
- Errors.

---

# 10. Navigation

The application should have a clear navigation structure.

Initial conceptual navigation:

```text
Authentication
 ├── Login
 ├── Register
 └── Password Reset

Authenticated Application
 ├── Dashboard
 ├── Gateways
 │    ├── Gateway List
 │    ├── Gateway Detail
 │    └── Add/Edit Gateway
 │
 ├── Sensors
 │    ├── Sensor Detail
 │    └── Add/Edit Sensor
 │
 ├── Notifications
 │
 └── Settings
```

The exact navigation package and routing architecture must be chosen before implementation.

---

# 11. Main Screens

## Login

Requirements:

- Email.
- Password.
- Login.
- Registration navigation.
- Password reset navigation.
- Authentication error handling.

---

## Registration

Requirements:

- Email.
- Password.
- Password confirmation.
- Validation.
- Account creation.
- Error handling.

---

## Dashboard

Should provide a useful overview of the user's IoT system.

Potential information:

- Gateway status.
- Sensor status.
- Recent events.
- Important alerts.
- Connectivity problems.

The dashboard should remain simple during the MVP.

---

## Gateway List

Display:

- Gateway name.
- Connection state.
- Important status information.
- Number of sensors.

Potential future features:

- Filtering.
- Sorting.
- Search.

---

## Gateway Detail

Potential information:

- Name.
- Identifier.
- State.
- Battery.
- Location.
- Connected sensors.
- Recent events.

Actions:

- Edit.
- Delete.
- Manage sensors.

---

## Sensor Detail

Display information appropriate to the sensor type.

Potential information:

- Sensor name.
- Sensor type.
- State.
- Latest telemetry.
- Battery.
- Recent events.
- Gateway.

Sensor-specific UI should be extensible.

---

## Sensor Configuration

Allow the user to configure supported sensor properties.

The exact configuration fields depend on the sensor type.

Do not invent configuration fields that are not supported by the backend/device protocol.

---

## Notifications

Allow users to:

- Enable/disable notifications.
- Configure supported event types.
- Configure notification preferences.

---

## Settings

Potential settings:

- Display name.
- Notification preferences.
- Language.
- Theme.
- Account.
- Logout.
- Diagnostics.

Initial supported languages:

- English.
- Spanish.

Initial theme support:

- System.
- Light.
- Dark.

---

# 12. Data Model

The initial conceptual model is:

```text
User
 ├── Gateways
 │    ├── Sensors
 │    │    ├── Telemetry
 │    │    └── Events
 │    │
 │    └── Gateway Events
 │
 └── Notification Preferences
```

Possible entities:

```text
users
gateways
sensors
telemetry
events
notifications
notificationRules
```

This is a conceptual model, not yet a final Firestore schema.

Before implementation of complex Firebase functionality, create:

```text
docs/data-model.md
```

containing the approved Firestore structure.

---

# 13. Security

Security is a first-class requirement.

The application must never rely only on client-side authorization.

Security must be enforced using Firebase Security Rules and backend authorization where appropriate.

Requirements include:

- Users can access only their own data.
- Storage access must be authorized.
- Sensitive backend credentials must never be included in the Flutter application.
- Firebase configuration must not be confused with backend secrets.
- Privileged operations must be performed server-side.
- Cloud Functions must validate authorization.
- Firestore rules must be tested.

---

# 14. IoT Communication

The Flutter application must NOT connect directly to MQTT.

The mobile architecture should be:

```text
Flutter
   ↓
Firebase
   ↓
Backend / IoT infrastructure
   ↓
Gateway
   ↓
Sensors
```

The mobile application should consume the Firebase-facing representation of the IoT system.

MQTT credentials, broker configuration and other IoT infrastructure secrets must never be hardcoded into the mobile application.

---

# 15. Realtime Data

The application should support realtime updates where useful.

Examples:

- Gateway online/offline state.
- Sensor state.
- Motion detection.
- Air measurements.
- Events.
- Notifications.

Realtime listeners should be scoped carefully to avoid:

- Unnecessary reads.
- Memory leaks.
- Excessive battery usage.
- Unnecessary Firebase costs.

---

# 16. Offline Behaviour

Offline support is desirable but should not complicate the MVP unnecessarily.

Potential future capabilities:

- Cached gateway list.
- Cached sensor information.
- Offline UI.
- Automatic synchronization.

Before implementing advanced offline behavior, define the desired consistency model.

---

# 17. Testing

The project should include automated tests.

Minimum expectations:

### Unit tests

For:

- Business logic.
- Validation.
- Data transformation.
- Notification rules.
- Sensor-specific logic.

### Widget tests

For:

- Important UI components.
- Forms.
- Error states.
- Loading states.

### Integration tests

For important end-to-end workflows.

Potential workflow:

```text
Register
  ↓
Login
  ↓
Create Gateway
  ↓
Create Sensor
  ↓
Receive State
  ↓
Trigger Event
  ↓
Receive Notification
```

Firebase Emulator Suite should be used where practical.

---

# 18. Error Handling

The application should distinguish between:

```text
Loading
Success
Empty
Failure
Offline
Unauthorized
```

Errors shown to users should be understandable.

Internal technical details must not unnecessarily leak into the UI.

---

# 19. Dependencies

Prefer Flutter/Dart packages that are:

- Well maintained.
- Widely used.
- Appropriate for the problem.
- Compatible with the current Flutter version.
- Justified by actual requirements.

Do not add dependencies merely because they are convenient.

Before introducing an important dependency, consider whether the functionality can be implemented cleanly with the existing stack.

---

# 20. Internationalization

The application should support:

```text
English
Spanish
```

User-facing strings must not be scattered throughout the codebase.

Prepare the application for future languages.

---

# 21. UI / UX Principles

The application should prioritize:

- Simplicity.
- Clear status information.
- Good mobile usability.
- Accessible controls.
- Consistent components.
- Clear loading states.
- Clear error states.
- Useful empty states.

Avoid unnecessary visual complexity.

The application is an IoT management tool, not a demonstration of UI effects.

---

# 22. Portfolio Quality

Because this is also a portfolio project, the codebase should demonstrate:

- Clean architecture.
- Meaningful tests.
- Good naming.
- Good documentation.
- Security awareness.
- Firebase knowledge.
- Flutter knowledge.
- State management.
- Async programming.
- Error handling.
- Realtime data.
- AI-assisted development used responsibly.

AI-generated code must still be understood, reviewed and tested.

---

# 23. Development Methodology

Development should be incremental.

Do not attempt to build the complete application in one step.

Preferred cycle:

```text
Requirement
    ↓
Analyze
    ↓
Update Master Plan if necessary
    ↓
Design
    ↓
Implement small change
    ↓
Run tests
    ↓
Review
    ↓
Update documentation/state
    ↓
Next change
```

---

# 24. Master Plan Rules

`docs/master-plan.md` is the source of truth for:

- Product requirements.
- Agreed architecture.
- Project scope.
- Important technical decisions.
- Current implementation state.
- Open architectural questions.

## When the user changes a requirement

If the user explicitly changes an agreed requirement, architecture decision or scope:

1. Read the current master plan.
2. Identify affected sections.
3. Explain important consequences if necessary.
4. Update `docs/master-plan.md`.
5. Do NOT modify implementation code unless the user asks for implementation.
6. Do NOT change unrelated sections.
7. Summarize exactly what changed.

Example:

> "Sensors can now belong to multiple gateways."

Expected behaviour:

```text
Read Master Plan
       ↓
Analyze impact
       ↓
Update Master Plan
       ↓
Report changes
       ↓
Wait for implementation request
```

---

# 25. What Should NOT Automatically Modify the Master Plan

Do not update the master plan for normal implementation details unless they represent an architectural or product decision.

Examples:

- Renaming a local variable.
- Refactoring a method.
- Fixing a bug.
- Changing widget spacing.
- Changing an internal class name.
- Improving a test.
- Reorganizing imports.
- Fixing lint errors.

These belong to the implementation, not the product plan.

---

# 26. Conflict Resolution

If a new user request conflicts with the current master plan:

1. Identify the conflict.
2. Explain the affected decision.
3. Do not silently overwrite important decisions.
4. Ask for confirmation when the conflict materially affects architecture or scope.
5. Once approved, update the master plan.

Example:

```text
Current decision:
Flutter does not communicate directly with MQTT.

New request:
"Make the Flutter app connect directly to MQTT."

Expected response:
Explain the architectural conflict before changing the plan.
```

---

# 27. Implementation Rule

A change to the master plan does NOT automatically mean that the code should be changed.

The user may explicitly request:

```text
"Update the master plan only."
```

or:

```text
"Update the master plan and implement the change."
```

These are different operations.

When unclear and the change is architectural, prefer:

```text
Update plan → explain impact → wait for approval
```

rather than making a large implementation automatically.

---

# 28. Current Status

## Project phase

**Phase 0 — Architecture and foundation**

Current objective:

Define the architecture, project structure and development workflow before implementing the main application.

---

## Completed

- Product concept defined.
- Flutter selected.
- Firebase selected.
- Initial sensor types defined.
- Authentication requirement defined.
- Gateway management requirement defined.
- Sensor management requirement defined.
- Notification requirement defined.
- High-level Firebase architecture defined.
- Mobile-to-MQTT direct communication explicitly rejected.
- Master Plan established.

---

## Not yet finalized

- Final Firestore schema.
- Gateway pairing mechanism.
- Exact gateway-to-Firebase communication architecture.
- Exact sensor telemetry model.
- Exact notification rule model.
- Gateway location implementation.
- Sharing gateways between users.
- Camera live streaming.
- Media retention policy.
- Offline synchronization model.
- Final navigation implementation.
- Final UI design system.

These must not be invented by the AI.

---

# 29. Roadmap

## Phase 0 — Foundation

- [ ] Define product vision.
- [ ] Define initial sensor types.
- [ ] Define high-level Firebase architecture.
- [ ] Define master plan.
- [ ] Define Flutter project architecture.
- [ ] Define Firestore data model.
- [ ] Define security model.
- [ ] Create initial project structure.

---

## Phase 1 — Authentication

- [ ] Firebase configuration.
- [ ] Authentication service.
- [ ] Login.
- [ ] Registration.
- [ ] Password reset.
- [ ] Auth state handling.
- [ ] Protected navigation.
- [ ] Tests.

---

## Phase 2 — Gateways

- [ ] Gateway model.
- [ ] Firestore repository.
- [ ] Gateway list.
- [ ] Gateway detail.
- [ ] Add gateway.
- [ ] Edit gateway.
- [ ] Delete gateway.
- [ ] Gateway realtime state.
- [ ] Tests.

---

## Phase 3 — Sensors

- [ ] Sensor model.
- [ ] Sensor repository.
- [ ] Sensor list.
- [ ] Sensor detail.
- [ ] Add sensor.
- [ ] Configure sensor.
- [ ] Edit sensor.
- [ ] Delete sensor.
- [ ] Sensor realtime state.
- [ ] Tests.

---

## Phase 4 — Events and Telemetry

- [ ] Event model.
- [ ] Telemetry model.
- [ ] Realtime updates.
- [ ] Event history.
- [ ] Sensor-specific telemetry.
- [ ] Tests.

---

## Phase 5 — Notifications

- [ ] Notification preferences.
- [ ] Notification rules.
- [ ] FCM configuration.
- [ ] Push notification handling.
- [ ] Event → notification workflow.
- [ ] Tests.

---

## Phase 6 — Camera and Media

- [ ] Camera state.
- [ ] Image storage.
- [ ] Image gallery.
- [ ] Video storage.
- [ ] Video playback.
- [ ] Media events.
- [ ] Security rules.

---

## Phase 7 — Location

- [ ] Gateway location model.
- [ ] Location source decision.
- [ ] Location UI.
- [ ] Optional map.
- [ ] Permission handling.

---

## Phase 8 — Polish

- [ ] English.
- [ ] Spanish.
- [ ] Theme support.
- [ ] Accessibility review.
- [ ] Error handling review.
- [ ] Offline strategy.
- [ ] Performance review.
- [ ] Security review.
- [ ] Documentation.
- [ ] Portfolio README.

---

# 30. Architecture Decision Records

Important architectural decisions should eventually be documented separately in:

```text
docs/adr/
```

Examples:

```text
ADR-001-flutter.md
ADR-002-firebase.md
ADR-003-riverpod.md
ADR-004-no-mqtt-in-mobile.md
ADR-005-firestore-model.md
```

Do not create ADRs for trivial implementation decisions.

---

# 31. Documentation Structure

Expected documentation:

```text
docs/
├── master-plan.md
├── architecture.md
├── data-model.md
├── security.md
├── testing.md
└── adr/
    ├── ADR-001-*.md
    ├── ADR-002-*.md
    └── ...
```

The master plan should remain readable.

Detailed technical information belongs in the appropriate document.

---

# 32. Open Questions

These questions require an explicit decision before the affected feature is implemented.

### Gateway

- How is a gateway initially paired with a user?
- Is pairing performed using QR?
- Is there a gateway registration code?
- Can a gateway be transferred between users?
- Can multiple users share a gateway?

### Sensors

- How are sensors physically associated with a gateway?
- Can one sensor belong to multiple gateways?
- What is the canonical sensor identifier?
- What telemetry is available for each sensor type?

### Location

- Does the gateway provide GPS?
- Can the user manually set the location?
- Is location private?
- Is a map actually necessary?

### Notifications

- Which events are configurable?
- Are notification rules global or per sensor?
- Are there schedules?
- Are repeated events throttled?

### Camera

- Are cameras live-streaming?
- Are images captured on demand?
- Are videos event-triggered?
- How long is media retained?

### Offline

- What functionality must work without connectivity?
- What happens when writes occur offline?
- Is conflict resolution required?

---

# 33. Definition of Done

A feature is not considered complete simply because the code compiles.

A feature is considered complete when appropriate:

- Requirements are understood.
- Architecture is consistent with the master plan.
- Code is implemented.
- Error states are handled.
- Authorization is considered.
- Tests exist for important behaviour.
- Tests pass.
- Lint/analyzer checks pass.
- Documentation is updated when necessary.
- No unnecessary dependencies were introduced.
- The implementation does not introduce architectural inconsistencies.

---

# 34. AI Agent Instructions

When working on this project, the AI agent must:

1. Read `docs/master-plan.md` before significant work.
2. Treat it as the source of truth.
3. Never invent unspecified product requirements.
4. Clearly distinguish assumptions from confirmed decisions.
5. Prefer small, incremental changes.
6. Avoid unnecessary dependencies.
7. Keep business logic outside UI widgets.
8. Keep Firebase-specific implementation isolated where practical.
9. Follow the established state-management architecture.
10. Write tests for important behaviour.
11. Consider security before implementing backend functionality.
12. Never expose secrets.
13. Never add direct MQTT communication to the Flutter application.
14. Update documentation when an important architectural decision changes.
15. Update this master plan when the user explicitly changes a product or architectural decision.
16. Do not modify implementation code merely because the master plan changed unless the user requests implementation.
17. When a request conflicts with an existing architectural decision, explain the conflict before proceeding.
18. Do not silently make large architectural decisions.
19. Prefer explaining uncertainty rather than inventing details.
20. Before large changes, summarize the proposed approach and affected areas.

---

# 35. First Development Task

The first implementation task should NOT be to build the entire application.

The next step is:

```text
Analyze Phase 0
    ↓
Propose project architecture
    ↓
Propose directory structure
    ↓
Propose state-management structure
    ↓
Propose Firebase integration boundaries
    ↓
Propose initial Firestore model
    ↓
Identify architectural risks
    ↓
Wait for approval
```

Only after the architecture is approved should the implementation begin.

---

# 36. Change Log

Important changes to this master plan should be recorded here.

Format:

```text
## YYYY-MM-DD

### Changed

- Description of the decision.

### Reason

- Why the decision changed.

### Impact

- What parts of the project are affected.
```

Keep this section concise. Detailed architectural decisions belong in ADRs.

---

# 37. Final Principle

The project should evolve through explicit decisions rather than uncontrolled AI-generated implementation.

The AI is responsible for helping design, implement, test and review the application.

The human developer remains responsible for approving product and architectural decisions.

```text
Master Plan
    = What we have decided

Rules
    = How the AI should work

Skills
    = Reusable ways of working

Prompt
    = What we want to do right now

Code
    = Current implementation
```
