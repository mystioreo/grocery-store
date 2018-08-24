require 'minitest/autorun'
require 'minitest/reporters'
require 'minitest/skip_dsl'

require_relative '../lib/customer'
require_relative '../lib/order'

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

describe "Order Wave 1" do
  let(:customer) do
    address = {
      street: "123 Main",
      city: "Seattle",
      state: "WA",
      zip: "98101"
    }
    Customer.new(123, "a@a.co", address)
  end

  describe "#initialize" do
    it "Takes an ID, collection of products, customer, and fulfillment_status" do
      id = 1337
      fulfillment_status = :shipped
      order = Order.new(id, {}, customer, fulfillment_status)

      expect(order).must_respond_to :id
      expect(order.id).must_equal id

      expect(order).must_respond_to :products
      expect(order.products.length).must_equal 0

      expect(order).must_respond_to :customer
      expect(order.customer).must_equal customer

      expect(order).must_respond_to :fulfillment_status
      expect(order.fulfillment_status).must_equal fulfillment_status
    end

    it "Accepts all legal statuses" do
      valid_statuses = %i[pending paid processing shipped complete]

      valid_statuses.each do |fulfillment_status|
        order = Order.new(1, {}, customer, fulfillment_status)
        expect(order.fulfillment_status).must_equal fulfillment_status
      end
    end

    it "Uses pending if no fulfillment_status is supplied" do
      order = Order.new(1, {}, customer)
      expect(order.fulfillment_status).must_equal :pending
    end

    it "Raises an ArgumentError for bogus statuses" do
      bogus_statuses = [3, :bogus, 'pending', nil]
      bogus_statuses.each do |fulfillment_status|
        expect {
          Order.new(1, {}, customer, fulfillment_status)
        }.must_raise ArgumentError
      end
    end
  end

  describe "#total" do
    it "Returns the total from the collection of products" do
      products = { "banana" => 1.99, "cracker" => 3.00 }
      order = Order.new(1337, products, customer)

      expected_total = 5.36

      expect(order.total).must_equal expected_total
    end

    it "Returns a total of zero if there are no products" do
      order = Order.new(1337, {}, customer)

      expect(order.total).must_equal 0
    end
  end

  describe "#add_product" do
    it "Increases the number of products" do
      products = { "banana" => 1.99, "cracker" => 3.00 }
      before_count = products.count
      order = Order.new(1337, products, customer)

      order.add_product("salad", 4.25)
      expected_count = before_count + 1
      expect(order.products.count).must_equal expected_count
    end

    it "Is added to the collection of products" do
      products = { "banana" => 1.99, "cracker" => 3.00 }
      order = Order.new(1337, products, customer)

      order.add_product("sandwich", 4.25)
      expect(order.products.include?("sandwich")).must_equal true
    end

    it "Raises an ArgumentError if the product is already present" do
      products = { "banana" => 1.99, "cracker" => 3.00 }

      order = Order.new(1337, products, customer)
      before_total = order.total

      expect {
        order.add_product("banana", 4.25)
      }.must_raise ArgumentError

      # The list of products should not have been modified
      expect(order.total).must_equal before_total
    end
  end

############Added Test for Optional remove_product
  describe "#remove_product" do
    it "Decreases the number of products" do
      products = { "banana" => 1.99, "cracker" => 3.00, "salad" => 4.25 }
      before_count = products.count
      order = Order.new(1337, products, customer)

      order.remove_product("banana")
      expected_count = before_count - 1
      expect(order.products.count).must_equal expected_count
    end

    it "Is removed from the collection of products" do
      products = { "banana" => 1.99, "cracker" => 3.00, "salad" => 4.25 }
      order = Order.new(1337, products, customer)

      order.remove_product("banana")
      expect(order.products.include?("banana")).must_equal false
    end

    it "Raises an ArgumentError if the product is not in the order" do
      products = { "banana" => 1.99, "cracker" => 3.00, "salad" => 4.25 }

      order = Order.new(1337, products, customer)
      before_total = order.total

      expect {
        order.remove_product("apple")
      }.must_raise ArgumentError

      # The list of products should not have been modified
      expect(order.total).must_equal before_total
    end
  end


end

# change 'xdescribe' to 'describe' to run these tests
describe "Order Wave 2" do
  describe "Order.all" do
    it "Returns an array of all orders" do

      expect(Order.all.class).must_equal Array

      expect(Order.all.length).must_equal 100

      expect(Order.all.all? {|item| item.class == Order})

    end

    it "Returns accurate information about the first order" do
      id = 1
      products = {
        "Lobster" => 17.18,
        "Annatto seed" => 58.38,
        "Camomile" => 83.21
      }
      customer_id = 25
      fulfillment_status = :complete

      order = Order.all.first

      # Check that all data was loaded as expected
      expect(order.id).must_equal id
      expect(order.products).must_equal products
      expect(order.customer).must_be_kind_of Customer
      expect(order.customer.id).must_equal customer_id
      expect(order.fulfillment_status).must_equal fulfillment_status
    end

    it "Returns accurate information about the last order" do
      id = 100
      products = {
        "Amaranth" => 83.81,
        "Smoked Trout" => 70.6,
        "Cheddar" => 5.63
      }
      customer_id = 20
      fulfillment_status = :pending

      order = Order.all.last

      # Check that all data was loaded as expected
      expect(order.id).must_equal id
      expect(order.products).must_equal products
      expect(order.customer).must_be_kind_of Customer
      expect(order.customer.id).must_equal customer_id
      expect(order.fulfillment_status).must_equal fulfillment_status
    end
  end

  describe "Order.find" do
    it "Can find the first order from the CSV" do
      id = 1
      products = {
        "Lobster" => 17.18,
        "Annatto seed" => 58.38,
        "Camomile" => 83.21
      }
      customer_id = 25
      fulfillment_status = :complete

      order = Order.find(1)

      # Check that all data was loaded as expected
      expect(order.id).must_equal id
      expect(order.products).must_equal products
      expect(order.customer).must_be_kind_of Customer
      expect(order.customer.id).must_equal customer_id
      expect(order.fulfillment_status).must_equal fulfillment_status
    end

    it "Can find the last order from the CSV" do
      id = 100
      products = {
        "Amaranth" => 83.81,
        "Smoked Trout" => 70.6,
        "Cheddar" => 5.63
      }
      customer_id = 20
      fulfillment_status = :pending

      order = Order.find(100)

      # Check that all data was loaded as expected
      expect(order.id).must_equal id
      expect(order.products).must_equal products
      expect(order.customer).must_be_kind_of Customer
      expect(order.customer.id).must_equal customer_id
      expect(order.fulfillment_status).must_equal fulfillment_status
    end

    it "Returns nil for an order that doesn't exist" do
      expect(Order.find(9999)).must_be_nil
      expect(Order.find(0)).must_be_nil
      expect(Order.find('gibberish')).must_be_nil
    end
  end

#Added test for optional find_by_customer method
  describe "Order.find_by_customer" do
    it "returns an array of orders" do
      expect(Order.find_by_customer(20).class).must_equal Array
      expect(Order.find_by_customer(20)).wont_be_empty
      expect(Order.find_by_customer(20).all? {|item| item.class == Order})
    end

    it "finds all of the orders for customer #4" do
      order_id_list = [11, 44, 86]

      orders = Order.find_by_customer(4)

      found_order_ids = orders.map do |order|
        order.id
      end

      expect(found_order_ids).must_equal order_id_list
    end

    it "returns nil for a customer that does not exist" do
      expect(Order.find_by_customer(9999)).must_be_nil
      expect(Order.find_by_customer('gibberish')).must_be_nil
    end

  end

end
