require 'rails_helper'

RSpec.describe "/carts", type: :request do
  pending "TODO: Escreva os testes de comportamento do controller de carrinho necessários para cobrir a sua implmentação #{__FILE__}"

  # NOTE: Teste original usava Cart.create e CartItem.create diretamente, sem sessão.
  # Atualizado para criar o carrinho via API (POST /cart), pois o README define que
  # o cart_id deve ser salvo na sessão. Rota corrigida de /add_items para /add_item
  # conforme especificação do README.
  describe "POST /add_item" do
    let(:product) { Product.create(name: "Test Product", price: 10.0) }

    before do
      post '/cart', params: { product_id: product.id, quantity: 1 }, as: :json
    end

    context 'when the product already is in the cart' do
      subject do
        post '/cart/add_item', params: { product_id: product.id, quantity: 1 }, as: :json
        post '/cart/add_item', params: { product_id: product.id, quantity: 1 }, as: :json
      end

      it 'updates the quantity of the existing item in the cart' do
        cart_item = CartItem.find_by(product_id: product.id)
        expect { subject }.to change { cart_item.reload.quantity }.by(2)
      end
    end
  end
end
