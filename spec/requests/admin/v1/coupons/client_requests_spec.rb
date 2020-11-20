require 'rails_helper'

RSpec.describe 'Admin::V1::Coupons as :client', type: :request do
  let(:user) { create(:user, profile: :client) }
  let(:url) { '/admin/v1/coupons' }

  describe 'GET /coupons' do
    let!(:coupons) { create_list(:coupon, 5) }

    before(:each) { get url, headers: auth_header(user) }

    include_examples 'forbidden access'
  end

  describe 'POST /coupons' do
    let(:coupon_params) { attributes_for(:coupon).to_json }

    before(:each) { post url, headers: auth_header(user), params: coupon_params }

    include_examples 'forbidden access'
  end

  describe 'PATCH /coupons/:id' do
    let(:coupon) { create(:coupon) }
    let(:url) { "/admin/v1/coupons/#{coupon.id}" }
    let(:new_name) { 'My new coupon' }
    let(:coupon_params) { { coupon: { name: new_name } }.to_json }

    before(:each) { patch url, headers: auth_header(user), params: coupon_params  }

    include_examples 'forbidden access'
  end

  describe 'DELETE /coupons/:id' do
    let!(:coupon) { create(:coupon) }
    let(:url) { "/admin/v1/coupons/#{coupon.id}" }

    before(:each) { delete url, headers: auth_header(user) }

    include_examples 'forbidden access'
  end
end