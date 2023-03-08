# Спасибо статейке:
# https://habr.com/ru/post/322086/
# И, конечно, документации:
# http://docs.peewee-orm.com
# -----------------------------------
# таблица связи между типом поля в нашей модели и в базе данных:
# http://docs.peewee-orm.com/en/latest/peewee/models.html#field-types-table

from peewee import *

from colors import *

# Подключаемся к нашей БД.
con = PostgresqlDatabase(
    database="agency",
    user="postgres",
    password="postgres",
    host="127.0.0.1",  # Адрес сервера базы данных.
    port="5431"  # Номер порта.
)


class BaseModel(Model):
    class Meta:
        database = con

class Agency(BaseModel):
    id = IntegerField(column_name='id')
    name_ag = CharField(column_name='name_ag')
    addr = CharField(column_name='addr')
    phone = IntegerField(column_name='phone')
    director = CharField(column_name='director')

    class Meta:
        table_name = 'agency_table'

class Client(BaseModel):
    id = IntegerField(column_name='id')
    name_cl = CharField(column_name='name_cl')
    surname = CharField(column_name='surname')
    phone = IntegerField(column_name='phone')
    agency = IntegerField(column_name='agency')
    #agency_id = ForeignKeyField(Agency, backref='agency')

    class Meta:
        table_name = 'client_table'

class Country(BaseModel):
    id = IntegerField(column_name='id')
    name_c = CharField(column_name='name_c')
    area = IntegerField(column_name='area')
    season = CharField(column_name='season')
    lang = CharField(column_name='lang')

    class Meta:
        table_name = 'country_table'

class Hotel(BaseModel):
    id = IntegerField(column_name='id')
    #country_id = ForeignKeyField(Country, backref='country')
    country = IntegerField(column_name='country')
    count_rooms = IntegerField(column_name='count_rooms')
    name_h = CharField(column_name='name_h')
    cat_hotel = IntegerField(column_name='cat_hotel')
    night_price = IntegerField(column_name='night_price')

    class Meta:
        table_name = 'hotel_table'

class Tour(BaseModel):
    id = IntegerField(column_name='id')
    rating_tour = IntegerField(column_name='rating_tour')
    count_nights = IntegerField(column_name='count_nights')
    type_t = CharField(column_name='type_t')
    eat_type = IntegerField(column_name='eat_type')

    class Meta:
        table_name = 'tour_table'

def query_1():
    # 1. Однотабличный запрос на выборку.
    tour = Tour.get(Tour.id == 1)
    print(GREEN, f'{"1. Однотабличный запрос на выборку:":^130}')
    print(tour.id, tour.rating_tour, tour.count_nights, tour.type_t, tour.eat_type)

    # Получаем набор записей.
    query = Tour.select().where(Tour.rating_tour > 3).limit(5).order_by(Tour.id)

    #print(BLUE, f'\n{"Запрос:":^130}\n\n', query, '\n')

    tours_selected = query.dicts().execute()

    print(YELLOW, f'\n{"Результат:":^130}\n')
    for elem in tours_selected:
        print(elem)


def query_2():
    # 2. Многотабличный запрос на выборку.
    global con
    print(GREEN, f'\n{"2. Многотабличный запрос на выборку:":^130}\n')

    print(BLUE, f'{"Отели и страны, в которых они состоят:":^130}\n')

    # Отели и страны, в которых они состоят
    query = Hotel.select(Hotel.id, Country.name_c).join(Country, on=(Hotel.country == Country.id))

    new_table = query.dicts().execute()
    for elem in new_table:
        print(elem)


def print_last_five_clients():
    # Вывод последних 5-ти записей.
    print(BLUE, f'\n{"Последние 5 клиентов:":^130}\n')
    query = Client.select().limit(5).order_by(Client.id.desc())
    for elem in query.dicts().execute():
        print(elem)
    print()


def add_client(new_id, new_name_cl, new_surname, new_phone, new_agency):
    global con

    try:
        with con.atomic() as txn:
            # client = Client.get(Client.id == new_id)
            Client.create(id=new_id, name_cl=new_name_cl, surname=new_surname, phone=new_phone,
                         agency=new_agency)
            print(GREEN, "Клиент успешно добавлен!")
    except:
        print(YELLOW, "Клиент уже существует!")
        txn.rollback()


def update_name_cl(client_id, new_name_cl):
    client = Client(id=client_id)
    client.name_cl = new_name_cl
    client.save()
    print(GREEN, "Имя успешно обновлено!")


def del_client(client_id):
    print(GREEN, "Клиент успешно удален!")
    client = Client.get(Client.id == client_id)
    client.delete_instance()


def query_3():
    # 3. Три запроса на добавление, изменение и удаление данных в базе данных.
    print(GREEN, f'\n{"3. Три запроса на добавление, изменение и удаление данных в базе данных:":^130}\n')

    print_last_five_clients()

    add_client(1020, 'Marina', 'Kiseleva', 456834, 550)
    print_last_five_clients()

    update_name_cl(1020, 'Lisa')
    print_last_five_clients()

    del_client(1020)
    print_last_five_clients()


def query_4():
    # 4. Получение доступа к данным, выполняя только хранимую процедуру.
    global con
    # Можно выполнять простые запросы.
    cursor = con.cursor()

    print(GREEN, f'\n{"4. Получение доступа к данным, выполняя только хранимую процедуру:":^130}\n')

    # cursor.execute("SELECT * FROM client_table ORDER BY id DESC LIMIT 5;")
    # for elem in cursor.fetchall():
    # 	print(*elem)

    print_last_five_clients()

    cursor.execute("CALL insert_client(%s, %s, %s, %s, %s);", (1020, 'Lena', 'Fredca', 465345, 234))
    # # Фиксируем изменения.
    # # Т.е. посылаем команду в бд.
    # # Метод commit() помогает нам применить изменения,
    # # которые мы внесли в базу данных,
    # # и эти изменения не могут быть отменены,
    # # если commit() выполнится успешно.
    con.commit()

    print_last_five_clients()

    cursor.execute("CALL insert_client(%s, %s, %s, %s, %s);", (1025, 'Fedak', 'Dank', 34675, 876))
    con.commit()

    print_last_five_clients()

    cursor.close()


def task_3():
    global con

    query_1()
    query_2()
    query_3()
    query_4()

    con.close()