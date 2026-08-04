## Change log

### V0.2
* Rename the published gem from `simple_crud` to `simple-crud`. That name is already taken on RubyGems by an unrelated gem; `simple-crud` is not. Install with `gem 'simple-crud', require: 'simple_crud'` (the require path is unchanged).
* Drop the last Wolox references now that this gem lives at icoluccio/simple-crud, and point the wor-paginate link and CI/gem badges at their new homes.
* Support Rails 6.1 through 8.1 (previously untested past very old Rails/Ruby versions): add an Appraisal-based test matrix, replace Travis CI with GitHub Actions, and drop the abandoned `devise_jwt_controllers` and `fictium` dependencies, which capped Rails compatibility at old versions.
* Fix several bugs found while getting the CRUD shared examples to 100% coverage (authorization checks that never actually ran, mismatched test fixtures, a dead `SimpleCrud.configure` that always raised).
* Add an overcommit pre-push hook (RuboCop + full spec suite) and tighten `.rubocop.yml` to the default cop set.
* Make both authorization and pagination pluggable via `SimpleCrud::Authorization::Adapter` / `SimpleCrud::Pagination::Adapter` (`SimpleCrud.configure { |c| c.authorization_adapter = ...; c.pagination_adapter = ... }`). Pundit and wor-paginate remain the defaults but are no longer hard dependencies of the gem: an app that sets `authorize: false` / `paginate: false` everywhere needs neither installed. Ship CanCanCan and Action Policy as ready-to-use authorization adapters, and Kaminari, will_paginate, and Pagy as ready-to-use pagination adapters (none of the six libraries is a hard dependency, require the one you use).

### V0.1
Release!
