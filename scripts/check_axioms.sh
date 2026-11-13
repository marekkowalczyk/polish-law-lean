#!/usr/bin/env bash
set -euo pipefail

REPORT_FILE="${1:-axiom-report.txt}"

echo "=== Step 1: Checking for 'sorry' and 'axiom' declarations in PolishLawLean ==="
if grep -rnE '(^|[^[:alnum:]_])sorry([^[:alnum:]_]|$)' PolishLawLean.lean PolishLawLean/; then
  echo "ERROR: Found 'sorry' in PolishLawLean source files." >&2
  exit 1
fi

if grep -rnE '^[[:space:]]*(private[[:space:]]+|protected[[:space:]]+)?axiom[[:space:]]+' PolishLawLean.lean PolishLawLean/; then
  echo "ERROR: Found custom 'axiom' declaration in PolishLawLean source files." >&2
  exit 1
fi
echo "OK: Zero 'sorry' and zero 'axiom' declarations in source files."

echo "=== Step 2: Collecting '#print axioms' for all theorems ==="
TMP_LEAN="$(mktemp /tmp/check_axioms_XXXXXX.lean)"
trap 'rm -f "$TMP_LEAN"' EXIT

echo "import PolishLawLean" > "$TMP_LEAN"
echo "" >> "$TMP_LEAN"

THEOREM_COUNT=0
while IFS= read -r file; do
  ns=""
  while IFS= read -r line; do
    if [[ "$line" =~ ^namespace[[:space:]]+([A-Za-z0-9_.]+) ]]; then
      ns="${BASH_REMATCH[1]}"
    elif [[ "$line" =~ ^theorem[[:space:]]+([A-Za-z0-9_′\']+) ]]; then
      thm="${BASH_REMATCH[1]}"
      if [[ -n "$ns" ]]; then
        full_name="${ns}.${thm}"
      else
        full_name="${thm}"
      fi
      echo "#print axioms ${full_name}" >> "$TMP_LEAN"
      THEOREM_COUNT=$((THEOREM_COUNT + 1))
    fi
  done < "$file"
done < <(find PolishLawLean -name '*.lean' | sort)

if [[ "$THEOREM_COUNT" -eq 0 ]]; then
  echo "ERROR: No theorems found in PolishLawLean/." >&2
  exit 1
fi

echo "Auditing $THEOREM_COUNT theorems via 'lake env lean'..."
lake env lean "$TMP_LEAN" > "$REPORT_FILE"

echo "=== Step 3: Validating axiom report ($REPORT_FILE) ==="
cat "$REPORT_FILE"

LINE_COUNT="$(wc -l < "$REPORT_FILE" | tr -d ' ')"
if [[ "$LINE_COUNT" -ne "$THEOREM_COUNT" ]]; then
  echo "ERROR: Expected $THEOREM_COUNT lines in axiom report, got $LINE_COUNT." >&2
  exit 1
fi

while IFS= read -r line; do
  if [[ "$line" =~ ^\'.+\'[[:space:]]does[[:space:]]not[[:space:]]depend[[:space:]]on[[:space:]]any[[:space:]]axioms$ ]]; then
    continue
  elif [[ "$line" =~ ^\'.+\'[[:space:]]depends[[:space:]]on[[:space:]]axioms:[[:space:]]\[(.*)\]$ ]]; then
    axioms_raw="${BASH_REMATCH[1]}"
    IFS=',' read -ra axioms <<< "$axioms_raw"
    for ax in "${axioms[@]}"; do
      ax_trimmed="$(echo "$ax" | tr -d ' ')"
      case "$ax_trimmed" in
        propext|Classical.choice|Quot.sound)
          ;;
        *)
          echo "ERROR: Disallowed axiom '$ax_trimmed' in line: $line" >&2
          exit 1
          ;;
      esac
    done
  else
    echo "ERROR: Unexpected output line in axiom report: $line" >&2
    exit 1
  fi
done < "$REPORT_FILE"

echo "=== PASS: All $THEOREM_COUNT theorems verified with no sorry and no extra axioms ==="
