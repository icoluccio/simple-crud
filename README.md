SimpleCrud
=============

[![CI](https://github.com/icoluccio/simple-crud/actions/workflows/ci.yml/badge.svg)](https://github.com/icoluccio/simple-crud/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/wor-simple_crud.svg)](https://badge.fury.io/rb/wor-simple_crud)

# Table of contents
  - [Description](#description)
  - [Installation](#installation)
  - [Usage](#usage)
    - [Setup](#setup)
      - [Application controller](#application-controller)
      - [Each controller](#each-controller)
      - [Options](#options)
        - [Paginate](#paginate)
        - [Authorize](#authorize)
        - [Authenticate](#authenticate)
        - [Serializer](#serializer)
        - [HTML](#html)
        - [Finder](#finder)
        - [Cache](#cache)
      - [Controller-level defaults](#controller-level-defaults)
      - [Shared examples](#shared-examples)
  - [Contributing](#contributing)
  - [Releases](#releases)
  - [About](#about)
  - [License](#license)

-----------------------

## Description

Simple Crud is a gem for Rails that simplifies writing standard CRUD actions, while also adding tools so it's not needed to write tests for them. Its main objective is replacing generally copy-pasted code like generic paginated, authenticated index methods for simple lines such as
```ruby
simple_crud_for :index
```
It includes support for index, create, destroy, update and show, and options to specify whether it should apply pagination, authorization and if a particular serializer should be used. Keep in mind, though, that the idea is not to replace writing methods in controllers altogether, but only to replace most standard cases.

## Installation
Add the following line to your application's Gemfile. The gem is named `wor-simple_crud`, but the require path is `simple_crud`, so tell Bundler where to find it:

```ruby
gem 'wor-simple_crud', require: 'simple_crud'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install wor-simple_crud
```

simple_crud only depends on Rails itself. Authorization (Pundit by default) and pagination (wor-paginate by default) are opt-in: add whichever libraries you actually use to your own Gemfile too.

```ruby
gem 'pundit'
gem 'wor-paginate'
```

See [Paginate](#paginate) and [Authorize](#authorize) below for the other supported libraries, or to skip either feature (`authorize: false` / `paginate: false`) and depend on neither.

## Usage
### Setup
#### Application controller
Before SimpleCrud can be used, some boilerplate is needed. Add the following to your ApplicationController (or every controller in case you don't want it included in all controllers)
```ruby
include Pundit::Authorization
include Wor::Paginate
extend SimpleCrudController
```

(Skip `include Pundit::Authorization` / `include Wor::Paginate` if you're using a different adapter, or `authorize: false` / `paginate: false` everywhere.)


### Each controller
In case you need either update or create, create a method with the valid input params using standard rails:
```ruby
def author_params
  params.permit(:first_name, :email, :last_name, :institution, :role)
end
```

For the actual crud methods, just use the lines you need
```ruby
simple_crud_for :update
simple_crud_for :show
simple_crud_for :index
simple_crud_for :create
simple_crud_for :destroy
simple_crud_for :new
simple_crud_for :edit
```

Each method supports different options, as in:
```
simple_crud_for :index, paginate: false, authorize: false, serializer: CustomSerializer
```

- Paginate: whether it should paginate or not. `true` paginates via the configured pagination adapter (wor-paginate by default), `false` doesn't paginate
- Authorize: whether it should check authorization via the configured authorization adapter (Pundit by default)
- Authenticate: whether the generated action calls `authenticate_user!`. `true` (default) or `false`
- Authenticate_headers: whether shared examples set auth headers and run the unauthorized test. Defaults to `authenticate:`. Set independently when a base-controller `before_action` handles auth and the lambda should skip `authenticate_user!`
- Serializer: specify a particular serializer you should use
- Html: renders the action's ERB template instead of JSON (valid for `:index`, `:show`, `:new`, `:edit`, `:create`, `:update` and `:destroy`). Only meaningful in controllers that render templates
- Scope: only valid for `:index`. A `Proc`/`lambda` taking `current_user` (plus the controller's `params` if it takes a second argument) that returns the relation to list, overriding the default `policy_scope`. The user is resolved via `SimpleCrud::Config.user_method` (`:current_user` by default; set it to e.g. `:current_admin`)
- Finder: only valid for `:show`, `:update`, `:destroy` and `:edit`. A `Proc`/`lambda` (invoked with the controller's params) or a `Symbol` naming a class method on the model, used to look up the record instead of `klass.find(params[:id])`.
- Build: only valid for `:new` and `:create`. A `Proc`/`lambda` that builds the record (invoked with the controller as `self`, so `current_user`, `params` and any instance variables are available), for building nested or owner-scoped records like `current_user.projects.build`. `:create` then assigns the permitted params to the built record before saving
- Raise_on_invalid: only valid for `:create` and `:update`. Keeps the strict `create!`/`update!` semantics (raising on invalid input) instead of returning `422` with the validation errors
- Redirect: only valid for HTML-mode `:create`, `:update` and `:destroy`. A `Proc`/`lambda` (called with the record) or a literal path used as the success redirect target. Defaults to the record (`:create`/`:update`) or the model's collection path (`:destroy`)

#### Controller-level defaults

`simple_crud_defaults` sets option defaults for every `simple_crud_for` in the controller. Subclasses inherit; per-action options override.

```ruby
class Api::BaseController < ActionController::API
  extend SimpleCrudController
  simple_crud_defaults authorize: false, authenticate: false, authenticate_headers: true
end

class Api::PostsController < Api::BaseController
  simple_crud_for :show                    # inherits defaults
  simple_crud_for :create, authorize: true # overrides for this action only
end
```

You'll need a few things so they work correctly:

### Options
#### Paginate
Pagination defaults to [wor-paginate](https://github.com/icoluccio/wor-paginate) and needs no extra options. Check its docs if you want to customize the output.

Three other pagination libraries have adapters built in too:

```ruby
# Kaminari (https://github.com/kaminari/kaminari)
require 'simple_crud/pagination/kaminari_adapter'
SimpleCrud.configure { |config| config.pagination_adapter = SimpleCrud::Pagination::KaminariAdapter.new }

# will_paginate (https://github.com/mislav/will_paginate)
require 'simple_crud/pagination/will_paginate_adapter'
SimpleCrud.configure { |config| config.pagination_adapter = SimpleCrud::Pagination::WillPaginateAdapter.new }

# Pagy (https://github.com/ddnexus/pagy) -- requires `include Pagy::Method` in your ApplicationController
require 'simple_crud/pagination/pagy_adapter'
SimpleCrud.configure { |config| config.pagination_adapter = SimpleCrud::Pagination::PagyAdapter.new }
```

They render a plain JSON array rather than wor-paginate's `{page:, count:, total_pages:, ...}` envelope. None of the four pagination gems is installed automatically, so add whichever one you pick to your own Gemfile.

Want something else, or nothing at all? Write your own `SimpleCrud::Pagination::Adapter`:

```ruby
class MyPaginationAdapter
  include SimpleCrud::Pagination::Adapter

  # Called from inside the generated index action when paginate: true.
  # Must render the response itself.
  def paginate(controller, klass, options)
    records = klass.some_pagination_method(controller.params[:page])
    controller.render({ json: records }.merge(options))
  end
end

SimpleCrud.configure { |config| config.pagination_adapter = MyPaginationAdapter.new }
```
#### Authorize
Authorization checks go through [Pundit](https://github.com/varvet/pundit) by default. Name the policy after the model plus `Policy`, e.g. `AuthorPolicy`, written as a regular Pundit policy:

> **Note:** authorization runs whenever `authorize: true`, independently of `authenticate`. With no signed-in user the policy receives `nil` as the user, so write policies that tolerate it (e.g. `user.nil? ? false : ...`). Devise provides `authenticate_user!` and `current_user` for you; non-Devise apps must define a `current_user` (or point `SimpleCrud::Config.user_method` at their own method) for policies and `scope:` lambdas to receive the user.

```ruby
class AuthorPolicy
  attr_reader :user, :author

  def initialize(user, author)
    @user = user
    @author = author
  end

  def show?
    user.present?
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    # Used by :index to scope the listed records to the current user.
    def resolve
      @scope.where(user: @user)
    end
  end
end

```

When `authorize: true`, the `:index` action paginates the Pundit `policy_scope` of the model (falling back to the full relation when no `Scope` is defined) instead of `klass.all`, so "only my records" scoping works out of the box. Override the scope per action with the `scope:` option, a callable that receives the user resolved via `SimpleCrud::Config.user_method` (`nil` when there is none, and `params` too when it takes a second argument):

```ruby
SimpleCrud.configure { |c| c.user_method = :current_admin } # non-Devise naming conventions
simple_crud_for :index, scope: ->(user) { Model.visible_to(user) }
simple_crud_for :index, scope: ->(user, params) { Model.where(status: params[:status]).visible_to(user) }
```

Prefer CanCanCan or Action Policy instead? Both have adapters ready to go:

```ruby
# CanCanCan (https://github.com/CanCanCommunity/cancancan)
require 'simple_crud/authorization/can_can_can_adapter'
SimpleCrud.configure do |config|
  config.authorization_adapter = SimpleCrud::Authorization::CanCanCanAdapter.new
end
```

```ruby
# Action Policy (https://github.com/palkan/action_policy)
require 'simple_crud/authorization/action_policy_adapter'
SimpleCrud.configure do |config|
  config.authorization_adapter = SimpleCrud::Authorization::ActionPolicyAdapter.new
end
```

As with pagination, simple_crud ships the adapter code but not the library itself. Add `cancancan` or `action_policy` to your own Gemfile, whichever you pick.

Using something else, or skipping authorization entirely? Write your own `SimpleCrud::Authorization::Adapter`:

```ruby
class MyAuthorizationAdapter
  include SimpleCrud::Authorization::Adapter

  # Called from inside a generated CRUD action. Raise (or otherwise halt
  # the request) when the current user may not act on +record+.
  def authorize(controller, record)
    controller.authorize!(record)
  end

  # Called once, when simple_crud_for is invoked, to fail fast if the
  # given model has no authorization rules defined at all.
  def policy_defined?(model_class)
    Kernel.const_defined?("#{model_class}Policy")
  end

  # Called when rendering :index with authorize: true. Must return the
  # relation the current user is allowed to list. The default returns
  # the full relation.
  def policy_scope(controller, model_class)
    model_class.all
  end
end

SimpleCrud.configure do |config|
  config.authorization_adapter = MyAuthorizationAdapter.new
end
```

#### Authenticate
`authenticate: true` (default) calls `authenticate_user!` inside the generated action. `authenticate: false` skips it.

If your base controller already runs `before_action :authenticate_user!`, set `authenticate: false` to avoid a double call and `authenticate_headers: true` so shared examples still cover the auth path:

```ruby
simple_crud_defaults authenticate: false, authenticate_headers: true
```

#### Serializer
The name of the serializer, by default, is the name of the model followed by Serializer, as is the standard for [ActiveModelSerializers](https://github.com/rails-api/active_model_serializers). It's possible to just pass a custom serializer class though. As for the serializer itself, it's a standard serializer, with the gotcha that you need to include `:id` for the SimpleCrud examples to work.

```ruby
class AuthorSerializer < ActiveModel::Serializer
  attributes :email, :first_name, :last_name, :institution, :role, :id
end
```

#### HTML
For server-rendered apps, `html: true` renders the action's ERB template instead of JSON, so be sure the controller can render templates (e.g. `ActionController::Base`). Behavior per action:

- `:index` renders `index.html.erb` with the paginated records exposed as `@records` (pagination still applies, or use `paginate: false`).
- `:show` renders `show.html.erb` with the record exposed as `@record` (custom `finder:` still applies).
- `:new` builds a new record, authorizes it, and renders `new.html.erb` with it exposed as `@record`.
- `:edit` looks the record up (honoring `finder:`), authorizes it, and renders `edit.html.erb` with it exposed as `@record`.
- `:create` saves and redirects to the created record on success, or re-renders `new.html.erb` (with `@record` and its errors) on failure.
- `:update` saves and redirects to the record on success, or re-renders `edit.html.erb` on failure.
- `:destroy` destroys and redirects to the collection (`redirect_to Model`) on success, or re-renders `show.html.erb` if a callback aborts the destroy.

```ruby
simple_crud_for :index, html: true
simple_crud_for :show, html: true
simple_crud_for :new, html: true
simple_crud_for :edit, html: true
simple_crud_for :create, html: true
simple_crud_for :update, html: true
simple_crud_for :destroy, html: true
```

Or pass a block that renders explicitly, overriding the auto-render. The block receives the records for `:index`, the record for `:show`/`:new`, or the record plus a saved flag for `:create`/`:update`/`:destroy`. Blocks do not change the `html:` default; pass it explicitly so the shared examples know which request format to use:

```ruby
# Server-rendered block: pass html: true so shared examples send HTML requests
simple_crud_for :index, html: true do |records|
  render :index, locals: { models: records }
end

simple_crud_for :create, html: true do |record, saved|
  saved ? redirect_to(record) : render(:new, locals: { model: record })
end

# API block: html: false is the default
simple_crud_for :show, html: false do |record|
  render json: record.as_json(only: %i[id name])
end
```

#### Build
`simple_crud_for :new` and `simple_crud_for :create` build the record with `klass.new`, which can't express owner-scoped or nested records (`current_user.projects.build`, `@project.tasks.build`). Pass a `build:` lambda; it runs with the controller as `self`, so `current_user`, `params` and any instance variables set by a `before_action` are available:

```ruby
simple_crud_for :new, build: -> { current_user.projects.build }
simple_crud_for :create, build: -> { @project.tasks.build }
```

`:create` assigns the permitted params to the built record before saving, so the owner/parent association survives. `:update` keeps finding the record via the `finder:`.

#### Edit
`simple_crud_for :edit` is the find-instead-of-build twin of `:new`, the last hand-written CRUD action in server-rendered apps. It looks the record up (honoring `finder:` exactly like `:show`), authorizes it, and renders `edit.html.erb` with the record exposed as `@record`; in JSON mode it returns the record:

```ruby
simple_crud_for :edit, finder: ->(params) { Project.find_by!(slug: params[:slug]) }
```

#### Finder
By default records are looked up by primary key via `klass.find(params[:id])`. The `finder:` option on `:show`, `:update` and `:destroy` replaces that with any lookup you want: pretty URLs (`resources :posts, param: :slug`), tokens, composite keys, or scoping by a parent resource. Pass a `Proc`/`lambda` that maps the controller's `params` to a record, or a `Symbol` naming a class method on the model that takes the params:

```ruby
simple_crud_for :show, finder: ->(params) { Model.find_by!(token: params[:token]) }
simple_crud_for :update, finder: :find_by_slug
simple_crud_for :destroy, finder: ->(params) { current_user.models.find(params[:id]) }
```

When omitted it defaults to `klass.find(params[:id])`, and `not_found` is still returned whenever the finder finds no record.

#### Cache
Pass `cache: { key:, ttl: }` on `:show` or `:index` to skip the DB on cache hits.

`key` is a lambda receiving `params`, or a plain string. Both `key` and `ttl` are optional — defaults are `"#{model}:#{action}:v1:#{request.fullpath}"` and 300 seconds. With `cache:` the block must return the payload hash, not call `render`. `@record`/`@records` is set before the block, so shared examples work unchanged.

Controllers get a default `fetch_cached(key, ttl, &block)` backed by `Rails.cache`. Override to use a different store:

```ruby
# Override with a direct Redis connection
def fetch_cached(key, ttl)
  cached = redis.get(key)
  return JSON.parse(cached, symbolize_names: true) if cached

  result = yield
  redis.setex(key, ttl, result.to_json)
  result
end

# All options explicit
simple_crud_for :show,
                finder: ->(p) { Article.includes(:author).find(p[:id]) },
                cache: { key: ->(p) { "article:v1:#{p[:id]}" }, ttl: 900 } do |article|
  article_payload(article)
end

# All defaults — key and TTL inferred from model name and params
simple_crud_for :index, paginate: false, cache: {} do |articles|
  articles.map { |a| article_summary(a) }
end
```

Invalidate on write. For the default key format, `expire_simple_crud_cache(action)` deletes it without constructing it by hand:

```ruby
expire_simple_crud_cache(:show)
expire_simple_crud_cache(:index)
```

For a custom `key:` lambda, delete the key yourself:

```ruby
def update
  article = current_user.articles.find(params[:id])
  if article.update(article_params)
    redis.del("article:v1:#{article.id}")
    render json: article_payload(article)
  else
    render json: { errors: article.errors.full_messages }, status: :unprocessable_entity
  end
end
```

### Shared examples
While optional, using the included shared examples saves you from writing the standard test cases for the methods. You can even use them if you didn't use `simple_crud_for`, as a set of basic tests. To include them, add `require 'simple_crud/rspec'` to your `rails_helper.rb` **after** `require "rspec/rails"`, then add the lines you need to your `*_spec.rb` files:
```ruby
require 'rails_helper'

describe V1::Backoffice::AuthorsController do
  include_examples 'simple crud for update'
  include_examples 'simple crud for show'
  include_examples 'simple crud for create'
  include_examples 'simple crud for index'
  include_examples 'simple crud for destroy'
end
```

The `create` and `update` examples cover the `422` response with validation errors (skipped when `raise_on_invalid: true`, or whenever the action uses a render block, since the block decides how the response is rendered), and all base examples adapt to `html: true` controllers (asserting the rendered template/redirect instead of JSON). Controllers using the extra options can include their dedicated examples too:

```ruby
include_examples 'simple crud for new'                    # the :new action
include_examples 'simple crud for edit'                   # the :edit action
include_examples 'simple crud for index with block'      # render block
include_examples 'simple crud for index with scope'      # scope: ->(user) { ... }
include_examples 'simple crud for show with block'       # render block on :show
include_examples 'simple crud for new with block'        # render block on :new
include_examples 'simple crud for create with block'     # render block on :create
include_examples 'simple crud for destroy with block'    # render block on :destroy
include_examples 'simple crud for show with finder'      # finder on :show
include_examples 'simple crud for update with finder'    # finder on :update
include_examples 'simple crud for destroy with finder'   # finder on :destroy
include_examples 'simple crud for new with build'        # build: -> { ... } on :new
include_examples 'simple crud for create with build'     # build: -> { ... } on :create
```

It's not needed to specify paginate: true and such, since the shared examples will use the configuration that was originally passed to simple_crud_for

#### Adopting the shared examples
The shared examples assume the gem's own stack by default (Devise-JWT authentication, FactoryBot, Pundit, ActiveModel Serializers). Wiring is opt-in: require the file and call `SimpleCrud::RSpec.install!` in `spec/spec_helper.rb` (or `rails_helper.rb`), then configure anything your app differs on:

```ruby
SimpleCrud::RSpec.configure do |config|
  # How the current user (and a secondary "other user") is built.
  config.current_user = -> { User.create!(email: 'user@example.com', password: 'secret') }
  config.other_user = -> { User.create!(email: 'other@example.com', password: 'secret') }

  # How to sign the current user in for a request (no Devise-JWT here).
  config.authenticate = -> { request.session[:user_id] = current_user.id }

  # How records and create/update params are built (no FactoryBot here).
  config.create_record = ->(klass, attributes) { klass.create!(attributes) }
  config.create_records = ->(klass, count, attributes) { count.times.map { klass.create!(attributes) } }
  config.params_for = ->(klass) { klass.new.attributes.slice('title') }

  # The owner association used when building records for the examples
  # (model_attributes defaults to `{ owner_association => current_user }`;
  # override model_attributes directly for multi-key or non-user-owned models).
  config.owner_association = :owner
  config.model_attributes = -> { { owner: current_user } }
  config.required_attribute = :title
  config.required_error = "Title can't be blank"

  # Redirect-based apps: unauthenticated requests get a redirect, not a 401.
  # And if the rendered template name doesn't match the action, drop the
  # render_template assertion.
  config.unauthenticated_status = :found
  config.assert_html_template = false

  # Server-rendered apps usually use nested strong params
  # (params.require(:task).permit(:name)); wrap request bodies under the
  # model's params key instead of posting flat params.
  config.params_key = :task

  # Nested resources (/projects/:project_slug/tasks): extra params
  # (e.g. the parent slug) added to every request.
  config.route_params = -> { { project_slug: project.slug } }

  # Re-render the form with a 422 on validation failure (instead of 200).
  config.invalid_status = :unprocessable_entity

  # How the 'simple crud for index with scope' example builds the records
  # that match the controller's scope and the ones that must be excluded.
  # Defaults derive from model_attributes (mine) plus an owner_association
  # => other_user variant (theirs); override both when your scope keys on
  # something other than the owner association.
  config.scoped_attributes = -> { { project: project } }
  config.other_scoped_attributes = -> { { project: other_project } }

  # Pundit policy and serializer class lookup.
  config.policy_class = ->(klass) { "#{klass}Policy".constantize }
  config.serializer_class = ->(model) { "#{model.class}Serializer".constantize }

  # Optional extra assertions on the persisted record in the create/update
  # success paths (catches regressions that save into the wrong parent).
  config.created_record_check = ->(record) { expect(record.project).to eq(project) }
end
```

Each setting has a sensible default, so you only override what differs. Callable settings (`current_user`, `authenticate`, `create_record`, `create_records`, `params_for`, `model_attributes`, `scoped_attributes`, `other_scoped_attributes`, `policy_class`, `serializer_class`) run in the example-group context, so they can call `request`, `create`, `current_user`, etc.; `created_record_check` receives the persisted record. The examples are controller-agnostic (they issue requests by action name, not hardcoded paths), so they work for namespaced and nested controllers alike. If you keep `assert_html_template` on (the default), add `gem 'rails-controller-testing'` for the `render_template` matcher.

#### Per-controller overrides via metadata

Any setting can also be overridden per controller (or per example) with `simple_crud:` metadata instead of globally, useful when the app matches the defaults except for one resource. Metadata wins over global config, and every read happens at example runtime, so there are no around hooks or state to restore:

```ruby
RSpec.describe TasksController, type: :controller, simple_crud: {
  model_attributes: -> { { project: project } },
  route_params: -> { { project_slug: project.slug } }
} do
  let(:project) { create(:project, owner: current_user) }

  include_examples 'simple crud for show'
end
```

Callable settings resolve in the example context, so their lambdas can close over the spec's `let`s; that's how records land in the same project the route params point at.

## Contributing

1. Fork it
2. Run `bundle install && bundle exec appraisal generate` once, to install dependencies and generate the per-Rails-version gemfiles (`gemfiles/rails_*.gemfile`) used for testing
3. Run `bundle exec overcommit --install` once, to enable the pre-push hook (runs RuboCop and the full spec suite automatically on every `git push`)
4. Create your feature branch (`git checkout -b my-new-feature`)
5. Commit your changes (`git commit -am 'Add some feature'`)
6. Run RuboCop lint (`bundle exec rubocop lib spec --format simple`)
7. Run rspec tests (`BUNDLE_GEMFILE=gemfiles/rails_8.1.gemfile bundle exec rspec`)
8. Push your branch (`git push origin my-new-feature`). The pre-push hook re-verifies both automatically
9. Create a new Pull Request to `main` branch

## Releases
📢 [See what's changed in a recent version](https://github.com/icoluccio/simple-crud/releases)

## About ##

The current maintainer of this gem is:
* [Ignacio Coluccio](https://github.com/icoluccio)

This project was developed by:
* [Ignacio Coluccio](https://github.com/icoluccio)

Originally at Wolox

## License

**simple-crud** is available under the MIT [license](https://raw.githubusercontent.com/icoluccio/simple-crud/main/LICENSE.md).

    Copyright (c) 2017 Wolox
    Copyright (c) 2026 Ignacio Coluccio

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.
