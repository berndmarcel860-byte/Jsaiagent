# System-Architektur

## Übersicht

JSAIAgent ist ein modularer, KI-gestützter Telefonagent mit folgenden Hauptkomponenten:

```
┌─────────────────────────────────────────────────────────────┐
│                      SIP Client (Ext 1000)                  │
└───────────────────────┬─────────────────────────────────────┘
                        │ SIP Protocol
                        ▼
┌─────────────────────────────────────────────────────────────┐
│                    Asterisk PBX                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Dialplan (extensions.conf)                          │  │
│  │  - Extension 1000: Caller                            │  │
│  │  - Extension 5000: AI Agent (AGI Call)               │  │
│  └──────────────────┬───────────────────────────────────┘  │
└─────────────────────┼───────────────────────────────────────┘
                      │ AGI Protocol
                      ▼
┌─────────────────────────────────────────────────────────────┐
│               JSAIAgent Node.js Application                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  AGI Server (Port 4573)                             │   │
│  │  - Empfängt Anrufe von Asterisk                     │   │
│  │  - Verwaltet Call Context                           │   │
│  └──────────────────┬──────────────────────────────────┘   │
│                     │                                        │
│  ┌──────────────────▼──────────────────────────────────┐   │
│  │  AGI Handler                                        │   │
│  │  - Anruf-Logik                                      │   │
│  │  - Gesprächsschleife                                │   │
│  │  - Audio Recording/Playback                         │   │
│  └─┬─────────────┬─────────────┬─────────────────────┘   │
│    │             │             │                           │
│    ▼             ▼             ▼                           │
│  ┌────────┐  ┌─────────┐  ┌──────────┐                   │
│  │ OpenAI │  │ Whisper │  │ Coqui    │                   │
│  │Service │  │ Service │  │TTS       │                   │
│  │        │  │         │  │Service   │                   │
│  └────┬───┘  └────┬────┘  └────┬─────┘                   │
└───────┼──────────┼──────────────┼─────────────────────────┘
        │          │              │
        ▼          ▼              ▼
┌──────────┐  ┌────────┐  ┌──────────────┐
│ OpenAI   │  │ OpenAI │  │ Coqui TTS    │
│ GPT-4o   │  │Whisper │  │ Server       │
│ API      │  │ API    │  │ (Thorsten)   │
└──────────┘  └────────┘  └──────────────┘
```

## Komponenten-Details

### 1. Asterisk PBX

**Zweck**: Telefonie-Server, verwaltet SIP-Verbindungen und Anruf-Routing

**Konfigurationsdateien**:
- `extensions.conf`: Dialplan - definiert Anrufrouting
- `sip.conf`: SIP-Endpunkte (Extensions 1000, 5000)
- `manager.conf`: AMI-Interface für Management

**Wichtige Funktionen**:
- SIP-Registrierung für Extensions
- Anruf-Routing basierend auf Extension
- AGI-Integration für externe Anrufsteuerung
- Audio-Codec-Verwaltung (ulaw, alaw)

### 2. AGI Server

**Technologie**: Node.js mit `agi` npm package

**Datei**: `src/agi/agi-server.js`

**Funktionen**:
- Lauscht auf Port 4573 (konfigurierbar)
- Akzeptiert AGI-Verbindungen von Asterisk
- Erstellt Context für jeden Anruf
- Delegiert an AGI Handler

**AGI Protocol**:
- Text-basiertes Protokoll über STDIN/STDOUT
- Befehle: ANSWER, STREAM FILE, RECORD FILE, HANGUP, etc.
- Synchrone Request-Response-Kommunikation

### 3. AGI Handler

**Datei**: `src/agi/agi-handler.js`

**Hauptfunktionen**:

#### 3.1 Call Handling
```javascript
handleCall(context)
  ├─ Answer call
  ├─ Welcome message
  └─ Conversation loop
      ├─ Record user input
      ├─ Transcribe (Whisper)
      ├─ Generate response (GPT)
      ├─ Synthesize speech (TTS)
      └─ Play response
```

#### 3.2 Audio Management
- Aufnahme mit Silence Detection (2 Sek. Stille)
- Max. Aufnahmedauer: 10 Sekunden
- Format: WAV, 8kHz, mono
- Temporäre Speicherung in `audio/` Verzeichnis
- Automatisches Cleanup nach Verarbeitung

#### 3.3 Conversation Flow
1. Begrüßung
2. Aufnahme der Benutzereingabe
3. Transkription → GPT → TTS → Wiedergabe
4. Wiederholung bis Gesprächsende oder Timeout
5. Verabschiedung

### 4. OpenAI Service

**Datei**: `src/services/openai-service.js`

**Komponenten**:

#### 4.1 GPT-4o-mini Chat
- **Model**: gpt-4o-mini (optimiert für Geschwindigkeit)
- **Temperature**: 0.7 (Balance zwischen Kreativität und Konsistenz)
- **Max Tokens**: 500 (kurze, prägnante Antworten)
- **System Prompt**: Investment-Berater-Rolle mit Produktwissen

#### 4.2 Whisper Transcription
- **Model**: whisper-1
- **Language**: Deutsch (de)
- **Input**: Audio Buffer (WAV)
- **Output**: Transkribierter Text

**Conversation History**:
- Speichert komplette Gesprächshistorie
- Context für GPT-Modell
- Reset bei neuem Anruf

### 5. TTS Service

**Datei**: `src/services/tts-service.js`

**Integration mit Coqui TTS**:
- **Model**: Thorsten (deutscher Sprecher)
- **Endpoint**: POST `/api/tts`
- **Input**: Text, Speaker ID, Language
- **Output**: Audio Buffer (WAV)

**Features**:
- Hochwertige deutsche Sprachausgabe
- Natürliche Intonation
- Fallback bei Fehler (Festival TTS)

### 6. Configuration & Logging

#### 6.1 Configuration (`src/config/config.js`)
- Zentrale Konfigurationsverwaltung
- Environment Variables via dotenv
- Type-safe Exports

#### 6.2 Logging (`src/config/logger.js`)
- Winston Logger
- Multiple Transports (File, Console)
- Strukturierte Logs (JSON)
- Separate Error Logs
- Timestamp und Service-Tagging

## Datenfluss

### Typischer Anruf-Ablauf

```
1. User wählt 5000 von Extension 1000
   └─> Asterisk empfängt Anruf

2. Asterisk Dialplan matched Extension 5000
   └─> AGI(agi://localhost:4573)

3. AGI Server akzeptiert Verbindung
   └─> Erstellt Call Context

4. AGI Handler übernimmt
   ├─> ANSWER
   └─> Begrüßung mit TTS

5. Gesprächsschleife startet
   ├─> RECORD (User spricht)
   ├─> Audio → Whisper → Text
   ├─> Text → GPT → Antwort
   ├─> Antwort → TTS → Audio
   └─> STREAM FILE (Wiedergabe)

6. Bei Verabschiedung oder Timeout
   └─> HANGUP
```

### Audio-Datenfluss

```
User → Mikrofon
  → SIP (Codec: ulaw/alaw)
    → Asterisk
      → AGI RECORD → WAV File
        → Node.js Buffer
          → OpenAI Whisper API
            → Text

Text → GPT-4o-mini
  → Antwort-Text
    → Coqui TTS Server
      → Audio Buffer
        → WAV File
          → AGI STREAM FILE
            → Asterisk
              → SIP
                → Lautsprecher
```

## Skalierbarkeit

### Horizontale Skalierung

**Aktuelle Architektur**:
- Single-Instance: 1 AGI Server
- 1 Anruf = 1 AGI Connection

**Skalierungs-Optionen**:
1. **Multiple AGI Servers**: Load Balancing über Asterisk
2. **Worker Pool**: Parallel Processing für Audio
3. **Redis Queue**: Asynchrone Verarbeitung
4. **Clustering**: Node.js Cluster Module

### Vertikal Skalierung

**Ressourcen-Anforderungen pro Anruf**:
- CPU: Audio-Verarbeitung (gering)
- Memory: ~50MB pro aktivem Anruf
- Network: API-Calls zu OpenAI/TTS
- Disk: Temporäre Audio-Dateien

**Optimierungen**:
- Audio Caching für häufige Phrasen
- Connection Pooling
- Stream Processing statt Buffer

## Sicherheit

### Netzwerk-Ebene
- AGI Server: Nur localhost binding empfohlen
- Asterisk AMI: IP-basierte ACLs
- Firewall: Restriktive Rules

### Daten-Ebene
- Environment Variables für Secrets
- Keine Credentials im Code
- Logs: Keine sensiblen Daten

### API-Ebene
- OpenAI API Key Rotation
- Rate Limiting
- Error Handling ohne Information Leakage

## Monitoring & Debugging

### Logs
```bash
# Application Logs
tail -f logs/combined.log
tail -f logs/error.log

# Asterisk Logs
sudo tail -f /var/log/asterisk/messages
sudo asterisk -rvvv  # CLI mit verbose output

# System Logs
sudo journalctl -u jsaiagent -f
```

### Metriken
- Anruf-Dauer
- Transcription-Latenz
- GPT Response-Time
- TTS Generation-Time
- Error Rates

### Health Checks
```bash
# AGI Server
netstat -tulpn | grep 4573

# Asterisk
sudo asterisk -rx "core show channels"

# TTS Server
curl http://localhost:5002/api/voices
```

## Erweiterungen

### Mögliche Features

1. **Call Recording**: Vollständige Anrufaufzeichnung
2. **Analytics**: Conversation Analytics & Sentiment
3. **CRM Integration**: Lead-Export zu Salesforce/HubSpot
4. **Multi-Language**: Unterstützung weiterer Sprachen
5. **Voice Selection**: Verschiedene TTS-Stimmen
6. **Callback Scheduling**: Automatische Rückruf-Terminierung
7. **Knowledge Base**: RAG für erweiterte Produktinfos
8. **Real-time Dashboard**: Web-UI für Live-Monitoring

### API Extensions

Potenzielle REST API für:
- Call History
- Statistics
- Configuration Updates
- Manual Call Triggering
