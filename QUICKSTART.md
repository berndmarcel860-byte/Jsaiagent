# Quick Start Guide

Schnellstart-Anleitung für JSAIAgent

## ⚡ 5-Minuten Setup (für erfahrene Benutzer)

### 1. Voraussetzungen installieren

```bash
# Node.js 18+
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Asterisk
sudo apt-get install -y asterisk

# Coqui TTS
pip3 install TTS
```

### 2. Projekt einrichten

```bash
git clone https://github.com/berndmarcel860-byte/Jsaiagent.git
cd Jsaiagent
npm install
cp .env.example .env
```

### 3. Konfiguration

Editiere `.env`:
```env
OPENAI_API_KEY=sk-your-api-key-here
ASTERISK_PASSWORD=your_password
```

### 4. Asterisk konfigurieren

```bash
sudo cp asterisk/*.conf /etc/asterisk/
sudo asterisk -rx "reload"
```

### 5. Services starten

```bash
# Terminal 1: TTS Server
tts-server --model_name tts_models/de/thorsten/tacotron2-DDC --port 5002

# Terminal 2: JSAIAgent
npm start
```

### 6. Testen

- Registriere SIP-Client mit Extension 1000
- Rufe Extension 5000 an
- Der AI-Agent antwortet automatisch

## 📋 Automatische Installation

Für eine vollständige automatische Installation:

```bash
sudo ./setup.sh
```

Das Script installiert:
- Node.js Dependencies
- Asterisk (optional)
- Coqui TTS (optional)
- Systemd Services
- Konfigurationsdateien

## 🔧 Minimale Test-Umgebung

Wenn Sie nur testen möchten ohne vollständige Asterisk-Installation:

### Entwicklungs-Setup

```bash
# 1. Dependencies installieren
npm install

# 2. .env konfigurieren
cp .env.example .env
# Trage nur OPENAI_API_KEY ein

# 3. Agent starten
npm run dev
```

Der AGI-Server läuft dann auf Port 4573 und wartet auf Verbindungen.

### Mit Docker (kommende Version)

```bash
docker-compose up
```

Wird in einer zukünftigen Version verfügbar sein.

## 🎯 Typische Anwendungsfälle

### Use Case 1: Lokale Entwicklung

```bash
# Terminal 1: Mock TTS (ohne echten TTS Server)
# Agent verwendet Fallback (Festival/Playback)

# Terminal 2: Agent im Dev-Mode
npm run dev

# Terminal 3: Asterisk CLI zum Testen
sudo asterisk -rvvv
> originate SIP/1000 extension 5000@internal
```

### Use Case 2: Produktiv-Betrieb

```bash
# Services als Systemd Daemons
sudo systemctl start coqui-tts
sudo systemctl start jsaiagent

# Monitoring
sudo journalctl -u jsaiagent -f
tail -f logs/combined.log
```

### Use Case 3: Multiple Agents

Für mehrere parallele Agenten:

```bash
# Agent 1 auf Port 4573
AGI_PORT=4573 npm start &

# Agent 2 auf Port 4574
AGI_PORT=4574 npm start &

# In Asterisk extensions.conf verschiedene Extensions zuweisen
```

## 🐛 Troubleshooting Quick Fixes

### Problem: "Cannot connect to Asterisk"

```bash
# Prüfe Asterisk Status
sudo systemctl status asterisk
sudo asterisk -rx "core show version"

# Neu starten
sudo systemctl restart asterisk
```

### Problem: "OpenAI API Error"

```bash
# API Key prüfen
echo $OPENAI_API_KEY

# In .env setzen
nano .env
# OPENAI_API_KEY=sk-...
```

### Problem: "TTS Server not responding"

```bash
# TTS Server Status
curl http://localhost:5002/api/voices

# Neu starten
pkill -f tts-server
tts-server --model_name tts_models/de/thorsten/tacotron2-DDC --port 5002
```

### Problem: "AGI Port already in use"

```bash
# Port 4573 prüfen
sudo netstat -tulpn | grep 4573

# Prozess beenden
sudo kill $(sudo lsof -t -i:4573)

# Anderen Port verwenden
AGI_PORT=4574 npm start
```

## 📊 System-Anforderungen

### Minimal
- 2 CPU Cores
- 2 GB RAM
- 5 GB Disk Space
- Ubuntu 20.04+ / Debian 11+

### Empfohlen
- 4 CPU Cores
- 4 GB RAM
- 20 GB Disk Space (für Logs und Audio-Cache)
- Ubuntu 22.04 LTS

### Für Produktiv-Betrieb
- 8+ CPU Cores
- 8+ GB RAM
- SSD Storage
- Load Balancer für Multi-Instance
- Monitoring & Alerting

## 🚀 Performance-Tipps

### Latenz reduzieren

1. **Lokaler TTS Server** statt Remote
2. **Audio Caching** für häufige Phrasen
3. **GPT-4o-mini** verwenden (schneller als GPT-4)
4. **Kurze System Prompts** für schnellere Responses

### Skalierung

```bash
# Multiple Worker Processes
pm2 start src/index.js -i 4

# Oder mit Cluster Module in Node.js
# (Erfordert Code-Anpassung)
```

## 📚 Weitere Dokumentation

- **README.md**: Projekt-Übersicht
- **INSTALLATION.md**: Detaillierte Installation
- **ARCHITECTURE.md**: System-Architektur
- **examples/**: Beispiel-Gespräche und Test-Scripts

## 💬 Support

- GitHub Issues: https://github.com/berndmarcel860-byte/Jsaiagent/issues
- Dokumentation: Siehe README.md

## ✅ Checkliste für Go-Live

- [ ] Alle Dependencies installiert
- [ ] .env vollständig konfiguriert
- [ ] Asterisk läuft und ist konfiguriert
- [ ] TTS Server läuft
- [ ] JSAIAgent startet ohne Fehler
- [ ] Test-Anruf erfolgreich
- [ ] Logs werden geschrieben
- [ ] Systemd Services eingerichtet
- [ ] Monitoring aktiv
- [ ] Backups konfiguriert
- [ ] Firewall-Regeln gesetzt
- [ ] Dokumentation für Team vorhanden

**Viel Erfolg mit Ihrem AI Phone Agent!** 🎉
