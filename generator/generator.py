import csv
import random

from faker import Faker
from datetime import timedelta, date, datetime
from faker_vehicle import VehicleProvider
import utills.utills as utills
import pandas as pd

fake = Faker('pl_PL')
fake.add_provider(VehicleProvider)
user_gens = 1000
car_gens = 100
car_state_gens = 1000
pricelists_gens = 10


def create_users_file(gen_num):
    with open('../users.csv', mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(
            ["User_ID", "First_name", "Last_name", "PESEL", "Driving_license_ID", "Nationality", "E-mail", "Password",
             "License_receiving_date"]
        )
        for i in range(gen_num):
            birth_date = fake.date_of_birth(minimum_age=18, maximum_age=65)
            min_license_date = birth_date + timedelta(days=18 * 365)
            today = date.today()
            max_license_date = today if min_license_date < today else min_license_date + timedelta(days=365)
            license_receiving_date = fake.date_between_dates(min_license_date, max_license_date)
            writer.writerow(
                [
                    i + 1,
                    fake.first_name(),
                    fake.last_name(),
                    fake.pesel(date_of_birth=datetime.combine(birth_date, datetime.min.time())),
                    fake.random_int(min=100000, max=999999),
                    fake.country(),
                    fake.email(),
                    fake.password(),
                    license_receiving_date
                ]
            )
            print(f"User {i + 1} created.")


def create_cars_file(gen_num):
    # car_id, brand, engine_power, manual or not, license_plate_number, model
    with open('../cars.csv', mode='w', newline='') as file:
        writer = csv.writer(file)
        writerCity = csv.writer(open('../cities.csv', mode='w', newline=''))
        writer.writerow(
            ["Car_ID", "Brand", "Engine_power", "Manual", "License_plate_number", "Model"]
        )
        writerCity.writerow(["Car_Id", "City"])
        for i in range(gen_num):
            make_model = fake.vehicle_make_model()
            make, model = make_model.split(' ', 1)  # Split into make and model
            writer.writerow(
                [
                    i + 1,
                    make,
                    fake.random_int(min=50, max=500),
                    fake.boolean(chance_of_getting_true=50),
                    fake.license_plate(),
                    model
                ]
            )
            writerCity.writerow(
                [i + 1, random.choice(list(utills.cities_coordinates.keys()))]
            )
            print(f"Car {i + 1} created.")


def create_pricelists_file(gen_num):
    # pricelist_id, starting_price, layover_price, price_per_km
    with open('../pricelists.csv', mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(
            ["Pricelist_ID", "Starting_price", "Layover_price", "Price_per_km"]
        )
        for i in range(gen_num):
            writer.writerow(
                [
                    i + 1,
                    round(random.uniform(4.0, 10.0), 2),
                    round(random.uniform(1.0, 2.0), 2),
                    round(random.uniform(3.0, 5.0), 2)
                ]
            )
            print(f"Pricelist {i + 1} created.")


def create_cars_states_file(gen_num, pricelist_gens):
    with open('../cars_states.csv', mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(
            ["Car_state_ID", "Is_broken", "Is_used", "Location", "Active", "Car_ID", "Pricelist_ID"]
        )
        cities = pd.read_csv('../cities.csv')
        active_cars = {}
        for i in range(gen_num):
            sampled_row = cities.sample()
            car_id = sampled_row.iloc[0]['Car_Id']
            city = sampled_row.iloc[0]['City']
            city, coordinates = utills.generate_random_city_coordinates(city=city)

            is_broken = fake.boolean(chance_of_getting_true=5)
            is_used = False if is_broken else fake.boolean(chance_of_getting_true=50)
            is_active = fake.boolean(chance_of_getting_true=50)
            if is_active and active_cars.get(car_id) is None:
                active_cars[car_id] = True
            else:
                is_active = False

            writer.writerow(
                [
                    i + 1,
                    is_broken,
                    is_used,
                    coordinates,
                    is_active,
                    car_id,
                    fake.random_int(min=1, max=pricelist_gens)
                ]
            )
            print(f"Car state {i + 1} created.")


def create_rentals_file(gen_num, user_gens, car_state_gens):
    # rental_id, rental_date_start, driven_km, total_cost, rental_date_end, layover_time, start_location, end_location
    with open('../rentals.csv', mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(
            ["Rental_ID", "Rental_date_start", "Driven_km", "Total_cost", "Rental_date_end", "Layover_time",
             "Start_location", "End_location"]
        )
        for i in range(gen_num):
            start_date = fake.date_time_between(start_date='-1y', end_date='now')
            end_date = start_date + timedelta(hours=random.randint(1, 5), minutes=random.randint(0, 59),
                                              seconds=random.randint(0, 59))
            writer.writerow(
                [
                    i + 1,
                    start_date.strftime("%Y-%m-%d %H:%M:%S"),
                    fake.random_int(min=1, max=500),
                    round(random.uniform(10.0, 100.0), 2),
                    end_date.strftime("%Y-%m-%d %H:%M:%S"),
                    random.randint(0, 24),
                    f"{fake.latitude()}, {fake.longitude()}",
                    f"{fake.latitude()}, {fake.longitude()}",
                ]
            )
            print(f"Rental {i + 1} created.")


def main():
    create_users_file(user_gens)
    create_cars_file(car_gens)
    create_pricelists_file(pricelists_gens)
    create_cars_states_file(car_state_gens, pricelists_gens)
    create_rentals_file(1000, user_gens, car_gens)


if __name__ == "__main__":
    main()
