class client():
    # Структура полностью соответствует таблице clients.
    id = int()
    name_cl = str()
    surname = str()
    phone = int()
    agency = int()

    def __init__(self, id, name_cl, surname, phone, agency):
        self.id = id
        self.name_cl = name_cl
        self.surname = surname
        self.phone = phone
        self.agency = agency

    def get(self):
        return {'id': self.id, 'name_cl': self.name_cl, 'surname': self.surname,
                'phone': self.phone, 'agency': self.agency}

    def __str__(self):
        return f"{self.id:<5} {self.name_cl:<30} {self.surname:<30} {self.phone:<15} {self.agency:<5}"

class country():
    id = int()
    name_c = str()
    area = int()
    season = str()
    lang = str()

    def __init__(self, id, name_c, area, season, lang):
        self.id = id
        self.name_c = name_c
        self.area = area
        self.season = season
        self.lang = lang

    def get(self):
        return {'id': self.id, 'name_c': self.name_c, 'area': self.area,
                'season': self.season, 'lang': self.lang}

    def __str__(self):
        return f"{self.id:<5} {self.name_c:<30} {self.area:<30} {self.season:<15} {self.lang:<15}"

def create_countries(file_name):
    file = open(file_name, 'r')
    countries = list()

    for line in file:
        arr = line.split(';')
        arr[0], arr[2] = int(arr[0]), int(arr[2])
        countries.append(country(*arr).get())

    return countries



def create_clients(file_name):
    # Содает коллекцию объектов.
    # Загружая туда данные из файла file_name.
    file = open(file_name, 'r')
    clients = list()

    for line in file:
        arr = line.split(';')
        arr[0], arr[3], arr[4] = int(
            arr[0]), int(arr[3]), int(arr[4])
        clients.append(client(*arr).get())

    return clients