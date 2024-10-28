import csv
import random
from faker import Faker
from datetime import datetime
import pandas as pd

fake = Faker()

def create_damage_csv():
    # Read existing data
    cars = pd.read_csv('../cars.csv')
    users = pd.read_csv('../users.csv')
    rentals = pd.read_csv('../rentals.csv')
    car_states = pd.read_csv('../cars_states.csv')

    # Convert date strings to datetime objects
    rentals['Rental_date_start'] = pd.to_datetime(rentals['Rental_date_start'])
    rentals['Rental_date_end'] = pd.to_datetime(rentals['Rental_date_end'])

    with open('../damages.csv', mode='w', newline='') as damages_file:
        damages_writer = csv.writer(damages_file)
        damages_writer.writerow(
            ['Car_id', 'Car_brand', 'Car_model', 'Damage_report_date', 'User_id', 'Rental_id', 'Repair_cost', 'Description']
        )

        for _ in range(5):  # Generate 100 damage records
            rental = rentals.sample(n=1).iloc[0]
            car_state = car_states[car_states['Car_state_ID'] == rental['Car_state_ID']]
            user = users[users['User_ID'] == rental['User_ID']]

            if not car_state.empty and not user.empty:
                car_state = car_state.iloc[0]
                car = cars[cars['Car_ID'] == car_state['Car_ID']].iloc[0]
                user = user.iloc[0]

                damage_report_date = fake.date_time_between(start_date=rental['Rental_date_start'], end_date=rental['Rental_date_end'])
                repair_cost = round(random.uniform(100.0, 10000.0), 2)
                description = fake.sentence(nb_words=6)

                damages_writer.writerow([
                    car['Car_ID'],
                    car['Brand'],
                    car['Model'],
                    damage_report_date.strftime("%Y-%m-%d %H:%M:%S"),
                    user['User_ID'],
                    rental['Rental_ID'],
                    repair_cost,
                    description,
                ])
                print(f"Damage record for car {car['Car_ID']} created.")
            else:
                print(f"Skipping record due to missing car or user for rental ID {rental['Rental_ID']}")

def main():
    create_damage_csv()

if __name__ == "__main__":
    main()