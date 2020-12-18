require 'rails_helper'

RSpec.describe 'Admin::V1::Licenses without authentication', type: :request do
  let(:url) { '/admin/v1/licenses' }

  describe 'GET /licenses' do
    let!(:licenses) { create_list(:license, 5) }

    before(:each) { get url }

    include_examples 'unauthenticated access'
  end

  describe 'GET /licenses/:id' do
    let!(:license) { create(:license) }
    let(:url) { "/admin/v1/licenses/#{license.id}" }

    before(:each) { get url }

    include_examples 'unauthenticated access'
  end

  describe 'POST /licenses' do
    let(:license_params) { attributes_for(:license).to_json }

    before(:each) { post url, params: license_params }

    include_examples 'unauthenticated access'
  end

  describe 'PATCH /licenses/:id' do
    let(:license) { create(:license) }
    let(:url) { "/admin/v1/licenses/#{license.id}" }
    let(:new_key) { 'My new key' }
    let(:license_params) { { license: { key: new_key } }.to_json }

    before(:each) { patch url, params: license_params  }

    include_examples 'unauthenticated access'
  end

  describe 'DELETE /licenses/:id' do
    let!(:license) { create(:license) }
    let(:url) { "/admin/v1/licenses/#{license.id}" }

    before(:each) { delete url }

    include_examples 'unauthenticated access'
  end
end
