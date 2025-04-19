#!/bin/bash

set -euo pipefail

INPUT="pg_dump.sql"
OUTPUT="clean_dump.sql"

if [ ! -f "$INPUT" ]; then
	echo "❌ Input file '$INPUT' not found."
	exit 1
fi

# -e 's/::[a-zA-Z0-9_ ]\+//g' \
sed \
	-e 's/\bNOW()\b/CURRENT_TIMESTAMP/g' \
	-e 's/\btrue\b/1/g' \
	-e 's/\bfalse\b/0/g' \
	-e "s/E'/'/g" \
	-e 's/\\\"/"/g' \
	-e 's/INSERT INTO public\./INSERT INTO /g' \
	"$INPUT" >"$OUTPUT"

echo "✅ Clean SQL written to: $OUTPUT"
