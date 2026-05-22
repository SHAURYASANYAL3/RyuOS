# Contributing to RyuOS

Thanks for your interest in contributing! Here's how to get started.

## Development Setup

```bash
git clone https://github.com/YOUR_USERNAME/ryuos.git
cd ryuos
./scripts/setup-build-env.sh
```

## Workflow

1. Fork the repo
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Make changes
4. Test locally: `./scripts/build-iso.sh && ./scripts/qemu-test.sh`
5. Commit with clear messages: `git commit -m "feat: Add feature description"`
6. Push and create a Pull Request

## Commit Message Format

```
<type>: <subject>

<body>

<footer>
```

Types: feat, fix, docs, style, refactor, perf, test, chore

Example:
```
feat: Optimize kernel boot sequence

- Disable unused drivers
- Enable CONFIG_PREEMPT
- Boot time: 18s → 12s

Fixes #42
```

## Reporting Issues

Include:
- System information (WSL2, Debian version, kernel version)
- Steps to reproduce
- Expected vs actual behavior
- Relevant logs from `build.log`

## Code Style

- Follow Linux kernel coding style
- Use meaningful variable names
- Keep functions focused and small
- Comment non-obvious logic

## Testing

Always test locally:
```bash
./scripts/build-iso.sh
./scripts/qemu-test.sh
```

Ensure:
- ISO builds without errors
- ISO boots in QEMU
- System reaches login prompt
- Basic tools work (ls, cd, cp, etc)

## Questions?

Open an issue or contact the maintainer.

Thank you for contributing! 🎉
