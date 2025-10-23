import OpenAI from 'openai';
import { config } from '../config/config.js';
import logger from '../config/logger.js';

class OpenAIService {
  constructor() {
    this.client = new OpenAI({
      apiKey: config.openai.apiKey
    });
    
    this.systemPrompt = `Du bist ein professioneller Investment-Berater der telefonisch Kunden zu Arbitrage- und Festgeld-Investments berät.

Deine Aufgaben:
- Führe ein natürliches, freundliches Gespräch
- Erkläre die Vorteile von Arbitrage-Investments und Festgeld-Anlagen
- Beantworte Fragen zu Renditen, Risiken und Laufzeiten
- Qualifiziere Interessenten und vereinbare Follow-up Termine
- Bleibe professionell und vertrauenswürdig

Arbitrage-Investments:
- Nutzen Preisunterschiede zwischen Märkten
- Typische Rendite: 8-15% p.a.
- Mittleres Risiko, aktives Management erforderlich
- Mindestanlage: 25.000 EUR

Festgeld-Anlagen:
- Sichere, planbare Rendite
- Typische Rendite: 3-4% p.a.
- Sehr niedriges Risiko, staatlich abgesichert
- Laufzeiten: 1-5 Jahre
- Mindestanlage: 5.000 EUR

Antworte kurz und prägnant (max. 2-3 Sätze pro Antwort).`;
    
    this.conversationHistory = [];
  }

  reset() {
    this.conversationHistory = [];
    logger.info('Conversation history reset');
  }

  async chat(userMessage) {
    try {
      // Add user message to history
      this.conversationHistory.push({
        role: 'user',
        content: userMessage
      });

      // Get response from GPT
      const response = await this.client.chat.completions.create({
        model: config.openai.model,
        messages: [
          { role: 'system', content: this.systemPrompt },
          ...this.conversationHistory
        ],
        temperature: config.openai.temperature,
        max_tokens: config.openai.maxTokens
      });

      const assistantMessage = response.choices[0].message.content;
      
      // Add assistant response to history
      this.conversationHistory.push({
        role: 'assistant',
        content: assistantMessage
      });

      logger.info('OpenAI response generated', { 
        userMessage: userMessage.substring(0, 50),
        response: assistantMessage.substring(0, 50)
      });

      return assistantMessage;
    } catch (error) {
      logger.error('Error in OpenAI chat', { error: error.message });
      throw error;
    }
  }

  async transcribeAudio(audioBuffer) {
    try {
      const file = new File([audioBuffer], 'audio.wav', { type: 'audio/wav' });
      
      const transcription = await this.client.audio.transcriptions.create({
        file: file,
        model: 'whisper-1',
        language: 'de'
      });

      logger.info('Audio transcribed', { text: transcription.text });
      return transcription.text;
    } catch (error) {
      logger.error('Error transcribing audio', { error: error.message });
      throw error;
    }
  }
}

export default OpenAIService;
