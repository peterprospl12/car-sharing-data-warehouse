import csv
import glob
import random
from faker import Faker
from datetime import datetime
import pandas as pd

fake = Faker()

# Define the constant date to split the data
SPLIT_DATE = datetime(2024, 1, 1)

def create_damage_csv():
    # Read existing data
    cars = pd.read_csv('../cars.csv', encoding='cp1250')
    users = pd.read_csv('../users.csv', encoding='cp1250')
    rentals = pd.read_csv('../rentals.csv', encoding='cp1250')
    car_states = pd.read_csv('../cars_states.csv', encoding='cp1250')

    cars_files = glob.glob('../cars_*.csv')
    users_files = glob.glob('../users_*.csv')
    rentals_files = glob.glob('../rentals_*.csv')
    car_states_files = glob.glob('../cars_states_*.csv')

    # # Read and concatenate all matching files
    # cars2 = pd.concat([pd.read_csv(f) for f in cars_files], ignore_index=True)
    # users2 = pd.concat([pd.read_csv(f, encoding='cp1250') for f in users_files], ignore_index=True)
    # rentals2 = pd.concat([pd.read_csv(f) for f in rentals_files], ignore_index=True)
    # car_states2 = pd.concat([pd.read_csv(f) for f in car_states_files], ignore_index=True)
    #
    # # Concatenate the original and new data
    # cars = pd.concat([cars, cars2], ignore_index=True)
    # users = pd.concat([users, users2], ignore_index=True)
    # rentals = pd.concat([rentals, rentals2], ignore_index=True)
    # car_states = pd.concat([car_states, car_states2], ignore_index=True)

    # Convert date strings to datetime objects
    rentals['Rental_date_start'] = pd.to_datetime(rentals['Rental_date_start'])
    rentals['Rental_date_end'] = pd.to_datetime(rentals['Rental_date_end'])

    with open('../damages.csv', mode='w', newline='', encoding='cp1250') as damages_file_before, \
            open('../damages_after_split.csv', mode='w', newline='', encoding='cp1250') as damages_file_after:

        damages_writer_before = csv.writer(damages_file_before)
        damages_writer_after = csv.writer(damages_file_after)

        header = ['Car_id', 'Car_brand', 'Car_model', 'Damage_report_date', 'User_id', 'Rental_id', 'Repair_cost', 'Description']
        damages_writer_before.writerow(header)
        damages_writer_after.writerow(header)

        for i in range(4000):  # Generate 100 damage records
            rental = rentals.sample(n=1).iloc[0]
            car_state = car_states[car_states['Car_state_ID'] == rental['Car_state_ID']]
            user = users[users['User_ID'] == rental['User_ID']]

            car_state = car_state.iloc[0]
            car = cars[cars['Car_ID'] == car_state['Car_ID']].iloc[0]
            user = user.iloc[0]

            damage_report_date = fake.date_time_between(start_date=rental['Rental_date_start'], end_date=rental['Rental_date_end'])
            repair_cost = round(random.uniform(100.0, 10000.0), 2)
            description = fake.sentence(nb_words=6)

            row = [
                car['Car_ID'],
                car['Brand'],
                car['Model'],
                damage_report_date.strftime("%Y-%m-%d %H:%M:%S"),
                user['User_ID'],
                rental['Rental_ID'],
                repair_cost,
                description,
            ]

            if damage_report_date < SPLIT_DATE:
                damages_writer_before.writerow(row)
            else:
                damages_writer_after.writerow(row)

            print(f"Damage record for car {car['Car_ID']} created.")
def main():
    create_damage_csv()

if __name__ == "__main__":
    main()