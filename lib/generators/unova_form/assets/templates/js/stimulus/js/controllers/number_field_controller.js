import StimulusController from "../lib/stimulus_controller";

/**
 * @property {HTMLElement} element
 */
export default class extends StimulusController {
  /**
   * @type {HTMLInputElement}
   */
  input;

  get inputVal() {
    try {
      let val = parseFloat(this.input.value);
      return isNaN(val) ? 0 : val
    } catch (e) {
      return 0;
    }
  }

  set inputVal(v) {
    this.input.value = `${v}`;
    this.input.dispatchEvent(new Event("change"))
  }

  connect() {
    this.input = this.findEl("input", "No input element found");
  }

  add() {
    if (this.input.max && this.inputVal >= parseFloat(this.input.max)) return;
    this.inputVal++;
  }

  sub() {
    if (this.input.min && this.inputVal <= parseFloat(this.input.min)) return;
    this.inputVal--;
  }
}
