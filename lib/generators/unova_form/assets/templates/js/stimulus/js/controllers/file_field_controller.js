// app/javascript/controllers/upload_file_controller.js

import StimulusController from "../lib/stimulus_controller";

export default class extends StimulusController {
  previewType = "img"

  /**
   * @returns {(HTMLImageElement | HTMLVideoElement | HTMLAudioElement)[]}
   */
  get previewEls() {
    let previewEl = Array.from(this.findAllEl("label .preview"));
    if (previewEl?.every(e => e.tagName === this.previewType.toUpperCase())) return previewEl;
    previewEl?.forEach(el => el.remove());
    previewEl = [];
    let previewContainer = this.findEl("label .preview-container");
    if (!previewContainer) {
      previewContainer = document.createElement("div")
      previewContainer.classList.add("preview-container")
    } else previewContainer.classList.remove("hidden")

    if(this.previewType === "div") previewContainer.classList.add("no-preview")
    else previewContainer.classList.remove("no-preview")

    previewEl[0] ||= document.createElement(this.previewType)
    previewEl[0].classList.add("preview")

    let resetButton = this.findEl(`button[data-action="click->file-field#reset"]`)
    if (resetButton) previewEl.forEach(el => resetButton.insertAdjacentElement("beforebegin", el))
    else previewContainer.append(...previewEl)

    previewEl.forEach(el => {
      !(el instanceof HTMLImageElement) && !(el instanceof HTMLDivElement) && (el.controls = true);
    })

    return previewEl
  }

  get newPreviewEl() {
    let previewEl = document.createElement(this.previewType)
    previewEl.classList.add("preview")
    !(previewEl instanceof HTMLImageElement) && !(previewEl instanceof HTMLDivElement) && (previewEl.controls = true);
    const currEls = this.previewEls
    currEls[currEls.length - 1].insertAdjacentElement("afterend", previewEl)
    return previewEl
  }

  /**
   * @returns {string[]}
   */
  get previews() {
    return this.previewEls.map(el => (el instanceof HTMLMediaElement) && el.srcObject ||
      !(el instanceof HTMLDivElement) && el.src ||
      el.innerText)
  }

  set previews(vs) {
    let previewEls = this.previewEls;
    if (vs.length > previewEls.length) {
      for (let i = previewEls.length; i < vs.length; i++) {
        previewEls.push(this.newPreviewEl)
      }
    }
    for (const i in previewEls) {
      const v = vs[i];
      if(!v) {
        previewEls[i]?.remove();
        continue;
      }
      let previewEl = previewEls[i];
      if (previewEl instanceof HTMLDivElement) {
        previewEl.innerText = (v instanceof File) && v?.name || v?.toString() || "";
        continue
      }
      if (previewEl instanceof HTMLMediaElement && typeof v !== "string") {
        try {
          previewEl.srcObject = v;
        } catch (err) {
          if (!(err instanceof TypeError) || v instanceof MediaStream) throw err;
          previewEl.src = v ? URL.createObjectURL(v) : "";
        }
      } else if (typeof v === "string") {
        previewEl.src = v || "";
      } else if ((v instanceof File)) {
        previewEl.src = v ? URL.createObjectURL(v) : "";
      } else {
        console.warn("Preview value type not supported")
      }
    }
  }

  /**
   * @returns {HTMLDivElement}
   */
  get previewTextsEl() {
    let previewTextEl = this.findEl("label div.filename");
    if (previewTextEl) return previewTextEl;
    previewTextEl = document.createElement("div");
    previewTextEl.classList.add("filename")
    this.findEl("label")?.insertAdjacentElement("beforeend", previewTextEl)
    return previewTextEl
  }

  get previewTexts() {
    return this.previewTextsEl.innerText
  }

  set previewTexts(v) {
    this.previewTextsEl.innerText = v
  }

  /**
   * @param {number} v
   */
  set displayedPreview(v) {
    let previewEls = this.previewEls;
    if (v >= previewEls.length) v = previewEls.length - 1;
    if (v < 0) v = 0;
    previewEls.forEach((el, i) =>
      el.style.display = !el.matches('video[src=""],audio[src=""],img[src=""],div:empty') && i === v
        ? ""
        : "none"
    )
  }
  get displayedPreview() {
    return this.previewEls.findIndex(el => el.style.display !== "none")
  }

  determinePreviewType() {
    let input = this.findEl("input[type=file]", "Cannot determine preview type: not found");
    if("accept" in input && input.accept) {
      if (input.accept.includes("image")) this.previewType = "img"
      else if (input.accept.includes("video")) this.previewType = "video"
      else if (input.accept.includes("audio")) this.previewType = "audio"
      else this.previewType = "div"
    } else {
      const previewEls = Array.from(this.findAllEl("label .preview"));
      if(previewEls.every(e => e instanceof HTMLImageElement)) this.previewType = "img"
      else if(previewEls.every(e => e instanceof HTMLVideoElement)) this.previewType = "video"
      else if(previewEls.every(e => e instanceof HTMLAudioElement)) this.previewType = "audio"
      else this.previewType = "div"
    }
  }

  connect() {
    this.determinePreviewType()
    this.updateButtons();
    this.updateDivPreviewEls();
    this.displayedPreview = 0;
  }

  updateButtons(){
    const container = this.findEl("label .preview-container")
    if(this.previewEls.length > 1 && container && this.previewType !== "div"){
      let [prev, next] = [
        container.querySelector("button.prev"),
        container.querySelector("button.next")
      ]
      if(!prev) {
        prev = document.createElement("button")
        prev.classList.add("prev")
        prev.type = "button"
        prev.addEventListener("click", () => this.displayedPreview--)
        container.insertAdjacentElement("afterbegin", prev)
      }
      if(!next) {
        next = document.createElement("button")
        next.classList.add("next")
        next.type = "button"
        next.addEventListener("click", () => this.displayedPreview++)
        container.insertAdjacentElement("beforeend", next)
      }
    } else if (container) {
      container.querySelectorAll("button.prev, button.next").forEach(e => e.remove())
    }
  }

  updateDivPreviewEls(){
    if(this.previewType !== "div") return;
    let [first, ...previewEls] = this.previewEls;
    if(!first) return;
    if(previewEls.length) first.innerText += " | "
    first.innerText += previewEls.map(e => e.innerText).join(" | ");
    previewEls.forEach(e => e.remove())
  }

  change(event) {
    if(!(event.target instanceof HTMLInputElement)) throw new Error("Cannot change file field: not found");
    if(!event.target.files) throw new Error("Cannot change file field: no files");
    let files = Array.from(event.target.files);
    if (files?.length) {
      event.target.classList.add("filled")
      if (files.every(e => e.type.startsWith("image"))) this.previewType = "img"
      else if (files.every(e => e.type.startsWith("video"))) this.previewType = "video"
      else if (files.every(e => e.type.startsWith("audio"))) this.previewType = "audio"
      else this.previewType = "div"

      this.previews = files;

      if(this.previewType !== "div") {
        this.previewTexts = files.map(e => e.name).join(" | ");
        this.displayedPreview = 0;
      } else {
        this.updateDivPreviewEls();
        this.previewTexts = "";
        this.displayedPreview = 0;
      }
      this.updateButtons();
    } else {
      event.target.classList.remove("filled");
      this.previews = [];
      this.previewTexts = "";
    }
  }

  reset() {
    let input = this.findEl("input[type=file]", "Cannot reset file field: not found");
    input.value = "";
    this.change({...(new InputEvent("change", {bubbles: true, cancelable: true})), target: input})
  }
}