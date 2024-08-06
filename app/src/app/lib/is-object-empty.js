/**
 * 
 * @param { * } obj 
 * @returns { boolean }
 */

export function isObjectEmpty(obj) {
    return obj && Object.keys(obj).length === 0 && obj.constructor === Object
}