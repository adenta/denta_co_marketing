# Chat App

## Development Workflow

`bin/setup` installs the repo's git hooks with Lefthook.

The pre-commit hook runs `bin/rubocop-changed`, which auto-corrects and re-stages only staged Ruby files. It refuses to touch staged Ruby files that still have unstaged edits, because auto-correcting those files would collapse partial staging.

You can run the same command manually before pushing:

```sh
bin/rubocop-changed
```

## How Pages Render

Interactive HTML pages follow a controller-to-React-page convention instead of per-action ERB templates.

1. A Rails controller action prepares serializable page data in `@props`.
2. `ApplicationController#default_render` falls back to `app/views/shared/page_fallback.html.erb` when no explicit template exists.
3. That fallback mounts the React page whose name matches `<controller_path>/<action_name>`.
4. `app/javascript/turbo-mount.js` eagerly registers page modules from `app/javascript/pages/**/*.tsx` and mounts their default exports.

As a routing rule of thumb, `GET` HTML routes are the page layer and should map to controller actions plus matching React page files. Mutating requests should usually target the `/api/v1/...` JSON endpoints and use `app/javascript/hooks/useApiRequest.ts` from the client.

Example: `SessionsController#new` sets `@props` in `app/controllers/sessions_controller.rb`, and the request renders `app/javascript/pages/sessions/new.tsx` without a `app/views/sessions/new.html.erb` template.

This convention is intentional. `config/initializers/generators.rb` sets `g.template_engine nil` so new controllers do not generate ERB page templates by default.

Use ERB for shared layout/shell concerns and non-page views only, such as `app/views/layouts/application.html.erb`, `app/views/shared/page_fallback.html.erb`, mailers, and PWA assets. If both an ERB template and a matching React page exist for the same action, the ERB template wins.
