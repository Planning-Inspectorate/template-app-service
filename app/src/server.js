import { app } from './app/app.js';
import config from './app/config.js';
import logger from './util/logger.js';

// set the HTTP port to use from loaded config
app.set('http-port', config.httpPort);

// start the app, listening for incoming requests on the given port
app.listen(app.get('http-port'), () => {
    logger.info(
        `Server is running at http://localhost:${app.get('http-port')} in ${app.get('env')} mode`
    );
});
