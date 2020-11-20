require 'rails_helper'

RSpec.describe 'Admin::V1::SystemRequirements without authentication', type: :request do
  let(:url) { '/admin/v1/system_requirements' }

  describe 'GET /system_requirements' do
    let!(:system_requirements) { create_list(:system_requirement, 5) }

    before(:each) { get url }

    include_examples 'unauthenticated access'
  end

  describe 'POST /system_requirements' do
    let(:system_requirement_params) { attributes_for(:system_requirement).to_json }

    before(:each) { post url, params: system_requirement_params }
    
    include_examples 'unauthenticated access'
  end

  describe 'PATCH /system_requirements/:id' do
    let(:system_requirement) { create(:system_requirement) }
    let(:url) { "/admin/v1/system_requirements/#{system_requirement.id}" }
    let(:new_name) { 'New System Requirement' }
    let(:system_requirement_params) { { system_requirement: { name: new_name } }.to_json }

    before(:each) { patch url, params: system_requirement_params  }

    include_examples 'unauthenticated access'
  end

  describe 'DELETE /system_requirements/:id' do
    let!(:system_requirement) { create(:system_requirement) }
    let(:url) { "/admin/v1/system_requirements/#{system_requirement.id}" }

    before(:each) { delete url }

    include_examples 'unauthenticated access'
  end
end