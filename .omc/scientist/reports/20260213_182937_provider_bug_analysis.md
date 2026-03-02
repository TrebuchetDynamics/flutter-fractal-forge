# Provider and State Management Bug Analysis
## Flutter Fractal Forge

**Date:** 2026-02-13T18:29:37.821898
**Analyst:** Scientist Agent
**Session:** flutter_provider_analysis

## Summary

Found **5 provider-related bugs** across **3 critical files**.

### Critical Issues (Priority 1)
1. **ProviderNotFoundException** in `FractalCatalogScreen._openViewer`

### Medium Priority Issues
2. Unsafe `context.read()` in `initState`
3. Controller disposal timing issues
4. Listener cleanup in `FractalViewerScreen`

### Low Priority Issues  
5. Multiple controller instances (already handled)

## Detailed Analysis


After thorough analysis, here are ALL provider-related bugs found:

BUG #1: ProviderNotFoundException in FractalCatalogScreen._openViewer
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FILE: lib/features/catalog/fractal_catalog_screen.dart
LINES: 312-341

ISSUE: The _openViewer method tries to read FractalController from context,
but the provider scope depends on HomeScreen's ChangeNotifierProvider.value.

CODE:
```dart
void _openViewer(BuildContext context, FractalModule module) {
  final controller = context.read<FractalController>();  // Line 313 - ERROR
  controller.selectModule(module);
  Navigator.of(context).push(
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          ChangeNotifierProvider.value(
        value: controller,
        child: const FractalViewerScreen(),
      ),
```

ROOT CAUSE: While the context SHOULD have access to FractalController (it's a
descendant of the ChangeNotifierProvider.value in HomeScreen), the error message
in the user's memory suggests this is failing.

MOST LIKELY REASON: The const FractalCatalogScreen() constructor at home_screen.dart
line 173 creates a widget that is not properly connected to the provider tree, OR
there's a scenario where FractalCatalogScreen is being used without the provider
(perhaps in a test or a different navigation path).

FIX: Change the approach to pass the controller explicitly or use a different
pattern. Options:
  a) Pass FractalController as a constructor parameter to FractalCatalogScreen
  b) Make FractalController available at app root level in main.dart
  c) Use Builder widget to ensure correct context
  d) Remove const from FractalCatalogScreen() usage

RECOMMENDED FIX: Option (a) - Pass controller as parameter to ensure it's always
available and makes the dependency explicit.


BUG #2: Unsafe context.read() in initState
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FILE: lib/features/home/home_screen.dart
LINE: 33

ISSUE: Reading from Provider in initState is technically unsafe, though it may
work if the widget is already in the tree.

CODE:
```dart
@override
void initState() {
  super.initState();
  final registry = context.read<ModuleRegistry>();  // Line 33 - UNSAFE
  _exploreController = FractalController(registry);
```

ROOT CAUSE: initState() is called before the widget is fully inserted into the
tree. While this may work for providers higher up in the tree, it's not guaranteed
and can cause subtle timing bugs.

FIX: Move the controller initialization to didChangeDependencies or use a lazy
initialization pattern.

RECOMMENDED FIX:
```dart
FractalController? _exploreController;

@override
void didChangeDependencies() {
  super.didChangeDependencies();
  if (_exploreController == null) {
    final registry = context.read<ModuleRegistry>();
    _exploreController = FractalController(registry);
  }
}
```


BUG #3: Missing Provider Disposal Handling
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FILE: lib/features/home/home_screen.dart
LINES: 128-132

ISSUE: The _exploreController is created locally and disposed locally, but if
the provider is still being accessed elsewhere, this could cause issues.

CODE:
```dart
@override
void dispose() {
  _deepLinkSubscription?.cancel();
  _exploreController.dispose();  // Line 130
  super.dispose();
}
```

ROOT CAUSE: When HomeScreen is disposed, the controller is disposed, but any
widgets that still have references to it (like a pushed FractalViewerScreen)
will have a disposed controller.

FIX: Ensure that FractalViewerScreen creates its own copy or that navigation
is properly managed to prevent accessing a disposed controller.

SEVERITY: Medium (could cause "setState() called after dispose()" errors)


BUG #4: Potential State Access After Disposal in FractalViewerScreen
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FILE: lib/features/viewer/fractal_viewer_screen.dart
LINES: 158-170, 266-309

ISSUE: The _onControllerChanged listener modifies state, but if the controller
is disposed before the screen, this could cause errors.

CODE:
```dart
void _onControllerChanged() {
  if (!mounted) return;
  
  final controller = context.read<FractalController>();  // Line 269
  // ... uses controller ...
  setState(() { ... });
}
```

ROOT CAUSE: If the controller is disposed (e.g., HomeScreen is popped) while
FractalViewerScreen is still mounted, the listener could fire and try to access
a disposed controller or call setState on a disposed widget.

FIX: Add more robust null checks and ensure listeners are removed before disposal.

SEVERITY: Medium (could cause crashes in edge cases)


BUG #5: Multiple Controller Instances Potential
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FILE: lib/features/viewer/fractal_viewer_screen.dart
LINES: 359-374

ISSUE: The compare mode creates a separate FractalController instance, which
could lead to confusion or memory leaks if not properly managed.

CODE:
```dart
void _ensureCompareController(BuildContext context) {
  if (_compareController != null) return;
  final registry = context.read<ModuleRegistry>();
  _compareController = FractalController(registry);  // New instance
  
  // Initialize B from A.
  final a = context.read<FractalController>();
  _compareController!.selectModule(a.module, animate: false);
```

ROOT CAUSE: Creating multiple controller instances is intentional for compare mode,
but it needs proper lifecycle management.

FIX: Ensure _compareController is disposed in the dispose method.

STATUS: Already handled (line 326: _compareController?.dispose())

SEVERITY: Low (already fixed)


## Recommended Fixes


FIX #1: Resolve ProviderNotFoundException in FractalCatalogScreen
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

OPTION A (RECOMMENDED): Pass controller as constructor parameter
────────────────────────────────────────────────────────────────────
Changes to lib/features/catalog/fractal_catalog_screen.dart:

1. Add constructor parameter:
```dart
class FractalCatalogScreen extends StatefulWidget {
  final FractalController controller;
  
  const FractalCatalogScreen({
    Key? key,
    required this.controller,
  }) : super(key: key);
```

2. Update _openViewer to use widget.controller:
```dart
void _openViewer(BuildContext context, FractalModule module) {
  widget.controller.selectModule(module);  // Use widget.controller
  Navigator.of(context).push(
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          ChangeNotifierProvider.value(
        value: widget.controller,  // Use widget.controller
        child: const FractalViewerScreen(),
      ),
```

3. Update lib/features/home/home_screen.dart line 173:
```dart
Expanded(child: FractalCatalogScreen(controller: _exploreController)),
```

PROS: Explicit dependency, no provider lookup, works everywhere
CONS: Requires passing controller through constructor


OPTION B: Make FractalController available at app root
────────────────────────────────────────────────────────────────────
Changes to lib/main.dart:

1. Create global controller in _FlutterFractalsAppState:
```dart
class _FlutterFractalsAppState extends State<FlutterFractalsApp> {
  late final FractalController _globalController;
  
  @override
  void initState() {
    super.initState();
    final registry = ModuleRegistry();
    _globalController = FractalController(registry);
  }
  
  @override
  void dispose() {
    _globalController.dispose();
    super.dispose();
  }
```

2. Add to MultiProvider (line 348+):
```dart
providers: [
  Provider<ModuleRegistry>.value(value: registry),
  ChangeNotifierProvider<FractalController>.value(value: _globalController),
  // ... other providers
```

PROS: Available everywhere, simple to access
CONS: Global state, harder to manage multiple instances


OPTION C: Use Builder widget for correct context
────────────────────────────────────────────────────────────────────
Changes to lib/features/catalog/fractal_catalog_screen.dart:

Wrap the context lookup in a Builder:
```dart
void _openViewer(BuildContext outerContext, FractalModule module) {
  Builder(
    builder: (BuildContext innerContext) {
      final controller = innerContext.read<FractalController>();
      controller.selectModule(module);
      Navigator.of(outerContext).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              ChangeNotifierProvider.value(
            value: controller,
            child: const FractalViewerScreen(),
          ),
```

PROS: Minimal changes
CONS: Awkward API, doesn't solve root cause


OPTION D: Remove const from FractalCatalogScreen
────────────────────────────────────────────────────────────────────
Changes to lib/features/home/home_screen.dart line 173:
```dart
Expanded(child: FractalCatalogScreen()),  // Remove const
```

PROS: Ensures widget is properly connected to tree
CONS: Slight performance impact, may not fix the issue


RECOMMENDED: Use OPTION A (pass controller as parameter) for clarity and reliability.


FIX #2: Move controller initialization to didChangeDependencies
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Changes to lib/features/home/home_screen.dart:

```dart
class _HomeScreenState extends State<HomeScreen> {
  FractalController? _exploreController;  // Make nullable
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Initialize controller on first call
    if (_exploreController == null) {
      final registry = context.read<ModuleRegistry>();
      _exploreController = FractalController(registry);
      
      // Move deep link initialization here too
      if (!kSafeMode) {
        _initDeepLinks();
      }
    }
  }
  
  @override
  void dispose() {
    _deepLinkSubscription?.cancel();
    _exploreController?.dispose();  // Add null check
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // Add null check since controller might not be initialized yet
    if (_exploreController == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    // ... rest of build method
  }
```


FIX #3: Ensure proper controller lifecycle management
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

No code changes needed, but be aware:
- When HomeScreen is disposed, _exploreController is disposed
- Any FractalViewerScreen that was pushed will keep its own reference via
  ChangeNotifierProvider.value
- This is correct behavior since the viewer gets a reference, not ownership


FIX #4: Add robust listener cleanup in FractalViewerScreen
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Changes to lib/features/viewer/fractal_viewer_screen.dart:

```dart
void _onControllerChanged() {
  if (!mounted) return;
  
  try {
    final controller = context.read<FractalController>();
    
    // Check if controller is disposed (has no listeners)
    if (!controller.hasListeners) return;
    
    // ... rest of method
  } catch (e) {
    // Provider might not be available anymore
    return;
  }
}
```

Add better cleanup in didChangeDependencies:
```dart
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  
  final controller = context.read<FractalController>();
  if (_lastController != controller) {
    // Remove listener from old controller
    _lastController?.removeListener(_onControllerChanged);
    _lastController = controller;
    
    // Add listener to new controller
    controller.addListener(_onControllerChanged);
    
    // ... rest of method
  }
}
```


## Limitations


1. Unable to run the app to reproduce the exact error
2. Cannot verify which specific navigation path triggers the ProviderNotFoundException
3. The error might occur in test files or edge cases not visible in main code paths
4. Some bugs may be masked by error handling or try-catch blocks
5. The const constructor issue is a hypothesis based on common Flutter pitfalls


## Conclusion

The root cause of the ProviderNotFoundException is likely that FractalCatalogScreen
attempts to read FractalController from context, but the provider scope is not
guaranteed to be available in all navigation scenarios.

**Recommended Action:** Implement FIX #1 OPTION A (pass controller as constructor
parameter) combined with FIX #2 (move initialization to didChangeDependencies).
