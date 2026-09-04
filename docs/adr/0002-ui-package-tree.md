# 2. UI package tree with deferred composition-root coordinator

- **Status**: Accepted
- **Date**: 2026-09-04
- **Supersedes**:
- **Superseded by**:

## Context

SwiftUI parent views must name concrete child view types, which naturally creates a dependency graph among UI packages (`RootUI → PagesUI → LayoutsUI`). Local package independence allows view packages to depend on other view packages, but the graph grows when Root also depends on Settings and when lower packages need to present surfaces owned higher up.

Alternatives considered:

1. **UI-package tree** — parent UI modules import child UI modules directly (chosen for now).
2. **Composition-root view injection** — parent views take child views as generic slots; `DependencyContainer` constructs the full tree and returns `makeRootView() -> some View`.
3. **UIKit-style coordinator class** — a dedicated navigation coordinator type. Rejected for now: SwiftUI already owns presentation; a separate coordinator duplicates that unless navigation state becomes complex.

## Decision

Use a **UI-package tree** for Root, Pages, and Layouts. Parent view packages may depend on child view packages per the local-package-independence exception for view packages.

When Settings is added or a dependency cycle appears, adopt **composition-root view injection** in `DependencyContainer`: parent views accept `@ViewBuilder` child slots instead of importing child UI modules; the container wires every `Runtime*ViewModel` and assembles the view tree. No UIKit-style coordinator class until navigation state justifies one.

## Consequences

**Positive**: Simple, idiomatic SwiftUI; matches Biker’s MainView pattern; easy to implement and test view models in isolation.

**Negative**: Root will eventually import both Pages and Settings UI; the graph may need refactoring before Settings lands.

**Risks / follow-ups**: Revisit when adding the Settings package. If Root imports Pages and Settings and a cycle threatens, switch to composition-root view injection and record any superseding ADR.
