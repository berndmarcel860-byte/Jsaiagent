import axios from 'axios';
import { config } from '../config/config.js';
import logger from '../config/logger.js';

class TTSService {
  constructor() {
    this.baseUrl = config.coquiTts.url;
  }

  async synthesize(text) {
    try {
      logger.info('Synthesizing speech', { text: text.substring(0, 50) });

      // Call Coqui TTS API with Thorsten voice
      const response = await axios.post(
        `${this.baseUrl}/api/tts`,
        {
          text: text,
          speaker_id: 'thorsten', // Thorsten voice
          language_id: 'de'
        },
        {
          responseType: 'arraybuffer',
          timeout: 30000
        }
      );

      logger.info('Speech synthesized successfully', { 
        size: response.data.byteLength 
      });

      return Buffer.from(response.data);
    } catch (error) {
      logger.error('Error synthesizing speech', { 
        error: error.message,
        text: text.substring(0, 50)
      });
      
      // Fallback: return empty buffer
      return Buffer.alloc(0);
    }
  }

  async getVoices() {
    try {
      const response = await axios.get(`${this.baseUrl}/api/voices`);
      return response.data;
    } catch (error) {
      logger.error('Error getting voices', { error: error.message });
      return [];
    }
  }
}

export default TTSService;
