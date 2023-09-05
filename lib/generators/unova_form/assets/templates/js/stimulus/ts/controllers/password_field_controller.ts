import StimulusController from "../lib/stimulus_controller";

export default class extends StimulusController {
  input!: HTMLInputElement;
  toggleEl!: HTMLElement;

  connect() {
    this.input = this.findEl("input", "No input element found");
    this.toggleEl = this.findEl(".icon", "No toggle element found");
    this.input.classList.add("pr-10");
    this.toggleEl.classList.add("cursor-pointer", "text-primary", "defined-color", "transition");
    this.toggleEl.classList.remove("text-secondary");
  }

  toggle() {
    this.toggleEl.classList.toggle("text-secondary");
    this.toggleEl.classList.toggle("text-primary");
    if (this.toggleEl.classList.contains("text-primary")) {
      this.input.type = "password";
    } else {
      this.input.type = "text";
    }
  }
}
