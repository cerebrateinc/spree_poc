require 'curb'
require 'json'
require "mysql"

# Curling the url
url = 'https://happy-basket-7349.spree.mx/api/orders.json?token=350b917d8371a0595cb1b7d869dc854e6dc08b13ca183000'
http = Curl.get(url)


# Storing the data in the url into a file and parsing it using JSON
File.open("myfile.json", 'w') { |file| file.write(http.body_str) }
file = File.read('myfile.json')
data_hash = JSON.parse(file)


# Database connection and creating Database
dbname="spree"
m = Mysql.new("localhost", "root", "hello")
r = m.query("CREATE DATABASE spree")
m.select_db(dbname)


# Iterating key values
$i = 0
sqlstring=""
$len = data_hash["orders"][0].keys.length
while $i < $len-1  do
   sqlstring=sqlstring + data_hash["orders"][0].keys[$i] + " varchar(50),"
   $i +=1
end
sqlstring=sqlstring + data_hash["orders"][0].keys[$len-1] + " varchar(50)"


# Creating Table
r=m.query("CREATE TABLE orders(" + sqlstring + ")")


# Iterating values to insert
$i = 0
$j = 0
sqlstring=""

# Counting number of rows
data_hash["orders"].each do |orders|
	$i +=1
end
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
	r=m.query("insert into orders values(" + sqlstring + ")")
        $j +=1
end
