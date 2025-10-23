import AGIServer from './agi/agi-server.js';
import logger from './config/logger.js';
import { config } from './config/config.js';

// Validate configuration
function validateConfig() {
  const errors = [];

  if (!config.openai.apiKey) {
    errors.push('OPENAI_API_KEY is not set');
  }

  if (!config.asterisk.password) {
    errors.push('ASTERISK_PASSWORD is not set');
  }

  if (errors.length > 0) {
    logger.error('Configuration errors:', { errors });
    console.error('\n⚠️  Configuration errors:');
    errors.forEach(err => console.error(`   - ${err}`));
    console.error('\nPlease check your .env file\n');
    process.exit(1);
  }
}

// Main application
async function main() {
  try {
    console.log('╔════════════════════════════════════════════════════════════╗');
    console.log('║   JSAIAgent - KI-gestützter Telefonagent                  ║');
    console.log('║   Investment Lead Generation System                       ║');
    console.log('╚════════════════════════════════════════════════════════════╝\n');

    logger.info('Starting JSAIAgent application');

    // Validate configuration
    validateConfig();
    logger.info('Configuration validated');

    // Start AGI server
    const agiServer = new AGIServer();
    agiServer.start();

    logger.info('Application started successfully');
    console.log('✓ AGI Server started on port', config.agi.port);
    console.log('✓ Waiting for calls from Asterisk...\n');
    console.log('Configuration:');
    console.log('  - Agent Extension:', config.agent.extension);
    console.log('  - Caller Extension:', config.agent.callerExtension);
    console.log('  - OpenAI Model:', config.openai.model);
    console.log('  - Coqui TTS URL:', config.coquiTts.url);
    console.log('\n');

  } catch (error) {
    logger.error('Fatal error starting application', { 
      error: error.message, 
      stack: error.stack 
    });
    console.error('\n❌ Fatal error:', error.message);
    process.exit(1);
  }
}

// Handle shutdown gracefully
process.on('SIGINT', () => {
  logger.info('Received SIGINT, shutting down gracefully');
  console.log('\n\nShutting down...');
  process.exit(0);
});

process.on('SIGTERM', () => {
  logger.info('Received SIGTERM, shutting down gracefully');
  console.log('\n\nShutting down...');
  process.exit(0);
});

process.on('unhandledRejection', (reason, promise) => {
  logger.error('Unhandled Rejection', { reason, promise });
});

process.on('uncaughtException', (error) => {
  logger.error('Uncaught Exception', { error: error.message, stack: error.stack });
  process.exit(1);
});

// Start the application
main();
