# Spree Connector.rb

require 'curb'
require 'json'
require 'yaml'
require "mysql"

# define class Spree Connector
class SpreeConnector
  def initialize(uniqueID, storeName, storeURL, storeAPIKey)
	@uniqueID = uniqueID
	@storeName = storeName
	@storeURL = storeURL
	@storeAPIKey = storeAPIKey
  end

  # Setup Method
  def setup

	# Database connection and creating Database
	dbname="spree"
	m = Mysql.new("localhost", "root", "hello")
	r = m.query("CREATE DATABASE spree")
	m.select_db(dbname)

	# Reading table configuration from YAML file
	orders = YAML.load_file("tableconfig.yml")
	$i=0
	sqlstring=""
	x=orders["orders"].keys[0]
	$len=orders["orders"].keys.length
	while $i<$len-1
		x=orders["orders"].keys[$i]
		sqlstring=sqlstring + orders["orders"].keys[$i] + " " + orders["orders"][x].to_s + ","
		$i+=1
	end
	x=orders["orders"].keys[$len-1]
	sqlstring=sqlstring + orders["orders"].keys[$len-1] + " " + orders["orders"][x].to_s
	puts sqlstring

	# Creating Table
	r=m.query("CREATE TABLE orders(" + sqlstring + ")")
	r=m.query("CREATE TABLE carts(" + sqlstring + ")")

  end


  # Fetch Orders Method
  def fetch_Orders
	#while true
		# Curling the url
		url=@storeURL
		http = Curl.get(url)

		# Storing the data in the url into a file and parsing it using JSON
		File.open("myfile.json", 'w') { |file| file.write(http.body_str) }
		file = File.read('myfile.json')
		data_hash = JSON.parse(file)
#		data_hash = JSON.parse(http.body_str)

		# Database connection and creating Database
		dbname="spree"
		m = Mysql.new("localhost", "root", "hello")
		m.select_db(dbname)

		# Iterating values to insert
		$i = 0
		$j = 0
		sqlstring=""

		# Counting number of rows
		data_hash["orders"].each do |orders|
			$i +=1
		end
		$len = data_hash["orders"][0].keys.length
		$len2 = $i

		# Inserting values into the table
		while $j < $len2  do
			$i = 0
			sqlstring=""
			while $i < $len-1  do
			   sqlstring=sqlstring + "'" + data_hash["orders"][$j].values[$i].to_s + "',"
			   $i +=1
			end
			sqlstring=sqlstring + "'" + data_hash["orders"][$j].values[$len-1].to_s + "'"
			r=m.query("replace into orders values(" + sqlstring + ")")
			$j +=1
		end
	#	sleep 300
	#end
  end


  # Update Orders Method
  def update_Orders
	while true
		time=Time.new
		time=time-(15*60)

		# Curling the url
		url=@storeURL + "&q[updated_at_gt]=" + time.strftime("%Y-%m-%dT%H:%M:%S.%LZ")
		http = Curl.get(url)

		# Storing the data in the url into a file and parsing it using JSON
		File.open("myfile.json", 'w') { |file| file.write(http.body_str) }
		file = File.read('myfile.json')
		data_hash = JSON.parse(file)
#		data_hash = JSON.parse(http.body_str)

		# Database connection and creating Database
		dbname="spree"
		m = Mysql.new("localhost", "root", "hello")
		m.select_db(dbname)

		# Iterating values to insert
		$i = 0
		$j = 0
		sqlstring=""

		# Counting number of rows
		data_hash["orders"].each do |orders|
			$i +=1
		end
		if $i>0
			$len = data_hash["orders"][0].keys.length
			$len2 = $i

			# Inserting values into the table
			while $j < $len2  do
				$i = 0
				sqlstring=""
				while $i < $len-1  do
				   sqlstring=sqlstring + "'" + data_hash["orders"][$j].values[$i].to_s + "',"
				   $i +=1
				end
				sqlstring=sqlstring + "'" + data_hash["orders"][$j].values[$len-1].to_s + "'"
				r=m.query("replace into orders values(" + sqlstring + ")")
				$j +=1
			end
		end
		sleep 15*60
	end
  end


  # Fetch Carts Method
  def fetch_Carts
	# Curling the url
	url=@storeURL
	http = Curl.get(url)

	# Storing the data in the url into a file and parsing it using JSON
	File.open("myfile.json", 'w') { |file| file.write(http.body_str) }
	file = File.read('myfile.json')
	data_hash = JSON.parse(file)
#		data_hash = JSON.parse(http.body_str)

	# Database connection and creating Database
	dbname="spree"
	m = Mysql.new("localhost", "root", "hello")
	m.select_db(dbname)

	# Iterating values to insert
	$i = 0
	$j = 0
	sqlstring=""

	# Counting number of rows
	data_hash["orders"].each do |orders|
		$i +=1
	end
	$len = data_hash["orders"][0].keys.length
	$len2 = $i

	# Inserting values into the table
	while $j < $len2  do
		$i = 0
		sqlstring=""
		if data_hash["orders"][$j]["state"].to_s == "cart"
			while $i < $len-1  do
			   sqlstring=sqlstring + "'" + data_hash["orders"][$j].values[$i].to_s + "',"
			   $i +=1
			end
			sqlstring=sqlstring + "'" + data_hash["orders"][$j].values[$len-1].to_s + "'"
			r=m.query("replace into carts values(" + sqlstring + ")")
		end
		$j +=1
	end
  end
end

store1=SpreeConnector.new(1,"SpreeCommerce","https://happy-basket-7349.spree.mx/api/orders.json?token=350b917d8371a0595cb1b7d869dc854e6dc08b13ca183000","350b917d8371a0595cb1b7d869dc854e6dc08b13ca183000")
store1.setup
store1.fetch_Orders
store1.update_Orders
store1.fetch_Carts
