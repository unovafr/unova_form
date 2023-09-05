// app/javascript/controllers/upload_file_controller.js

import StimulusController from "../lib/stimulus_controller";

export default class extends StimulusController {
  previewType = "img"

  /**
   * @returns {HTMLImageElement | HTMLVideoElement | HTMLAudioElement}
   */
  get previewEl() {
    let previewEl = this.findEl("label .preview");
    if (previewEl?.tagName === this.previewType.toUpperCase()) return previewEl;
    previewEl?.remove();
    let previewContainer = this.findEl("label .preview-container");
    if (!previewContainer) {
      previewContainer = document.createElement("div")
      previewContainer.classList.add("preview-container")
    } else previewContainer.classList.remove("hidden")

    previewEl ||= document.createElement(this.previewType)
    previewEl.classList.add("preview")

    let resetButton = this.findEl(`button[data-action="click->file-field#reset"]`)
    if (resetButton) resetButton.insertAdjacentElement("beforebegin", previewEl)
    else previewContainer.insertAdjacentElement("beforeend", previewEl)

    !(previewEl instanceof HTMLImageElement) && (previewEl.controls = true);

    return previewEl
  }

  get preview() {
    return (this.previewEl instanceof HTMLMediaElement) && this.previewEl.srcObject || this.previewEl.src
  }

  set preview(v) {
    let previewEl = this.previewEl;
    if (previewEl instanceof HTMLMediaElement && typeof v !== "string") {
      try {
        if (!v) previewEl.srcObject = null;
        if (v) previewEl.srcObject = v;
      } catch (err) {
        if (!(err instanceof TypeError) || v instanceof MediaStream) {
          throw err;
        }
        if (!v) previewEl.src = "";
        if (v) previewEl.src = URL.createObjectURL(v);
      }
    } else if (typeof v === "string") {
      if (!v) previewEl.src = "";
      if (v) previewEl.src = v;
    } else {
      console.warn("Preview value type not supported")
    }
  }

  /**
   * @returns {HTMLSpanElement}
   */
  get previewTextEl() {
    let previewTextEl = this.findEl("label span.label");
    if (previewTextEl) return previewTextEl;
    previewTextEl = document.createElement("span");
    previewTextEl.classList.add("label")
    this.findEl("label")?.insertAdjacentElement("beforeend", previewTextEl)
    return previewTextEl
  }

  get previewText() {
    return this.previewTextEl.innerText
  }

  set previewText(v) {
    this.previewTextEl.innerText = v
  }

  connect() {
  }

  change(event) {
    let files = event.target.files;
    if (files?.length) {
      event.target.classList.add("filled")
      let file = files[0];
      if (file.type.startsWith("image")) this.previewType = "img";
      if (file.type.startsWith("video")) this.previewType = "video";
      if (file.type.startsWith("audio")) this.previewType = "audio";
      this.preview = file;
      this.previewText = file.name;
    } else {
      event.target.classList.remove("filled");
      this.preview = null;
    }
  }

  reset() {
    let input = this.findEl("input[type=file]", "Cannot reset file field: not found");
    input.value = "";
    this.change({...(new InputEvent("change", {bubbles: true, cancelable: true})), target: input})
  }
}