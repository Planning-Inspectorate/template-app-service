/**
 * Render the home page
 *
 * @type {import('express').RequestHandler}
 */
export function viewHomepage(req, res) {
    res.render('pages/home/home.view.njk', {
        pageTitle: 'Welcome home'
    });
}
