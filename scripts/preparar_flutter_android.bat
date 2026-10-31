@echo off
echo MOZ LIVROS R - preparacao Android
where flutter >nul 2>nul
if errorlevel 1 (
  echo Flutter SDK nao encontrado. Instale o Flutter e configure o PATH.
  pause
  exit /b 1
)
if not exist android (
  flutter create --platforms=android,web --org mz.mozlivrosr .
) else (
  echo A estrutura Android ja existe; nao sera substituida.
)
flutter pub get
echo.
echo Configure Firebase com:
echo dart pub global activate flutterfire_cli
echo flutterfire configure
echo.
echo Para testar:
echo flutter run
pause
