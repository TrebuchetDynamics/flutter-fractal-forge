# Start with pure Dart fixed-point reference orbits

Accepted: the next exactness prototype for deep-zoom reference orbits starts with pure Dart `BigInt`/fixed-point arithmetic rather than GMP/MPFR FFI. This keeps the first CPU Precision proof portable across Flutter targets and easy to test in-process, while deferring native FFI performance and packaging complexity until the Precision Ladder model proves useful.

## Considered Options

- Pure Dart `BigInt`/fixed-point reference-orbit generation first.
- GMP/MPFR FFI reference-orbit generation first.

## Consequences

The prototype may be slow and narrow, but it can become a deterministic exactness fixture for tests without adding platform build dependencies. FFI remains available later if measured performance or zoom depth requirements justify the integration cost.
