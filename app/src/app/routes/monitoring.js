import { Router as createRouter } from 'express';
import { asyncHandler } from '../../util/async-handler.js';
/**
 * @param {Object} params
 * @param {import('pino').BaseLogger} params.logger
 * @param {{gitSha?: string}} params.config
 * @returns {import('express').Router}
 */
export function createMonitoringRoutes({ config, logger }) {
	const router = createRouter();
	const handleHealthCheck = buildHandleHeathCheck(logger, config);

	router.head('/', asyncHandler(handleHeadHealthCheck));
	router.get('/health', asyncHandler(handleHealthCheck));

	return router;
}

/** @type {import('express').RequestHandler} */
export function handleHeadHealthCheck(_, response) {
	// no-op - HEAD mustn't return a body
	response.sendStatus(200);
}

/**
 * @param {import('pino').BaseLogger} logger
 * @param {{gitSha?: string}} config
 * @returns {import('express').RequestHandler}
 */
export function buildHandleHeathCheck(logger, config) {
	return async (_, response) => {
		response.status(200).send({
			status: 'OK',
			uptime: process.uptime(),
			commit: config.gitSha
		});
	};
}
