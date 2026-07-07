#!/usr/bin/env bash
set -euo pipefail

FLUTTER_ROOT="${FLUTTER_ROOT:-$HOME/flutter}"

if [ ! -x "$FLUTTER_ROOT/bin/flutter" ]; then
  git clone --depth 1 -b stable https://github.com/flutter/flutter.git "$FLUTTER_ROOT"
fi

export PATH="$FLUTTER_ROOT/bin:$PATH"

: "${SUPABASE_URL:?SUPABASE_URL is required for the Vercel build}"
: "${SUPABASE_ANON_KEY:?SUPABASE_ANON_KEY is required for the Vercel build}"

flutter config --enable-web
flutter pub get
flutter build web --release \
  --dart-define="SUPABASE_URL=$SUPABASE_URL" \
  --dart-define="SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY"