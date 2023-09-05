import {Controller} from "@hotwired/stimulus";
import Thrower from "./thrower";

class QueryError extends Error {
  constructor(message) {
    super(message);
    this.name = "QueryError";
  }
}


class StimulusController extends Controller {
  /**
   * Used to find an element in the controller's element
   *
   * @param {string} selectors
   * @param {string=} errorTextIfNull
   * @returns {Element | null} Element found or null, or throw an error if errorTextIfNull is defined
   * @throws {QueryError} If the query returns null and errorTextIfNull is defined.
   */
  findEl(selectors, errorTextIfNull) {
    const e = this.element.querySelector(selectors);
    if (e != null) return e;
    if (errorTextIfNull !== undefined) this.throw(`Query error thrown on ${this.constructor.name}:\nElement: ${this.element}\nQuery: ${selectors}\nError: ${errorTextIfNull}`, QueryError);
    return null;
  }

  /**
   * Finds all elements of a given type.
   *
   * @param {string} selectors - The query selector.
   * @param {string=} errorTextIfEmpty - The error text to throw if the query returns an empty array.
   * @returns {NodeListOf<Element>} An array containing all found elements.
   * @throws {QueryError} If the query returns an empty array and errorTextIfEmpty is defined.
   */
  findAllEl(selectors, errorTextIfEmpty) {
    const e = this.element.querySelectorAll(selectors);
    if (e.length === 0 && errorTextIfEmpty !== undefined) this.throw(`Query error thrown on ${this.constructor.name}:\nElement: ${this.element}\nQuery: ${selectors}\nError: ${errorTextIfEmpty}`, QueryError);
    return e;
  }
}

Object.defineProperties(StimulusController.prototype, Object.getOwnPropertyDescriptors(Thrower.prototype));

export default StimulusController;