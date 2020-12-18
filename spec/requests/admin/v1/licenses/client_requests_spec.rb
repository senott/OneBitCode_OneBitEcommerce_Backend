require 'rails_helper'

RSpec.describe 'Admin::V1::Licenses as :client', type: :request do
  let(:user) { create(:user, profile: :client) }
  let(:url) { '/admin/v1/licenses' }

  describe 'GET /licenses' do
    let!(:licenses) { create_list(:license, 5) }

    before(:each) { get url, headers: auth_header(user) }

    include_examples 'forbidden access'
  end

  describe 'POST /licenses' do
    let(:license_params) { attributes_for(:license).to_json }

    before(:each) { post url, headers: auth_header(user), params: license_params }

    include_examples 'forbidden access'
  end

  describe 'PATCH /licenses/:id' do
    let(:license) { create(:license) }
    let(:url) { "/admin/v1/licenses/#{license.id}" }
    let(:new_key) { 'My new key' }
    let(:license_params) { { license: { name: new_key } }.to_json }

    before(:each) { patch url, headers: auth_header(user), params: license_params }

    include_examples 'forbidden access'
  end

  describe 'DELETE /licenses/:id' do
    let!(:license) { create(:license) }
    let(:url) { "/admin/v1/licenses/#{license.id}" }

    before(:each) { delete url, headers: auth_header(user) }

    include_examples 'forbidden access'
  end
end
