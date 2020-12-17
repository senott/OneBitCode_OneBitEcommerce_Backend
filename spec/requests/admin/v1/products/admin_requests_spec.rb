require 'rails_helper'

RSpec.describe 'Admin V1 Products as :admin', type: :request do
  let(:user) { create(:user) }

  describe 'GET /products' do
    let(:url) { '/admin/v1/products' }
    let(:categories) { create_list(:category, 2) }
    let!(:products) { create_list(:product, 10, categories: categories) }

    before(:each) { get url, headers: auth_header(user) }

    context 'without any params' do
      it 'should return 10 records' do
        expect(body_json['products'].count).to eq(10)
      end

      it 'should return Products with :productable following default pagination' do
        expected_return = products[0..9].map do |product|
          build_game_product_json(product)
        end

        expect(body_json['products']).to contain_exactly(*expected_return)
      end

      it 'should return success status' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with search[name] param' do
      let!(:search_name_products) do
        products = []
        15.times { |n| products << create(:product, name: "Search #{n + 1}") }
        products
      end

      let(:search_params) { { search: { name: 'Search' } } }

      before(:each) { get url, headers: auth_header(user), params: search_params }

      it 'should return only searched products limited by default pagination' do
        expected_return = search_name_products[0..9].map do |product|
          build_game_product_json(product)
        end

        expect(body_json['products']).to contain_exactly(*expected_return)
      end

      it 'should return success status' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with pagination params' do
      let(:page) { 2 }
      let(:length) { 5 }

      let(:pagination_params) { { page: page, length: length } }

      before(:each) { get url, headers: auth_header(user), params: pagination_params }

      it 'should return records sized by :length' do
        expect(body_json['products'].count).to eq(length)
      end

      it 'should return records limited by pagination' do
        expected_return = products[5..9].map do |product|
          build_game_product_json(product)
        end

        expect(body_json['products']).to contain_exactly(*expected_return)
      end

      it 'should return success status' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with order params' do
      let(:order_params) { { order: { name: 'desc' } } }

      before(:each) { get url, headers: auth_header(user), params: order_params }

      it 'should return ordered products limited by default pagination' do
        products.sort! { |a, b| b.name <=> a.name }
        expected_return = products[0..9].map do |product|
          build_game_product_json(product)
        end

        expect(body_json['products']).to contain_exactly(*expected_return)
      end

      it 'should return success status' do
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'POST /products' do
    let(:url) { '/admin/v1/products' }
    let(:categories) { create_list(:category, 2) }
    let(:system_requirement) { create(:system_requirement) }
    let(:post_header) { auth_header(user, merge_with: { 'Content-Type' => 'multipart/form-date' }) }

    context 'with valid params' do
      let(:game_params) { attributes_for(:game, system_requirement_id: system_requirement.id) }
      let(:product_params) do
        { product: attributes_for(:product).merge(category_ids: categories.map(&:id))
                                             .merge(productable: 'game').merge(game_params) }
      end

      it 'should create a new product' do
        expect do
          post url, headers: post_header, params: product_params
        end.to change(Product, :count).by(1)
      end

      it 'should create a new productable' do
        expect do
          post url, headers: post_header, params: product_params
        end.to change(Game, :count).by(1)
      end

      it 'should associate categories to product' do
        post url, headers: post_header, params: product_params

        expect(Product.last.categories.ids).to contain_exactly(*categories.map(&:id))
      end

      it 'should return last added product' do
        post url, headers: post_header, params: product_params
        expected_product = build_game_product_json(Product.last)

        expect(body_json['product']).to eq(expected_product)
      end

      it 'should return success status' do
        post url, headers: post_header, params: product_params

        expect(response).to have_http_status(:ok)
      end
    end

    context 'with invalid product params' do
      let(:game_params) { attributes_for(:game, system_requirement_id: system_requirement.id) }
      let(:product_invalid_params) do
        { product: attributes_for(:product, name: nil).merge(category_ids: categories.map(&:id))
                                                      .merge(productable: "game").merge(game_params) }
      end

      it 'should not add a new product' do
        expect do
          post url, headers: post_header, params: product_invalid_params
        end.not_to change(Product, :count)
      end

      it 'should not add a new productable' do
        expect do
          post url, headers: post_header, params: product_invalid_params
        end.not_to change(Game, :count)
      end

      it 'should not create ProductCategory' do
        expect do
          post url, headers: post_header, params: product_invalid_params
        end.not_to change(ProductCategory, :count)
      end

      it 'should return error message' do
        post url, headers: post_header, params: product_invalid_params
        expect(body_json['errors']['fields']).to have_key('name')
      end

      it 'should return unprocessable entity status' do
        post url, headers: post_header, params: product_invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'with invalid productable params' do
      let(:game_params) { attributes_for(:game, developer: '', system_requirement_id: system_requirement.id) }
      let(:productable_invalid_params) do
        { product: attributes_for(:product).merge(category_ids: categories.map(&:id))
                                           .merge(productable: "game").merge(game_params) }
      end

      it 'should not add a new product' do
        expect do
          post url, headers: post_header, params: productable_invalid_params
        end.not_to change(Product, :count)
      end

      it 'should not add a new productable' do
        expect do
          post url, headers: post_header, params: productable_invalid_params
        end.not_to change(Game, :count)
      end

      it 'should not create ProductCategory' do
        expect do
          post url, headers: post_header, params: productable_invalid_params
        end.not_to change(ProductCategory, :count)
      end

      it 'should return error message' do
        post url, headers: post_header, params: productable_invalid_params
        expect(body_json['errors']['fields']).to have_key('developer')
      end

      it 'should return unprocessable entity status' do
        post url, headers: post_header, params: productable_invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'without productable params' do
      let(:product_without_productable_params) do
        { product: attributes_for(:product).merge(category_ids: categories.map(&:id)) }
      end

      it 'should not add a new product' do
        expect do
          post url, headers: post_header, params: product_without_productable_params
        end.not_to change(Product, :count)
      end

      it 'should not add a new productable' do
        expect do
          post url, headers: post_header, params: product_without_productable_params
        end.not_to change(Game, :count)
      end

      it 'should not create ProductCategory' do
        expect do
          post url, headers: post_header, params: product_without_productable_params
        end.not_to change(ProductCategory, :count)
      end

      it 'should return error message' do
        post url, headers: post_header, params: product_without_productable_params
        expect(body_json['errors']['fields']).to have_key('productable')
      end

      it 'should return unprocessable entity status' do
        post url, headers: post_header, params: product_without_productable_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'GET /products/:id' do
    let(:product) { create(:product) }
    let(:url) { "/admin/v1/products/#{product.id}" }

    before(:each) { get url, headers: auth_header(user) }

    it 'should return requested product' do
      expected_product = build_game_product_json(product)

      expect(body_json['product']).to eq(expected_product)
    end

    it 'should return success status' do
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PATCH /products/:id' do
    let(:old_categories) { create_list(:category, 2) }
    let(:new_categories) { create_list(:category, 2) }
    let(:product) { create(:product, categories: old_categories) }
    let(:system_requirement) { create(:system_requirement) }
    let(:url) { "/admin/v1/products/#{product.id}" }
    let(:patch_header) { auth_header(user, merge_with: { 'Content-Type' => 'multipart/form-data' }) }

    context 'with valid product params' do
      let(:new_name) { 'New Name' }
      let(:game_params) { attributes_for(:game, system_requirement_id: system_requirement.id) }
      let(:product_params) do
        { product: attributes_for(:product, name: new_name).merge(category_ids: new_categories.map(&:id))
                                                           .merge(productable: "game").merge(game_params) }
      end

      before(:each) { patch url, headers: patch_header, params: product_params }

      it 'should update product' do
        product.reload
        expect(product.name).to eq(new_name)
      end

      it 'should update the categories' do
        product.reload
        expect(product.categories.ids).to contain_exactly(*new_categories.map(&:id))
      end

      it 'should return updated product' do
        product.reload
        expected_product = build_game_product_json(product)
        expect(body_json['product']).to eq(expected_product)
      end

      it 'should return success status' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with invalid product params' do
      let(:product_invalid_params) do
        { product: attributes_for(:product, name: nil).merge(category_ids: new_categories.map(&:id)) }
      end
      let(:old_name) { product.name }

      before(:each) { patch url, headers: patch_header, params: product_invalid_params }

      it 'should not update product' do
        product.reload
        expect(product.name).to eq(old_name)
      end

      it 'should not update categories' do
        product.reload
        expect(product.categories.ids).to contain_exactly(*old_categories.map(&:id))
      end

      it 'should return error message' do
        expect(body_json['errors']['fields']).to have_key('name')
      end

      it 'should return unprocessable entity status' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'with invalid productable params' do
      let(:productable_invalid_params) do
        { product: attributes_for(:game, developer: nil) }
      end
      let(:old_developer) { product.productable.developer }

      before(:each) { patch url, headers: patch_header, params: productable_invalid_params }

      it 'should not update productable' do
        product.productable.reload
        expect(product.productable.developer).to eq(old_developer)
      end

      it 'should return error message' do
        expect(body_json['errors']['fields']).to have_key('developer')
      end

      it 'should return unprocessable entity status' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'without productable params' do
      let(:new_name) { 'New Name' }
      let(:product_without_productable_params) do
        { product: attributes_for(:product, name: new_name).merge(category_ids: new_categories.map(&:id)) }
      end

      before(:each) { patch url, headers: patch_header, params: product_without_productable_params }

      it 'should update product' do
        product.reload
        expect(product.name).to eq(new_name)
      end

      it 'should update the categories' do
        product.reload
        expect(product.categories.ids).to contain_exactly(*new_categories.map(&:id))
      end

      it 'should return updated product' do
        product.reload
        expected_product = build_game_product_json(product)
        expect(body_json['product']).to eq(expected_product)
      end

      it 'should return success status' do
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'DELETE /products/:id' do
    let(:productable) { create(:game) }
    let!(:product) { create(:product, productable: productable) }
    let(:url) { "/admin/v1/products/#{product.id}" }

    it 'should remove the product' do
      expect do
        delete url, headers: auth_header(user)
      end.to change(Product, :count).by(-1)
    end

    it 'should remove productable' do
      expect do
        delete url, headers: auth_header(user)
      end.to change(Game, :count).by(-1)
    end

    it 'returns no content status' do
      delete url, headers: auth_header(user)
      expect(response).to have_http_status(:no_content)
    end

    it 'should not return body content' do
      delete url, headers: auth_header(user)
      expect(body_json).to_not be_present
    end

    it 'should remove all associated ProductCategories' do
      product_categories = create_list(:product_category, 3, product: product)
      delete url, headers: auth_header(user)
      expected_product_categories = ProductCategory.where(id: product_categories.map(&:id))

      expect(expected_product_categories.count).to eq(0)
    end

    it 'should not remove unassociated ProductCategories' do
      product_categories = create_list(:product_category, 3)
      delete url, headers: auth_header(user)
      present_product_categories_ids = product_categories.map(&:id)
      expected_product_categories = ProductCategory.where(id: present_product_categories_ids)

      expect(expected_product_categories.ids).to contain_exactly(*present_product_categories_ids)
    end
  end
end

def build_game_product_json(product)
  json = product.as_json(only: %i[id name description price status])
  json['categories'] = product.categories.map(&:name)
  json['image_url'] = rails_blob_url(product.image)
  json['productable'] = product.productable_type.underscore
  json.merge product.productable.as_json(only: %i[mode release_date developer])
end
