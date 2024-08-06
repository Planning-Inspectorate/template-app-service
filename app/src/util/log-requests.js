import logger from './logger.js';

/**
 * Log all requests to console
 *
 * @type {import('express').RequestHandler}
 */
export function logRequests(_, res, next) {
    const { req, statusCode } = res;
	logger.info(`${req.method} ${req.originalUrl.toString()} (Response code: ${statusCode})`);
	next();
}