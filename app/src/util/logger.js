import pino from 'pino';
import config from '../app/config.js';

// configure the pino logger for use within the app
const logger = pino({
  transport: {
    target: 'pino-pretty',
    level: config.logLevel,
    options: {
      colorize: true
    }
  }
});

export default logger;
