require 'rails_helper'

RSpec.describe 'Admin V1 Products without authenticated user', type: :request do
  let(:user) { create(:user, profile: :client) }

  describe 'GET /products' do
    let(:url) { '/admin/v1/products' }
    let(:products) { create_list(:product, 5) }

    before(:each) { get url }

    include_examples 'unauthenticated access'
  end

  describe 'POST /products' do
    let(:url) { '/admin/v1/products' }

    before(:each) { get url }

    include_examples 'unauthenticated access'
  end

  describe 'GET /products/:id' do
    let(:product) { create(:product) }
    let(:url) { "/admin/v1/products/#{product.id}" }

    before(:each) { get url }

    include_examples 'unauthenticated access'
  end

  describe 'PATCH /products/:id' do
    let(:product) { create(:product) }
    let(:url) { "/admin/v1/products/#{product.id}" }

    before(:each) { patch url }

    include_examples 'unauthenticated access'
  end

  describe 'DELETE /products/:id' do
    let!(:product) { create(:product) }
    let(:url) { "/admin/v1/products/#{product.id}" }

    before(:each) { delete url }

    include_examples 'unauthenticated access'
  end
end
