import dotenv from 'dotenv';

dotenv.config();

export const config = {
  openai: {
    apiKey: process.env.OPENAI_API_KEY,
    model: 'gpt-4o-mini',
    temperature: 0.7,
    maxTokens: 500
  },
  asterisk: {
    host: process.env.ASTERISK_HOST || 'localhost',
    port: parseInt(process.env.ASTERISK_PORT || '5038'),
    username: process.env.ASTERISK_USERNAME || 'admin',
    password: process.env.ASTERISK_PASSWORD
  },
  agi: {
    port: parseInt(process.env.AGI_PORT || '4573')
  },
  coquiTts: {
    url: process.env.COQUI_TTS_URL || 'http://localhost:5002'
  },
  agent: {
    extension: process.env.AGENT_EXTENSION || '5000',
    callerExtension: process.env.CALLER_EXTENSION || '1000'
  }
};
