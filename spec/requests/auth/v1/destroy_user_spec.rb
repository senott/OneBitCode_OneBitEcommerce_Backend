require 'rails_helper'

RSpec.describe 'Auth::V1::Users', type: :request do
  let(:url) { '/auth/v1/user' }

  describe 'DELETE /user' do
    let!(:user) { create(:user, profile: :client) }
    let!(:user_count) { User.count }

    let(:url) { '/auth/v1/user/' }

    context 'with valid params' do
      before(:each) { delete url, headers: auth_header(user) }

      it 'should delete the user' do
        expect(User.count).to eq(user_count - 1)
      end

      it 'should return success message' do
        expect(body_json['message']).to eq("A conta com uid '#{user.email}' foi excluída.") 
      end

      it 'should return status code 200' do
        expect(response.status).to eq(200)
      end
    end

    context 'with invalid params' do
      before(:each) { delete url }

      it 'should not delete the user' do
        expect(User.count).to_not eq(user_count - 1)
      end

      it 'should return an error message' do
        expect(body_json['errors'][0]).to eq('Não foi possível encontrar a conta para exclusão.')
      end

      it 'should return not found status code' do
        expect(response.status).to eq(404)
      end
    end
  end
end
