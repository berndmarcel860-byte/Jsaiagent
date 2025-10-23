# Python AGI Implementation

Schnelle Python-basierte Implementierung des JSAIAgent für bessere Performance.

## Vorteile der Python-Version

- **Schnellere Antwortzeiten** - Direkter Aufruf durch Asterisk ohne Server-Overhead
- **Geringerer Ressourcenverbrauch** - Kein permanenter Server-Prozess
- **Einfachere Integration** - Direkte AGI-Script-Ausführung
- **Bessere Performance** - Optimiert für Asterisk AGI

## Installation

```bash
# Python-Dependencies installieren
pip install -r ../requirements.txt

# Script ausführbar machen
chmod +x agi_handler.py
```

## Konfiguration in Asterisk

Fügen Sie in Ihrer Asterisk Dialplan hinzu:

```ini
[internal]
exten => 5000,1,NoOp(AI Agent)
 same => n,Answer()
 same => n,AGI(/vollständiger/pfad/zu/python/agi_handler.py)
 same => n,Hangup()
```

**Wichtig**: Verwenden Sie den vollständigen absoluten Pfad zum Script!

## Outbound-Gesprächsszenarien

Der Agent ist optimiert für ausgehende Anrufe mit folgenden Szenarien:

### Szenario 1: Festgeld-Interesse
Der Agent berät zu sicheren Festgeld-Anlagen mit 3-4% Rendite, Laufzeiten von 1-5 Jahren und erklärt die Einlagensicherung.

### Szenario 2: Arbitrage-Investment
Der Agent erklärt Arbitrage-Investments (8-15% Rendite), Risikoprofil und Liquiditätsbedingungen.

### Szenario 3: Kombinierte Strategie
Der Agent empfiehlt ausgewogene Portfolios mit Festgeld + Arbitrage basierend auf Kundensituation.

## Gesprächsführung

Der Agent wurde trainiert für:
- Kurze, prägnante Antworten (max. 2-3 Sätze)
- Qualifizierende Fragen zur Lead-Bewertung
- Terminvereinbarungen als Gesprächsziel
- Professionelle, vertrauenswürdige Kommunikation

## Logging

Logs werden geschrieben nach: `logs/jsaiagent.log`

```bash
# Logs in Echtzeit verfolgen
tail -f ../logs/jsaiagent.log
```

## Testing

```bash
# Test via Asterisk CLI
sudo asterisk -rvvv
> originate SIP/1000 extension 5000@internal

# AGI Debug einschalten
> agi set debug on
```

## Troubleshooting

### AGI Script wird nicht ausgeführt

1. Prüfen Sie Berechtigungen: `chmod +x agi_handler.py`
2. Prüfen Sie den Pfad in extensions.conf (muss absolut sein)
3. Prüfen Sie Python-Shebang: `#!/usr/bin/env python3`

### Audio-Probleme

1. Prüfen Sie AUDIO_DIR in .env (muss schreibbar sein)
2. Prüfen Sie Coqui TTS: `curl http://localhost:5002/api/voices`

### OpenAI-Fehler

1. Prüfen Sie API Key in .env
2. Prüfen Sie Logs: `tail -f ../logs/jsaiagent.log`

## Performance-Optimierung

Die Python-Implementierung ist bereits optimiert:
- Asynchrone I/O für OpenAI und TTS
- Minimale Latenz durch direkten AGI-Aufruf
- Effizientes Audio-Handling
- Schnelle Konversations-Verarbeitung

Für zusätzliche Performance:
- Verwenden Sie lokalen Coqui TTS Server
- Optimieren Sie OPENAI_MAX_TOKENS (Standard: 300)
- Nutzen Sie SSD für AUDIO_DIR
