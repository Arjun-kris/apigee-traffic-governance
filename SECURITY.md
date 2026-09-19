# Security

## Scope

This repository intentionally does not handle backend credentials or API
consumer secrets.

The governance KVM should contain traffic-control configuration only. Do not put
passwords, private keys, access tokens, or client secrets in the example JSON.

## Operational security

- Restrict who can edit environment KVMs.
- Restrict who can deploy Shared Flows.
- Restrict who can attach/detach Flow Hooks.
- Use change review for production `enforce` changes.
- Keep `.env` out of source control.
- Use short-lived Google Cloud access tokens from `gcloud auth print-access-token`
  rather than committing credentials.

## Blast radius

A PreProxy Flow Hook runs for every proxy in the environment. Treat a Flow Hook
change as a platform-level production change.

The repository therefore defaults to monitor mode and requires a confirmation
before attaching or detaching the hook.
