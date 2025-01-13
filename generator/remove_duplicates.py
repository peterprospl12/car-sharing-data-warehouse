import csv
from datetime import datetime

from faker import Faker
import os
import random

fake = Faker('pl_PL')
def generate_random_pesel():
    """Generuje losowy, 11-cyfrowy ciąg liczb jako PESEL."""
    return ''.join(str(random.randint(0, 9)) for _ in range(11))

def generate_random_driving_license_id():
    """Generuje losowy, 10-cyfrowy ciąg liczb jako numer prawa jazdy."""
    return ''.join(str(random.randint(0, 9)) for _ in range(6))

def replace_duplicate_emails(file_path):
    unique_emails = set()
    rows = []
    temp_file = file_path + '.temp'  # Tworzymy plik tymczasowy

    # Wczytanie pliku CSV i generowanie unikalnych e-maili
    with open(file_path, 'r', newline='', encoding='utf-8') as file:
        reader = csv.DictReader(file)
        fieldnames = reader.fieldnames  # Przechowujemy nagłówki kolumn
        for row in reader:
            original_email = row['E-mail']
            while row['E-mail'] in unique_emails:  # Unikamy duplikatów
                row['E-mail'] = fake.email()
            unique_emails.add(row['E-mail'])
            rows.append(row)

    # Zapisanie do nowego pliku
    with open(temp_file, 'w', newline='', encoding='utf-8') as file:
        writer = csv.DictWriter(file, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)

    # Zamiana oryginalnego pliku na plik tymczasowy
    os.replace(temp_file, file_path)  # Nadpisanie oryginalnego pliku

def replace_duplicate_pesel(file_path):
    unique_pesels = set()
    rows = []
    temp_file = file_path + '.temp'  # Tworzymy plik tymczasowy

    # Wczytanie pliku CSV i generowanie unikalnych PESEL-i
    with open(file_path, 'r', newline='', encoding='utf-8') as file:
        reader = csv.DictReader(file)
        fieldnames = reader.fieldnames  # Przechowujemy nagłówki kolumn
        if 'PESEL' not in fieldnames:
            raise ValueError("CSV file does not contain 'PESEL' column")
        for row in reader:
            original_pesel = row['PESEL']
            birth_date = fake.date_of_birth(minimum_age=18, maximum_age=65)
            while row['PESEL'] in unique_pesels:
                row['PESEL'] = fake.pesel(date_of_birth=datetime.combine(birth_date, datetime.min.time()))
                print(f'Zmieniono PESEL z {original_pesel} na {row["PESEL"]}')
            unique_pesels.add(row['PESEL'])
            rows.append(row)

    # Zapisanie do nowego pliku
    with open(temp_file, 'w', newline='', encoding='utf-8') as file:
        writer = csv.DictWriter(file, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)

    # Zamiana oryginalnego pliku na plik tymczasowy
    os.replace(temp_file, file_path)  # Nadpisanie oryginalnego pliku

def replace_duplicate_driving_license_id(file_path):
    unique_pesels = set()
    rows = []
    temp_file = file_path + '.temp'  # Tworzymy plik tymczasowy

    # Wczytanie pliku CSV i generowanie unikalnych Driving_license_ID-i
    with open(file_path, 'r', newline='', encoding='utf-8') as file:
        reader = csv.DictReader(file)
        fieldnames = reader.fieldnames  # Przechowujemy nagłówki kolumn
        if 'Driving_license_ID' not in fieldnames:
            raise ValueError("CSV file does not contain 'Driving_license_ID' column")
        for row in reader:
            original_pesel = row['Driving_license_ID']
            while row['Driving_license_ID'] in unique_pesels:
                row['Driving_license_ID'] = generate_random_pesel()  # Generowanie nowego Driving_license_ID
                print(f'Zmieniono Driving_license_ID z {original_pesel} na {row["Driving_license_ID"]}')
            unique_pesels.add(row['Driving_license_ID'])
            rows.append(row)

    # Zapisanie do nowego pliku
    with open(temp_file, 'w', newline='', encoding='utf-8') as file:
        writer = csv.DictWriter(file, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)

    # Zamiana oryginalnego pliku na plik tymczasowy
    os.replace(temp_file, file_path)  # Nadpisanie oryginalnego pliku

if __name__ == "__main__":
    replace_duplicate_pesel('../users.csv')
