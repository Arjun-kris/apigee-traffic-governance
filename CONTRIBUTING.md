# Contributing

1. Create a branch.
2. Keep default behavior fail-open and monitor-only.
3. Do not add secrets to configuration samples.
4. Add or update tests for decision-engine behavior.
5. Run `./scripts/validate.sh`.
6. Run `./scripts/package-sharedflow.sh`.
7. Open a pull request describing runtime impact and rollback steps.

Changes to `sharedflowbundle/` should be reviewed as environment-wide changes,
because the bundle is intended for a PreProxy Flow Hook.
