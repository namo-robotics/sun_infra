# Development guide

This repository owns shared Sun development infrastructure. Run commands from
this repository's root. Keep generated validation outputs in `build/` and
temporary files in `tmp/`; both directories are ignored.

- Validate with `python3 scripts/prepare-smoke-test.py`,
  `bash -n src/sun-existing-dockerfile/.devcontainer/post-create.sh`, and
  `devcontainer read-configuration --workspace-folder build/smoke > build/configuration.json`.
- Run the container smoke test using the commands in README.md.
- Bump the template metadata version when changing published template files.
- Preserve project-specific Dockerfiles, build scripts, and release policies.
- Do not automatically update compilers or import repositories during startup.
- Limit parallel builds and tests to at most half the available cores, minimum one.
- Document every function, type, and module using the language's native comments.
- Use commit subjects in the form `<scope>: <imperative description>`.
- Do not create issues or pull requests unless explicitly requested.
- Do not use mutating Git commands unless explicitly requested.
