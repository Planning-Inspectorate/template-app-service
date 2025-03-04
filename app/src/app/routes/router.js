import { Router as createRouter } from 'express';

import { viewHomepage } from '../pages/home/home.controller.js';
import {createMonitoringRoutes} from "./monitoring.js";
import logger from "../../util/logger.js";
import config from "../config.js";
import {handlePost} from "../pages/post/post.controller.js";

// create an express router, for handling different paths
const router = createRouter();
const monitoringRoutes = createMonitoringRoutes({
    config,
    logger,
});

// setup the handlers for the pages
router.use('/', monitoringRoutes);
router.route('/').get(viewHomepage);
router.route('/post').post(handlePost);

// export the router for use by the app
export default router;
