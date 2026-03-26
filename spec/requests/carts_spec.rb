require 'rails_helper'

RSpec.describe "/carts", type: :request do
  describe "GET /cart" do
    context 'when cart exists in session' do
      before { post '/cart', params: { product_id: create(:product).id, quantity: 1 }, as: :json }

      it 'returns status ok' do
        get '/cart', as: :json
        expect(response).to have_http_status(:ok)
      end

      it 'returns cart with id field' do
        get '/cart', as: :json
        expect(JSON.parse(response.body)).to include('id')
      end

      it 'returns cart with products field' do
        get '/cart', as: :json
        expect(JSON.parse(response.body)).to include('products')
      end

      it 'returns cart with total_price field' do
        get '/cart', as: :json
        expect(JSON.parse(response.body)).to include('total_price')
      end
    end

    context 'when no cart in session' do
      it 'returns not found' do
        get '/cart', as: :json
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "POST /cart" do
    let(:product) { create(:product, price: 10.0) }

    context 'with valid params' do
      it 'returns status created' do
        post '/cart', params: { product_id: product.id, quantity: 2 }, as: :json
        expect(response).to have_http_status(:created)
      end

      it 'returns the correct product quantity' do
        post '/cart', params: { product_id: product.id, quantity: 2 }, as: :json
        expect(JSON.parse(response.body)['products'].first['quantity']).to eq(2)
      end

      it 'returns the correct total_price' do
        post '/cart', params: { product_id: product.id, quantity: 2 }, as: :json
        expect(JSON.parse(response.body)['total_price'].to_f).to eq(20.0)
      end

      it 'reuses existing cart on subsequent requests' do
        post '/cart', params: { product_id: product.id, quantity: 1 }, as: :json
        expect { post '/cart', params: { product_id: create(:product).id, quantity: 1 }, as: :json }
          .not_to change { Cart.count }
      end
    end

    context 'with invalid quantity' do
      it 'returns unprocessable entity' do
        post '/cart', params: { product_id: product.id, quantity: 0 }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'with nonexistent product' do
      it 'returns not found' do
        post '/cart', params: { product_id: 999999, quantity: 1 }, as: :json
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "POST /cart/add_item" do
    let(:product) { create(:product) }

    context 'when no cart in session' do
      it 'returns not found' do
        post '/cart/add_item', params: { product_id: product.id, quantity: 1 }, as: :json
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when cart exists in session' do
      before { post '/cart', params: { product_id: product.id, quantity: 1 }, as: :json }

      context 'when the product already is in the cart' do
        it 'returns status ok' do
          post '/cart/add_item', params: { product_id: product.id, quantity: 1 }, as: :json
          expect(response).to have_http_status(:ok)
        end

        it 'updates the quantity of the existing item' do
          cart_item = CartItem.find_by(product_id: product.id)
          expect {
            post '/cart/add_item', params: { product_id: product.id, quantity: 2 }, as: :json
          }.to change { cart_item.reload.quantity }.by(2)
        end
      end

      context 'when the product is not yet in the cart' do
        let(:new_product) { create(:product) }

        it 'returns status ok' do
          post '/cart/add_item', params: { product_id: new_product.id, quantity: 3 }, as: :json
          expect(response).to have_http_status(:ok)
        end

        it 'adds the new product to the cart' do
          post '/cart/add_item', params: { product_id: new_product.id, quantity: 3 }, as: :json
          added = JSON.parse(response.body)['products'].find { |p| p['id'] == new_product.id }
          expect(added).not_to be_nil
        end

        it 'adds the product with the correct quantity' do
          post '/cart/add_item', params: { product_id: new_product.id, quantity: 3 }, as: :json
          added = JSON.parse(response.body)['products'].find { |p| p['id'] == new_product.id }
          expect(added['quantity']).to eq(3)
        end
      end

      context 'with invalid quantity' do
        it 'returns unprocessable entity' do
          post '/cart/add_item', params: { product_id: product.id, quantity: 0 }, as: :json
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end

  describe "DELETE /cart/:product_id" do
    let(:product) { create(:product) }

    context 'when no cart in session' do
      it 'returns not found' do
        delete "/cart/#{product.id}", as: :json
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when cart exists in session' do
      before { post '/cart', params: { product_id: product.id, quantity: 1 }, as: :json }

      context 'when product is in the cart' do
        it 'returns status ok' do
          delete "/cart/#{product.id}", as: :json
          expect(response).to have_http_status(:ok)
        end

        it 'removes the product from the cart' do
          delete "/cart/#{product.id}", as: :json
          expect(JSON.parse(response.body)['products']).to be_empty
        end
      end

      context 'when product is not in the cart' do
        it 'returns not found' do
          other_product = create(:product)
          delete "/cart/#{other_product.id}", as: :json
          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end

  describe "response payload structure" do
    let(:product) { create(:product, price: 20.0) }

    before { post '/cart', params: { product_id: product.id, quantity: 2 }, as: :json }

    it 'includes id field in product item' do
      item = JSON.parse(response.body)['products'].first
      expect(item).to include('id')
    end

    it 'includes name field in product item' do
      item = JSON.parse(response.body)['products'].first
      expect(item).to include('name')
    end

    it 'includes quantity field in product item' do
      item = JSON.parse(response.body)['products'].first
      expect(item).to include('quantity')
    end

    it 'includes unit_price field in product item' do
      item = JSON.parse(response.body)['products'].first
      expect(item).to include('unit_price')
    end

    it 'includes total_price field in product item' do
      item = JSON.parse(response.body)['products'].first
      expect(item).to include('total_price')
    end

    it 'returns correct unit_price for product' do
      item = JSON.parse(response.body)['products'].first
      expect(item['unit_price'].to_f).to eq(20.0)
    end

    it 'returns correct total_price for product item' do
      item = JSON.parse(response.body)['products'].first
      expect(item['total_price'].to_f).to eq(40.0)
    end
  end
end
