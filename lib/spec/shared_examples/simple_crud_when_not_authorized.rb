# frozen_string_literal: true

shared_examples 'simple crud when not authorized' do |action, verb, request_params = {}|
  if check_authorize(action)
    context 'when not authorized' do
      include_context 'with authenticated user' if check_authenticate(action)

      before do
        make_policies_fail(action)
        send(verb, action, params: with_route_params(request_params))
      end

      it 'fails with forbidden' do
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
