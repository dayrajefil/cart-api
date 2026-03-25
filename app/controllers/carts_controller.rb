class CartsController < ApplicationController
  before_action :set_cart, only: [:show, :add_item, :remove_item]
  before_action :validate_quantity, only: [:create, :add_item]

  rescue_from ActiveRecord::RecordInvalid do |e|
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
  end

  rescue_from ActiveRecord::RecordNotFound do |e|
    render json: { errors: [e.message] }, status: :not_found
  end

  def show
    render json: cart_payload(@cart)
  end

  def create
    @cart = Cart.find_or_initialize_by(id: session[:cart_id])

    if @cart.new_record?
      @cart.save!
      session[:cart_id] = @cart.id
    end

    add_or_update_item(@cart, params[:product_id], params[:quantity].to_i)
    @cart.recalculate_total

    render json: cart_payload(@cart), status: :created
  end

  def add_item
    add_or_update_item(@cart, params[:product_id], params[:quantity].to_i)
    @cart.recalculate_total

    render json: cart_payload(@cart), status: :ok
  end

  def remove_item
    cart_item = @cart.cart_items.find_by(product_id: params[:product_id])

    return render json: { errors: ["Product not found in cart"] }, status: :not_found unless cart_item

    cart_item.destroy!
    @cart.recalculate_total

    render json: cart_payload(@cart), status: :ok
  end

  private

  def validate_quantity
    quantity = params[:quantity].to_i
    render json: { errors: ["Quantity must be greater than 0"] }, status: :unprocessable_entity unless quantity > 0
  end

  def set_cart
    @cart = Cart.find_by(id: session[:cart_id])
    render json: { errors: ["Cart not found"] }, status: :not_found unless @cart
  end

  def add_or_update_item(cart, product_id, quantity)
    cart_item = cart.cart_items.find_or_initialize_by(product_id: product_id)
    cart_item.quantity = cart_item.new_record? ? quantity : cart_item.quantity + quantity
    cart_item.save!
  end

  def cart_payload(cart)
    {
      id: cart.id,
      products: cart.cart_items.map { |item|
        {
          id: item.product.id,
          name: item.product.name,
          quantity: item.quantity,
          unit_price: item.product.price,
          total_price: item.total_price
        }
      },
      total_price: cart.total_price
    }
  end
end
