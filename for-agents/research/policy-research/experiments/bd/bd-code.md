# Beautiful Code Policy

Code exists to make behavior real.

Beautiful code is code that has little to hide. It can be read from source. It
can be understood in order. It makes its structure available before it asks for
trust.

This policy follows a simple test. If code does not express behavior, remove
it. If removing it hides behavior, keep it.

## Principles

Prefer plain language names.

Prefer direct structure.

Prefer standard tools.

Prefer small files that can be read whole.

Prefer behavior that still works in modest environments.

Prefer comments that explain intent only where intent is not obvious.

## Rules

Code must be honest about what it does.

Code must not use abstraction to avoid naming a decision.

Code must not make simple behavior depend on complex machinery.

Code must not require a large runtime for a small promise.

Code must keep generated, decorative, and incidental work away from the main
path of understanding.

## Checks

Read the source in a terminal.

Read the output in the simplest useful renderer.

Count what changed.

Delete a helper. If the result is clearer, the helper was not helping.

Keep the version that makes the next edit obvious.

## Source Spirit

The beautiful document is static HTML. Its source looks like its rendered
shape. Its code is small enough that review can be an act of reading.

