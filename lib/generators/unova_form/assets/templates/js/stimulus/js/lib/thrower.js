
export default class Thrower {

  /**
   * Used to throw an error.
   *
   * @template T extends Error
   * @param {string} message - The error message.
   * @param {ErrorConstructor<T>} type - The error type.
   * @throws {T} The error.
   */
  throw(message, type) {
    const errorType = type || Error;
    throw new errorType(message);
  }

  /**
   * Used to throw an error.
   * @template T extends Error
   * @param {string} message - The error message.
   * @param {ErrorConstructor<T>} type - The error type.
   * @throws {T} The error.
   */

  static throw(message, type) {
    const errorType = type || Error;
    throw new errorType(message);
  }
}