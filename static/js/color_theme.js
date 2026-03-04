// const themeCycle = ["latte", "frappe", "macchiato", "mocha"].reverse();
const themeCycle = ["latte", "mocha"].reverse();

function setTheme(themeName) {
  document.body.classList = Array.from(document.body.classList)
    .filter((c) => !c.startsWith("theme-"))
    .concat([`theme-${themeName}`]);
  localStorage.setItem("theme", themeName);
}

setTheme(localStorage.getItem("theme") || themeCycle[0]);

const cycleTheme = () =>
  setTheme(
    themeCycle[
      (themeCycle.indexOf(localStorage.getItem("theme")) + 1) %
        themeCycle.length
    ],
  );
