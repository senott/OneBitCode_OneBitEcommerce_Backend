require 'rails_helper'

RSpec.describe 'Admin::V1::Licenses as :admin', type: :request do
  let(:user) { create(:user) }
  let(:url) { '/admin/v1/licenses' }

  describe 'GET /licenses' do
    let!(:licenses) { create_list(:license, 5) }

    it 'should return all licenses' do
      get url, headers: auth_header(user)
      expect(body_json['licenses']).to contain_exactly(*licenses.as_json(only: %i[id key]))
    end

    it 'returns status code 200' do
      get url, headers: auth_header(user)
      expect(response.status).to eq(200)
    end
  end

  describe 'POST /licenses' do
    context 'with valid params' do
      let!(:game) { create(:game) }
      let(:license_params) { attributes_for(:license, game_id: game.id).to_json }

      it 'should create a new license' do
        expect do
          post url, headers: auth_header(user), params: license_params
        end.to change(License, :count).by(1)
      end

      it 'should return the license created' do
        post url, headers: auth_header(user), params: license_params
        expected_license = License.last.as_json(only: %i[id key])
        expect(body_json['license']).to eq(expected_license)
      end

      it 'should return status code 200' do
        post url, headers: auth_header(user), params: license_params
        expect(response.status).to eq(200)
      end
    end

    context 'with invalid params' do
      let!(:game) { create(:game) }
      let(:license_invalid_params) { attributes_for(:license, key: nil, game_id: game.id).to_json }

      it 'should not create a new license' do
        expect do
          post url, headers: auth_header(user), params: license_invalid_params
        end.to_not change(License, :count)
      end

      it 'should return an error message' do
        post url, headers: auth_header(user), params: license_invalid_params
        expect(body_json['errors']['fields']).to have_key('key')
      end

      it 'should return unprocessable entity status code' do
        post url, headers: auth_header(user), params: license_invalid_params
        expect(response.status).to eq(422)
      end
    end
  end

  describe 'PATCH /licenses/:id' do
    let(:license) { create(:license) }
    let(:url) { "/admin/v1/licenses/#{license.id}" }

    context 'with valid params' do
      let(:new_key) { 'My new key' }
      let(:license_params) { { license: { key: new_key } }.to_json }

      it 'should update license key' do
        patch url, headers: auth_header(user), params: license_params
        license.reload
        expect(license.key).to eq(new_key)
      end

      it 'should return updated license' do
        patch url, headers: auth_header(user), params: license_params
        license.reload
        expected_license = license.as_json(only: %i[id key])
        expect(body_json['license']).to eq(expected_license)
      end

      it 'should return status code 200' do
        patch url, headers: auth_header(user), params: license_params
        expect(response.status).to eq(200)
      end
    end

    context 'with invalid params' do
      let(:license_invalid_params) { attributes_for(:license, key: nil).to_json }

      it 'should not update license' do
        old_key = license.key
        patch url, headers: auth_header(user), params: license_invalid_params
        license.reload
        expect(license.key).to eq(old_key)
      end

      it 'should return an error message' do
        patch url, headers: auth_header(user), params: license_invalid_params
        expect(body_json['errors']['fields']).to have_key('key')
      end

      it 'should return unprocessable entity status code' do
        patch url, headers: auth_header(user), params: license_invalid_params
        expect(response.status).to eq(422)
      end
    end
  end

  describe 'DELETE /licenses/:id' do
    let!(:license) { create(:license) }

    context 'with valid parameter' do
      let(:url) { "/admin/v1/licenses/#{license.id}" }

      it 'should remove the license' do
        expect do
          delete url, headers: auth_header(user)
        end.to change(License, :count).by(-1)
      end

      it 'should return status code 204' do
        delete url, headers: auth_header(user)
        expect(response.status).to eq(204)
      end

      it 'should not return any body content' do
        delete url, headers: auth_header(user)
        expect(body_json).to_not be_present
      end
    end

    context 'with invalid parameter' do
      let(:url) { '/admin/v1/licenses/invalid-id' }

      it 'should not remove the license' do
        expect do
          delete url, headers: auth_header(user)
        end.to_not change(License, :count)
      end

      it 'should return an error message' do
        delete url, headers: auth_header(user)
        expect(body_json['errors']['message']).to eq('Could not find license.')
      end

      it 'should return unprocessable entity status code' do
        delete url, headers: auth_header(user)
        expect(response.status).to eq(422)
      end
    end
  end
end
