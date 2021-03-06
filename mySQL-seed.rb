# frozen_string_literal: true

require 'mysql2'
require 'faker'
I18n.reload!

# http://zetcode.com/db/mysqlrubytutorial/
# https://www.ntu.edu.sg/home/ehchua/programming/sql/SampleDatabases.html
# https://www.dofactory.com/sql/sample-database

# this takes a hash of options, almost all of which map directly
# to the familiar database.yml in rails
# See http://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/Mysql2Adapter.html
# client = Mysql2::Client.new(host: ARGV[0], username: 'xx', password: 'xx', database: 'productsDB')
client = Mysql2::Client.new(host: ARGV[0], username: ARGV[1], password: ARGV[2], database: ARGV[3])

# Create new customers in the database
def createNewCustomer(client, numCustomers)
  puts("\n\n=== Creating Customers ============================")
  (1..numCustomers).each do |_i|
    insertData = "'#{Faker::Name.first_name}','#{Faker::Name.last_name.gsub("'") { "\\'" }}','#{Faker::Address.city.gsub("'") { "\\'" }}','#{Faker::Address.country.gsub("'") { "\\'" }}','#{Faker::PhoneNumber.phone_number_with_country_code}'"
    puts insertData
    client.query("INSERT INTO Customer (FirstName,LastName,City,Country,Phone) VALUES (#{insertData});")
  end
end

# Create new Products
def createProducts(client, numSuppliers, numProducts)
  puts("\n\n=== Creating Products ============================")
  (0..numSuppliers).each do |i|
    puts("\n\n=== Creating Products for Supplier #{i} ===============")
    (0..rand(2..numProducts)).each do |_j|
      insertData = "'#{Faker::Dessert.flavor.gsub("'") { "\\'" }} #{Faker::Dessert.variety.gsub("'") { "\\'" }} with #{Faker::Dessert.topping.gsub("'") { "\\'" }} ','#{i}','#{rand(20.0)}','#{Faker::Construction.material.gsub("'") { "\\'" }}',#{rand(0..1)}"
      puts insertData
      client.query("INSERT INTO Product (ProductName,SupplierId,UnitPrice,Package,IsDiscontinued) VALUES (#{insertData});")
    end
  end
end

# Create new suppliers
def createSuppliers(client, num)
  puts("\n\n=== Creating Suppliers ============================")
  (1..num).each do |_i|
    insertData = "'#{Faker::Company.name.gsub("'") { "\\'" }}','#{Faker::Name.name.gsub("'") { "\\'" }}','#{Faker::Job.title.gsub("'") { "\\'" }}','#{Faker::Address.city.gsub("'") { "\\'" }}','#{Faker::Address.country.gsub("'") { "\\'" }}','#{Faker::PhoneNumber.phone_number_with_country_code}','#{Faker::PhoneNumber.phone_number_with_country_code}'"
    puts insertData
    client.query("INSERT INTO Supplier (CompanyName,ContactName,ContactTitle,City,Country,Phone,Fax) VALUES (#{insertData});")
  end
end

# Create new Orders, including Order Items.
def createNewOrder(client, numOrders)
  (1..numOrders).each do |_i|
    puts("\n\n=== Creating New Order ===============")

    customers = client.query('SELECT * from Customer')

    insertOrderData = "#{rand(1_000_000..2_000_000)},#{rand(1..customers.count)},#{rand(1.0..1000.0).round(2)}"
    puts insertOrderData
    client.query("INSERT INTO Orders (OrderNumber,CustomerID,TotalAmount) VALUES (#{insertOrderData});")

    lastOrders = client.query('SELECT * from Orders')
    products = client.query('SELECT * from Product')

    puts('=== Adding Order Items ===============')

    # create order items
    (1..(rand(5)+1)).each do |_j|
      insertOrderItemData = "#{lastOrders.count},#{rand(products.count)},#{rand(0.0..10.0).round(2)},#{rand(1..5)}"
      puts insertOrderItemData
      client.query("INSERT INTO OrderItem (OrderID,ProductID,UnitPrice,Quantity) VALUES (#{insertOrderItemData});")
    end
  end
end

# How many entities ofeach type do we want to seed the database with?
numSuppliers = 30
numProducts  = 10 # What is the upper bounds for the random number of products per supplier
numCustomers = 20
numOrders    = 20

# Create the Suppliers
createSuppliers(client, numSuppliers)

# Create the Products
createProducts(client, numSuppliers, numProducts)

# Create some customers
createNewCustomer(client, numCustomers)

# Create some orders
createNewOrder(client, numOrders)
