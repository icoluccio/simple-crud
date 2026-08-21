# THINGS_TO_DO

Feedback from adopting the shared examples in a real consumer app
(`classroom`: server-rendered HTML, session auth, nested slug routes, Pundit,
render blocks everywhere). Written for the agent working on this gem.

Verified against branch `metadata-driven-shared-examples` @ `543fb24`.

## Status

| Item | State |
|---|---|
| Metadata-first settings resolution (`simple_crud:` → global → default) | ✅ done |
| `model_attributes` setting | ✅ done |
| Generic dedicated examples (`*_with_block/build/scope`) | ✅ done |
| `created_record_check` hook (create/update success) | ✅ done, adopted by the app |
| Destroy-failure context | ✅ done — block-aware (`check_block`), regression fixture in `spec/block_redirect` |
| TODO 2 guards on create/update invalid contexts | ✅ done — persistence-only assertions for block actions |

## TODO 1 (blocking): destroy-failure context pins the response shape for block actions

**Fixed**: `simple_crud_for` writes `block: true` into the controller metadata,
the shared examples skip status/template assertions for block actions
(persistence-only),
and `spec/block_redirect` reproduces the redirect-on-failure case.

Repro from the consumer app — a destroy declared with a block:

```ruby
simple_crud_for :destroy do |enrollment, destroyed|
  if destroyed
    redirect_to classrooms_path, notice: ...
  else
    redirect_to enrollment.classroom, alert: ...   # failure path redirects -> 302
  end
end
```

Including `'simple crud for destroy'` fails the new context with:

```
expected the response to have status code :ok (200) but it was :found (302)
```

Cause: the context branches only on `check_html(:destroy)`. The HTML path pins
`'simple crud renders template', :show` at `:ok`, which matches the *default*
non-block flow (`render options[:failure_template]`) but not blocks. This
contradicts the rule PR #16 itself established ("a block's response body/status
is app-defined by definition"), which `create_with_block` already follows.

Fix — three small changes:

```ruby
# 1. lib/simple_crud/simple_crud_controller.rb, in simple_crud_for, before write_metadata:
parameters[:block] = true if block

# 2. lib/simple_crud/rspec/helpers.rb, add :block to the check_* option list:
%i[paginate authorize authenticate serializer html finder scope build raise_on_invalid block].each do |option|

# 3. lib/spec/shared_examples/simple_crud_for_destroy.rb, failure context — keep the
#    universal persistence assertion, make shape assertions block-aware:
it 'keeps the record' do
  expect(model_class_object.exists?(model.id)).to be true
end

unless check_block(:destroy)
  if check_html(:destroy)
    include_examples 'simple crud renders template', :show
  else
    it 'responds with unprocessable entity' do
      expect(response).to have_http_status(unprocessable_status)
    end
  end
end
```

Add a regression test in the gem's own dummy suite: a controller using
`simple_crud_for :destroy do |record, destroyed| ... end` whose failure path
redirects, asserting 302 + record kept.

## TODO 2 (same pass): base create/update invalid contexts have the same latent issue

The invalid-input contexts pin template + status (`invalid_status`) whenever
`check_html` is true — including block-rendering actions. A block that
*redirects* on invalid input would fail them today. Apply the same
`check_block` guard there (blocks get persistence-only assertions; non-blocks
keep the current pinned statuses). The consumer app passes today only because
its create/update blocks happen to re-render with 422.

## Context: how the app consumes the examples (no action needed)

Per-controller adoption via metadata, e.g.:

```ruby
RSpec.describe AssignmentsController, type: :controller, simple_crud: {
  current_user: -> { classroom.instructor },
  model_attributes: -> { { classroom: classroom } },
  route_params: -> { { classroom_slug: classroom.slug } },
  params_key: :assignment,
  created_record_check: ->(record) { expect(record.classroom).to eq(classroom) }
} do
  let(:classroom) { create(:classroom) }
  include_examples "simple crud for index"
  include_examples "simple crud for new"
  include_examples "simple crud for show"
end
```

App-side cleanups enabled once TODO 1 lands: delete the hand-written
failed-destroy test (flash-message assertion on that path would be dropped),
and optionally convert two more hand-written CRUD-ish controllers
(`ClassroomsController#index` via the index block form; `#edit/#update` via
`simple_crud_for :update, finder: ->(p) { Classroom.find_by!(slug: p[:slug]) },
html: true`).

Command-shaped actions (join/enroll guards with distinct flash reasons,
`update_role`, accept/review/export/grade) stay hand-written on purpose: they
are not generated CRUD actions, and collapsing their behavior into a generic
403 would be a UX regression.
