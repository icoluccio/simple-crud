## Change log

### Unreleased
* Drop the last Wolox references now that this gem lives at icoluccio/simple-crud; point the wor-paginate link and CI/gem badges at their new homes.
* Support Rails 6.1 through 8.1 (previously untested past very old Rails/Ruby versions): add an Appraisal-based test matrix, replace Travis CI with GitHub Actions, and drop the abandoned `devise_jwt_controllers` and `fictium` dependencies that hard-capped Rails compatibility.
* Fix several latent bugs surfaced while getting the CRUD shared examples to 100% coverage (authorization checks that never actually ran, mismatched test fixtures, a dead `SimpleCrud.configure` that always raised).
* Add an overcommit pre-push hook (RuboCop + full spec suite) and tighten `.rubocop.yml` to the default cop set.
* `simple_crud` now `require`s `pundit` and `wor/paginate` itself, so consumers no longer need to add them to their own Gemfile or manually `require 'wor/paginate'` just to make the documented ApplicationController setup work.
* Make the authorization backend pluggable via `SimpleCrud::Authorization::Adapter` (`SimpleCrud.configure { |c| c.authorization_adapter = ... }`); Pundit remains the default, zero-setup-required adapter.

### V0.1
Release!
