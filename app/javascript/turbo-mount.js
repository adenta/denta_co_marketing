import { TurboMount } from "turbo-mount/react";
import { createElement, StrictMode } from "react";
import { createRoot } from "react-dom/client";

// Pages are mounted implicitly from app/javascript/pages/<controller>/<action>.tsx.
// Prefer that convention for interactive HTML pages instead of introducing per-page ERB templates.
const pages = import.meta.glob("./pages/**/*.tsx", { eager: true });
const components = import.meta.glob("./components/**/*.tsx", { eager: true });

const plugin = {
  mountComponent: ({ el, Component, props }) => {
    const root = createRoot(el);
    root.render(createElement(StrictMode, null, createElement(Component, props)));
    return () => root.unmount();
  },
};

const turboMount = new TurboMount();

const componentNameFromPath = (path, rootDir) =>
  path.replace(new RegExp(`^\\./${rootDir}/`), "").replace(/\.tsx$/, "");

const registerModules = (modules, rootDir, { requireDefault = false } = {}) => {
  Object.entries(modules).forEach(([path, module]) => {
    const component = module.default;

    if (!component) {
      if (requireDefault) {
        throw new Error(
          `Page module '${path}' must have a default export to be mounted.`,
        );
      }

      return;
    }

    const componentName = componentNameFromPath(path, rootDir);
    turboMount.register(plugin, componentName, component);
  });
};

registerModules(pages, "pages", { requireDefault: true });
registerModules(components, "components");
