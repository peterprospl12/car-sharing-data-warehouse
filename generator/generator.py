import csv
import random

import numpy as np
from faker import Faker
from datetime import timedelta, date, datetime
from faker_vehicle import VehicleProvider
import utills.utills as utills
from utills.utills import cities_coordinates
import pandas as pd

fake = Faker('pl_PL')
fake.add_provider(VehicleProvider)
user_gens = 20
car_gens = 10
car_state_gens = 50
PRICE_INCREASES = 5
rental_gens = 100

car_brands_and_models = [
    ["Renault", "Clio", [90, 100, 120]],
    ["Renault", "Master", [100, 120, 140]],
    ["Renault", "Arkana", [140, 160, 180]],
    ["Renault", "Zoe", [90, 100, 120]],
    ["Dacia", "Sandero", [90, 100, 120]],
    ["Dacia", "Spring", [90, 100, 120]],
    ["Renault", "Megane", [130, 190, 240]],
    ["Dacia", "Dokker", [90, 100, 120]],
    ["Renault", "Express", [12, 150, 180]],
]


def create_users_file(gen_num):
    # User_ID, First_name, Last_name, PESEL, Driving_license_ID, Nationality, E-mail, Password, License_receiving_date

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

            # print(f"User {i + 1} created.")


def create_cars_file(gen_num):
    # car_id, brand, engine_power, manual or not, license_plate_number, model

    with open('../cars.csv', mode='w', newline='') as file:
        writer = csv.writer(file)

        writer.writerow(
            ["Car_ID", "Brand", "Model", "Engine_power", "Manual", "License_plate_number"]
        )

        for i in range(gen_num):
            brand_and_model = random.choice(car_brands_and_models)

            writer.writerow(
                [
                    i + 1,
                    brand_and_model[0],
                    brand_and_model[1],
                    random.choice(brand_and_model[2]),
                    fake.boolean(chance_of_getting_true=50),
                    fake.license_plate(),
                ]
            )

            # print(f"Car {i + 1} created.")


# Cenik [i] - mało luksusowe, [i + 1] - średnio luksusowe, [i + 2] - luksusowe
# Zakładamy PRICE_INCREASE podwyżek cen
# [Pricelist_ID, Starting_price, Layover_price, Price_per_km]
pricelists = [[i + 1, 4 + 0.5 * i, 0.1 + i * 0.02, 1.7 + i * 0.2] for i in range(PRICE_INCREASES)]


def create_pricelists_file():
    # pricelist_id, starting_price, layover_price, price_per_km

    with open('../pricelists.csv', mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(["Pricelist_ID", "Starting_price", "Layover_price", "Price_per_km"])
        writer.writerows(pricelists)

        # print(f"{PRICE_INCREASES} pricelists created.")


def create_cars_states_file(gen_num):
    # Car_state_ID, Is_broken, Is_used, Location, Active, Car_ID, Pricelist_ID

    # Read only the 'Car_ID' column from 'cars.csv'
    car_ids = pd.read_csv('../cars.csv', usecols=['Car_ID'])['Car_ID'].tolist()

    # Read only the 'Pricelist_ID' column from 'pricelists.csv'
    pricelist_ids = pd.read_csv('../pricelists.csv', usecols=['Pricelist_ID'])['Pricelist_ID'].tolist()

    with open('../cars_states.csv', mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(
            ["Car_state_ID", "Is_broken", "Is_used", "Location", "Active", "Car_ID", "Pricelist_ID"]
        )
        active_cars = {}
        for i in range(gen_num):
            car_id = random.choice(car_ids)
            _, coordinates = utills.generate_random_city_coordinates()

            is_broken = fake.boolean(chance_of_getting_true=2)
            is_used = False if is_broken else fake.boolean(chance_of_getting_true=30)
            is_active = fake.boolean(chance_of_getting_true=int(np.floor(100 / PRICE_INCREASES)))

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
                    random.choice(pricelist_ids)
                ]
            )
            # print(f"Car state {i + 1} created.")


def create_rentals_file(gen_num):
    # Rental_ID, rental_date_start, driven_km, total_cost, rental_date_end, layover_time, start_location, end_location, User_ID, Car_state_ID
    with open('../rentals.csv', mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(
            ["Rental_ID", "Rental_date_start", "Driven_km", "Total_cost", "Rental_date_end", "Layover_time",
             "Start_location", "End_location", "Car_state_ID", "User_ID"]
        )

        car_states = pd.read_csv('../cars_states.csv')
        users = pd.read_csv('../users.csv', usecols=['User_ID', 'License_receiving_date'])
        users['License_receiving_date'] = pd.to_datetime(users['License_receiving_date'])
        cities = list(cities_coordinates.keys())
        pricelists = pd.read_csv('../pricelists.csv')

        i = 0
        while i < gen_num:
            car_state = car_states.sample(n=1).iloc[0]
            car_state_id = car_state['Car_state_ID']
            pricelist_id = car_state['Pricelist_ID']
            pricelist = pricelists[pricelists['Pricelist_ID'] == pricelist_id].iloc[0]

            city = random.choice(cities)
            _, coordinates_start = utills.generate_random_city_coordinates(city=city)
            _, coordinates_end = utills.generate_random_city_coordinates(city=city)
            start_date = fake.date_time_between(start_date='-5y', end_date='now')
            end_date = start_date + timedelta(hours=random.randint(0, 5), minutes=random.randint(0, 59),
                                              seconds=random.randint(0, 59))

            # Randomly select a user and check if they had a valid driving license at the time of rental
            user = users.sample(n=1).iloc[0]
            if user['License_receiving_date'] > start_date:
                continue  # Skip if the user did not have a valid license

            user_id = user['User_ID']
            driven_km = utills.calc_distance(coordinates_start, coordinates_end) + fake.random_int(min=1, max=30)
            layover_time = random.randint(0, 24)

            # Calculate total cost
            total_cost = (pricelist['Starting_price'] +
                          pricelist['Layover_price'] * layover_time +
                          pricelist['Price_per_km'] * driven_km)

            writer.writerow(
                [
                    i + 1,
                    start_date.strftime("%Y-%m-%d %H:%M:%S"),
                    driven_km,
                    round(total_cost, 2),
                    end_date.strftime("%Y-%m-%d %H:%M:%S"),
                    layover_time,
                    coordinates_start,
                    coordinates_end,
                    car_state_id,
                    user_id
                ]
            )
            # print(f"Rental {i + 1} created.")
            i += 1


def main():
    create_users_file(user_gens)
    create_cars_file(car_gens)
    create_pricelists_file()
    create_cars_states_file(car_state_gens)
    create_rentals_file(rental_gens)


if __name__ == "__main__":
    main()
