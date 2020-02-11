require 'rubygems'
require 'json'
require 'time'


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

def level_3
  s = File.read("data/input.json")
  obj = JSON.parse(s)
  car = Car.new obj["cars"][0]

  rental1 = Rental.new obj["rentals"][0]
  rental2 = Rental.new obj["rentals"][1]
  rental3 = Rental.new obj["rentals"][2]

  rentals = [rental1, rental2, rental3].map do |rental|
    price = if rental.get_use_day > 1 && rental.get_use_day <= 4
              car.get_price_per_day * (1 + (rental.get_use_day - 1)*0.9) + car.get_price_per_km * rental.get_distance
            elsif rental.get_use_day > 4 && rental.get_use_day <= 10
              car.get_price_per_day * (3.7 + (rental.get_use_day - 4)*0.7) + car.get_price_per_km * rental.get_distance
            elsif rental.get_use_day > 10
              car.get_price_per_day * (7.9 + (rental.get_use_day - 10)*0.5) + car.get_price_per_km * rental.get_distance
            else
              car.get_price_per_day * rental.get_use_day + car.get_price_per_km * rental.get_distance
            end
    comission = calculate_commission(price, rental.get_use_day)
    {"id" => rental.get_id, "price" => price.to_i, "comission" => comission}
  end

  rentals_export = {rentals: rentals}

  File.open("expected_output.json","w") do |f|
    f.write(rentals_export.to_json)
  end
end

def calculate_commission price, use_day
  insurance_fee = price * 0.3 * 0.5
  assistance_fee = (use_day * 100 + insurance_fee) > price ? (price - insurance_fee) : use_day * 100
  drivy_fee =  price * 0.3 - insurance_fee - assistance_fee
  {
    insurance_fee: insurance_fee.to_i,
    assistance_fee: assistance_fee.to_i,
    drivy_fee: drivy_fee.to_i
  }
end

level_3
