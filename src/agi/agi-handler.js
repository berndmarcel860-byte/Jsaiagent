import AGI from 'agi';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import OpenAIService from '../services/openai-service.js';
import TTSService from '../services/tts-service.js';
import logger from '../config/logger.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

class AGIHandler {
  constructor() {
    this.openaiService = new OpenAIService();
    this.ttsService = new TTSService();
    this.audioDir = path.join(process.cwd(), 'audio');
    
    // Ensure audio directory exists
    if (!fs.existsSync(this.audioDir)) {
      fs.mkdirSync(this.audioDir, { recursive: true });
    }
  }

  async handleCall(context) {
    try {
      logger.info('AGI call started', {
        callerid: context.callerid,
        extension: context.extension,
        channel: context.channel
      });

      // Answer the call
      await context.answer();
      logger.info('Call answered');

      // Welcome message
      const welcomeMessage = 'Guten Tag! Willkommen bei unserem Investment Service. Ich bin Ihr KI-Assistent und berate Sie gerne zu Arbitrage- und Festgeld-Investments. Wie kann ich Ihnen heute helfen?';
      await this.speakAndWait(context, welcomeMessage);

      // Conversation loop
      let conversationActive = true;
      let silenceCount = 0;
      const maxSilenceCount = 2;

      while (conversationActive && silenceCount < maxSilenceCount) {
        // Record user input
        const audioFile = await this.recordUserInput(context);
        
        if (!audioFile) {
          silenceCount++;
          logger.info('No audio recorded', { silenceCount });
          
          if (silenceCount < maxSilenceCount) {
            await this.speakAndWait(context, 'Sind Sie noch da? Wie kann ich Ihnen weiterhelfen?');
          }
          continue;
        }

        // Reset silence counter on successful recording
        silenceCount = 0;

        // Transcribe audio
        const audioBuffer = fs.readFileSync(audioFile);
        const userText = await this.openaiService.transcribeAudio(audioBuffer);
        logger.info('User said', { text: userText });

        // Clean up audio file
        fs.unlinkSync(audioFile);

        // Check for goodbye phrases
        if (this.isGoodbye(userText)) {
          await this.speakAndWait(context, 'Vielen Dank für Ihr Interesse. Auf Wiederhören!');
          conversationActive = false;
          break;
        }

        // Get AI response
        const aiResponse = await this.openaiService.chat(userText);
        logger.info('AI response', { text: aiResponse });

        // Speak response
        await this.speakAndWait(context, aiResponse);
      }

      if (silenceCount >= maxSilenceCount) {
        await this.speakAndWait(context, 'Auf Wiederhören!');
      }

      // Hangup
      await context.hangup();
      logger.info('Call ended');

    } catch (error) {
      logger.error('Error handling AGI call', { error: error.message, stack: error.stack });
      
      try {
        await context.hangup();
      } catch (hangupError) {
        logger.error('Error hanging up', { error: hangupError.message });
      }
    } finally {
      // Reset conversation for next call
      this.openaiService.reset();
    }
  }

  async speakAndWait(context, text) {
    try {
      // Generate TTS audio
      const audioBuffer = await this.ttsService.synthesize(text);
      
      if (audioBuffer.length === 0) {
        logger.warn('Empty audio buffer, using festival as fallback');
        // Fallback to Asterisk's built-in TTS
        await context.exec('Festival', text);
        return;
      }

      // Save audio to file
      const audioFile = path.join(this.audioDir, `tts_${Date.now()}.wav`);
      fs.writeFileSync(audioFile, audioBuffer);

      // Play audio file
      const audioFileWithoutExt = audioFile.replace('.wav', '');
      await context.streamFile(audioFileWithoutExt);

      // Clean up
      fs.unlinkSync(audioFile);
      
    } catch (error) {
      logger.error('Error speaking', { error: error.message, text });
      // Fallback to simple playback
      await context.exec('Playback', 'beep');
    }
  }

  async recordUserInput(context) {
    try {
      const filename = path.join(this.audioDir, `recording_${Date.now()}`);
      
      // Record with silence detection
      // format: wav, silence: 2 seconds, maxduration: 10 seconds
      await context.exec('Record', `${filename}.wav,2,10,y`);
      
      const audioFile = `${filename}.wav`;
      
      // Check if file exists and has content
      if (fs.existsSync(audioFile)) {
        const stats = fs.statSync(audioFile);
        if (stats.size > 1000) { // More than 1KB
          return audioFile;
        } else {
          fs.unlinkSync(audioFile);
        }
      }
      
      return null;
    } catch (error) {
      logger.error('Error recording user input', { error: error.message });
      return null;
    }
  }

  isGoodbye(text) {
    const goodbyePhrases = [
      'tschüss',
      'auf wiedersehen',
      'auf wiederhören',
      'bye',
      'ciao',
      'bis bald',
      'danke, das reicht',
      'beenden'
    ];
    
    const lowerText = text.toLowerCase();
    return goodbyePhrases.some(phrase => lowerText.includes(phrase));
  }
}

export default AGIHandler;
