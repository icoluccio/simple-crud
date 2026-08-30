## Change log

### V0.4.0

Breaking:
* Blocks given to `simple_crud_for` no longer imply `html: true`. HTML controllers with render blocks must pass `html: true` explicitly.

New options:
* `authenticate_headers:` controls whether shared examples set auth headers and run the unauthorized test, independent of `authenticate:`. Defaults to `authenticate:`. Set `authenticate: false, authenticate_headers: true` when a base-controller `before_action` handles auth so the lambda skips the call but tests still cover the auth path.
* `simple_crud_defaults(options)` sets option defaults at the controller level. Subclasses inherit. Per-action options override. Precedence: gem defaults < controller defaults < per-action options.

Fixes:
* Use `RSpec.shared_examples` instead of the top-level alias, which is unavailable with `config.disable_monkey_patching!`.
* Auto-require `SimpleCrud::Authorization::Adapter` on `require 'simple_crud'`.
* Remove `cattr_accessor :params, :permitted` (thread-unsafe, never read by the gem). Remove the `set_params` boilerplate from host controllers.
* Raise a clear error when `owner_association` names an attribute the model doesn't have, instead of a bare `NoMethodError` from FactoryBot.

### V0.3.1

Shared examples configuration:
* Every setting can be overridden per controller or per example via `simple_crud:` RSpec metadata. Metadata takes precedence over `SimpleCrud::RSpec.configure` and the defaults, and all reads happen at example runtime, so per-resource tweaks need no around hooks, no global mutation and no restore logic.
* New `model_attributes` setting (default: `{ owner_association => current_user }`) decides how records are built for the examples, so multi-key (`{ user:, project: }`), non-user-owned (`{ project: project }`) or owner-less models work without editing the shared examples.
* Dedicated examples (`*_with_block`, `*_with_build`, `*_with_scope`) no longer assume the gem's dummy app: request params derive from `params_for`/`owner_params`, authentication wraps conditionally on the action's `authenticate:` option, and render-block actions are asserted on status and persistence effects only (a block's response body is app-defined by definition).
* The finder/build dedicated families (`show/update/destroy with finder`, `not found with finder`, `new with build`) adapt to each action's declared options too: render-block actions are asserted success-only, `html: true` actions assert the rendered template or redirect, and plain JSON keeps the status/body assertions. Server-rendered apps no longer need to skip these families.
* `index with scope` builds its records through new `scoped_attributes` (default: `model_attributes`) and `other_scoped_attributes` (default: `model_attributes.merge(owner_association => other_user)`) settings instead of hardcoding `owner_association => user`, so factories without that attribute keep working and multi-key models express their scope via metadata. The assertion follows the controller: `assigns(:records)` ids for `html: true`, the wor-paginate envelope for paginated JSON, and the bare serialized array otherwise.
* Actions declared with a render block expose `block: true` in the controller metadata, and the shared examples treat them accordingly: failure/invalid paths assert persistence effects only (the block decides how the response is rendered), while default flows keep their pinned statuses/templates.
* The base destroy example covers the failure path (record always kept; non-block flows respond 422 as JSON or re-render `show` as HTML).
* New optional `created_record_check` setting: a lambda receiving the persisted record in the create/update success paths, to assert ownership/scope that `count == 1` alone can't catch.

### V0.3.0

Server-rendered (HTML) support:
* `html: true` or a render block on every action: `:index` renders `index.html.erb` with the paginated records as `@records`; `:show`/`:new` expose `@record`; `:create`/`:update` redirect to the record on success and re-render the form with errors on failure; `:destroy` redirects to the collection (re-rendering `show.html.erb` when a callback aborts). Blocks receive the records (`:index`), the record (`:show`/`:new`) or `(record, saved)` (`:create`/`:update`/`:destroy`) and override the auto-render.
* New `:new` action: builds a record, authorizes it, and renders `new.html.erb` (or returns JSON in API mode).

Custom lookups, scoping and building:
* `finder:` on `:show`/`:update`/`:destroy`/`:edit`: a `Proc`/lambda invoked with the controller's params, or a `Symbol` naming a class method on the model. Defaults to `klass.find(params[:id])`.
* New `simple_crud_for :edit`: the find-instead-of-build twin of `:new`. It looks the record up (honoring `finder:`), authorizes it and renders `edit.html.erb` with `@record` in HTML mode, returning the record as JSON otherwise. A matching `simple crud for edit` shared example covers the authorized/denied, not-found and html/json/block paths.
* `build:` on `:new`/`:create` for owner-scoped or nested builds (`current_user.projects.build`); runs with the controller as `self`, and `:create` assigns the permitted params to the built record before saving.
* With `authorize: true`, `:index` paginates the Pundit `policy_scope` of the model (falling back to the full relation when no `Scope` is defined) instead of `klass.all`, with a per-action `scope: ->(user[, params]) { ... }` override.
* `redirect:` on HTML-mode `:create`/`:update`/`:destroy`: a `Proc` called with the record, or a literal path, overriding the default success redirect.

Validation errors:
* `:create` returns `201` / `422 { errors: [...] }` and `:update` returns `200` / `422` instead of raising; `raise_on_invalid: true` keeps strict `create!`/`update!` semantics.

Authorization changes:
* Breaking: `authorize: true` now always enforces policy checks, including for `authenticate: false` actions, which reach policies with a `nil` user. Policies must tolerate a `nil` user.
* Breaking: `:index` authorizes the model class instead of an unsaved instance, matching the Pundit/CanCanCan collection conventions. `index?` policies can no longer inspect record state (there is none), so write them against the user.
* `SimpleCrud::Config.user_method` (default `:current_user`) selects the controller method providing the user to policies and scope lambdas, so apps with other conventions (`current_admin`, ...) need no shims.

Adapter interfaces:
* Authorization adapters gain `policy_scope`; pagination adapters gain `paginated_records`, so HTML-mode `:index` can fetch the current page without rendering. Both are implemented by every shipped adapter (Pundit, CanCanCan, Action Policy / wor-paginate, Kaminari, will_paginate, Pagy).

Fixes:
* Kaminari adapter: string query params corrupted offsets (`?page=3&per_page=10` resolved to `OFFSET 1010`), and `per_page` now respects `Kaminari.config.max_per_page`.
* Custom finders returning anything but a single record raise `ActiveRecord::RecordNotFound` instead of failing later with an obscure error.
* Invalid `simple_crud_for` usage (unknown action, missing policy, missing serializer) raises `ArgumentError` instead of throwing uncatchable string tags.

Testing library:
* The shared examples are a reusable library: configure via `SimpleCrud::RSpec.configure`, wire up explicitly with `SimpleCrud::RSpec.install!`. Every app-specific assumption has an overridable default matching the gem's own stack (Devise-JWT + FactoryBot + Pundit + AMS): `authenticate`/`current_user`/`other_user`, `create_record`/`create_records`/`params_for`, `owner_association`/`required_attribute`/`required_error`, `finder_key`, `params_key`, `route_params`, `invalid_status`, `unauthenticated_status`, `assert_html_template`, `policy_class`, `serializer_class`.
* Examples are HTML-aware (branching on the `html:` option, inferring it for block-form actions) and issue requests by action name, so one set covers API and server-rendered controllers, namespaced and nested routes alike.
* Refactor `SimpleCrudController` helpers into `SimpleCrud::ControllerHelpers`, dedupe repeated test code, and require `rails-controller-testing` for template assertions. Tested across Rails 6.1-8.1.

### V0.2.1
* Rename the published gem from `simple_crud` to `wor-simple_crud`. `simple_crud` is already taken on RubyGems by an unrelated gem, and RubyGems also rejects names that differ from an existing one only by hyphen/underscore (so `simple-crud` was rejected too). Install with `gem 'wor-simple_crud', require: 'simple_crud'` (the require path is unchanged).
* Drop the last Wolox references now that this gem lives at icoluccio/simple-crud, and point the wor-paginate link and CI/gem badges at their new homes.
* Support Rails 6.1 through 8.1 (previously untested past very old Rails/Ruby versions): add an Appraisal-based test matrix, replace Travis CI with GitHub Actions, and drop the abandoned `devise_jwt_controllers` and `fictium` dependencies, which capped Rails compatibility at old versions.
* Fix several bugs found while getting the CRUD shared examples to 100% coverage (authorization checks that never actually ran, mismatched test fixtures, a dead `SimpleCrud.configure` that always raised).
* Add an overcommit pre-push hook (RuboCop + full spec suite) and tighten `.rubocop.yml` to the default cop set.
* Make both authorization and pagination pluggable via `SimpleCrud::Authorization::Adapter` / `SimpleCrud::Pagination::Adapter` (`SimpleCrud.configure { |c| c.authorization_adapter = ...; c.pagination_adapter = ... }`). Pundit and wor-paginate remain the defaults but are no longer hard dependencies of the gem: an app that sets `authorize: false` / `paginate: false` everywhere needs neither installed. Ship CanCanCan and Action Policy as ready-to-use authorization adapters, and Kaminari, will_paginate, and Pagy as ready-to-use pagination adapters (none of the six libraries is a hard dependency, require the one you use).

### V0.1
Release!
