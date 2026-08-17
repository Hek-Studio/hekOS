#!/bin/bash
# scripts/release.sh — release helper for hekOS maintainers.
#
# Reads Conventional Commits (feat:, fix:, refactor:, chore:, docs:, ...)
# since the last tag, suggests a semver bump, writes a CHANGELOG.md entry,
# and optionally creates the git tag / GitHub release. Every consequential
# step (tag, push, gh release) asks for confirmation first.
#
# Usage: scripts/release.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

entry_file=""
cleanup() { [ -n "$entry_file" ] && rm -f "$entry_file"; }
trap cleanup EXIT

CHANGELOG_FILE="$REPO_ROOT/CHANGELOG.md"

if ! git rev-parse --is-inside-work-tree &> /dev/null; then
    echo "Not a git repository." >&2
    exit 1
fi

last_tag=$(git describe --tags --abbrev=0 2>/dev/null || true)

if [ -z "$last_tag" ]; then
    range="HEAD"
    echo "No previous tags found — this will be the first release."
else
    range="$last_tag..HEAD"
    echo "Changes since $last_tag:"
fi
echo ""

mapfile -t commits < <(git log --no-merges --pretty=format:'%s' $range)

if [ ${#commits[@]} -eq 0 ]; then
    echo "No new commits since $last_tag. Nothing to release."
    exit 0
fi

declare -a feats=() fixes=() refactors=() chores=() docs=() others=()
breaking=0

for subject in "${commits[@]}"; do
    type="" desc=""
    if [[ "$subject" =~ ^([a-zA-Z]+)(\([^\)]*\))?(!)?:\ (.*)$ ]]; then
        type="${BASH_REMATCH[1],,}"
        bang="${BASH_REMATCH[3]}"
        desc="${BASH_REMATCH[4]}"
        [ -n "$bang" ] && breaking=1
    else
        type="other"
        desc="$subject"
    fi
    [[ "$subject" == *"BREAKING CHANGE"* ]] && breaking=1

    case "$type" in
        feat) feats+=("$desc") ;;
        fix) fixes+=("$desc") ;;
        refactor) refactors+=("$desc") ;;
        chore) chores+=("$desc") ;;
        docs) docs+=("$desc") ;;
        *) others+=("$subject") ;;
    esac
done

# --- Suggest a version ---
if [ -z "$last_tag" ]; then
    suggested="v1.0.0"
else
    ver="${last_tag#v}"
    IFS='.' read -r major minor patch <<< "$ver"
    if [ "$breaking" -eq 1 ]; then
        major=$((major + 1)); minor=0; patch=0
    elif [ ${#feats[@]} -gt 0 ]; then
        minor=$((minor + 1)); patch=0
    else
        patch=$((patch + 1))
    fi
    suggested="v${major}.${minor}.${patch}"
fi

print_section() {
    local title="$1"; shift
    local items=("$@")
    [ ${#items[@]} -eq 0 ] && return
    echo "$title"
    printf '  - %s\n' "${items[@]}"
    echo ""
}

echo "=================================================="
echo " Suggested version: $suggested"
echo "=================================================="
echo ""
print_section "Features:" "${feats[@]}"
print_section "Fixes:" "${fixes[@]}"
print_section "Refactors:" "${refactors[@]}"
print_section "Chores:" "${chores[@]}"
print_section "Docs:" "${docs[@]}"
print_section "Other:" "${others[@]}"

read -rp "Use version $suggested? [Y/n, or type a custom version like v1.2.0]: " answer
case "$answer" in
    ""|[Yy]|[Yy][Ee][Ss]) version="$suggested" ;;
    [Nn]|[Nn][Oo]) echo "Aborted."; exit 1 ;;
    v[0-9]*) version="$answer" ;;
    *) echo "Unrecognized input, aborting."; exit 1 ;;
esac

date_str=$(date +%Y-%m-%d)
entry_file=$(mktemp)

{
    echo "## $version - $date_str"
    echo ""
    if [ ${#feats[@]} -gt 0 ]; then
        echo "### Added"
        printf -- '- %s\n' "${feats[@]}"
        echo ""
    fi
    if [ ${#fixes[@]} -gt 0 ]; then
        echo "### Fixed"
        printf -- '- %s\n' "${fixes[@]}"
        echo ""
    fi
    if [ ${#refactors[@]} -gt 0 ]; then
        echo "### Changed"
        printf -- '- %s\n' "${refactors[@]}"
        echo ""
    fi
    if [ ${#chores[@]} -gt 0 ] || [ ${#docs[@]} -gt 0 ] || [ ${#others[@]} -gt 0 ]; then
        echo "### Other"
        for item in "${chores[@]}" "${docs[@]}" "${others[@]}"; do
            printf -- '- %s\n' "$item"
        done
        echo ""
    fi
} > "$entry_file"

if [ -f "$CHANGELOG_FILE" ]; then
    tmp_file=$(mktemp)
    cat "$entry_file" "$CHANGELOG_FILE" > "$tmp_file"
    mv "$tmp_file" "$CHANGELOG_FILE"
else
    { echo "# Changelog"; echo ""; cat "$entry_file"; } > "$CHANGELOG_FILE"
fi

echo "Updated $CHANGELOG_FILE with $version. Review it before continuing."
echo ""

read -rp "Commit the changelog and create git tag $version now? [y/N]: " do_tag
if [[ "$do_tag" =~ ^[Yy] ]]; then
    git add "$CHANGELOG_FILE"
    git commit -m "chore: release $version"
    git tag -a "$version" -m "$version"
    echo "Tagged $version locally."

    read -rp "Push the commit and tag to origin now? [y/N]: " do_push
    if [[ "$do_push" =~ ^[Yy] ]]; then
        git push
        git push origin "$version"
        echo "Pushed."

        if command -v gh &> /dev/null; then
            read -rp "Create a GitHub Release for $version via gh? [y/N]: " do_gh
            if [[ "$do_gh" =~ ^[Yy] ]]; then
                gh release create "$version" --title "$version" --notes-file "$entry_file" 2>/dev/null \
                    || gh release create "$version" --title "$version" --generate-notes
                echo "GitHub Release created."
            fi
        fi
    else
        echo "Not pushed. Run 'git push && git push origin $version' when ready."
    fi
else
    echo "Skipped tagging. Review $CHANGELOG_FILE, commit it yourself, then re-run this script or tag manually."
fi
