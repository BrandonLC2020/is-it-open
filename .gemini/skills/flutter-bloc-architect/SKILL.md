---
name: flutter-bloc-architect
description: Guidance for Flutter app architecture using the Bloc/Cubit pattern. Use when managing state, creating new features, or refactoring the frontend.
---

# Flutter Bloc Architect

## Overview
This skill focuses on state management patterns using `flutter_bloc`, emphasizing separation of concerns and testability.

## Best Practices

### Bloc vs. Cubit
- Use **Cubit** for simple state (e.g., loading, success, failure) where no complex event streams are needed.
- Use **Bloc** for complex state transitions, undo/redo, or when multiple events affect the same state.

### State Design
- States should be **sealed classes** or use `equatable` for efficient rebuilding.
- Prefer explicit state names: `SearchInitial`, `SearchLoading`, `SearchLoaded`, `SearchError`.

### UI Integration
- Use `BlocBuilder` for UI updates based on state changes.
- Use `BlocListener` for side-effects (e.g., showing SnackBars, navigation).
- Use `BlocProvider` high enough in the tree to provide state where needed.

### Testing
- Use `bloc_test` for unit testing state transitions.
- Ensure every Bloc/Cubit has corresponding tests.

## Resources
- [Bloc Library Documentation](https://bloclibrary.dev/)
