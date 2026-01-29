#!/usr/bin/env python3
"""
Project Discovery Script for Autonomous Agent Readiness Assessment

Scans a project directory and reports findings relevant to agent readiness.
Output is JSON for easy parsing by Claude.

Usage:
    python discover.py /path/to/project
    python discover.py .  # current directory
"""

import json
import os
import sys
from pathlib import Path


def find_files(root: Path, patterns: list[str]) -> list[str]:
    """Find files matching any of the given patterns."""
    found = []
    for pattern in patterns:
        found.extend(str(p.relative_to(root)) for p in root.rglob(pattern))
    return sorted(set(found))


def check_file_exists(root: Path, paths: list[str]) -> dict[str, bool]:
    """Check which files exist."""
    return {p: (root / p).exists() for p in paths}


def read_file_preview(path: Path, max_lines: int = 50) -> str | None:
    """Read first N lines of a file, return None if not readable."""
    try:
        with open(path, 'r', encoding='utf-8', errors='ignore') as f:
            lines = []
            for i, line in enumerate(f):
                if i >= max_lines:
                    lines.append(f"... (truncated at {max_lines} lines)")
                    break
                lines.append(line.rstrip())
            return '\n'.join(lines)
    except Exception:
        return None


def detect_stack(root: Path) -> list[str]:
    """Detect the project's technology stack."""
    stack = []

    indicators = {
        'node': ['package.json'],
        'python': ['requirements.txt', 'pyproject.toml', 'setup.py', 'Pipfile'],
        'ruby': ['Gemfile'],
        'go': ['go.mod'],
        'rust': ['Cargo.toml'],
        'java': ['pom.xml', 'build.gradle'],
        'dotnet': ['*.csproj', '*.sln'],
        'php': ['composer.json'],
    }

    for tech, files in indicators.items():
        for f in files:
            if '*' in f:
                if list(root.glob(f)):
                    stack.append(tech)
                    break
            elif (root / f).exists():
                stack.append(tech)
                break

    return stack


def discover_project(project_path: str) -> dict:
    """Run discovery on a project and return findings."""
    root = Path(project_path).resolve()

    if not root.is_dir():
        return {"error": f"Not a directory: {project_path}"}

    findings = {
        "project_root": str(root),
        "project_name": root.name,
        "stack": detect_stack(root),
    }

    # Containerization
    container_files = check_file_exists(root, [
        'Dockerfile',
        'docker-compose.yml',
        'docker-compose.yaml',
        '.devcontainer/devcontainer.json',
        'devcontainer.json',
    ])
    findings["containerization"] = {
        "files": {k: v for k, v in container_files.items() if v},
        "has_dockerfile": container_files.get('Dockerfile', False),
        "has_compose": container_files.get('docker-compose.yml', False) or container_files.get('docker-compose.yaml', False),
        "has_devcontainer": container_files.get('.devcontainer/devcontainer.json', False) or container_files.get('devcontainer.json', False),
    }

    # CI/CD
    ci_files = find_files(root, [
        '.github/workflows/*.yml',
        '.github/workflows/*.yaml',
        '.gitlab-ci.yml',
        'Jenkinsfile',
        '.circleci/config.yml',
        'azure-pipelines.yml',
        '.travis.yml',
        'bitbucket-pipelines.yml',
    ])
    findings["ci_cd"] = {
        "files": ci_files,
        "has_ci": len(ci_files) > 0,
        "platforms": [],
    }
    if any('.github' in f for f in ci_files):
        findings["ci_cd"]["platforms"].append("github_actions")
    if any('.gitlab' in f for f in ci_files):
        findings["ci_cd"]["platforms"].append("gitlab_ci")
    if any('Jenkins' in f for f in ci_files):
        findings["ci_cd"]["platforms"].append("jenkins")

    # Database setup
    db_indicators = find_files(root, [
        'migrations/*',
        'db/migrate/*',
        'alembic/*',
        'prisma/migrations/*',
        'seeds/*',
        'fixtures/*',
        '**/seeds.sql',
        '**/seed.sql',
    ])
    findings["database"] = {
        "migration_files": [f for f in db_indicators if 'migrat' in f.lower()],
        "seed_files": [f for f in db_indicators if 'seed' in f.lower() or 'fixture' in f.lower()],
        "has_migrations": any('migrat' in f.lower() for f in db_indicators),
        "has_seeds": any('seed' in f.lower() or 'fixture' in f.lower() for f in db_indicators),
    }

    # Check for database in docker-compose
    compose_path = root / 'docker-compose.yml'
    if not compose_path.exists():
        compose_path = root / 'docker-compose.yaml'
    if compose_path.exists():
        compose_content = read_file_preview(compose_path, 200)
        if compose_content:
            db_services = []
            for db in ['postgres', 'mysql', 'mongo', 'redis', 'sqlite']:
                if db in compose_content.lower():
                    db_services.append(db)
            findings["database"]["compose_services"] = db_services

    # Environment management
    env_files = check_file_exists(root, [
        '.env.example',
        '.env.sample',
        '.env.template',
        'env.example',
        '.envrc',
    ])
    findings["environment"] = {
        "example_env": {k: v for k, v in env_files.items() if v},
        "has_env_example": any(env_files.values()),
    }

    # Dependency lockfiles
    lockfiles = check_file_exists(root, [
        'package-lock.json',
        'yarn.lock',
        'pnpm-lock.yaml',
        'poetry.lock',
        'Pipfile.lock',
        'Gemfile.lock',
        'go.sum',
        'Cargo.lock',
        'composer.lock',
    ])
    findings["dependencies"] = {
        "lockfiles": {k: v for k, v in lockfiles.items() if v},
        "has_lockfile": any(lockfiles.values()),
    }

    # Version pinning
    version_files = check_file_exists(root, [
        '.nvmrc',
        '.node-version',
        '.python-version',
        '.ruby-version',
        '.tool-versions',
        '.sdkmanrc',
    ])
    findings["version_pinning"] = {
        "files": {k: v for k, v in version_files.items() if v},
        "has_version_pinning": any(version_files.values()),
    }

    # Testing
    test_dirs = []
    for pattern in ['tests', 'test', '__tests__', 'spec', 'specs']:
        if (root / pattern).is_dir():
            test_dirs.append(pattern)

    test_configs = check_file_exists(root, [
        'jest.config.js',
        'jest.config.ts',
        'pytest.ini',
        'pyproject.toml',  # may contain pytest config
        'vitest.config.ts',
        'vitest.config.js',
        '.rspec',
        'phpunit.xml',
    ])

    findings["testing"] = {
        "test_directories": test_dirs,
        "config_files": {k: v for k, v in test_configs.items() if v},
        "has_tests": len(test_dirs) > 0,
    }

    # Scripts and CLI
    script_dirs = []
    for pattern in ['scripts', 'bin', 'tools']:
        if (root / pattern).is_dir():
            script_dirs.append(pattern)

    has_makefile = (root / 'Makefile').exists()
    has_taskfile = (root / 'Taskfile.yml').exists() or (root / 'Taskfile.yaml').exists()
    has_justfile = (root / 'justfile').exists() or (root / 'Justfile').exists()

    findings["scripts"] = {
        "directories": script_dirs,
        "has_makefile": has_makefile,
        "has_taskfile": has_taskfile,
        "has_justfile": has_justfile,
        "has_task_runner": has_makefile or has_taskfile or has_justfile,
    }

    # Documentation
    doc_files = check_file_exists(root, [
        'README.md',
        'README.rst',
        'CONTRIBUTING.md',
        'docs/README.md',
        'DEVELOPMENT.md',
        'SETUP.md',
    ])
    findings["documentation"] = {
        "files": {k: v for k, v in doc_files.items() if v},
        "has_readme": doc_files.get('README.md', False) or doc_files.get('README.rst', False),
        "has_contributing": doc_files.get('CONTRIBUTING.md', False),
    }

    # Resource limits (check for kubernetes/docker resource configs)
    k8s_files = find_files(root, [
        'k8s/*.yaml',
        'k8s/*.yml',
        'kubernetes/*.yaml',
        'kubernetes/*.yml',
        'helm/**/values.yaml',
        'deploy/*.yaml',
        'deploy/*.yml',
    ])
    findings["resource_management"] = {
        "kubernetes_files": k8s_files,
        "has_k8s": len(k8s_files) > 0,
    }

    return findings


def main():
    if len(sys.argv) < 2:
        print("Usage: discover.py <project-path>", file=sys.stderr)
        sys.exit(1)

    project_path = sys.argv[1]
    findings = discover_project(project_path)
    print(json.dumps(findings, indent=2))


if __name__ == "__main__":
    main()
