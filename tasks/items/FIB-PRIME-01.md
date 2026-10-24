+++
schema = 1
id = "FIB-PRIME-01"
title = "Implement and independently test the complex Fibonacci orbit model.**"
short = "Implement and independently test the complex Fibonacci orbit model.**"
status = "open"
goal = "FIB-PRIME-001"
section = "Next"
rank = 16000
depends_on = []
touches = ["lib/core/models/fibonacci_complex_model.dart", "test/models/fibonacci_complex_model_test.dart"]
resources = []
kind = "implementation"
ownership = "worker"
scope = "Implement the small family-owned immutable orbit/status model for H_c(z,w)=(zw+c,z), diagonal initial state, simultaneous old-state updates, k=0..N indexing, safe both-component escape region and exact finite prime-degree metadata through F47. No UI, shader, generic complex framework or runtime prime search."
acceptance = ["The new model test independently verifies polynomial degrees for nonzero c, all prime-degree steps/F4 exception/F19 counterexample, c=0 reference points away from precision ambiguity, three-cycle, one-large collapse and both-large growth. Invalid/nonfinite, cap reached and escaped outcomes remain distinct and finite; color cannot alter them. No conjecture proof or rigorous floating-pixel certification claim."]
checks = ["Planned new target: `flutter test --no-pub test/models/fibonacci_complex_model_test.dart --reporter expanded`; format the two touched Dart files and run `flutter analyze --no-pub`. The target does not yet exist; all implementation checks are NOT_RUN."]
exclusions = []
+++

- Section: Next.
- Sources: [Owner outcome](PRD.md#fibonacci-prime-degree-julia-fractal), [decided contract](docs/engineering/spec.md#fibonacci-prime-degree-julia), [checks](docs/engineering/test-plan.md#fibonacci-prime-degree-julia-verification), [retained research](research/fibonacci-prime-degree-julia.md).
- Ownership: Repository backlog, unassigned; preserve existing ordering/owners. Planning-only; no implementation, migration, scheduling or publication dispatched.
- Next action: Write the independent model regression first, observe RED, implement the bounded model and retain GREEN with the tested inputs. Preserve all other task ownership.
