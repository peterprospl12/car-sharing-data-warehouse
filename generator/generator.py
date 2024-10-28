import csv
import random

from faker import Faker
from datetime import timedelta, date, datetime
from faker_vehicle import VehicleProvider
import utills.utills as utills
from utills.utills import cities_coordinates
import pandas as pd
from dateutil.relativedelta import relativedelta

fake = Faker('pl_PL')
fake.add_provider(VehicleProvider)

N_USERS = 5  # Number of users
N_CARS = 3  # Number of cars
N_CAR_STATES = 3  # Number of car states per car (amount of car states >= N_CARS * N_PRICE_INCREASE)
N_PRICE_INCREASES = 1  # Numer of pricelist changes
N_RENTALS = 10  # Number of car rentals per vehicle (amount of car rentals >= N_CAR_STATES * N_USERS)

# Possible car models with possible engine powers and luxury levels

car_brands_and_models = [
    ["Renault", "Clio", [90, 100, 120], 0],
    ["Renault", "Master", [100, 120, 140], 1],
    ["Renault", "Arkana", [140, 160, 180], 1],
    ["Renault", "Zoe", [90, 100, 120], 2],
    ["Dacia", "Sandero", [90, 100, 120], 0],
    ["Dacia", "Spring", [90, 100, 120], 1],
    ["Renault", "Megane", [130, 190, 240], 2],
    ["Dacia", "Dokker", [90, 100, 120], 1],
    ["Renault", "Express", [12, 150, 180], 2],
]


def create_users_file():
    # User_ID, First_name, Last_name, PESEL, Driving_license_ID, Nationality, E-mail, Password, License_receiving_date

    with open('../users.csv', mode='w', newline='') as file:
        writer = csv.writer(file)

        writer.writerow(
            ["User_ID", "First_name", "Last_name", "PESEL", "Driving_license_ID", "License_receiving_date", "Nationality", "E-mail", "Password"]
        )

        for i in range(N_USERS):
            # Birthdate is between 18 and 65 years ago

            birth_date = fake.date_of_birth(minimum_age=18, maximum_age=65)

            # License receiving date is between 18 and 65 years after birthdate

            min_license_date = birth_date + timedelta(days=18 * 365)
            today = date.today()
            max_license_date = today if min_license_date < today else min_license_date + timedelta(days=365)

            license_receiving_date = fake.date_between_dates(min_license_date, max_license_date)

            writer.writerow(
                [
                    i + 1,  # User_ID
                    fake.first_name(),  # First_name
                    fake.last_name(),  # Last_name
                    fake.pesel(date_of_birth=datetime.combine(birth_date, datetime.min.time())),  # PESEL
                    fake.random_int(min=100000, max=999999),  # Driving license ID
                    license_receiving_date,  # License_receiving_date
                    fake.country(),  # Nationality
                    fake.email(),  # E-mail
                    fake.password()  # Password
                ]
            )


# Pricelist [i] - non-luxury, [i + 1] - semi-luxury, [i + 2] - luxury
# Zakładamy PRICE_INCREASE podwyżek cen
# [Pricelist_ID, Starting_price, Layover_price, Price_per_km]
pricelists = [[i + 1, 4 + 0.5 * i, 0.1 + i * 0.02, 1.7 + i * 0.2] for i in range(N_PRICE_INCREASES + 2)]


def create_pricelists_file():
    # pricelist_id, starting_price, layover_price, price_per_km

    with open('../pricelists.csv', mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(["Pricelist_ID", "Starting_price", "Layover_price", "Price_per_km"])
        writer.writerows(pricelists)


def create_cars_car_states_and_rentals():
    # CARS : Car_ID, brand, model, engine_power, manual, license_plate_number
    # CAR_STATES : Car_state_ID, Is_broken, Is_used, Location, Active, Car_ID, Pricelist_ID
    # RENTALS : Rental_ID, rental_date_start, rental_date_end, start_location, end_location, driven_km, layover_time, total_cost, Car_state_ID, User_ID

    id_rental = 1
    id_state = 1

    users = pd.read_csv('../users.csv', usecols=['User_ID', 'License_receiving_date'])
    users['License_receiving_date'] = pd.to_datetime(users['License_receiving_date'])

    with open('../cars.csv', mode='w', newline='') as cars_file:
        cars_writer = csv.writer(cars_file)
        cars_writer.writerow(
            ["Car_ID", "Brand", "Model", "Engine_power", "Manual", "License_plate_number"]
        )

        with open('../rentals.csv', mode='w', newline='') as rentals_file:
            rentals_writer = csv.writer(rentals_file)
            rentals_writer.writerow(
                ["Rental_ID", "Rental_date_start", "Rental_date_end",
                 "Start_location", "End_location", "Driven_km", "Layover_time",
                 "Total_cost", "Car_state_ID", "User_ID"]
            )

            with open('../cars_states.csv', mode='w', newline='') as car_states_file:
                car_states_writer = csv.writer(car_states_file)
                car_states_writer.writerow(
                    ["Car_state_ID", "Is_broken", "Is_used", "Location", "Is_active", "Car_ID", "Pricelist_ID"]
                )

                # Generate N_CARS cars

                for i in range(N_CARS):
                    brand_and_model = random.choice(car_brands_and_models)
                    cars_writer.writerow(
                        [
                            i + 1,
                            brand_and_model[0],  # Brand
                            brand_and_model[1],  # Model
                            random.choice(brand_and_model[2]),  # Engine power
                            fake.boolean(chance_of_getting_true=50),  # Manula
                            fake.license_plate(),  # Random license plate
                        ]
                    )

                    # For each car generate from 0 to 2*N_CAR_STATES car states

                    pricelist_ids = range(brand_and_model[3], brand_and_model[3] + N_PRICE_INCREASES)
                    CAR_STATES_PER_PRICELIST = N_CAR_STATES // N_PRICE_INCREASES

                    for idx, pricelist_id in enumerate(pricelist_ids):
                        # Generate car state ID, and flag attributes

                        car_state_id = id_state
                        id_state += 1

                        is_broken = fake.boolean(chance_of_getting_true=2)
                        is_used = False if is_broken else fake.boolean(chance_of_getting_true=30)

                        # is_active is true only if its last pricelist
                        is_active = pricelist_id == pricelist_ids[-1]

                        car_states_writer.writerow(
                            [
                                car_state_id,  # Car_State_ID
                                is_broken,  # is_broken flag
                                is_used,  # is_used flag
                                utills.generate_random_city_coordinates()[1],  # Location
                                is_active,  # is_used flag
                                i + 1,  # Car_ID
                                pricelist_id + 1  # Pricelist_ID
                            ]
                        )

                        # For each car state generate from 0 to 2*N_RENTALS rentals

                        rental_periods = []

                        for k in range(random.randint(0, 2 * N_CAR_STATES)):

                            # Generate rental ID

                            rental_id = id_rental

                            # Generate rental city and start and end locations

                            city = random.choice(list(cities_coordinates.keys()))
                            _, coordinates_start = utills.generate_random_city_coordinates(city=city)
                            _, coordinates_end = utills.generate_random_city_coordinates(city=city)

                            # Generate rental start and end dates

                            start_date = fake.date_time_between(
                                start_date=f'-{N_PRICE_INCREASES - idx}y',
                                end_date=f'-{N_PRICE_INCREASES - idx - 1}y'
                            )
                            max_end_date = start_date + timedelta(hours=5, minutes=59, seconds=59)
                            end_date_limit = datetime.now() - relativedelta(years=N_PRICE_INCREASES - idx - 1)
                            end_date = fake.date_time_between(
                                start_date=start_date,
                                end_date=min(max_end_date, end_date_limit)
                            )

                            overlap_found = False
                            for period in rental_periods:
                                if start_date < period[1] and end_date > period[0]:
                                    overlap_found = True
                                    break

                            if not overlap_found:
                                rental_periods.append((start_date, end_date))
                            else:
                                continue

                            # Randomly select a user and check if they had a valid driving license at the time of rental

                            user = users.sample(n=1).iloc[0]
                            if user['License_receiving_date'] > start_date:
                                continue

                            id_rental += 1

                            user_id = user['User_ID']
                            driven_km = utills.calc_distance(coordinates_start, coordinates_end) + fake.random_int(
                                min=1, max=30)
                            layover_time = random.randint(0, 24)

                            # Calculate total cost
                            total_cost = (pricelists[pricelist_id][1] +
                                          pricelists[pricelist_id][2] * layover_time +
                                          pricelists[pricelist_id][3] * driven_km)

                            rentals_writer.writerow(
                                [
                                    rental_id,  # Rental_ID
                                    start_date.strftime("%Y-%m-%d %H:%M:%S"),  # Rental_date_start
                                    end_date.strftime("%Y-%m-%d %H:%M:%S"),  # Rental_date_end
                                    coordinates_start,  # Start_location
                                    coordinates_end,  # End_location
                                    driven_km,  # Driven_km
                                    layover_time,  # Layover_time
                                    round(total_cost, 2),  # Total_cost
                                    car_state_id,  # Car_state_ID
                                    user_id  # User_ID
                                ]
                            )


def main():
    create_users_file()
    create_pricelists_file()
    create_cars_car_states_and_rentals()


if __name__ == "__main__":
    main()
