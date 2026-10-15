# frozen_string_literal: true

RSpec.shared_examples 'simple crud for update with block' do
  describe 'PUT #update with a render block' do
    include_context 'with authenticated user' if check_authenticate(:update)

    let!(:record) { model }

    context 'when successfully updating a record' do
      before do
        make_policies_succeed(:update, permissive: true) if check_authorize(:update)
        put :update, params: with_route_params(body_params(model_params).merge(record_param(:update, record))),
                     format: format_param(:update)
      end

      it 'passes the saved record to the block' do
        expect(response).to satisfy('render or redirect') { |response| response.successful? || response.redirect? }
      end

      it 'updates the record' do
        expect(record.reload).to have_attributes(model_params)
      end
    end

    if invalid_case?(:update)
      context 'when updating with invalid attributes' do
        before do
          make_policies_succeed(:update, permissive: true) if check_authorize(:update)
          put :update, params: with_route_params(body_params({ required_attribute => nil }.merge(owner_params))
                                                         .merge(record_param(:update, record))),
                       format: format_param(:update)
        end

        it 'does not change the record' do
          expect(record.reload.public_send(required_attribute)).not_to be_nil
        end
      end
    end
  end
end
