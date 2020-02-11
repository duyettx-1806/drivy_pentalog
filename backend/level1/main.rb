require 'rubygems'
require 'json'
require 'time'

s = File.read("data/input.json")
obj = JSON.parse(s)

class Car
  def initialize params
    @id = params["id"]
    @price_per_day = params["price_per_day"]
    @price_per_km = params["price_per_km"]
  end

  def get_id
    @id
  end

  def get_price_per_day
    @price_per_day
  end

  def get_price_per_km
    @price_per_km
  end
end

class Rental
  def initialize params
    @id = params["id"]
    @car_id = params["car_id"]
    @start_date = params["start_date"]
    @end_date = params["end_date"]
    @distance = params["distance"]
  end

  def get_car_id
    @car_id
  end

  def get_id
    @id
  end

  def get_use_day
    return 0 if  Date.parse(@end_date) < Date.parse(@start_date)
    (Date.parse(@end_date) - Date.parse(@start_date)).to_i + 1
  end

  def get_distance
    @distance
  end
end

car1 = Car.new obj["cars"][0]
car2 = Car.new obj["cars"][1]
car3 = Car.new obj["cars"][2]

rental1 = Rental.new obj["rentals"][0]
rental2 = Rental.new obj["rentals"][1]
rental3 = Rental.new obj["rentals"][2]

rentals = [rental1, rental2, rental3].map do |rental|
  [car1, car2, car3].map do |car|
    next if rental.get_car_id != car.get_id
    price = car.get_price_per_day * rental.get_use_day + car.get_price_per_km * rental.get_distance
    {"id" => rental.get_id, "price" => price}
  end
end

rentals_export = {:rentals => rentals}

File.open("expected_output.json","w") do |f|
  f.write(rentals_export.to_json)
end
