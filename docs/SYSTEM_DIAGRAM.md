# JSAIAgent System Diagram

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         External Systems                         │
├──────────────────┬──────────────────┬──────────────────────────┤
│  OpenAI API      │  Coqui TTS       │  SIP Clients             │
│  - GPT-4o-mini   │  - Thorsten      │  - Extension 1000        │
│  - Whisper       │    Voice Model   │  - Softphones            │
└────────┬─────────┴────────┬─────────┴──────────┬───────────────┘
         │                  │                    │
         │ HTTPS            │ HTTP               │ SIP/RTP
         │                  │                    │
┌────────▼──────────────────▼────────────────────▼───────────────┐
│                      Local Server                               │
│                                                                  │
│  ┌────────────────────────────────────────────────────────┐   │
│  │                    Asterisk PBX                         │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │   │
│  │  │ Dialplan     │  │ SIP          │  │ AMI          │ │   │
│  │  │ extensions   │  │ Extensions   │  │ Manager      │ │   │
│  │  └──────┬───────┘  └──────────────┘  └──────────────┘ │   │
│  └─────────┼────────────────────────────────────────────┘   │
│            │ AGI Protocol (Port 4573)                          │
│            │                                                    │
│  ┌─────────▼────────────────────────────────────────────────┐ │
│  │              JSAIAgent Node.js Application               │ │
│  │                                                           │ │
│  │  ┌─────────────────────────────────────────────────┐   │ │
│  │  │  AGI Server (agi-server.js)                     │   │ │
│  │  │  - Listens on port 4573                         │   │ │
│  │  │  - Accepts connections from Asterisk            │   │ │
│  │  └──────────────────┬──────────────────────────────┘   │ │
│  │                     │                                    │ │
│  │  ┌──────────────────▼──────────────────────────────┐   │ │
│  │  │  AGI Handler (agi-handler.js)                   │   │ │
│  │  │  - Manages call lifecycle                       │   │ │
│  │  │  - Conversation loop                            │   │ │
│  │  │  - Audio recording/playback                     │   │ │
│  │  └─┬────────────┬────────────┬────────────────────┘   │ │
│  │    │            │            │                          │ │
│  │  ┌─▼──────┐  ┌─▼──────┐  ┌─▼──────┐                  │ │
│  │  │ OpenAI │  │ OpenAI │  │ Coqui  │                  │ │
│  │  │ GPT    │  │Whisper │  │ TTS    │                  │ │
│  │  │Service │  │Service │  │Service │                  │ │
│  │  └────────┘  └────────┘  └────────┘                  │ │
│  │                                                           │ │
│  │  ┌─────────────────────────────────────────────────┐   │ │
│  │  │  Configuration & Logging                        │   │ │
│  │  │  - config.js, logger.js                         │   │ │
│  │  │  - .env variables                               │   │ │
│  │  └─────────────────────────────────────────────────┘   │ │
│  └───────────────────────────────────────────────────────┘ │
│                                                              │
│  ┌─────────────────┐  ┌─────────────────┐                 │
│  │  Logs           │  │  Audio Files    │                 │
│  │  - combined.log │  │  - recordings   │                 │
│  │  - error.log    │  │  - tts output   │                 │
│  └─────────────────┘  └─────────────────┘                 │
└──────────────────────────────────────────────────────────────┘
```

## Call Flow - Internal Test (Extension 1000 → 5000)

```
Extension 1000 (Test Caller)
    │
    │ Dials 5000
    ▼
Asterisk Dialplan
    │
    │ Matches: exten => 5000
    ▼
AGI Call: agi://localhost:4573
    │
    ▼
JSAIAgent AGI Server
    │
    ▼
AGI Handler starts
    │
    ├─ Answer Call
    ├─ Play Welcome Message
    │
    └─ Conversation Loop:
        │
        ├─ Record User Audio (2s silence detection)
        ├─ Transcribe with Whisper
        ├─ Generate Response with GPT-4o-mini
        ├─ Synthesize Speech with Coqui TTS
        ├─ Play Response
        │
        └─ Repeat until goodbye phrase detected
    │
    └─ Hangup
```

## Technology Stack

- **Node.js 18+**: Runtime environment
- **Asterisk 18+**: PBX system
- **OpenAI GPT-4o-mini**: Conversation AI
- **OpenAI Whisper**: Speech recognition
- **Coqui TTS**: Speech synthesis (Thorsten voice)
- **Winston**: Logging framework

## Network Ports

| Port | Service | Protocol | Access |
|------|---------|----------|--------|
| 4573 | AGI Server | TCP | Localhost |
| 5002 | Coqui TTS | HTTP | Localhost |
| 5038 | Asterisk AMI | TCP | Localhost |
| 5060 | Asterisk SIP | UDP | Network |
| 10000-20000 | RTP Media | UDP | Network |
