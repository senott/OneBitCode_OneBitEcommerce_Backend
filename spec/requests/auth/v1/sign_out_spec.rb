require 'rails_helper'

RSpec.describe 'Auth::V1::Users::SignOut', type: :request do
  let(:url) { '/auth/v1/user/sign_out' }
  let(:user) { create(:user) }

  describe 'DELETE /sign_out' do
    context 'with valid params' do
      before(:each) { delete url, headers: auth_header(user) }

      it 'should sign out the user' do
        expect(body_json['success']).to be_truthy
      end

      it 'should return status code 200' do
        expect(response.status).to eq(200)
      end
    end

    context 'with invalid logged user' do
      before(:each) { delete url }

      it 'should not sign out the user' do
        expect(body_json['success']).to be_falsey
      end

      it 'should return an error message' do
        expect(body_json['errors']).to include('Usuário não existe ou não está logado.')
      end

      it 'should return not found status code' do
        expect(response.status).to eq(404)
      end
    end
  end
end
