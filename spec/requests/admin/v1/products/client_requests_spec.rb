require 'rails_helper'

RSpec.describe 'Admin V1 Products as :client', type: :request do
  let(:user) { create(:user, profile: :client) }

  describe 'GET /products' do
    let(:url) { '/admin/v1/products' }
    let(:products) { create_list(:product, 5) }

    before(:each) { get url, headers: auth_header(user) }

    include_examples 'forbidden access'
  end

  describe 'POST /products' do
    let(:url) { '/admin/v1/products' }

    before(:each) { get url, headers: auth_header(user) }

    include_examples 'forbidden access'
  end

  describe 'GET /products/:id' do
    let(:product) { create(:product) }
    let(:url) { "/admin/v1/products/#{product.id}" }

    before(:each) { get url, headers: auth_header(user) }

    include_examples 'forbidden access'
  end

  describe 'PATCH /products/:id' do
    let(:product) { create(:product) }
    let(:url) { "/admin/v1/products/#{product.id}" }

    before(:each) { patch url, headers: auth_header(user) }

    include_examples 'forbidden access'
  end

  describe 'DELETE /products/:id' do
    let!(:product) { create(:product) }
    let(:url) { "/admin/v1/products/#{product.id}" }

    before(:each) { delete url, headers: auth_header(user) }

    include_examples 'forbidden access'
  end
end
