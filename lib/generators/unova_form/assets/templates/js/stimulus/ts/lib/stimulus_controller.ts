import {Controller} from "@hotwired/stimulus";
import Thrower from "./thrower";

class QueryError extends Error {
  constructor(message: string) {
    super(message);
    this.name = "QueryError";
  }
}


class StimulusController<ElementType extends Element = Element> extends Controller<ElementType> {
  findEl<K extends keyof HTMLElementTagNameMap>(selectors: K): HTMLElementTagNameMap[K] | null;
  findEl<K extends keyof HTMLElementTagNameMap>(selectors: K, errorTextIfNull: string): HTMLElementTagNameMap[K] | never;
  findEl<K extends keyof SVGElementTagNameMap>(selectors: K): SVGElementTagNameMap[K] | null;
  findEl<K extends keyof SVGElementTagNameMap>(selectors: K, errorTextIfNull: string): SVGElementTagNameMap[K] | never;
  findEl<K extends Element>(selectors: string): K | null;
  findEl<K extends Element>(selectors: string, errorTextIfNull: string): K | never;
  findEl<T extends Element>(selectors: string, errorTextIfNull?: string): T | null {
    const e = this.element.querySelector<T>(selectors);
    if (e != null) return e;
    if (errorTextIfNull != undefined) this.throw(`Query error thrown on ${this.constructor.name}:\nElement: ${this.element}\nQuery: ${selectors}\nError: ${errorTextIfNull}`, QueryError);
    return null;
  }

  findAllEl<K extends keyof HTMLElementTagNameMap>(selectors: K): NodeListOf<HTMLElementTagNameMap[K]>;
  findAllEl<K extends keyof HTMLElementTagNameMap>(selectors: K, errorTextIfEmpty: string): NodeListOf<HTMLElementTagNameMap[K]> | never;
  findAllEl<K extends keyof SVGElementTagNameMap>(selectors: K): NodeListOf<SVGElementTagNameMap[K]>;
  findAllEl<K extends keyof SVGElementTagNameMap>(selectors: K, errorTextIfEmpty: string): NodeListOf<SVGElementTagNameMap[K]> | never;
  findAllEl<K extends Element>(selectors: string): NodeListOf<K>;
  findAllEl<K extends Element>(selectors: string, errorTextIfEmpty: string): NodeListOf<K> | never;
  findAllEl<T extends Element>(selectors: string, errorTextIfEmpty?: string): NodeListOf<T> {
    const e = this.element.querySelectorAll<T>(selectors);
    if (e.length == 0 && errorTextIfEmpty != undefined) this.throw(`Query error thrown on ${this.constructor.name}:\nElement: ${this.element}\nQuery: ${selectors}\nError: ${errorTextIfEmpty}`, QueryError);
    return e;
  }
}

// Defines all the properties of Thrower.prototype on StimulusController.prototype because javascript don't allow multiple inheritance
interface StimulusController<ElementType extends Element = Element> extends Controller<ElementType>, Thrower {
}

Object.defineProperties(StimulusController.prototype, Object.getOwnPropertyDescriptors(Thrower.prototype));

export default StimulusController;