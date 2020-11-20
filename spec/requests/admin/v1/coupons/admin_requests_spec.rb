require 'rails_helper'

RSpec.describe 'Admin::V1::Coupons as :admin', type: :request do
  let(:user) { create(:user) }
  let(:url) { '/admin/v1/coupons' }

  describe 'GET /coupons' do
    let!(:coupons) { create_list(:coupon, 5) }

    it 'should return all coupons' do
      get url, headers: auth_header(user)
      expect(body_json['coupons']).to contain_exactly(*coupons.as_json(only: %i[id code status discount_value due_date]))
    end

    it 'returns status code 200' do
      get url, headers: auth_header(user)
      expect(response.status).to eq(200)
    end
  end

  describe 'POST /coupons' do
    context 'with valid params' do
      let(:coupon_params) { attributes_for(:coupon).to_json }

      it 'should create a new coupon' do
        expect do
          post url, headers: auth_header(user), params: coupon_params
        end.to change(Coupon, :count).by(1)
      end

      it 'should return the coupon created' do
        post url, headers: auth_header(user), params: coupon_params
        expected_coupon = Coupon.last.as_json(only: %i[id code status discount_value due_date])
        expect(body_json['coupon']).to eq(expected_coupon)
      end

      it 'should return status code 200' do
        post url, headers: auth_header(user), params: coupon_params
        expect(response.status).to eq(200)
      end
    end

    context 'with invalid params' do
      let(:coupon_invalid_params) { attributes_for(:coupon, code: nil).to_json }

      it 'should not create a new coupon' do
        expect do
          post url, headers: auth_header(user), params: coupon_invalid_params
        end.to_not change(Coupon, :count)
      end

      it 'should return an error message' do
        post url, headers: auth_header(user), params: coupon_invalid_params
        expect(body_json['errors']['fields']).to have_key('code')
      end

      it 'should return unprocessable entity status code' do
        post url, headers: auth_header(user), params: coupon_invalid_params
        expect(response.status).to eq(422)
      end
    end
  end

  describe 'PATCH /coupons/:id' do
    let(:coupon) { create(:coupon) }
    let(:url) { "/admin/v1/coupons/#{coupon.id}" }

    context 'with valid params' do
      let(:new_code) { 'My new coupon' }
      let(:coupon_params) { { coupon: { code: new_code } }.to_json }

      it 'should update coupon code' do
        patch url, headers: auth_header(user), params: coupon_params
        coupon.reload
        expect(coupon.code).to eq(new_code)
      end

      it 'should return updated coupon' do
        patch url, headers: auth_header(user), params: coupon_params
        coupon.reload
        expected_coupon = coupon.as_json(only: %i[id code status discount_value due_date])
        expect(body_json['coupon']).to eq(expected_coupon)
      end

      it 'should return status code 200' do
        patch url, headers: auth_header(user), params: coupon_params
        expect(response.status).to eq(200)
      end
    end

    context 'with invalid params' do
      let(:coupon_invalid_params) { attributes_for(:coupon, code: nil).to_json }

      it 'should not update coupon' do
        old_code = coupon.code
        patch url, headers: auth_header(user), params: coupon_invalid_params
        coupon.reload
        expect(coupon.code).to eq(old_code)
      end

      it 'should return an error message' do
        patch url, headers: auth_header(user), params: coupon_invalid_params
        expect(body_json['errors']['fields']).to have_key('code')
      end

      it 'should return unprocessable entity status code' do
        patch url, headers: auth_header(user), params: coupon_invalid_params
        expect(response.status).to eq(422)
      end
    end
  end

  describe 'DELETE /coupons/:id' do
    let!(:coupon) { create(:coupon) }

    context 'with valid parameter' do
      let(:url) { "/admin/v1/coupons/#{coupon.id}" }

      it 'should remove the coupon' do
        expect do
          delete url, headers: auth_header(user)
        end.to change(Coupon, :count).by(-1)
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
      let(:url) { '/admin/v1/coupons/invalid-id' }

      it 'should not remove the coupon' do
        expect do
          delete url, headers: auth_header(user)
        end.to_not change(Coupon, :count)
      end

      it 'should return an error message' do
        delete url, headers: auth_header(user)
        expect(body_json['errors']['message']).to eq('Could not find coupon.')
      end

      it 'should return unprocessable entity status code' do
        delete url, headers: auth_header(user)
        expect(response.status).to eq(422)
      end
    end
  end
end
