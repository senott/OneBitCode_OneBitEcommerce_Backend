require 'rails_helper'

RSpec.describe 'Admin::V1::SystemRequirements as :admin', type: :request do
  let(:user) { create(:user) }
  let(:url) { '/admin/v1/system_requirements' }

  describe 'GET /system_requirements' do
    let!(:system_requirements) { create_list(:system_requirement, 5) }

    it 'should return all categories' do
      get url, headers: auth_header(user)
      expect(body_json['system_requirements']).to contain_exactly(*system_requirements.as_json(only: %i[id name operational_system storage processor memory video_board]))
    end

    it 'returns status code 200' do
      get url, headers: auth_header(user)
      expect(response.status).to eq(200)
    end
  end

  describe 'POST /system_requirements' do
    context 'with valid params' do
      let(:system_requirement_params) { attributes_for(:system_requirement).to_json }

      it 'should create a new system requirement' do
        expect do
          post url, headers: auth_header(user), params: system_requirement_params
        end.to change(SystemRequirement, :count).by(1)
      end

      it 'should return the system requirement created' do
        post url, headers: auth_header(user), params: system_requirement_params
        expected_system_requirement = SystemRequirement.last.as_json(only: %i[id name operational_system storage processor memory video_board])
        expect(body_json['system_requirement']).to eq(expected_system_requirement)
      end

      it 'should return status code 200' do
        post url, headers: auth_header(user), params: system_requirement_params
        expect(response.status).to eq(200)
      end
    end

    context 'with invalid params' do
      let(:system_requirement_invalid_params) { attributes_for(:system_requirement, name: nil).to_json }

      it 'should not create a new system requirement' do
        expect do
          post url, headers: auth_header(user), params: system_requirement_invalid_params
        end.to_not change(SystemRequirement, :count)
      end

      it 'should return an error message' do
        post url, headers: auth_header(user), params: system_requirement_invalid_params
        expect(body_json['errors']['fields']).to have_key('name')
      end

      it 'should return unprocessable entity status code' do
        post url, headers: auth_header(user), params: system_requirement_invalid_params
        expect(response.status).to eq(422)
      end
    end
  end

  describe 'PATCH /system_requirements/:id' do
    let(:system_requirement) { create(:system_requirement) }
    let(:url) { "/admin/v1/system_requirements/#{system_requirement.id}" }

    context 'with valid params' do
      let(:new_name) { 'New system requirement' }
      let(:system_requirement_params) { { system_requirement: { name: new_name } }.to_json }

      it 'should update system requirement name' do
        patch url, headers: auth_header(user), params: system_requirement_params
        system_requirement.reload
        expect(system_requirement.name).to eq(new_name)
      end

      it 'should return updated system requirement' do
        patch url, headers: auth_header(user), params: system_requirement_params
        system_requirement.reload
        expected_system_requirement = system_requirement.as_json(only: %i[id name operational_system storage processor memory video_board])
        expect(body_json['system_requirement']).to eq(expected_system_requirement)
      end

      it 'should return status code 200' do
        patch url, headers: auth_header(user), params: system_requirement_params
        expect(response.status).to eq(200)
      end
    end

    context 'with invalid params' do
      let(:system_requirement_invalid_params) { attributes_for(:system_requirement, name: nil).to_json }

      it 'should not update system requirement' do
        old_name = system_requirement.name
        patch url, headers: auth_header(user), params: system_requirement_invalid_params
        system_requirement.reload
        expect(system_requirement.name).to eq(old_name)
      end

      it 'should return an error message' do
        patch url, headers: auth_header(user), params: system_requirement_invalid_params
        expect(body_json['errors']['fields']).to have_key('name')
      end

      it 'should return unprocessable entity status code' do
        patch url, headers: auth_header(user), params: system_requirement_invalid_params
        expect(response.status).to eq(422)
      end
    end
  end

  describe 'DELETE /system_requirements/:id' do
    let!(:system_requirement) { create(:system_requirement) }

    context 'with valid parameter' do
      let(:url) { "/admin/v1/system_requirements/#{system_requirement.id}" }

      it 'should remove the category' do
        expect do
          delete url, headers: auth_header(user)
        end.to change(SystemRequirement, :count).by(-1)
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
      let(:url) { '/admin/v1/system_requirements/invalid-id' }

      it 'should not remove the category' do
        expect do
          delete url, headers: auth_header(user)
        end.to_not change(SystemRequirement, :count)
      end

      it 'should return an error message' do
        delete url, headers: auth_header(user)
        expect(body_json['errors']['message']).to eq('Could not find system requirement.')
      end

      it 'should return unprocessable entity status code' do
        delete url, headers: auth_header(user)
        expect(response.status).to eq(422)
      end
    end
  end
end
