/**
 * Render the POST page
 *
 * @type {import('express').RequestHandler}
 */
export function handlePost(req, res) {
    res.render('pages/post/post.view.njk', {
        pageTitle: 'Submitted successfully'
    });
}
