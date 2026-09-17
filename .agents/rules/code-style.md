---
trigger: always_on
---

# Rule: Self-Explanatory Flutter Code & English Comments Only

## Goal
Ensure all generated and refactored Dart/Flutter code for the IoT sensor project is highly readable, self-explanatory, features zero redundant comments, and uses exclusively English for any allowed comments.

## Activation Mode
always-on

## Coding Standards
1. **Self-Explanatory Architecture:** 
   - Write clean, declarative, and descriptive variable and function names. 
   - Avoid generic or single-letter names (e.g., use `isOverheatingThreshold` instead of `tempCheck`).
   - Break down complex logic into descriptive, well-named local variables or helper methods rather than adding explanatory comments.

2. **Comment Minimization:**
   - DO NOT write comments that describe *what* the code does (e.g., do not add `// increments counter`). The code must explain the "what" by itself.
   - ONLY allow comments that explain the *why* (e.g., workarounds for IoT hardware limitations, specific sensor buffer delays, or API edge cases).

3. **Strict Language Constraints:**
   - EVERY single comment, documentation block (`///`), or variable name MUST be written strictly in English.
   - Spanish words, notes, or placeholders are strictly forbidden anywhere in the codebase.

## Examples

### Bad Code (Violates this rule)
```dart
// Check if sensor is hot
if (val > 45) { 
  // Alarma activa
  triggerAlarm(); 
}
```

### Good Code (Complies with this rule)
```dart
final isSensorOverheating = currentSensorValue > 45;
if (isSensorOverheating) {
  triggerAlarm();
}
// Note: IoT gateway requires a 200ms cooldown after trigger to prevent buffer overflow
await Future.delayed(const Duration(milliseconds: 200));
```