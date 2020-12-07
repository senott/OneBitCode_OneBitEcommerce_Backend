require 'rails_helper'

RSpec.describe 'Admin::V1::Categories as :client', type: :request do
  let(:user) { create(:user, profile: :client) }
  let(:url) { '/admin/v1/categories' }

  describe 'GET /categories' do
    let!(:categories) { create_list(:category, 5) }

    before(:each) { get url, headers: auth_header(user) }

    include_examples 'forbidden access'
  end

  describe 'GET /categories/:id' do
    let(:category) { create(:category) }
    let(:url) { "/admin/v1/categories/#{category.id}" }

    before(:each) { get url, headers: auth_header(user) }

    include_examples 'forbidden access'
  end

  describe 'POST /categories' do
    let(:category_params) { attributes_for(:category).to_json }

    before(:each) { post url, headers: auth_header(user), params: category_params }
    
    include_examples 'forbidden access'
  end

  describe 'PATCH /categories/:id' do
    let(:category) { create(:category) }
    let(:url) { "/admin/v1/categories/#{category.id}" }
    let(:new_name) { 'My new category' }
    let(:category_params) { { category: { name: new_name } }.to_json }

    before(:each) { patch url, headers: auth_header(user), params: category_params  }

    include_examples 'forbidden access'
  end

  describe 'DELETE /categories/:id' do
    let!(:category) { create(:category) }
    let(:url) { "/admin/v1/categories/#{category.id}" }

    before(:each) { delete url, headers: auth_header(user) }

    include_examples 'forbidden access'
  end
end