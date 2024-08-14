import * as sass from 'sass'
import path from 'node:path';
import fs from 'node:fs/promises';
import { createRequire } from 'node:module';
import { copyFolder } from './copy.js';
import config from '../app/config.js';

const staticDir = config.staticDir;
const require = createRequire(import.meta.url);

// resolves to <root>/node_modules/govuk-frontend/govuk/all.js than maps to `<root>`
const govUkRoot = path.resolve(require.resolve('govuk-frontend'), '../../../..');

/**
 * Compile sass into a css file in the .static folder
 *
 * @see https://sass-lang.com/documentation/js-api/#md:usage
 * @returns {Promise<void>}
 */
async function compileSass() {
    const styleFile = path.join(config.srcDir, 'app', 'sass/style.scss');
    const out = sass.compile(styleFile, {
        // ensure scss can find the govuk-frontend folders
		loadPaths: [govUkRoot],
        style: 'compressed',
        // don't show depreciate warnings for govuk
        // see https://frontend.design-system.service.gov.uk/importing-css-assets-and-javascript/#silence-deprecation-warnings-from-dependencies-in-dart-sass
        quietDeps: true
    });
    const outputPath = path.join(staticDir, 'style.css');
    // make sure the static directory exists
    await fs.mkdir(staticDir, {recursive: true});
    // write the css file
    await fs.writeFile(outputPath, out.css);
}

/**
 * Copy govuk assets into the .static folder
 *
 * @see https://frontend.design-system.service.gov.uk/importing-css-assets-and-javascript/#copy-the-font-and-image-files-into-your-application
 * @returns {Promise<void>}
 */
async function copyAssets() {
    const images = path.join(govUkRoot, 'node_modules/govuk-frontend/govuk/assets/images');
    const fonts = path.join(govUkRoot, 'node_modules/govuk-frontend/govuk/assets/fonts');

    const staticImages = path.join(staticDir, 'assets', 'images');
    const staticFonts = path.join(staticDir, 'assets', 'fonts');

    // copy all images and fonts for govuk-frontend
    await copyFolder(images, staticImages);
    await copyFolder(fonts, staticFonts);
}

/**
 * Do all steps to run the build
 * @returns {Promise<void[]>}
 */
function run() {
    return Promise.all([
        compileSass(),
        copyAssets()
    ]);
}

// run the build, and write any errors to console
run().catch(console.error);
