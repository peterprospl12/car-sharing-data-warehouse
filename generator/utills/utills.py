import random

cities_coordinates = {
    "Warszawa": (52.2297, 21.0122),
    "Kraków": (50.0647, 19.9450),
    "Gdańsk": (54.3520, 18.6466),
    "Wrocław": (51.1079, 17.0385),
    "Poznań": (52.4064, 16.9252),
    "Łódź": (51.7592, 19.4560),
}


# radius = 0.2 means that the generated coordinates will be in the range of 0.2 degrees from the city center (+- 20km)
def generate_coordinates(city, radius=0.2):
    lat, lon = cities_coordinates[city]

    latitude = lat + random.uniform(-radius, radius)
    longitude = lon + random.uniform(-radius, radius)

    return f'{latitude} {longitude}'


def generate_random_city_coordinates(city=random.choice(list(cities_coordinates.keys()))):
    return city, generate_coordinates(city)