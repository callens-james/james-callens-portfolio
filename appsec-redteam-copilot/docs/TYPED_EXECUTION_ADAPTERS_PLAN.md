# Typed Execution Adapters Plan (v0.5 direction)

## Why
Raw shell commands are flexible but difficult to constrain safely. Typed operations allow clearer policy boundaries.

## Proposed adapter operations
- `write_file(path, content)`
- `apply_patch(path, diff)`
- `move_file(src, dst)`
- `delete_file(path)`
- `run_tests(cmd, cwd)`
- `install_dependency(manager, package, workspace)`

## Policy binding
Each typed operation should require:
- capability token
- workspace containment check
- protected-path floor check
- operation-specific limits (max files/bytes/runtime)

## Benefits
- lower ambiguity vs raw shell
- cleaner audit semantics
- safer non-coder UX
- easier deterministic testing

## Incremental rollout
1. Keep shell broker path.
2. Add typed write/patch adapters first.
3. Route dashboard operations through typed adapters.
4. Keep shell path for advanced fallback with stricter warnings.
