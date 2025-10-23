# Contributing to JSAIAgent

Vielen Dank für Ihr Interesse an JSAIAgent! 

## 🤝 Wie kann ich beitragen?

### Bug Reports

Wenn Sie einen Bug finden:

1. Prüfen Sie, ob der Bug bereits gemeldet wurde
2. Erstellen Sie ein neues Issue mit:
   - Klare Beschreibung des Problems
   - Schritte zur Reproduktion
   - Erwartetes vs. tatsächliches Verhalten
   - Log-Ausgaben (falls relevant)
   - System-Informationen (OS, Node.js Version, etc.)

### Feature Requests

Für neue Features:

1. Erstellen Sie ein Issue mit dem Label "enhancement"
2. Beschreiben Sie:
   - Das Problem, das gelöst werden soll
   - Ihre vorgeschlagene Lösung
   - Alternativen, die Sie in Betracht gezogen haben
   - Zusätzlicher Kontext

### Pull Requests

1. **Fork** das Repository
2. **Erstellen** Sie einen Feature-Branch (`git checkout -b feature/AmazingFeature`)
3. **Commiten** Sie Ihre Änderungen (`git commit -m 'Add some AmazingFeature'`)
4. **Pushen** Sie zum Branch (`git push origin feature/AmazingFeature`)
5. **Öffnen** Sie einen Pull Request

#### Pull Request Richtlinien

- Beschreiben Sie klar, was Ihr PR macht
- Referenzieren Sie relevante Issues
- Stellen Sie sicher, dass der Code funktioniert
- Fügen Sie Tests hinzu (falls zutreffend)
- Aktualisieren Sie die Dokumentation
- Folgen Sie dem Code-Style des Projekts

## 📝 Code-Style

### JavaScript

- ES6+ Module (import/export)
- 2 Leerzeichen für Einrückung
- Aussagekräftige Variablennamen
- Kommentare für komplexe Logik
- Error Handling mit try-catch

### Beispiel

```javascript
import logger from '../config/logger.js';

/**
 * Processes user input and generates response
 * @param {string} input - User's spoken input
 * @returns {Promise<string>} AI-generated response
 */
async function processInput(input) {
  try {
    logger.info('Processing input', { input });
    
    // Your code here
    const response = await generateResponse(input);
    
    return response;
  } catch (error) {
    logger.error('Error processing input', { error: error.message });
    throw error;
  }
}
```

## 🧪 Testing

Bevor Sie einen PR einreichen:

```bash
# Syntax prüfen
node --check src/**/*.js

# Manueller Test
npm start
# Führen Sie Test-Anrufe durch

# Logs prüfen
tail -f logs/combined.log
```

## 📚 Dokumentation

Wenn Sie Code hinzufügen:

- Aktualisieren Sie README.md
- Fügen Sie JSDoc-Kommentare hinzu
- Aktualisieren Sie ARCHITECTURE.md (bei größeren Änderungen)
- Fügen Sie Beispiele hinzu (bei neuen Features)

## 🎯 Entwicklungsbereiche

Hier sind einige Bereiche, in denen Beiträge besonders willkommen sind:

### High Priority

- [ ] Unit Tests & Integration Tests
- [ ] Docker/Docker-Compose Setup
- [ ] CI/CD Pipeline (GitHub Actions)
- [ ] Performance Monitoring
- [ ] Load Testing

### Medium Priority

- [ ] Web Dashboard für Monitoring
- [ ] REST API für Management
- [ ] Multiple TTS-Engine Support
- [ ] Voice Activity Detection (VAD)
- [ ] Call Recording & Playback
- [ ] Analytics & Reporting

### Nice to Have

- [ ] Multi-Language Support (English, etc.)
- [ ] CRM Integration (Salesforce, HubSpot)
- [ ] Webhook Support
- [ ] Custom Agent Personalities
- [ ] A/B Testing für Prompts
- [ ] Voice Biometrics

## 🏗️ Architektur-Entscheidungen

Wenn Sie größere Änderungen vornehmen:

1. Erstellen Sie ein Issue zur Diskussion
2. Beschreiben Sie die Architektur-Entscheidung
3. Diskutieren Sie Vor- und Nachteile
4. Warten Sie auf Feedback
5. Implementieren Sie nach Zustimmung

## 🔐 Sicherheit

Wenn Sie eine Sicherheitslücke finden:

**Melden Sie diese NICHT öffentlich!**

Kontaktieren Sie die Maintainer privat:
- Erstellen Sie ein privates Security Advisory auf GitHub
- Oder senden Sie eine E-Mail (falls verfügbar)

## 📄 Lizenz

Indem Sie zu diesem Projekt beitragen, stimmen Sie zu, dass Ihre Beiträge unter der MIT-Lizenz lizenziert werden.

## 🙏 Anerkennung

Alle Beiträge werden in der Release-Note erwähnt.

Vielen Dank für Ihre Unterstützung! 🎉
