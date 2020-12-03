require 'rails_helper'

RSpec.describe 'Auth::V1::Users', type: :request do
  let(:url) { '/auth/v1/user' }

  describe 'PATCH /user_registration' do
    let(:user) { create(:user, profile: :client) }
    let(:url) { '/auth/v1/user/' }

    context 'with valid params' do
      let(:new_name) { 'New User' }
      let(:user_params) { { name: new_name }.to_json }

      before(:each) { patch url, headers: auth_header(user), params: user_params }

      it 'should update user name' do
        user.reload
        expect(user.name).to eq(new_name)
      end

      it 'should return updated user' do
        user.reload
        expected_user = user.as_json(only: %i[id name email])
        expect(body_json['data']).to include(expected_user)
      end

      it 'should return status code 200' do
        expect(response.status).to eq(200)
      end
    end

    context 'with invalid params' do
      let(:user_invalid_params) { attributes_for(:user, name: nil).to_json }

      before(:each) { patch url, headers: auth_header(user), params: user_invalid_params }

      it 'should not update system requirement' do
        old_name = user.name
        user.reload
        expect(user.name).to eq(old_name)
      end

      it 'should return an error message' do
        expect(body_json['errors']).to have_key('name')
      end

      it 'should return unprocessable entity status code' do
        expect(response.status).to eq(422)
      end
    end
  end
end
