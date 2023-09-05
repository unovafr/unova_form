import { useClickOutside } from "stimulus-use";
import StimulusController from "../lib/stimulus_controller";

export default class extends StimulusController {
  /**
   * @type {HTMLSelectElement}
   */
  selectEl;

  /**
   * @type {HTMLDivElement}
   */
  dropdownEl;

  /**
   * @type {HTMLDivElement}
   */
  containerEl;

  /**
   * @type {HTMLInputElement}
   */
  inputSearchEl;

  /**
   * @type {HTMLDivElement}
   */
  SelectedElementsContainerEl;

  /**
   * @type {{value: string, label: string}[]}
   */
  selectedValues = [];

  /**
   * @type {{value: string, label: string}[]}
   */
  options= [];

  /**
   * @type {string | null}
   */
  queryUrl;

  /**
   * @type {string | null}
   */
  responseArrayPos;

  /**
   * @type {string | null}
   */
  responseItemKey;

  /**
   * @type {string | null}
   */
  responseItemLabel;

  /**
   * @type {NodeJS.Timeout | undefined}
   */
  timeout;

  /**
   * @type {string}
   */
  placeholder = "Select ...";

  connect() {
    this.selectEl = this.findEl(":scope>select", "No select element found");
    this.selectEl.multiple = true;
    this.selectEl.addEventListener("focusin", ()=>{this.startsearch()})

    this.placeholder = this.selectEl.querySelector("option[selected][disabled]")?.textContent || this.placeholder;

    this.selectEl.insertAdjacentHTML(
      "afterend",
      `
        <div class="multiselect-container" data-action="click->multiselect#startsearch">
          <div class="multiselect-selected-element-container">
            <span class="text-grey">${this.placeholder}</span>
          </div>
          <div class="input-container">
            <input type="search" placeholder="Rechercher..." data-action="keyup->multiselect#updatesearch">
          </div>
          <div class="multiselect-dropdown"></div>
        </div>
      `
    );
    this.containerEl = this.findEl(":scope>div.multiselect-container", "No container element found");
    this.SelectedElementsContainerEl = this.findEl(":scope>div.multiselect-selected-element-container", "No selected element container element found");
    this.inputSearchEl = this.findEl(":scope>div.input-container>input", "No input element found");
    this.dropdownEl = this.findEl(":scope>div.multiselect-dropdown", "No dropdown element found");

    this.selectEl.querySelectorAll("option[selected]:not([disabled])").forEach((el) => {
      this.selectedValues.push({ value: el.value, label: el.innerText });
    });
    this.selectEl.querySelectorAll("option").forEach((el) => {
      if(!el.disabled) this.options.push({ value: el.value, label: el.innerText });
      el.remove();
    });

    const tempOptions = this.element.getAttribute("data-options");
    if(tempOptions) this.options.push(...JSON.parse(tempOptions));

    this.queryUrl = this.element.getAttribute("data-query-url");
    this.responseArrayPos = this.element.getAttribute("data-resp-array-pos");
    this.responseItemKey = this.element.getAttribute("data-resp-item-key");
    this.responseItemLabel = this.element.getAttribute("data-resp-item-label");

    this.update();
    useClickOutside(this);
  }

  get isSearching() {
    return this.inputSearchEl.classList.contains("show");
  }

  update() {
    if (this.selectedValues.length) this.SelectedElementsContainerEl.querySelector("span")?.classList.add("hidden");
    else this.SelectedElementsContainerEl.querySelector("span")?.classList.remove("hidden");

    this.selectEl.querySelectorAll("option").forEach((el) => { el.remove(); });
    this.SelectedElementsContainerEl.querySelectorAll("div.multiselect-selected-element").forEach((el) => { el.remove(); });

    this.selectedValues.forEach((val) => {
      this.selectEl.insertAdjacentHTML(
        "beforeend",
        `<option selected value="${val.value}">${val.label}</option>`
      );
      this.SelectedElementsContainerEl.insertAdjacentHTML(
        "afterbegin",
        `
          <div class="multiselect-selected-element">
              ${val.label}
              <button type="button" class="multiselect-unselect-btn" data-action="click->multiselect#remove" data-value="${val.value}">x</button>
          </div>
        `
      );
    });
    this.updatesearch()
  }

  remove(event) {
    event.stopPropagation();
    this.selectedValues = this.selectedValues.filter(
      (v) => v.value !== event.target?.getAttribute("data-value")
    );
    this.update();
  }

  add(event:  MouseEvent & { target: Element }) {
    event.stopPropagation();
    this.selectedValues = this.selectedValues.filter(
      (v) => v.value !== event.target.getAttribute("data-value")
    );
    this.selectedValues.push({
      value: event.target.getAttribute("data-value")  || "",
      label: event.target.getAttribute("data-label") || "",
    });
    event.target.remove();
    this.update();
  }

  startsearch() {
    this.containerEl.classList.add("active");
    this.inputSearchEl.classList.add("show");
    this.inputSearchEl.focus();
    this.dropdownEl.classList.add("show");
    this.updatesearch();
  }

  stopsearch() {
    this.containerEl.classList.remove("active");
    this.inputSearchEl.classList.remove("show");
    this.dropdownEl.classList.remove("show");
    this.inputSearchEl.value = "";
    this.dropdownEl.innerHTML = "";
  }

  updatesearch() {
    if(this.selectedValues.length !== 0) {
      if (this.selectEl.nextElementSibling?.hasAttribute("data-empty-value-definition"))
        this.selectEl.nextElementSibling.remove();
    } else if(!this.selectEl.nextElementSibling?.hasAttribute("data-empty-value-definition")) {
      this.selectEl.insertAdjacentHTML("afterend", `<input class="hidden" data-empty-value-definition name="${this.selectEl.name}" value="" title="empty value of multiselect" />`)
    }
    if(this.options){
      this.dropdownEl.innerHTML = "";
      for (let {value, label} of this.options){
        if(
            label.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "").includes(
                this.inputSearchEl.value.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "")
            ) &&
            !this.selectedValues.find((el) => el.value === value)
        )
        this.dropdownEl.insertAdjacentHTML(
          "beforeend",
          `
            <button type="button" class="btn" data-value="${value}" data-label="${label}" data-action="click->multiselect#add">${label}</button>
          `
        );
      }
      return;
    }
    if (this.timeout != null) clearTimeout(this.timeout);
    this.timeout = setTimeout(() => {
      if(this.queryUrl && this.responseArrayPos && this.responseItemKey && this.responseItemLabel)
        fetch(this.queryUrl.replace("{query}", this.inputSearchEl.value))
          .then((res) => res.json())
          .then((json) => {
            if(!(this.responseArrayPos && this.responseItemKey && this.responseItemLabel)) return;
            let arrPath = this.responseArrayPos.split(".");
            let arr = json;
            while (arrPath.length > 0) {
              arr = arr[arrPath.shift()];
            }
            if (arr.length > 0) {
              this.dropdownEl.innerHTML = "";
              arr.forEach((item: any) => {
                let keyPath = this.responseItemKey.split(".");
                let key = { ...item };
                while (keyPath.length > 0) {
                  key = key[keyPath.shift()];
                }
                let labelPath = this.responseItemLabel.split(".");
                let label = { ...item };
                while (labelPath.length > 0) {
                  label = label[labelPath.shift()];
                }
                if (
                  this.selectedValues.find((el) => el.value === "" + key) == null
                ) {
                  this.dropdownEl.insertAdjacentHTML(
                    "beforeend",
                    `
                      <button type="button" class="btn" data-value="${key}" data-label="${label}" data-action="click->multiselect#add">${label}</button>
                    `
                  );
                }
              });
            } else {
              this.dropdownEl.innerHTML = `<span>${this.placeholder}</span>`;
            }
          })
    }, 500);
  }

  clickOutside(event: MouseEvent){
    this.stopsearch();
  }
}
