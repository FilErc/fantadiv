@echo off
echo 🔧 Abilitazione supporto web...
flutter config --enable-web

echo 📱 Verifica dispositivi disponibili...
flutter devices

echo 🧹 Pulizia progetto...
flutter clean

echo 🛠 Build web app con base-href "/fantadiv/"...
flutter build web --base-href "/fantadiv/"

echo 🌍 Installazione gh-pages globalmente (se non già installato)...
npm install -g gh-pages

echo 🚀 Deploy su GitHub Pages...
gh-pages -d build/web

echo ✅ Deploy completato! Visita: https://filerc.github.io/fantadiv/
pause
