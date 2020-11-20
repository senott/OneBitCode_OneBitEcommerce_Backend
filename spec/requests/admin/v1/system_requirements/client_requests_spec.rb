require 'rails_helper'

RSpec.describe 'Admin::V1::SystemRequirements as :client', type: :request do
  let(:user) { create(:user, profile: :client) }
  let(:url) { '/admin/v1/system_requirements' }

  describe 'GET /categories' do
    let!(:system_requirements) { create_list(:system_requirement, 5) }

    before(:each) { get url, headers: auth_header(user) }

    include_examples 'forbidden access'
  end

  describe 'POST /system_requirements' do
    let(:system_requirement_params) { attributes_for(:system_requirement).to_json }

    before(:each) { post url, headers: auth_header(user), params: system_requirement_params }
    
    include_examples 'forbidden access'
  end

  describe 'PATCH /system_requirements/:id' do
    let(:system_requirement) { create(:system_requirement) }
    let(:url) { "/admin/v1/system_requirements/#{system_requirement.id}" }
    let(:new_name) { 'New System Requirement' }
    let(:system_requirement_params) { { system_requirement: { name: new_name } }.to_json }

    before(:each) { patch url, headers: auth_header(user), params: system_requirement_params  }

    include_examples 'forbidden access'
  end

  describe 'DELETE /system_requirements/:id' do
    let!(:system_requirement) { create(:system_requirement) }
    let(:url) { "/admin/v1/system_requirements/#{system_requirement.id}" }

    before(:each) { delete url, headers: auth_header(user) }

    include_examples 'forbidden access'
  end
end