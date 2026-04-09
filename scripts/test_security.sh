#!/bin/bash
# Script de test de sécurité - SENTINEL-GATE
# Usage : ./test_security.sh <IP_CIBLE>

TARGET=$1

echo "--- Début des tests de sécurité vers $TARGET ---"

# 1. Test de scan de ports (Simule Nmap)
echo "[*] Test de scan de ports rapide..."
for port in {21,22,80,443,1883}; do
    (echo >/dev/tcp/$TARGET/$port) &>/dev/null && echo "Port $port ouvert" || echo "Port $port fermé"
done

# 2. Test de Brute-Force SSH (Déclenche la règle Suricata)
echo "[*] Simulation de Brute-Force SSH (5 tentatives)..."
for i in {1..6}; do
    ssh -o ConnectTimeout=2 -o BatchMode=yes -o StrictHostKeyChecking=no admin@$TARGET "exit" 2>/dev/null
    echo "Tentative $i envoyée..."
done

echo "--- Tests terminés. Vérifiez les logs sur la Gateway (/var/log/suricata/eve.json) ---"

sleep 2