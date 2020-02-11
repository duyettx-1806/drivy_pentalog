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

class Option
  def initialize params
    @id = params["id"]
    @rental_id = params["rental_id"]
    @type = params["type"]
  end

  def get_rental_id
    @rental_id
  end

  def get_id
    @id
  end

  def get_type
    @type
  end
end

def level_5
  s = File.read("data/input.json")
  obj = JSON.parse(s)
  car = Car.new obj["cars"][0]

  rental1 = Rental.new obj["rentals"][0]
  rental2 = Rental.new obj["rentals"][1]
  rental3 = Rental.new obj["rentals"][2]

  option1 = Option.new obj["options"][0]
  option2 = Option.new obj["options"][1]
  option3 = Option.new obj["options"][2]

  rentals = [rental1, rental2, rental3].map do |rental|
    list_option = [option1, option2, option3].map do |option|
      next if option.get_rental_id != rental.get_id
      option.get_type
    end.compact
    price = if rental.get_use_day > 1 && rental.get_use_day <= 4
              car.get_price_per_day * (1 + (rental.get_use_day - 1)*0.9) + car.get_price_per_km * rental.get_distance
            elsif rental.get_use_day > 4 && rental.get_use_day <= 10
              car.get_price_per_day * (3.7 + (rental.get_use_day - 4)*0.7) + car.get_price_per_km * rental.get_distance
            elsif rental.get_use_day > 10
              car.get_price_per_day * (7.9 + (rental.get_use_day - 10)*0.5) + car.get_price_per_km * rental.get_distance
            else
              car.get_price_per_day * rental.get_use_day + car.get_price_per_km * rental.get_distance
            end
    actions = action(price, rental.get_use_day, list_option)
    {"id" => rental.get_id, "price" => price.to_i, "option" => list_option, "actions" => actions}
  end

  rentals_export = {rentals: rentals}

  File.open("expected_output.json","w") do |f|
    f.write(rentals_export.to_json)
  end
end

def action price, use_day, list_option
  owner_fee = if list_option.include?("gps") && list_option.include?("baby_seat")
                price * 0.7 + 500 * use_day + 200 * use_day
              elsif list_option.include? "gps"
                price * 0.7 + 500 * use_day
              elsif list_option.include? "baby_seat"
                price * 0.7 + 200 * use_day
              else
                price * 0.7
              end

  insurance_fee = price * 0.3 * 0.5
  assistance_fee = (use_day * 100 + insurance_fee) > price * 0.3 ? (price - insurance_fee) : use_day * 100
  drivy_fee = if list_option.include? "additional_insurance"
                price * 0.3 - insurance_fee - assistance_fee + 100 * use_day
              else
                price * 0.3 - insurance_fee - assistance_fee
              end
  price = owner_fee + insurance_fee + assistance_fee + drivy_fee
  user_with_fee = {"driver" => price, "owner" => owner_fee, "insurance" => insurance_fee, "assistance" => assistance_fee, "drivy" => drivy_fee}
  user_with_fee.map do |who, fee|
    type = who == "driver" ? "debit" : "credit"
    {
      who: who,
      type: type,
      amount: fee.to_i
    }
  end
end

level_5
