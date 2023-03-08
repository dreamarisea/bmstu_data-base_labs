from faker import Faker
from random import randint
from random import choice

MAX_N = 1001

t_tour = ["beach", "excursion", "sports", "quiet", "mobile"]
eat = [1, 2, 3]
seasons = ["winter", "summer", "spring", "fall"]

cat_hotel = [1, 2, 3, 4, 5]

def generate_countries():
    with open('countries.txt') as file:
        countries = [row.strip() for row in file]
    with open('languages.txt') as file:
        languages = [row.strip() for row in file]
    f = open('countries.csv', 'w')
    for i in range(MAX_N):
        id = i
        area = randint(300, 2000000)
        line = "{0};{1};{2};{3};{4}\n".format(
            id,
            choice(countries),
            area,
            choice(seasons),
            choice(languages)
        )
        f.write(line)
    f.close()

def generate_hotels():
    faker = Faker()
    f = open('hotels.csv', 'w')
    for i in range(MAX_N):
        id = i
        country = randint(1, 1000)
        count_rooms = randint(1, 800)
        night_price = randint(100, 100000)
        line = "{0};{1};{2};{3};{4};{5}\n".format(
            id,
            country,
            count_rooms,
            faker.name(),
            choice(cat_hotel),
            night_price
        )
        f.write(line)
    f.close()

def generate_tours():
    f = open('tours.csv', 'w')
    for i in range(MAX_N):
        id = i
        count_nights = randint(1, 30)
        rating_tour = randint(1, 5)
        line = "{0};{1};{2};{3};{4}\n".format(
            id,
            rating_tour,
            count_nights,
            choice(t_tour),
            choice(eat)
        )
        f.write(line)
    f.close()


def generate_clients():
    faker = Faker()
    f = open('clients.csv', 'w')
    with open('surname.txt') as file:
        surname = [row.strip() for row in file]
    for i in range(MAX_N):
        id = i
        phone = randint(10000000000, 99999999999)
        agency = randint(1, 1000)
        line = "{0};{1};{2};{3};{4}\n".format(
            id,
            faker.name()[:5],
            choice(surname),
            phone,
            agency
        )
        f.write(line)
    f.close()


def generate_agencies():
    faker = Faker()
    f = open('agencies.csv', 'w')
    for i in range(MAX_N):
        id = i
        addr = faker.address()
        addr = addr.replace('\n', '=')
        phone = randint(10000000000, 99999999999)
        line = "{0};{1};{2};{3};{4};{5}\n".format(
            id,
            faker.name()[:5],
            addr,
            phone,
            faker.phone_number()[2:8] + "@dat.com",
            "Dir " + faker.name(),
        )
        f.write(line)
    f.close()


if __name__ == "__main__":
    generate_agencies()
    generate_clients()
    generate_tours()
    generate_hotels()
    generate_countries()