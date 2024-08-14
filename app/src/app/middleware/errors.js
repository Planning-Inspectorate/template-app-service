import logger from '../../util/logger.js';

/**
 * A catch-all error handler to use as express middleware
 *
 * @type {import('express').ErrorRequestHandler}
 */
export function defaultErrorHandler(error, req, res, next) {
    const message = error.message || 'unknown error'
    logger.error(message, error);

    console.log(error)
    if (res.headersSent) {
        next(error);
        return;
    }

    const code = error.statusCode || 500;
    res.status(code);
    res.render(`layouts/error`, {
        pageTitle: 'Sorry, there was an error',
        messages: [
            message,
            'Try again later'
        ]
     });
}

/**
 * A catch-all handler to serve a 404 page
 *
 * @type {import('express').RequestHandler}
 */
export function notFoundHandler(req, res) {
    res.status(404);
    res.render(`layouts/error`, {
        pageTitle: 'Page not found',
        messages: [
            'If you typed the web address, check it is correct.',
            'If you pasted the web address, check you copied the entire address.'
        ]
    });
}
