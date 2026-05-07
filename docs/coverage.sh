#!/bin/sh
# Run coverage scenarios, annotate, and write a Shields.io JSON badge.
# Usage: docs/coverage.sh <binary> <output.json>
set -eu

BINARY="${1:?binary path required}"
OUT_JSON="${2:?output json path required}"
COV_DIR="$(dirname "$BINARY")"
MERGED="$COV_DIR/merged.out"

echo "Running coverage scenarios..."

# no_stdin: direct piped run — PTY-based expect tests can't produce stdin EOF
printf '' | valgrind --tool=callgrind \
    --callgrind-out-file="$COV_DIR/no_stdin.out" \
    --quiet "$BINARY" >/dev/null 2>&1 || true

for pair in \
    "$COV_DIR/draw.out:tests/test_draw.exp" \
    "$COV_DIR/win_diag_tl.out:tests/test_win.exp" \
    "$COV_DIR/double_invalid.out:tests/test_invalid_repeat.exp" \
    "$COV_DIR/win_horiz.out:tests/test_win_horiz.exp" \
    "$COV_DIR/win_vert.out:tests/test_win_vert.exp" \
    "$COV_DIR/win_diag_tr.out:tests/test_win_diag_tr.exp"; do
    COVERAGE_OUT="${pair%%:*}" expect "${pair##*:}" >/dev/null 2>&1
done

# Merge: strip repeated file headers from files 2+
awk 'FNR==1 && NR>1 {skip=1} /^fl=/{skip=0} !skip' \
    "$COV_DIR/no_stdin.out" \
    "$COV_DIR/draw.out" \
    "$COV_DIR/win_diag_tl.out" \
    "$COV_DIR/double_invalid.out" \
    "$COV_DIR/win_horiz.out" \
    "$COV_DIR/win_vert.out" \
    "$COV_DIR/win_diag_tr.out" > "$MERGED"

# Fix summary so callgrind_annotate's 99% threshold uses the correct total
TOTAL_IR=$(grep '^totals:' "$MERGED" | awk '{s+=$2} END{print s}')
sed -i "s/^summary:.*/summary: $TOTAL_IR/" "$MERGED"

callgrind_annotate --auto=yes "$MERGED"

# Executable lines from DWARF debug info
objdump --dwarf=decodedline "$BINARY" 2>/dev/null | awk '
    $2 ~ /^[0-9]+$/ && $3 ~ /^0x/ {
        n = split($1, p, "/"); print p[n] ":" $2
    }' | sort -u > "$COV_DIR/dwarf.tmp"

# Lines recorded by callgrind (two-pass to resolve forward alias refs)
awk '
FNR == NR {
    if (/^(fl|cfi)=\([0-9]+\) /) {
        line = $0; sub(/^[a-z]+=/, "", line)
        e = index(line, ")")
        n = split(substr(line, e + 2), p, "/")
        aliases[substr(line, 2, e - 2)] = p[n]
    }
    next
}
/^fl=/ {
    line = $0; sub(/^fl=/, "", line)
    e = index(line, ")")
    if (substr(line, 1, 1) == "(") {
        cur_file = aliases[substr(line, 2, e - 2)]
    } else {
        n = split(line, p, "/"); cur_file = p[n]
    }
    cur_line = 0
}
/^fn=/ { cur_line = 0 }
/^[0-9]+ [0-9]+$/ && NF==2 { cur_line = $1+0; print cur_file ":" cur_line }
/^\+[0-9]+ [0-9]+$/ && NF==2 { cur_line += substr($1,2)+0; print cur_file ":" cur_line }
' "$MERGED" "$MERGED" | sort -u > "$COV_DIR/cg.tmp"

COVERED=$(comm -12 "$COV_DIR/dwarf.tmp" "$COV_DIR/cg.tmp" | wc -l | tr -d ' ')
TOTAL=$(wc -l < "$COV_DIR/dwarf.tmp" | tr -d ' ')
rm "$COV_DIR/dwarf.tmp" "$COV_DIR/cg.tmp"

PCT=$(printf "%.1f" "$(echo "scale=4; $COVERED * 100 / $TOTAL" | bc)")
printf "Coverage: %s/%s lines (%s%%)\n" "$COVERED" "$TOTAL" "$PCT"

PCT_INT=$(echo "$PCT" | cut -d. -f1)
if   [ "$PCT_INT" -lt 60 ]; then COLOR="red"
elif [ "$PCT_INT" -lt 80 ]; then COLOR="yellow"
elif [ "$PCT_INT" -lt 90 ]; then COLOR="yellowgreen"
else                             COLOR="brightgreen"
fi
printf '{"schemaVersion":1,"label":"coverage","message":"%s%%","color":"%s"}\n' \
    "$PCT" "$COLOR" > "$OUT_JSON"
