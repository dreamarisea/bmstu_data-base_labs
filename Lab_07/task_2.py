from clients import client
import json
import psycopg2

from colors import *


def connection():
    con = None
    # Подключаемся к БД.
    try:
        con = psycopg2.connect(
            database="agency",
            user="postgres",
            password="postgres",
            host="127.0.0.1",  # Адрес сервера базы данных.
            port="5431"		   # Номер порта.
        )
    except:
        print("Ошибка при подключении к БД")
        return con

    print("База данных успешно открыта")
    return con


def output_json(array):
    print(BLUE)
    for elem in array:
        print(json.dumps(elem.get()))
    print(YELLOW)


def read_table_json(cur, count=15):
    # Возвращает массив кортежей словарей.
    cur.execute("select * from clients_json")

    # with open('data/task_2.json', 'w') as f:
    # f.write(rows)

    rows = cur.fetchmany(count)

    array = list()
    for elem in rows:
        tmp = elem[0]
        print(elem[0], sep=' ', end='\n')
        array.append(client(tmp['id'], tmp['name_cl'], tmp['surname'], tmp['phone'],
                          tmp['agency']))

    #print(GREEN, f"{'id':<2} name_cl surname phone agency")
    print(*array, sep='\n')

    return array


def update_client(clients, in_id):
    # Увеличивает номер телефона пользователя.
    for elem in clients:
        if elem.id == in_id:
            elem.phone += 1

    # dumps - сериализация.
    # print(json.dumps(users[0].get()))
    output_json(clients)


def add_client(clients, client):
    clients.append(client)
    output_json(clients)


def task_2():
    con = connection()
    # Объект cursor используется для фактического
    # выполнения наших команд.
    cur = con.cursor()

    # 1. Чтение из XML/JSON документа.
    print(GREEN, f'{"1.Чтение из XML/JSON документа:":^130}')
    clients_array = read_table_json(cur)
    # 2. Обновление XML/JSON документа.
    print(BLUE, f'\n{"2.Обновление XML/JSON документа:":^130}')
    update_client(clients_array, 2)
    # 3. Запись (Добавление) в XML/JSON документ.
    print(BLUE, f'{"3.Запись (Добавление) в XML/JSON документ:":^130}')
    add_client(clients_array, client(1111, 'Marina', 'Kiseleva', 89039827667, 500))

    # Закрываем соединение с БД.
    cur.close()
    con.close()