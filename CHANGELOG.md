# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-10-23

### Added
- Initial release of JSAIAgent
- OpenAI GPT-4o-mini integration for conversational AI
- Whisper speech recognition for German language
- Coqui-TTS integration with Thorsten voice model
- Asterisk PBX integration via AGI protocol
- Node.js AGI server and handler
- Investment advisory system prompt (Arbitrage & Fixed Deposit)
- Role-based conversation management
- Comprehensive logging with Winston
- Configuration management with dotenv
- Asterisk configuration templates (extensions, SIP, AMI)
- Automated setup script
- Complete documentation:
  - README.md - Project overview
  - INSTALLATION.md - Detailed installation guide
  - ARCHITECTURE.md - System architecture documentation
  - QUICKSTART.md - Quick start guide
  - CONTRIBUTING.md - Contribution guidelines
- Example conversations in German
- Test scripts for development
- MIT License

### Features
- Fully automated call handling
- Natural language conversation in German
- Speech-to-text with OpenAI Whisper
- Text-to-speech with Coqui TTS (Thorsten)
- Goodbye phrase detection for natural call ending
- Silence detection (2-second timeout)
- Audio recording and playback
- Error handling and recovery
- Structured logging (JSON format)
- Environment-based configuration

### Configuration
- Extension 1000: Test caller
- Extension 5000: AI agent
- AGI server on port 4573
- Coqui TTS on port 5002
- Asterisk Manager Interface on port 5038

### System Requirements
- Node.js 18+
- Asterisk 18+
- Python 3.8+ (for Coqui TTS)
- OpenAI API key

## [Unreleased]

### Planned
- Unit and integration tests
- Docker and Docker Compose support
- CI/CD pipeline with GitHub Actions
- Web dashboard for monitoring
- REST API for management
- Call recording and playback features
- Analytics and reporting
- CRM integrations (Salesforce, HubSpot)
- Multi-language support
- Performance monitoring and metrics
- Load balancing support
- Audio caching for common phrases
- Advanced conversation analytics

---

For more details, see the [GitHub releases page](https://github.com/berndmarcel860-byte/Jsaiagent/releases).
