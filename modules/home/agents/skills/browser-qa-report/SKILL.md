---
name: browser-qa-report
description: "Run browser QA for a UI change: verify a remote deployment, test in Ego Browser, capture screenshots, and publish a Japanese Poof report. Use for browser QA, UI regression validation, or dogfooding; not for non-browser-only changes."
---

# Browser QA report

QA only. Do not change product code.

## 1. Verify deployment

Read repository rules and define the comparison range. Choose the target URL. Do not use an assumed environment.

For a remote environment, record its URL, the source revision and diff, the deployed revision or build, and changed static image assets. Prefer deployment metadata, CI, provider APIs, or CLIs. If browser inspection is the only proof, invoke `ego-browser` and create one TaskSpace for the whole goal.

A branch name, asset URL, or successful response alone is insufficient. Match the deployed revision to the requested diff. For each changed image asset, compare served content or a revision-bound digest or manifest with the source asset. If anything is missing or cannot be verified, publish a Japanese `ブロック` report to Poof. Do not create a QA charter, take change screenshots, or run QA. Local QA requires the user's explicit request and must state that remote deployment was not verified.

## 2. Plan and run QA

For every changed UI behavior, record an ID, preconditions, steps, expected result, and evidence. Test each changed UI area at least once. Add error, loading, responsive, or permission cases only when the diff makes them relevant. Record the actual result. Use `合格`, `不合格`, `ブロック`, or `未実施`. Mark `合格` only after verifying the expected result.

Use `ego-browser` and its rules. Continue in the same TaskSpace used for deployment verification, or create one TaskSpace if that check did not need a browser. Use snapshots for semantic state and stable screenshots for changed UI. Save screenshots with absolute paths and associate each with its case.

Use test data. Exclude credentials, tokens, personal data, and confidential content from screenshots and uploads. Do not purchase, send, delete, publish, bill, or update live data without explicit authorization. Hand off the existing TaskSpace when the user must authenticate or handle a browser prompt.

## 3. Report and publish

Write `report.html` in Japanese. Keep code, URLs, filenames, IDs, and product text verbatim when needed. Include deployment verification, QA scope and environment, the case matrix, defects, automated checks, blockers, and residual risk. When deployment blocks QA, state that QA did not start and leave test and evidence fields as not applicable.

Use `mcp__poof__push` with `files`: `report.html` plus `evidence/*.png`, relative paths, and base64 PNG data. Use a Japanese title. Keep the document owner-only unless the user explicitly requests a public share. After upload, use one `files` call to verify the report and all screenshots. Use `cat` with `raw: true` only when image links need checking. Record the document ID and owner URL.

## Completion

Every case has a status, the report matches its screenshots, and the Poof document is verified. Return the outcome, failures, blockers, residual risks, and owner URL or requested public URL in Japanese.
