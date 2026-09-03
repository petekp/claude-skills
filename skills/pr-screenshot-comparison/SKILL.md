---
name: pr-screenshot-comparison
description: "Create clear, polished before-and-after screenshots for a GitHub pull request. Use when a UI change needs visual proof: capture matching states, crop to the relevant UI, stitch and caption one comparison image, attach it natively to the PR, and keep the image out of the repository."
---

# PR Screenshot Comparison

Create a single, reviewer-friendly image that makes a visual UI change easy to evaluate.

## Workflow

1. Define the proof before capturing: route, viewport, theme, interaction state, and the exact UI area that changed. Use the same data and controls on both sides. Prefer the smallest set of states that proves the change; do not screenshot unrelated chrome.
2. Capture the **before** state from the base branch and the **after** state from the PR branch. Use separate worktrees or an equivalent reversible setup so the two captures are genuinely comparable. If real auth or data blocks the route, build a temporary, uncommitted harness from the real shared primitives; remove it before committing.
3. Crop both captures tightly to the affected controls. Preserve enough nearby context to explain the state. Keep crop dimensions and scale identical unless the layout itself changed.
4. Stitch the images side by side in this order: **Before**, then **After**. Add a restrained caption above or below each panel. Use a neutral divider/background and ensure labels remain readable in the captured theme. Produce one PNG, not a set of loose images.
5. Inspect the final image at normal review size. Confirm it shows the actual change, labels are accurate, the crops align, and no sensitive data or unrelated UI is visible.
6. Attach the image to the PR description as a **native GitHub attachment** with `gh pr edit --attach` (see "Attaching with gh" below). Then re-read the stored body and confirm the image reference is a hosted `github.com/user-attachments` URL that renders for the repository.

## Non-negotiable rules

- Do **not** add the PNG to the repository, `.github/assets`, or the PR branch. It is PR context, not product source.
- Do **not** use a raw private-repository file URL for the PR image; it may not render for reviewers. Native GitHub attachments are the durable option.
- Do **not** leave capture harnesses, fixtures, Vite changes, or screenshot tooling in the branch.
- Match viewport, zoom, theme, and component state. A comparison is invalid if those differ without being called out.
- If only one theme is included, say so in the PR description (for example, “Dark-mode comparison”).

## Suggested PR copy

Use a short heading, then the image referenced by its local path, then one sentence:

```md
### Visual comparison (dark mode)

![Before and after: the hover state no longer clips the checkbox](./compare.png)

Before: [old behavior]. After: [new behavior].
```

Describe the meaningful visual difference in one sentence. Do not claim full visual coverage when the image covers only one state or theme.

## Attaching with gh

`gh pr create`, `gh pr edit`, and `gh pr comment` take `--attach '<file>#<alt text>'` (gh 2.99.0 or newer; check `gh --version`). gh uploads the file and rewrites a matching local path in the body to the hosted asset URL, keeping the alt text. With no body flag it appends the image to the end of the existing body instead.

To place the image under its heading, append the copy above to the current body and attach in the same command:

```bash
gh pr view <number> --json body --jq .body > "$TMPDIR/pr-body.md"
cat >> "$TMPDIR/pr-body.md" <<'EOF'
<the PR copy above>
EOF
gh pr edit <number> --body-file "$TMPDIR/pr-body.md" --attach './compare.png#Before and after: ...'
gh pr view <number> --json body --jq .body
```

The path in the body must match the path passed to `--attach`. The flag repeats for more files, up to 50 per command. Accepted formats: PNG, JPEG, GIF, WebP, SVG, MP4, MOV, WebM. Images are capped at 10 MB. Uploading needs write access to the repository, and GitHub Enterprise Server is not supported.

Fall back to the web editor only when gh is older than 2.99.0 or the repository is on GitHub Enterprise Server: drag the PNG into the description, save, and verify it renders.

## Final check

Before handoff, verify all of the following:

- The PR description displays one captioned before/after image.
- The stored PR body references a hosted `github.com/user-attachments` URL, not a local path or a file changed by the PR.
- `git diff <base>...HEAD` contains no image asset or temporary capture code.
- The visible after state matches the committed implementation.
