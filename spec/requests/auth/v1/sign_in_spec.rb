require 'rails_helper'

RSpec.describe 'Auth::V1::Users::SignIn', type: :request do
  let(:url) { '/auth/v1/user/sign_in' }
  let(:user) { create(:user) }

  describe 'POST /sign_in' do
    context 'with valid params' do
      before(:each) { post url, params: { email: user.email, password: user.password } }

      it 'should sign in the user' do
        expect(response.has_header?('access-token')).to be_truthy
      end

      it 'should return the logged user' do
        expected_user = user.as_json(only: %i[id name email])
        expect(body_json['data']).to include(expected_user)
      end

      it 'should return status code 200' do
        expect(response.status).to eq(200)
      end
    end

    context 'with invalid params' do
      before(:each) { post url, params: { email: 'invalid-email', password: user.password } }

      it 'should not sign in the user' do
        expect(response.has_header?('access-token')).to be_falsey
      end

      it 'should return an error message' do
        expect(body_json['errors']).to include('E-mail ou senha inválidos.')
      end

      it 'should return unauthorized status code' do
        expect(response.status).to eq(401)
      end
    end
  end
end