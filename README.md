# JSAIAgent - KI-gestützter Telefonagent für Investment-Lead-Generierung

Ein vollautomatischer, KI-gestützter Telefonagent für professionelle Outbound-Kundengespräche zu Arbitrage- und Festgeld-Investments.

## 🚀 Features

- **Python-basiert** für schnellere Antworten und bessere Performance
- **OpenAI GPT-4o-mini** für natürliche, intelligente Gesprächsführung
- **Whisper** für hochpräzise deutsche Spracherkennung
- **Coqui-TTS** mit Thorsten-Stimme für realistische deutsche Sprachausgabe
- **Asterisk-Integration** über Python AGI
- **Optimierte Outbound-Szenarien** mit Investment-Expertise
- **Vollautomatische Anrufbearbeitung** ohne menschliche Intervention

## 📋 Systemanforderungen

- Python 3.8+ oder höher
- Asterisk 18+ oder höher (mit Ihren existierenden Konfigurationen)
- Coqui TTS Server (lokal oder remote)
- OpenAI API Key

## 🔧 Installation

### 1. Repository klonen

```bash
git clone https://github.com/berndmarcel860-byte/Jsaiagent.git
cd Jsaiagent
```

### 2. Python-Abhängigkeiten installieren

```bash
pip install -r requirements.txt
```

### 3. Umgebungsvariablen konfigurieren

Kopieren Sie `.env.example` nach `.env` und tragen Sie Ihre Konfiguration ein:

```bash
cp .env.example .env
```

Bearbeiten Sie `.env`:

```env
# OpenAI Configuration
OPENAI_API_KEY=sk-your-api-key-here

# Asterisk Configuration
ASTERISK_HOST=localhost
ASTERISK_PORT=5038
ASTERISK_USERNAME=admin
ASTERISK_PASSWORD=your_asterisk_password

# AGI Configuration
AGI_PORT=4573

# Coqui TTS Configuration
COQUI_TTS_URL=http://localhost:5002

# Agent Configuration
AGENT_EXTENSION=5000
CALLER_EXTENSION=1000
```

### 4. Asterisk konfigurieren

**Hinweis**: Die Asterisk-Konfigurationsdateien im `asterisk/` Verzeichnis sind nur Beispiele. 
Wenn Sie bereits existierende Asterisk-Konfigurationen haben, können Sie diese verwenden.

Fügen Sie in Ihrer Asterisk-Dialplan eine Extension hinzu, die das Python-AGI-Script aufruft:

```ini
; In Ihrer extensions.conf
exten => 5000,1,NoOp(AI Agent Call)
 same => n,Answer()
 same => n,AGI(/pfad/zu/Jsaiagent/python/agi_handler.py)
 same => n,Hangup()
```

**Optional**: Verwenden Sie die Beispiel-Konfigurationen aus dem `asterisk/` Verzeichnis als Referenz.

### 5. Coqui TTS Server installieren (optional)

Falls noch nicht vorhanden, installieren Sie Coqui TTS:

```bash
pip install TTS
```

Starten Sie den TTS Server mit dem Thorsten-Modell:

```bash
tts-server --model_name tts_models/de/thorsten/tacotron2-DDC --port 5002
```

## 🎯 Verwendung

### Agent testen

Das Python AGI-Script wird direkt von Asterisk aufgerufen, wenn ein Anruf eingeht.
Kein separater Server-Start erforderlich!

Testen Sie mit einem Anruf auf die konfigurierte Extension (z.B. 5000):

```bash
# Test via Asterisk CLI
sudo asterisk -rvvv
> originate SIP/1000 extension 5000@internal
```

### Test-Anruf durchführen

Für interne Tests: **Extension 1000 ruft Extension 5000 an**

1. Registrieren Sie einen SIP-Client (z.B. Zoiper, Linphone) mit Extension 1000
2. Wählen Sie Extension 5000
3. Der KI-Agent beantwortet den Anruf automatisch

```bash
# Alternative: CLI-Test mit Asterisk
sudo asterisk -rvvv
> originate SIP/1000 extension 5000@internal
```

## 📁 Projektstruktur

```
Jsaiagent/
├── src/
│   ├── config/
│   │   ├── config.js          # Zentrale Konfiguration
│   │   └── logger.js           # Logging Setup
│   ├── services/
│   │   ├── openai-service.js   # OpenAI GPT & Whisper Integration
│   │   └── tts-service.js      # Coqui TTS Integration
│   ├── agi/
│   │   ├── agi-handler.js      # AGI Call Handler
│   │   └── agi-server.js       # AGI Server
│   └── index.js                # Haupteinstiegspunkt
├── asterisk/
│   ├── extensions.conf         # Asterisk Dialplan
│   ├── sip.conf                # SIP Konfiguration
│   └── manager.conf            # AMI Konfiguration
├── logs/                       # Log-Dateien
├── audio/                      # Temporäre Audio-Dateien
├── .env                        # Umgebungsvariablen
└── package.json
```

## 🤖 Funktionsweise

### Anrufablauf (Outbound)

1. **Anruf eingehend**: Extension 1000 ruft 5000 an
2. **Asterisk** ruft Python AGI-Script auf
3. **AGI Handler** beantwortet mit Begrüßung
4. **Gesprächsschleife**:
   - Kundeneingabe aufnehmen (Audio)
   - Transkription mit Whisper
   - Antwort generieren mit GPT-4o-mini (optimiert für schnelle Antworten)
   - Sprachsynthese mit Coqui TTS (Thorsten)
   - Antwort abspielen
5. **Gesprächsende**: Bei Verabschiedung oder Timeout

### Optimierte Outbound-Gesprächsszenarien

Der Agent ist für ausgehende Anrufe optimiert und führt professionelle Beratungsgespräche:

#### Szenario 1: Festgeld-Interesse
- Agent erklärt Festgeld-Anlagen (3-4% p.a., sehr sicher)
- Laufzeiten: 1-5 Jahre (z.B. 3 Jahre: 3,5%)
- Einlagensicherung bis 100.000 EUR
- Mindestanlage: 5.000 EUR
- Ziel: Terminvereinbarung für detaillierte Beratung

#### Szenario 2: Arbitrage-Investment
- Agent erklärt Arbitrage-Strategie (8-15% p.a.)
- Risikoprofil: Mittelhoch, aber kontrolliert
- Kündigungsfrist: 3 Monate
- Mindestanlage: 25.000 EUR
- Qualifizierende Fragen zur Liquidität

#### Szenario 3: Kombinierte Strategie
- Agent empfiehlt ausgewogenes Portfolio
- Beispiel: 30.000 EUR Festgeld + 20.000 EUR Arbitrage
- Durchschnittsrendite: ~6% p.a.
- Balance zwischen Sicherheit und Rendite

### Gesprächsführung

Der Agent wurde optimiert für:
- **Kurze Antworten** (max. 2-3 Sätze) für natürlichen Gesprächsfluss
- **Qualifizierende Fragen** zur Lead-Bewertung
- **Terminvereinbarung** als primäres Gesprächsziel
- **Professionelle Kommunikation** durchgehend

## 🔍 Troubleshooting

### AGI-Verbindung schlägt fehl

```bash
# Prüfen Sie, ob der AGI-Server läuft
netstat -tulpn | grep 4573

# Asterisk CLI Logs prüfen
sudo asterisk -rvvv
```

### Coqui TTS Fehler

```bash
# TTS Server Status prüfen
curl http://localhost:5002/api/voices

# TTS Server neu starten
pkill -f tts-server
tts-server --model_name tts_models/de/thorsten/tacotron2-DDC --port 5002
```

### OpenAI API Fehler

- Überprüfen Sie Ihren API Key in `.env`
- Prüfen Sie Ihr OpenAI Kontingent
- Logs prüfen: `tail -f logs/error.log`

### Audio-Probleme

```bash
# Asterisk Codec-Support prüfen
sudo asterisk -rx "core show codecs"

# Audio-Format konvertieren (falls nötig)
sox input.wav -r 8000 -c 1 output.wav
```

## 📊 Logging

Logs werden in `logs/` gespeichert:
- `combined.log` - Alle Logs
- `error.log` - Nur Fehler

Log-Level in `.env` anpassen:
```env
LOG_LEVEL=debug  # debug, info, warn, error
```

## 🔐 Sicherheit

- **API Keys**: Niemals in Git committen! Nutzen Sie `.env`
- **Asterisk Manager**: Beschränken Sie den Zugriff auf localhost
- **Firewall**: Öffnen Sie nur notwendige Ports
- **SIP-Passwörter**: Verwenden Sie starke Passwörter

## 🛠️ Entwicklung

### Tests ausführen

```bash
npm test
```

### Code-Style

Das Projekt verwendet ESM (ES Modules) - alle Imports mit `.js` Extension.

## 📝 Lizenz

MIT License

## 🤝 Beitragen

Pull Requests sind willkommen! Für größere Änderungen öffnen Sie bitte zuerst ein Issue.

## 📧 Support

Bei Fragen oder Problemen öffnen Sie ein Issue im GitHub Repository.

---

**Entwickelt mit ❤️ für professionelle Investment-Beratung**