import csv
import os
import random
import re

from faker import Faker
from datetime import timedelta, date, datetime
from faker_vehicle import VehicleProvider
import utills.utills as utills
from utills.utills import cities_coordinates
import pandas as pd

fake = Faker('pl_PL')
fake.add_provider(VehicleProvider)

N_USERS = 100000  # Number of users
N_CARS = 100  # Number of cars
N_CAR_STATES = 3000  # Number of car states per car (amount of car states >= N_CARS * N_PRICE_INCREASE)
N_PRICE_INCREASES = 3  # Number of pricelist changes

start_date = datetime(2023, 1, 1)
end_date = datetime(2024, 1, 1)

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

# Generate a unique identifier for the current run
run_id = datetime.now().strftime("%Y%m%d%H%M%S")

# Define file paths with the unique identifier
users_file_path = f'../users_{run_id}.csv'
pricelists_file_path = f'../pricelists_{run_id}.csv'
cars_file_path = f'../cars_{run_id}.csv'
car_states_file_path = f'../cars_states_{run_id}.csv'
rentals_file_path = f'../rentals_{run_id}.csv'


# Function to get the last ID from a CSV file
def get_last_id(file_path, id_column):
    try:
        with open(file_path, 'r') as file:
            reader = csv.DictReader(file)
            rows = list(reader)
            if rows:
                return int(rows[-1][id_column])
    except FileNotFoundError:
        return 0
    return 0


# Load the last used IDs from existing CSV files
id_state = {}

def id_state_update():
    global id_state
    id_state = {
        "user_id": get_last_id('../users.csv', 'User_ID'),
        "car_id": get_last_id('../cars.csv', 'Car_ID'),
        "car_state_id": get_last_id('../cars_states.csv', 'Car_state_ID'),
        "rental_id": get_last_id('../rentals.csv', 'Rental_ID'),
        "pricelist_id": get_last_id('../pricelists.csv', 'Pricelist_ID')
    }


def create_users_file(start_date, end_date):
    global id_state
    with open(users_file_path, mode='a', newline='', encoding='cp1250') as file:
        writer = csv.writer(file)
        writer.writerow(
            ["User_ID", "First_name", "Last_name", "PESEL", "Driving_license_ID", "License_receiving_date",
             "Nationality", "E-mail", "Password"]
        )

        for i in range(N_USERS):
            id_state["user_id"] += 1
            birth_date = fake.date_of_birth(minimum_age=18, maximum_age=65)
            min_license_date = birth_date + timedelta(days=18 * 365)
            today = date.today()
            end_date_date = end_date.date()
            max_license_date = min(end_date_date,
                                   today if min_license_date < today else min_license_date + timedelta(days=365))

            if min_license_date >= max_license_date:
                max_license_date = min_license_date + timedelta(days=1)

            license_receiving_date = fake.date_between_dates(min_license_date, max_license_date)
            gender = random.choice(['M', 'F'])
            first_name = fake.first_name_male() if gender == 'M' else fake.first_name_female()
            last_name = fake.last_name_male() if gender == 'M' else fake.last_name_female()
            nationalities = ['Poland', 'Other']
            weights = [0.8, 0.2]
            nationality = random.choices(nationalities, weights)[0]

            writer.writerow(
                [
                    id_state["user_id"],
                    first_name,
                    last_name,
                    fake.pesel(date_of_birth=datetime.combine(birth_date, datetime.min.time()), sex=gender),
                    fake.random_int(min=100000, max=999999),
                    license_receiving_date,
                    nationality,
                    fake.email(),
                    fake.password()
                ]
            )
            print(f"User record for user {id_state['user_id']} created.")


# Pricelist [i] - non-luxury, [i + 1] - semi-luxury, [i + 2] - luxury
# Zakładamy PRICE_INCREASE podwyżek cen
# [Pricelist_ID, Starting_price, Layover_price, Price_per_km]
pricelists = [[i + 1, 4 + 0.5 * i, 0.1 + i * 0.02, 1.7 + i * 0.2] for i in range(N_PRICE_INCREASES + 2)]


def create_pricelists_file():
    global id_state
    with open(pricelists_file_path, mode='a', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(["Pricelist_ID", "Starting_price", "Layover_price", "Price_per_km"])

        for i in range(N_PRICE_INCREASES + 2):
            id_state["pricelist_id"] += 1
            writer.writerow([id_state["pricelist_id"], 4 + 0.5 * i, 0.1 + i * 0.02, 1.7 + i * 0.2])
            print(f"Pricelist record for pricelist {id_state['pricelist_id']} created.")


def get_pricelist_from_csv(pricelist_id):
    with open(pricelists_file_path, mode='r') as file:
        reader = csv.DictReader(file)
        for row in reader:
            if int(row['Pricelist_ID']) == pricelist_id:
                return {
                    "Starting_price": float(row['Starting_price']),
                    "Layover_price": float(row['Layover_price']),
                    "Price_per_km": float(row['Price_per_km'])
                }
    return None


def get_existing_data(file_path, id_column):
    data = []
    try:
        with open(file_path, 'r') as file:
            reader = csv.DictReader(file)
            for row in reader:
                data.append(row)
    except FileNotFoundError:
        pass
    return data


def create_cars():
    global id_state
    with open(cars_file_path, mode='a', newline='') as cars_file:
        cars_writer = csv.writer(cars_file)
        cars_writer.writerow(
            ["Car_ID", "Brand", "Model", "Engine_power", "Manual", "License_plate_number"]
        )

        for i in range(N_CARS):
            id_state["car_id"] += 1
            brand_and_model = random.choice(car_brands_and_models)
            cars_writer.writerow(
                [
                    id_state["car_id"],
                    brand_and_model[0],
                    brand_and_model[1],
                    random.choice(brand_and_model[2]),
                    int(fake.boolean(chance_of_getting_true=50)),
                    fake.license_plate(),
                ]
            )
            print(f"Car record for car {id_state['car_id']} created.")


def create_car_states():
    global id_state

    # Read existing cars from the old CSV file
    existing_cars_old = get_existing_data('../cars.csv', 'Car_ID')
    # Read newly created cars from the new CSV file
    existing_cars_new = get_existing_data(cars_file_path, 'Car_ID')
    # Combine both lists of cars
    existing_cars = existing_cars_old + existing_cars_new

    # Read newly created pricelists from the new CSV file
    existing_pricelists = get_existing_data(pricelists_file_path, 'Pricelist_ID')

    with open(car_states_file_path, mode='a', newline='') as car_states_file:
        car_states_writer = csv.writer(car_states_file)
        car_states_writer.writerow(
            ["Car_state_ID", "Is_broken", "Is_used", "Location", "Is_active", "Car_ID", "Pricelist_ID"]
        )

        for car in existing_cars:
            for pricelist in existing_pricelists:
                id_state["car_state_id"] += 1
                is_broken = int(fake.boolean(chance_of_getting_true=2))
                is_used = 0 if is_broken else int(fake.boolean(chance_of_getting_true=30))
                is_active = int(pricelist['Pricelist_ID'] == existing_pricelists[-1]['Pricelist_ID'])

                car_states_writer.writerow(
                    [
                        id_state["car_state_id"],
                        is_broken,
                        is_used,
                        utills.generate_random_city_coordinates()[1],
                        is_active,
                        car['Car_ID'],
                        pricelist['Pricelist_ID']
                    ]
                )
                print(f"Car state record for car {car['Car_ID']} created.")


def create_rentals(start_date, end_date):
    global id_state

    # Read existing cars and pricelists from CSV files
    existing_car_states = get_existing_data(car_states_file_path, 'Car_state_ID')

    # Read existing users from the old CSV file
    existing_users_old = get_existing_data('../users.csv', 'User_ID')
    # Read newly created users from the new CSV file
    existing_users_new = get_existing_data(users_file_path, 'User_ID')
    # Combine both lists of users into a single dictionary
    existing_users = {user['User_ID']: user for user in (existing_users_old + existing_users_new)}

    # Convert dictionary values to a list
    existing_users_list = list(existing_users.values())

    total_days = (end_date - start_date).days
    period_duration = total_days // len(pricelists)

    with open(rentals_file_path, mode='a', newline='') as rentals_file:
        rentals_writer = csv.writer(rentals_file)
        rentals_writer.writerow(
            ["Rental_ID", "Rental_date_start", "Rental_date_end",
             "Start_location", "End_location", "Driven_km", "Layover_time",
             "Total_cost", "Car_state_ID", "User_ID"]
        )

        for car_state in existing_car_states:
            for idx, pricelist in enumerate(pricelists):
                rental_periods = []

                period_start_date = start_date + timedelta(days=idx * period_duration)
                period_end_date = period_start_date + timedelta(days=period_duration)

                for k in range(random.randint(0, 2 * N_CAR_STATES)):
                    id_state["rental_id"] += 1
                    city = random.choice(list(cities_coordinates.keys()))
                    _, coordinates_start = utills.generate_random_city_coordinates(city=city)
                    _, coordinates_end = utills.generate_random_city_coordinates(city=city)

                    rental_start_date = fake.date_time_between(start_date=period_start_date, end_date=period_end_date)
                    max_end_date = rental_start_date + timedelta(hours=5, minutes=59, seconds=59)
                    rental_end_date = fake.date_time_between(start_date=rental_start_date,
                                                             end_date=min(max_end_date, period_end_date))

                    if rental_end_date <= rental_start_date:
                        rental_end_date = rental_start_date + timedelta(hours=1)

                    overlap_found = False
                    for period in rental_periods:
                        if rental_start_date < period[1] and rental_end_date > period[0]:
                            overlap_found = True
                            break

                    if not overlap_found:
                        rental_periods.append((rental_start_date, rental_end_date))
                    else:
                        continue

                    user = random.choice(existing_users_list)
                    license_receiving_date = datetime.strptime(user['License_receiving_date'], "%Y-%m-%d")
                    if license_receiving_date > rental_start_date:
                        continue

                    user_id = user['User_ID']
                    driven_km = utills.calc_distance(coordinates_start, coordinates_end) + fake.random_int(min=1,
                                                                                                           max=30)
                    layover_time = random.randint(0, 24)

                    total_cost = (pricelist[1] +
                                  pricelist[2] * layover_time +
                                  pricelist[3] * driven_km)

                    rentals_writer.writerow(
                        [
                            id_state["rental_id"],
                            rental_start_date.strftime("%Y-%m-%d %H:%M:%S"),
                            rental_end_date.strftime("%Y-%m-%d %H:%M:%S"),
                            coordinates_start,
                            coordinates_end,
                            driven_km,
                            layover_time,
                            round(total_cost, 2),
                            car_state['Car_state_ID'],
                            user_id
                        ]
                    )
                    print(f"Rental record for car {car_state['Car_state_ID']} created.")


def main():
    date_pattern = re.compile(r'_\d{8}\d{6}')

# Iterate over files in the current directory
    for filename in os.listdir('../'):
        # Check if the filename matches the date pattern
        if date_pattern.search(filename):
            # Remove the date from the filename
            new_filename = date_pattern.sub('', filename)
        # Rename the file
            os.rename(f'../{filename}', f'../{new_filename}')
            print(f'Renamed: {filename} -> {new_filename}')
    id_state_update()
    create_users_file(start_date, end_date)
    create_pricelists_file()
    create_cars()
    create_car_states()
    create_rentals(start_date, end_date)


if __name__ == "__main__":
    main()
