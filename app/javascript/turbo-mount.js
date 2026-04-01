import { TurboMount } from "turbo-mount/react";
import { createElement, lazy, StrictMode, Suspense } from "react";
import { createRoot } from "react-dom/client";

// Pages are mounted implicitly from app/javascript/pages/<controller>/<action>.tsx.
// Prefer that convention for interactive HTML pages instead of introducing per-page ERB templates.
const pages = import.meta.glob("./pages/**/*.tsx");
const components = import.meta.glob("./components/**/*.tsx");

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

const buildLazyMountedComponent = (path, loadModule) => {
  const LazyComponent = lazy(async () => {
    const module = await loadModule();
    const component = module.default;

    if (!component) {
      throw new Error(
        `Turbo mount module '${path}' must have a default export to be mounted.`,
      );
    }

    return { default: component };
  });

  function TurboMountLazyComponent(props) {
    return createElement(
      Suspense,
      { fallback: null },
      createElement(LazyComponent, props),
    );
  }

  TurboMountLazyComponent.displayName = `TurboMountLazy(${path})`;

  return TurboMountLazyComponent;
};

const registerModules = (modules, rootDir) => {
  Object.entries(modules).forEach(([path, loadModule]) => {
    const componentName = componentNameFromPath(path, rootDir);
    turboMount.register(
      plugin,
      componentName,
      buildLazyMountedComponent(path, loadModule),
    );
  });
};

registerModules(pages, "pages");
registerModules(components, "components");
