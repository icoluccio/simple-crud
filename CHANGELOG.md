## Change log

### V0.6.0
* Make the RSpec shared examples a reusable testing library via `SimpleCrud::RSpec.configure`. Every app-specific assumption is now a configurable setting with a gem-convention default, so apps on a different stack than the gem's (Devise-JWT + FactoryBot + Pundit + AMS) can adopt them: `authenticate`/`current_user`/`other_user` (sign-in and user creation), `create_record`/`create_records`/`params_for` (model and param building), `owner_association`/`required_attribute`/`required_error` (model-specific fixtures and assertions), `finder_key` (custom-finder param), and `policy_class`/`serializer_class`.
* The base examples are now HTML-aware: they branch on the `html:` option and assert the rendered template/redirect instead of a JSON body, so one set of examples per action works for both API and server-rendered controllers. Removed the now-redundant `simple crud for ... with html` variants.
* The HTML/block/finder/scope/build examples are controller-agnostic: they issue requests by action name instead of hardcoded routes, so they work for namespaced and nested controllers without editing paths.
* Infer `html: true` in the metadata when a block is passed to `simple_crud_for` (unless `html` is set explicitly), so block-form server-rendered actions are asserted as HTML by the shared examples instead of JSON. JSON-rendering blocks can pass `html: false` explicitly.
* Add `params_key` (default `nil`) so apps using nested strong params (`params.require(:classroom).permit(...)`) can have the shared examples wrap create/update request bodies under the model's params key instead of posting flat params.
* Add `unauthenticated_status` (default `:unauthorized`, so redirect-based auth apps can expect a `302` instead) and `assert_html_template` (default `true`, so apps whose rendered template name doesn't match the action can drop the `render_template` assertion).
* Add `simple crud for new` to the standard set and extract the shared auth contexts (`simple crud without authenticated user`, `simple crud when not authorized`, `simple crud renders template`).
* Document adoption in the README with a `SimpleCrud::RSpec.configure` example. Tested across Rails 6.1-8.1.

### V0.5.0
* Add a `build:` option to `:new` and `:create` for building owner-scoped or nested records (`current_user.classrooms.build`, `@classroom.assignments.build`). The lambda runs with the controller as `self`; `:create` assigns the permitted params to the built record before saving.
* Add HTML mode to `:destroy`: `html: true` redirects to the collection on success (re-rendering `show.html.erb` if a callback aborts the destroy), and a render block receives `(record, destroyed)`.
* Document the `authenticate`/`authorize` coupling: authorization only runs when `authenticate: true`, so non-Devise apps must define `authenticate_user!` and `current_user` for `authorize: true` to do anything.
* Add shared examples and dummy coverage for `build:` and HTML destroy (`simple crud for new/create with build`, `simple crud for destroy with html/block`). Tested across Rails 6.1-8.1.

### V0.4.0
* Extend HTML rendering (via `html: true` or a render block) to the remaining actions so server-rendered apps can use the gem end to end:
  * `:show` renders `show.html.erb` with the record exposed as `@record`.
  * `:new` builds a new record, authorizes it, and renders `new.html.erb` (or returns it as JSON in API mode).
  * `:create`/`:update` redirect to the record on success and re-render the form (`new`/`edit`) with the errors on failure.
* Render blocks now receive the records (`:index`), the record (`:show`/`:new`), or the record plus a `saved` flag (`:create`/`:update`) and override the auto-render.
* Add shared examples and dummy-app coverage for each new HTML form (`simple crud for new`, `... with html`/`... with block` for show/new/create/update).
* Extract the shared auth contexts (`simple crud without authenticated user`, `simple crud when not authorized`) to remove duplicated shared-example setup. Tested across Rails 6.1-8.1.

### V0.3.0
* Support server-rendered (HTML) apps: `:index` can render an ERB template via `html: true` (exposing the paginated records as `@records`) or a render block that receives the records, while still honoring pagination.
* Allow a custom record finder on `:show`, `:update` and `:destroy` via `finder:` (a `Proc`/`lambda` invoked with the controller's params, or a `Symbol` naming a class method on the model). Defaults to `klass.find(params[:id])` and still returns `not_found` when no record is found.
* Scope `:index` by current user when `authorize: true`: paginate the Pundit `policy_scope` of the model (falling back to the full relation when no `Scope` is defined) instead of `klass.all`, with a per-action `scope: ->(user) { ... }` override. Add `policy_scope` to the authorization adapter interface (defaults to the full relation).
* Return `422` with `{ errors: [...] }` on validation failure in `:create` and `:update` instead of raising. Keep strict `create!`/`update!` semantics behind the optional `raise_on_invalid: true` flag.
* Add `paginated_records` to the pagination adapter interface so HTML-mode `:index` can fetch the current page's records without rendering (implemented for wor-paginate, Kaminari, will_paginate and Pagy).
* Add shared examples and dummy-app coverage for each new option (`simple crud for index with html/block/scope`, `... with finder`, `simple crud not found with finder`, `authorization adapter #authorize`); the `create`/`update` examples now cover the `422` response.
* Refactor `SimpleCrudController` helpers into `SimpleCrud::ControllerHelpers`, dedupe repeated test code, and require `rails-controller-testing` for `render_template` assertions. Tested across Rails 6.1-8.1.

### V0.2.1
* Rename the published gem from `simple_crud` to `wor-simple_crud`. `simple_crud` is already taken on RubyGems by an unrelated gem, and RubyGems also rejects names that differ from an existing one only by hyphen/underscore (so `simple-crud` was rejected too). Install with `gem 'wor-simple_crud', require: 'simple_crud'` (the require path is unchanged).
* Drop the last Wolox references now that this gem lives at icoluccio/simple-crud, and point the wor-paginate link and CI/gem badges at their new homes.
* Support Rails 6.1 through 8.1 (previously untested past very old Rails/Ruby versions): add an Appraisal-based test matrix, replace Travis CI with GitHub Actions, and drop the abandoned `devise_jwt_controllers` and `fictium` dependencies, which capped Rails compatibility at old versions.
* Fix several bugs found while getting the CRUD shared examples to 100% coverage (authorization checks that never actually ran, mismatched test fixtures, a dead `SimpleCrud.configure` that always raised).
* Add an overcommit pre-push hook (RuboCop + full spec suite) and tighten `.rubocop.yml` to the default cop set.
* Make both authorization and pagination pluggable via `SimpleCrud::Authorization::Adapter` / `SimpleCrud::Pagination::Adapter` (`SimpleCrud.configure { |c| c.authorization_adapter = ...; c.pagination_adapter = ... }`). Pundit and wor-paginate remain the defaults but are no longer hard dependencies of the gem: an app that sets `authorize: false` / `paginate: false` everywhere needs neither installed. Ship CanCanCan and Action Policy as ready-to-use authorization adapters, and Kaminari, will_paginate, and Pagy as ready-to-use pagination adapters (none of the six libraries is a hard dependency, require the one you use).

### V0.1
Release!
