require 'rails_helper'

RSpec.describe 'Admin::V1::Categories without authentication', type: :request do
  let(:url) { '/admin/v1/categories' }

  describe 'GET /categories' do
    let!(:categories) { create_list(:category, 5) }

    before(:each) { get url }

    include_examples 'unauthenticated access'
  end

  describe 'POST /categories' do
    let(:category_params) { attributes_for(:category).to_json }

    before(:each) { post url, params: category_params }
    
    include_examples 'unauthenticated access'
  end

  describe 'PATCH /categories/:id' do
    let(:category) { create(:category) }
    let(:url) { "/admin/v1/categories/#{category.id}" }
    let(:new_name) { 'My new category' }
    let(:category_params) { { category: { name: new_name } }.to_json }

    before(:each) { patch url, params: category_params  }

    include_examples 'unauthenticated access'
  end

  describe 'DELETE /categories/:id' do
    let!(:category) { create(:category) }
    let(:url) { "/admin/v1/categories/#{category.id}" }

    before(:each) { delete url }

    include_examples 'unauthenticated access'
  end
end