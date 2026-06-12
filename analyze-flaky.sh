#!/usr/bin/env bash
# Flaky test analyzer — scans GitHub Actions runs and reports failure rates
set -euo pipefail

REPO="${1:-}"
RUNS="${2:-50}"

if [[ -z "$REPO" ]]; then
  echo "Usage: ./analyze-flaky.sh owner/repo [num_runs]"
  echo "Example: ./analyze-flaky.sh microsoft/vscode 100"
  exit 1
fi

if ! gh auth status &>/dev/null; then
  echo "Not authenticated. Run: gh auth login"
  exit 1
fi

echo "=== Flaky Test Analyzer ==="
echo "Repo : $REPO"
echo "Runs : $RUNS"
echo ""

# Fetch recent workflow runs
echo "Fetching workflow runs..."
RUNS_JSON=$(gh run list --repo "$REPO" --limit "$RUNS" --json databaseId,conclusion,headBranch,workflowName,createdAt 2>/dev/null)

TOTAL=$(echo "$RUNS_JSON" | python3 -c "import json,sys; data=json.load(sys.stdin); print(len(data))")
FAILED=$(echo "$RUNS_JSON" | python3 -c "import json,sys; data=json.load(sys.stdin); print(sum(1 for r in data if r['conclusion']=='failure'))")
SUCCESS=$(echo "$RUNS_JSON" | python3 -c "import json,sys; data=json.load(sys.stdin); print(sum(1 for r in data if r['conclusion']=='success'))")

echo "--- Summary (last $TOTAL runs) ---"
echo "Total  : $TOTAL"
echo "Success: $SUCCESS"
echo "Failed : $FAILED"
if [[ "$TOTAL" -gt 0 ]]; then
  RATE=$(python3 -c "print(f'{$FAILED/$TOTAL*100:.1f}%')")
  echo "Fail rate: $RATE"
fi

echo ""
echo "--- Failures by workflow ---"
echo "$RUNS_JSON" | python3 -c "
import json, sys
from collections import Counter
data = json.load(sys.stdin)
failed = [r['workflowName'] for r in data if r['conclusion'] == 'failure']
for name, count in Counter(failed).most_common(10):
    print(f'  {count:3d}x  {name}')
"

echo ""
echo "--- Failed run IDs (most recent 10) ---"
echo "$RUNS_JSON" | python3 -c "
import json, sys
data = json.load(sys.stdin)
failed = [r for r in data if r['conclusion'] == 'failure'][:10]
for r in failed:
    print(f'  {r[\"databaseId\"]}  [{r[\"headBranch\"]}]  {r[\"createdAt\"]}')
"

echo ""
echo "To inspect a specific run:"
echo "  gh run view <run_id> --repo $REPO --log-failed"
