require 'rails_helper'

RSpec.describe 'Auth::V1::Users', type: :request do
  let(:url) { '/auth/v1/user' }

  describe 'POST /user' do
    context 'with valid params' do
      let(:user_params) { attributes_for(:user).to_json(only: %i[name email password password_confirmation]) }

      it 'should create a new user' do
        expect do
          post url, headers: { 'Content-Type' => 'application/json' }, params: user_params
        end.to change(User, :count).by(1)
      end

      it 'should return the user created' do
        post url, headers: { 'Content-Type' => 'application/json' }, params: user_params
        expected_user = User.last.as_json(only: %i[name email])
        expect(body_json['data']['email']).to eq(expected_user['email'])
      end

      it 'should return status code 200' do
        post url, headers: { 'Content-Type' => 'application/json' }, params: user_params
        expect(response.status).to eq(200)
      end
    end

    context 'with invalid params' do
      let(:user_invalid_params) { attributes_for(:user, name: nil).to_json }

      it 'should not create a new user' do
        expect do
          post url, headers: { 'Content-Type' => 'application/json' }, params: user_invalid_params
        end.to_not change(User, :count)
      end

      it 'should return an error message' do
        post url, headers: { 'Content-Type' => 'application/json' }, params: user_invalid_params
        expect(body_json['errors']).to have_key('name')
      end

      it 'should return unprocessable entity status code' do
        post url, headers: { 'Content-Type' => 'application/json' }, params: user_invalid_params
        expect(response.status).to eq(422)
      end
    end
  end
end