let translate_environment_names = {
  theorem: "théorèmes",
  proposition: "propositions",
  corollary: "corollaires",
  lemma: "lemmes",
  property: "propriétés",
  notation: "notations",
  proof: "démonstrations",
  remark: "remarques",
  definition: "définitions",
  "definition-proposition": "définitions-propositions",
  example: "exemples",
  method: "méthodes",
  exercise: "exercices",
  quote: "citations",
  callout: "important",
  recall: "rappel",
  plain: "texte",
};

const plain_elements = Array.from(document.querySelector(".right").childNodes)
  .filter((e) => !e.classList.contains("environment"))
  .filter((e) => !e.matches("h1, h2, h3, h4, h5, h6, .off-program")); // Only "text" at the root of the document

const environment_elements = Array.from(
  document.querySelectorAll(".environment"),
);

const used_environments = environment_elements.reduce((acc, cur) => {
  const name = Array.from(cur.classList)
    .find((c) => c.startsWith("environment-"))
    ?.split("-")
    .slice(1)
    .join("-");
  return name && !acc.includes(name) ? [...acc, name] : acc;
}, []);

const detailsElement = document.createElement("details");
detailsElement.className = "visibility-menu";

const summaryElement = document.createElement("summary");
summaryElement.textContent = "Afficher uniquement";
detailsElement.appendChild(summaryElement);

let checkboxes = [...used_environments, "plain"].map((name) => {
  const container = document.createElement("div");

  const checkbox_wrapper = document.createElement("div");
  checkbox_wrapper.classList.add("checkbox-slide");

  const checkbox = document.createElement("input");
  checkbox.type = "checkbox";
  checkbox.id = `check-${name}`;

  checkbox.addEventListener("change", (event) => {
    if (allUnchecked()) {
      // Last unchecked
      setAllEnvironmentVisibility(true);
    } else {
      if (numberChecked() == 1 && event.target.checked) {
        // First checked
        setAllEnvironmentVisibility(false);
      }
      setEnvironmentVisibility(name, event.target.checked);
    }
  });

  const label = document.createElement("label");
  label.setAttribute("for", `check-${name}`);
  label.textContent =
    name in translate_environment_names
      ? translate_environment_names[name]
      : name;

  checkbox_wrapper.appendChild(checkbox);
  container.appendChild(checkbox_wrapper);
  container.appendChild(label);
  detailsElement.appendChild(container);

  return checkbox;
});

document.querySelector("aside.left").appendChild(detailsElement);

function setAllEnvironmentVisibility(visible) {
  environment_elements.forEach(
    (env) => (env.style.display = visible ? "block" : "none"),
  );
  plain_elements.forEach(
    (env) => (env.style.display = visible ? "block" : "none"),
  );
}

function setEnvironmentVisibility(name, visible) {
  if (name == "plain") {
    plain_elements.forEach(
      (env) => (env.style.display = visible ? "block" : "none"),
    );
  } else {
    document
      .querySelectorAll(`.environment-${name}`)
      .forEach((env) => (env.style.display = visible ? "block" : "none"));
  }
}

function allUnchecked() {
  return checkboxes.every((c) => !c.checked);
}
function numberChecked() {
  return checkboxes.filter((c) => c.checked).length;
}
