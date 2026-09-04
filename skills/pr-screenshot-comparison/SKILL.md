---
name: pr-screenshot-comparison
description: "Create clear, polished before-and-after screenshots from the actual running product for a GitHub pull request. Use when a UI change needs visual proof: capture matching product states, crop to the relevant UI, stitch and caption one comparison image, attach it natively to the PR, and keep the image out of the repository."
---

# PR Screenshot Comparison

Create a single, reviewer-friendly image that makes a visual UI change easy to evaluate.

## Product evidence rule

A PR screenshot is evidence of the product, not a design illustration. Every panel must come from the actual product route running the exact base or PR commit. It must use the real app shell, routing, authentication boundary, and data path.

A component harness, Storybook story, static reconstruction, fabricated destination page, or mock data screen does not qualify as product evidence. Do not attach one to a PR or describe it as an application screenshot.

If authentication or data blocks the route:

1. Start or reuse the project's canonical local environment.
2. Reuse an authenticated browser session when one is available. If sign-in needs the user, request the smallest necessary handoff.
3. If the actual route still cannot be reached, stop and report the blocker. A missing screenshot is more accurate than fabricated proof.

Build a harness only when the user explicitly asks for component-level evidence. Label it **Component harness** in the image and PR copy. Never mix it with or substitute it for product screenshots.

## Internal data policy

For a verified private or internal PR, use the actual product data on screen, including PHI. Do not replace names, records, or content with fake data solely for privacy. These screenshots are internal review artifacts.

Still exclude credentials, access tokens, passwords, API keys, and unrelated sensitive data. For a public or externally visible PR, minimize or redact sensitive data before capture.

## Workflow

1. Define the proof before capturing: route, viewport, theme, interaction states, and the exact UI area that changed. Before capture, list every user-visible behavior introduced or changed by the PR; the final artifact must cover each material behavior. If an interactive control is central to the change, show both its default state and its primary open or activated state. When the base has no equivalent control, use three panels: **Before**, **After at rest**, and **After activated**. Use the same data and controls wherever they exist. Prefer the smallest complete set of states that proves the change; do not screenshot unrelated chrome.
2. Capture the **before** state from the actual product route on the base branch and the **after** state from that same route on the PR branch. Use separate worktrees or an equivalent reversible setup so the two captures are genuinely comparable. Use the same authenticated session and product data where possible. Do not replace a blocked product route with a mock or harness.
3. Crop both captures tightly to the affected controls. Preserve enough nearby context to explain the state. Keep crop dimensions and scale identical unless the layout itself changed.
4. Stitch the images into one comparison image, ordered **Before** then **After**. Use the three-panel order from step 1 when the change adds a central interaction that has no base equivalent. Add a restrained caption above or below each panel. Use a neutral divider/background and ensure labels remain readable in the captured theme. Produce one PNG, not a set of loose images.
5. Inspect the final image at normal review size. Confirm it shows the actual running product, labels are accurate, the crops align, and no unrelated UI or prohibited secret is visible. Apply the internal data policy above instead of fabricating safer-looking content.
6. Attach the image to the PR description as a **native GitHub attachment** with `gh pr edit --attach` (see "Attaching with gh" below). Then re-read the stored body and confirm the image reference is a hosted `github.com/user-attachments` URL that renders for the repository.

## Non-negotiable rules

- Every product screenshot must come from the actual product route on the named commit. Do not fabricate UI, records, or destination pages.
- Do not use a harness as a fallback for blocked authentication or data. Use it only after an explicit request for component-level evidence, and label it clearly.
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

- Every panel came from the actual product route and named commit, not a harness, fixture page, Storybook story, or reconstruction.
- Any PHI shown is going only to a verified private or internal PR.
- The PR description displays one captioned before/after image.
- The stored PR body references a hosted `github.com/user-attachments` URL, not a local path or a file changed by the PR.
- `git diff <base>...HEAD` contains no image asset or temporary capture code.
- The visible after state matches the committed implementation.
- Every material state in the PR description or acceptance criteria is shown or explicitly excluded.
