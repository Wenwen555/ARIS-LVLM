#!/usr/bin/env python3
"""
ARIS Skills Installer - Project-Level Mode

This script ensures skills are installed to the project-level skills/ directory,
making them git-trackable and syncable across multiple machines.

Usage:
    python tools/install_skills.py [--check] [--list]

Options:
    --check    Check if project-level skills are properly configured
    --list     List all available skills in the project
"""

import argparse
import os
import sys
import shutil
from pathlib import Path


def get_project_root():
    """Get the project root directory (where this script's parent tools/ dir is)."""
    script_dir = Path(__file__).parent.resolve()
    return script_dir.parent


def get_user_skills_dir():
    """Get user-level Claude skills directory."""
    return Path.home() / ".claude" / "skills"


def get_project_skills_dir():
    """Get project-level skills directory."""
    return get_project_root() / "skills"


def list_project_skills():
    """List all skills in the project-level directory."""
    skills_dir = get_project_skills_dir()
    if not skills_dir.exists():
        print(f"Project skills directory not found: {skills_dir}")
        return []

    skills = []
    for item in skills_dir.iterdir():
        if item.is_dir():
            skill_file = item / "SKILL.md"
            if skill_file.exists():
                # Extract skill name from frontmatter or directory name
                name = item.name
                skills.append(name)

    return sorted(skills)


def check_skills_config():
    """Check if project-level skills are properly configured."""
    project_skills = get_project_skills_dir()
    user_skills = get_user_skills_dir()

    print("=" * 60)
    print("ARIS Skills Configuration Check")
    print("=" * 60)

    # Check project-level skills
    if project_skills.exists():
        skills = list_project_skills()
        print(f"\n[OK] Project-level skills directory: {project_skills}")
        print(f"  Found {len(skills)} skills:")
        for s in skills[:10]:
            print(f"    - {s}")
        if len(skills) > 10:
            print(f"    ... and {len(skills) - 10} more")
    else:
        print(f"\n[X] Project-level skills directory not found: {project_skills}")

    # Check user-level skills (potential duplicates)
    if user_skills.exists():
        user_skills_list = []
        for item in user_skills.iterdir():
            if item.is_dir() and (item / "SKILL.md").exists():
                user_skills_list.append(item.name)

        if user_skills_list:
            print(f"\n[!] User-level skills also exist: {user_skills}")
            print(f"  Found {len(user_skills_list)} skills (may cause confusion):")
            for s in user_skills_list[:10]:
                print(f"    - {s}")

            # Check for duplicates
            project_skills_set = set(list_project_skills())
            duplicates = project_skills_set & set(user_skills_list)
            if duplicates:
                print(f"\n  [!] DUPLICATE skills (loaded from both locations):")
                for d in sorted(duplicates):
                    print(f"    - {d}")
                print("\n  Recommendation: Remove duplicates from user-level to avoid ambiguity")
                print(f"    Run: rm -rf ~/.claude/skills/<skill-name>")

    # Check settings.local.json
    settings_file = get_project_root() / ".claude" / "settings.local.json"
    if settings_file.exists():
        print(f"\n[OK] Project settings found: {settings_file}")
    else:
        print(f"\n[X] Project settings not found: {settings_file}")
        print("  Recommendation: Create .claude/settings.local.json for project-level config")

    print("\n" + "=" * 60)
    print("Summary: Skills are installed at PROJECT level (git-trackable)")
    print("=" * 60)


def install_from_source(source_path: Path):
    """Install skills from a source directory to project-level."""
    project_skills = get_project_skills_dir()

    if not source_path.exists():
        print(f"Source directory not found: {source_path}")
        sys.exit(1)

    print(f"Installing skills from: {source_path}")
    print(f"Target: {project_skills}")

    # Ensure project skills directory exists
    project_skills.mkdir(parents=True, exist_ok=True)

    installed = []
    for item in source_path.iterdir():
        if item.is_dir():
            skill_file = item / "SKILL.md"
            if skill_file.exists():
                target = project_skills / item.name
                if target.exists():
                    print(f"  Skipping {item.name} (already exists)")
                else:
                    shutil.copytree(item, target)
                    installed.append(item.name)
                    print(f"  [OK] Installed {item.name}")

    if installed:
        print(f"\nInstalled {len(installed)} new skills to project level.")
        print("These skills are now git-trackable and will sync across machines.")
    else:
        print("\nNo new skills to install (all already present).")


def main():
    parser = argparse.ArgumentParser(
        description="ARIS Skills Installer - Project-Level Mode"
    )
    parser.add_argument(
        "--check", action="store_true",
        help="Check if project-level skills are properly configured"
    )
    parser.add_argument(
        "--list", action="store_true",
        help="List all available skills in the project"
    )
    parser.add_argument(
        "--clean-user", action="store_true",
        help="Remove duplicate skills from user-level directory"
    )

    args = parser.parse_args()

    if args.check:
        check_skills_config()
    elif args.list:
        skills = list_project_skills()
        print(f"Project-level skills ({len(skills)}):")
        for s in skills:
            print(f"  - {s}")
    elif args.clean_user:
        # Remove duplicates from user-level
        project_skills = set(list_project_skills())
        user_skills_dir = get_user_skills_dir()

        if not user_skills_dir.exists():
            print("No user-level skills directory found.")
            return

        removed = []
        for item in user_skills_dir.iterdir():
            if item.is_dir() and item.name in project_skills:
                skill_file = item / "SKILL.md"
                if skill_file.exists():
                    print(f"Removing duplicate: {item.name}")
                    shutil.rmtree(item)
                    removed.append(item.name)

        if removed:
            print(f"\nRemoved {len(removed)} duplicate skills from user-level.")
        else:
            print("No duplicates found to remove.")
    else:
        # Default: show status
        check_skills_config()


if __name__ == "__main__":
    main()