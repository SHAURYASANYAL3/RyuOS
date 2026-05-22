# Security & Best Practices

As a systems developer working on RyuOS, adhering to strict security and ops best practices is crucial to maintaining the integrity of the project.

## 1. Secrets Management
- **Never commit credentials:** Do not commit API keys, personal access tokens (PATs), or raw passwords into this repository.
- **`.gitignore` enforcement:** The `.gitignore` file is configured to exclude `*.pem`, `*.key`, `.env`, and other secret files. Ensure you do not forcefully add them.
- If a secret is required for an automated build pipeline, use **GitHub Actions Secrets**.

## 2. Checksum Verification
When downloading external ISOs, scripts, or compiling tools, ensure you verify checksums if available.
The automated release pipeline for RyuOS automatically generates a `SHA256SUM` file. Users are encouraged to verify their downloaded ISOs using:
```bash
sha256sum -c ryuos-cli.iso.sha256
```

## 3. Secure Scripting Practices
All bash scripts in the `scripts/` directory must adhere to the following standards:
- Enable strict mode at the top of every script: `set -euo pipefail`. This ensures the script exits on errors, undefined variables, and pipe failures.
- Avoid passing unsanitized variables to execution strings or `eval`.
- When running commands with `sudo` or `run_root`, explicitly state why root is required.
- Do not use `chmod 777`. Use precise permissions (e.g., `chmod +x` or `chmod 755` for scripts).

## 4. Build Environment Security
When building RyuOS:
- The build script (`scripts/build-iso.sh`) heavily uses `chroot` and requires root access. Ensure you only build RyuOS on a trusted, isolated machine (like a WSL instance or dedicated VM).
- Do not add random untrusted PPAs to the `packages/ryuos.list` configuration. Limit packages to the official Debian/Ubuntu repositories to ensure supply chain security.
