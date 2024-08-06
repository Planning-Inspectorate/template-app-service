import dotenv from 'dotenv';
import path from 'node:path';
import {fileURLToPath} from 'url';

// load configuration from .env file into process.env
dotenv.config();

// get the file path for the directory this file is in
const dirname = path.dirname(fileURLToPath(import.meta.url));
// get the file path for the web/src directory
const srcDir = path.join(dirname, '..');
// get the file path for the .static directory
const staticDir = path.join(srcDir, '.static');

// export configuration, with defaults if they are not set
export default {
    // the URL of the API service
    apiUrl: process.env.API_URL || 'http://localhost:3000',
    // the log level to use
    logLevel: process.env.LOG_LEVEL || 'info',
    // the HTTP port to listen on
    httpPort: process.env.HTTP_PORT || 8080,
    // the web/src directory
    srcDir,
    sessionSecret: 'shhh, secret!',
    // the static directory to serve assets from (images, css, etc..)
    staticDir
};