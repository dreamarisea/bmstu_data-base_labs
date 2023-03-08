from faker import Faker
from random import randint, choice
import datetime
import time
import json

class country():
    country_id = int()
    name_c = str()
    area = int()
    season = str()
    lang = str()

    def __init__(self, country_id, name_c, area, season, lang):
        self.country_id = country_id
        self.name_c = name_c
        self.area = area
        self.season = season
        self.lang = lang

    def get(self):
        return {'country_id': self.country_id, 'name_c': self.name_c, 'area': self.area,
                'season': self.season, 'lang': self.lang}

    def __str__(self):
        return f"{self.country_id:<5} {self.name_c:<30} {self.area:<30} {self.season:<15} {self.lang:<15}"


def main():
    faker = Faker()  # faker.name()
    season = ["summer", "winter", "spring", "fall"]
    lang = ["English", "Swedish", "Croatian", "French", "Spanish", "Chinese", "Korean"]
    i = 0

    while True:
        obj = country(i, faker.name(), randint(300, 2000000), choice(season), choice(lang))

        # print(obj)
        # print(json.dumps(obj.get()))

        file_name = "nifi/in_file/country_" + str(i) + "_" + \
                    str(datetime.datetime.now().strftime("%d-%m-%Y_%H-%M-%S")) + ".json"

        print(file_name)
        i += 1

        with open(file_name, "w") as f:
            print(json.dumps(obj.get()), file=f)

        time.sleep(5)


if __name__ == "__main__":
    main()



