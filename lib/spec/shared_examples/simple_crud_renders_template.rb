# frozen_string_literal: true

shared_examples 'simple crud renders template' do |template|
  it "renders the #{template} template", :aggregate_failures do
    expect(response).to have_http_status(:ok)
    expect(response).to render_template(template) if assert_html_template
  end
end
