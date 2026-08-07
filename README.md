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

before_action :set_params

def set_params
  SimpleCrudController.params = params
end
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
```

Each method supports different options, as in:
```
simple_crud_for :index, paginate: false, authorize: false, serializer: CustomSerializer
```

- Paginate: whether it should paginate or not. `true` paginates via the configured pagination adapter (wor-paginate by default), `false` doesn't paginate
- Authorize: whether it should check authorization via the configured authorization adapter (Pundit by default)
- Authenticate: whether it should use Devise to check for a current_user
- Serializer: specify a particular serializer you should use
- Html: renders the action's ERB template instead of JSON (valid for `:index`, `:show`, `:new`, `:create`, `:update` and `:destroy`). Only meaningful in controllers that render templates
- Finder: only valid for `:show`, `:update` and `:destroy`. A `Proc`/`lambda` (invoked with the controller's params) or a `Symbol` naming a class method on the model, used to look up the record instead of `klass.find(params[:id])`
- Scope: only valid for `:index`. A `Proc`/`lambda` taking `current_user` (plus the controller's `params` if it takes a second argument) that returns the relation to list, overriding the default `policy_scope`
- Build: only valid for `:new` and `:create`. A `Proc`/`lambda` that builds the record (invoked with the controller as `self`, so `current_user`, `params` and any instance variables are available), for building nested or owner-scoped records like `current_user.classrooms.build`. `:create` then assigns the permitted params to the built record before saving
- Raise_on_invalid: only valid for `:create` and `:update`. Keeps the strict `create!`/`update!` semantics (raising on invalid input) instead of returning `422` with the validation errors

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

> **Note:** authorization only runs when `authenticate: true` (the default) — `maybe_authorize` skips the check unless a `current_user` is present. Devise provides `authenticate_user!` and `current_user` for you; non-Devise apps must define both themselves for `authorize: true` to have any effect (and use `authenticate: false` when there's no notion of a signed-in user).

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

When `authorize: true`, the `:index` action paginates the Pundit `policy_scope` of the model (falling back to the full relation when no `Scope` is defined) instead of `klass.all`, so "only my records" scoping works out of the box. Override the scope per action with the `scope:` option, a callable that receives `current_user` (and the controller's `params` when it takes a second argument):

```ruby
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
SimpleCrud will assume a current_user method. Future versions will support a custom model. Defining a current_user method in ApplicationController should work if you're using a different model, as of now.

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
- `:create` saves and redirects to the created record on success, or re-renders `new.html.erb` (with `@record` and its errors) on failure.
- `:update` saves and redirects to the record on success, or re-renders `edit.html.erb` on failure.
- `:destroy` destroys and redirects to the collection (`redirect_to Model`) on success, or re-renders `show.html.erb` if a callback aborts the destroy.

```ruby
simple_crud_for :index, html: true
simple_crud_for :show, html: true
simple_crud_for :new, html: true
simple_crud_for :create, html: true
simple_crud_for :update, html: true
simple_crud_for :destroy, html: true
```

Or pass a block that renders explicitly, overriding the auto-render. The block receives the records for `:index`, the record for `:show`/`:new`, or the record plus a saved flag for `:create`/`:update`/`:destroy`. Passing a block also implies `html: true` for the shared examples (so a server-rendered block is asserted as HTML); if your block renders JSON instead, pass `html: false` explicitly:

```ruby
simple_crud_for :index do |records|
  render :index, locals: { models: records }
end

simple_crud_for :create do |record, saved|
  saved ? redirect_to(record) : render(:new, locals: { model: record })
end
```

#### Build
`simple_crud_for :new` and `simple_crud_for :create` build the record with `klass.new`, which can't express owner-scoped or nested records (`current_user.classrooms.build`, `@classroom.assignments.build`). Pass a `build:` lambda — it runs with the controller as `self`, so `current_user`, `params` and any instance variables set by a `before_action` are available:

```ruby
simple_crud_for :new, build: -> { current_user.classrooms.build }
simple_crud_for :create, build: -> { current_user.classrooms.build }
```

`:create` assigns the permitted params to the built record before saving, so the owner/parent association survives. `:update` keeps finding the record via the `finder:`.

#### Finder
Slug-based (or otherwise custom) record lookups are supported on `:show`, `:update` and `:destroy`. Pass a `Proc`/`lambda` that maps the controller's `params` to a record, or a `Symbol` naming a class method on the model that takes the params:

```ruby
simple_crud_for :show, finder: ->(params) { Model.find_by!(slug: params[:slug]) }
simple_crud_for :update, finder: :find_by_slug
```

When omitted it defaults to `klass.find(params[:id])`, and `not_found` is still returned whenever the finder finds no record.

### Shared examples
While optional, using the included shared examples saves you from writing the standard test cases for the methods. You can even use them if you didn't use `simple_crud_for`, as a set of basic tests. To include them, just add `require 'simple_crud/rspec'` to your `rails_helper.rb` file and add the lines you need to your `*_spec.rb` files:
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

The `create` and `update` examples cover the `422` response with validation errors (skipped when `raise_on_invalid: true`), and all base examples adapt to `html: true` controllers (asserting the rendered template/redirect instead of JSON). Controllers using the extra options can include their dedicated examples too:

```ruby
include_examples 'simple crud for new'                    # the :new action
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
The shared examples assume the gem's own stack by default (Devise-JWT authentication, FactoryBot, Pundit, ActiveModel Serializers). If your app differs, configure them once in `spec/spec_helper.rb` (or `rails_helper.rb`):

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

  # The owner association and the validation this app's models enforce.
  config.owner_association = :instructor
  config.required_attribute = :title
  config.required_error = "Title can't be blank"

  # Redirect-based apps: unauthenticated requests get a redirect, not a 401.
  # And if the rendered template name doesn't match the action, drop the
  # render_template assertion.
  config.unauthenticated_status = :found
  config.assert_html_template = false

  # Server-rendered apps usually use nested strong params
  # (params.require(:classroom).permit(:name)); wrap request bodies under the
  # model's params key instead of posting flat params.
  config.params_key = :classroom

  # Pundit policy and serializer class lookup.
  config.policy_class = ->(klass) { "#{klass}Policy".constantize }
  config.serializer_class = ->(model) { "#{model.class}Serializer".constantize }
end
```

Each setting has a sensible default, so you only override what differs. Callable settings (`current_user`, `authenticate`, `create_record`, `create_records`, `params_for`, `policy_class`, `serializer_class`) run in the example-group context, so they can call `request`, `create`, `current_user`, etc. The examples are controller-agnostic (they issue requests by action name, not hardcoded paths), so they work for namespaced and nested controllers alike. If you keep `assert_html_template` on (the default), add `gem 'rails-controller-testing'` for the `render_template` matcher.

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
