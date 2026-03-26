require 'rails_helper'

RSpec.describe "/products", type: :request do
  let(:valid_attributes) { { name: 'A product', price: 1 } }
  let(:invalid_attributes) { { price: -1 } }

  describe "GET /products" do
    it "returns a successful response" do
      Product.create!(valid_attributes)
      get products_url, as: :json
      expect(response).to be_successful
    end

    it "returns products as an array" do
      Product.create!(valid_attributes)
      get products_url, as: :json
      expect(JSON.parse(response.body)).to be_an(Array)
    end
  end

  describe "GET /products/:id" do
    it "returns a successful response" do
      product = Product.create!(valid_attributes)
      get product_url(product), as: :json
      expect(response).to be_successful
    end

    it "returns not found for nonexistent product" do
      get product_url(id: 0), as: :json
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /products" do
    context "with valid parameters" do
      it "creates a new Product" do
        expect {
          post products_url, params: { product: valid_attributes }, as: :json
        }.to change(Product, :count).by(1)
      end

      it "returns status created" do
        post products_url, params: { product: valid_attributes }, as: :json
        expect(response).to have_http_status(:created)
      end

      it "returns json content type" do
        post products_url, params: { product: valid_attributes }, as: :json
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with invalid parameters" do
      it "does not create a new Product" do
        expect {
          post products_url, params: { product: invalid_attributes }, as: :json
        }.not_to change(Product, :count)
      end

      it "returns status unprocessable entity" do
        post products_url, params: { product: invalid_attributes }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns json content type" do
        post products_url, params: { product: invalid_attributes }, as: :json
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end
  end

  describe "PATCH /products/:id" do
    let(:new_attributes) { { name: 'Another name', price: 2 } }

    context "with valid parameters" do
      it "updates the product name" do
        product = Product.create!(valid_attributes)
        patch product_url(product), params: { product: new_attributes }, as: :json
        expect(product.reload.name).to eq('Another name')
      end

      it "updates the product price" do
        product = Product.create!(valid_attributes)
        patch product_url(product), params: { product: new_attributes }, as: :json
        expect(product.reload.price).to eq(2)
      end

      it "returns status ok" do
        product = Product.create!(valid_attributes)
        patch product_url(product), params: { product: new_attributes }, as: :json
        expect(response).to have_http_status(:ok)
      end

      it "returns json content type" do
        product = Product.create!(valid_attributes)
        patch product_url(product), params: { product: new_attributes }, as: :json
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with invalid parameters" do
      it "returns status unprocessable entity" do
        product = Product.create!(valid_attributes)
        patch product_url(product), params: { product: invalid_attributes }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns json content type" do
        product = Product.create!(valid_attributes)
        patch product_url(product), params: { product: invalid_attributes }, as: :json
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end
  end

  describe "DELETE /products/:id" do
    it "destroys the requested product" do
      product = Product.create!(valid_attributes)
      expect {
        delete product_url(product), as: :json
      }.to change(Product, :count).by(-1)
    end

    it "returns no content status" do
      product = Product.create!(valid_attributes)
      delete product_url(product), as: :json
      expect(response).to have_http_status(:no_content)
    end
  end
end
