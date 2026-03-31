# Agent Instructions

## Page Rendering Convention

- Interactive HTML pages do not get per-action ERB templates by default.
- For a new page, add the route and controller action, set `@props` in the controller, and rely on `ApplicationController#default_render` to mount the React page automatically.
- Treat `GET` HTML routes as page-entry routes. They should render page state and hand off to a matching React page component.
- When controller props or JSON responses serialize Active Record models, prefer Blueprinter classes in `app/blueprints` over inline `map`/hash shaping in the controller.
- Treat writes and other non-page interactions as API work. `POST`, `PATCH`, `PUT`, and `DELETE` requests should usually go through the `/api/v1/...` endpoints and the shared `app/javascript/hooks/useApiRequest.ts` helper.
- The page component must live at `app/javascript/pages/<controller_path>/<action_name>.tsx`.
- Page modules must have a default export because `app/javascript/turbo-mount.js` registers pages by file path and mounts the default export.
- Do not add `app/views/<controller>/<action>.html.erb` unless you intentionally want to opt out of the React-page convention. If both an ERB template and a matching page component exist, the ERB template wins.
- Shared chrome belongs in layout-level mounts such as `app/views/layouts/application.html.erb`. Page-specific UI belongs in the React page component.
- ERB is still valid for shared layout/shell concerns and non-page views such as `app/views/layouts/application.html.erb`, `app/views/shared/page_fallback.html.erb`, mailers, and PWA assets.

## Source Of Truth

- `app/controllers/application_controller.rb` handles the implicit fallback from controller/action to `app/javascript/pages/...`.
- `app/blueprints/**/*.rb` is the default serialization layer for controller props and API payloads derived from models.
- `app/javascript/turbo-mount.js` eagerly registers `app/javascript/pages/**/*.tsx` and `app/javascript/components/**/*.tsx`.
- `app/javascript/hooks/useApiRequest.ts` is the default client helper for JSON mutations against `/api/v1/...`.
- `test/integration/implicit_page_fallback_test.rb` exercises the fallback behavior, including the rule that an explicit ERB template takes precedence.
