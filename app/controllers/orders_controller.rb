class OrdersController < ApplicationController
	skip_before_filter :verify_authenticity_token

	def create
		puts params

		headers['Access-Control-Allow-Origin'] = '*'

		order = ShopifyAPI::Order.new
		name = params["purchase_order"]["name"].split(' ')

		order.email = params["purchase_order"]["email"]
		order.note_attributes = [{name: 'Phone Number', value: params["purchase_order"]["phone"]}] if !params["purchase_order"]["phone"].blank?
		order.note = params["purchase_order"]["special_instructions"]
		order.tags = 'purchase_order'
		order.send_receipt = true
		order.financial_status = 'pending'
		order.customer = {}
		order.customer["email"] = params["purchase_order"]["email"]
		order.customer["first_name"] = name.first
		order.customer["last_name"] = name.last if name.length > 1
		order.line_items = []
		for item in params["purchase_order"]["items"]
			properties_hash = []

			for p in item["properties"]
				properties_hash << {
					"name": p.first,
					"value": p.last
				}
			end

			order.line_items << {
				"variant_id": item["id"],
				"quantity": item["quantity"],
				"properties": properties_hash
			}
		end

		if order.save
			render json: order
		else
			render json: { errors: order.errors }
		end
	end
end