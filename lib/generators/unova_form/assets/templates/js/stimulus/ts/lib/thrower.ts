import {Constructor} from "@hotwired/stimulus/dist/types/core/constructor";

export default class Thrower {
  throw<T extends Error>(message: string, type?: Constructor<T>): never {
    const errorType = type || Error;
    throw new errorType(message);
  }

  static throw<T extends Error>(message: string, type?: Constructor<T>): never {
    const errorType = type || Error;
    throw new errorType(message);
  }
}