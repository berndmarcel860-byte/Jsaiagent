import AGI from 'agi';
import { config } from '../config/config.js';
import AGIHandler from './agi-handler.js';
import logger from '../config/logger.js';

class AGIServer {
  constructor() {
    this.port = config.agi.port;
    this.handler = new AGIHandler();
  }

  start() {
    const server = AGI.createServer((context) => {
      logger.info('New AGI connection', {
        callerid: context.callerid,
        extension: context.extension
      });

      this.handler.handleCall(context);
    });

    server.listen(this.port, () => {
      logger.info(`AGI server listening on port ${this.port}`);
    });

    server.on('error', (error) => {
      logger.error('AGI server error', { error: error.message });
    });

    return server;
  }
}

export default AGIServer;
