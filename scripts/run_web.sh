#!/bin/bash

set -euo pipefail

IP=${1:-$(hostname -I | awk '{print $1}')}
PORT=${2:-8080}
BACKEND_HOST=${BACKEND_HOST_WEB:-$IP:8000}
OPEN_BROWSER=${OPEN_BROWSER:-true}

CHROME_BIN=""
for candidate in google-chrome google-chrome-stable chromium chromium-browser; do
  if command -v "$candidate" >/dev/null 2>&1; then
    CHROME_BIN="$candidate"
    break
  fi
done

echo "------------------------------------------------"
echo "🚀 Préparation du serveur Web Freelance..."
echo "📍 Adresse locale : http://$IP:$PORT"
echo "🔗 Backend utilisé : http://$BACKEND_HOST"
echo "------------------------------------------------"

# Arrêt d'une instance précédente si elle existe
echo "🛑 Arrêt du serveur précédent..."
pkill -f "python3 -m http.server $PORT" || true
pkill -f "cors_proxy.py" || true

# Reconstruction de l'application
echo "📦 Compilation de Flutter Web..."
flutter build web --dart-define=BACKEND_HOST_WEB=$BACKEND_HOST

# Lancement du serveur proxy
echo "🌐 Lancement du serveur proxy sur http://0.0.0.0:$PORT"
cd build/web
nohup python3 ../../scripts/cors_proxy.py --host 0.0.0.0 --port "$PORT" --directory . --backend-url "http://$BACKEND_HOST" > ../../server.log 2>&1 &

if [ "$OPEN_BROWSER" = "true" ]; then
  if [ -n "$CHROME_BIN" ]; then
    echo "🧪 Ouverture de Chrome avec le proxy CORS..."
    "$CHROME_BIN" "http://$IP:$PORT" >/dev/null 2>&1 &
  else
    echo "⚠️ Aucun navigateur Chrome/Chromium détecté. Ouvre manuellement : http://$IP:$PORT"
  fi
fi

echo "✅ Serveur lancé avec succès !"
echo "📱 Ouvre : http://$IP:$PORT"
echo "🧩 Le frontend sera dirigé vers le backend sur http://$BACKEND_HOST"
echo "🛡️ Le proxy local ajoute les en-têtes CORS pour les appels API depuis Chrome"
echo "------------------------------------------------"
