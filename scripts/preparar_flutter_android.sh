#!/usr/bin/env bash
set -euo pipefail

echo "MOZ LIVROS R — preparação Android"
if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter SDK não encontrado. Instale o Flutter e configure o PATH."
  exit 1
fi

if [ ! -d android ]; then
  echo "A criar a estrutura Android padrão do Flutter..."
  flutter create --platforms=android,web --org mz.mozlivrosr .
else
  echo "A estrutura Android já existe; não será substituída."
fi

flutter pub get
echo
echo "Estrutura preparada. Agora configure Firebase com:"
echo "dart pub global activate flutterfire_cli"
echo "flutterfire configure"
echo
echo "Depois de configurar Firebase, teste com:"
echo "flutter run"
