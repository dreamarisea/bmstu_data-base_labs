# Документация:
# https://viralogic.github.io/py-enumerable/

from py_linq import *

from clients import *
from colors import *


def request_1(clients):
    # Клиенты с номером агенства >= 250 отсортированные по имени
    result = clients.where(lambda x: x['agency'] >= 250).order_by(lambda x: x['name_cl']).select(
        lambda x: {x['name_cl'], x['agency']})
    return result


# Отсортированные имена.
# names = clients.select(lambda x: x['name_cl']).order_by(lambda x: x)
# names = clients.select(lambda x: {x['name_cl'], x['age']})


def request_2(clients):
    # Необязательным параметром является условие
    # Количество клиентов, сотоящим в агенстве с номером >= 50
    result = clients.count(lambda x: x['agency'] >= 50)

    return result


def request_3(clients):
    # минимальный, максимальный номер агенства.
    agency = Enumerable([{clients.min(lambda x: x['agency']), clients.max(lambda x: x['agency'])}])
    # минимальный, минимальный номер телефона.
    phone = Enumerable([{clients.min(lambda x: x['phone']), clients.max(lambda x: x['phone'])}])
    # А теперь объединяем все это.
    result = Enumerable(agency).union(Enumerable(phone), lambda x: x)

    return result


def request_4(clients):
    # Группировка по агенству
    result = clients.group_by(key_names=['agency'], key=lambda x: x['agency']).select(
        lambda g: {'key': g.key.agency, 'count': g.count()})
    return result


def request_5(clients):
    agency = Enumerable([{'id': 491, 'name_ag': 'Paradise'}, {'id': 220, 'name_ag': 'Traveltime'}, {'id': 993, 'name_ag': 'Adventure'}])
    # inner_key = i_k первичный ключ
    # outer_key = o_k внешний ключ
    # inner join
    c_d = clients.join(agency, lambda o_k: o_k['agency'], lambda i_k: i_k['id'])

    for elem in c_d:
        print(elem)

    return c_d

def request_6(countries):
    result = countries.count(lambda x: x['area'] > 500000)
    return result

def task_1():
    # Создаем коллекцию.
    clients = Enumerable(create_clients('data/client.csv'))
    countries = Enumerable(create_countries('data/country.csv'))

    print(GREEN, '\n1.Клиенты с номером агенства >= 250 отсортированные по имени:\n')
    for elem in request_1(clients):
        print(elem)

    print(YELLOW, f'\n2.Количество клиентов, сотоящим в агенстве с номером >= 50: {str(request_2(clients))}')

    print(BLUE, '\n3.Некоторые характеристики:\n')
    for elem in request_3(clients):
        print(elem)

    print(GREEN, '\n4.Группировка по агенству:\n')
    for elem in request_4(clients):
        print(elem)

    print(GREEN, '\n5.Соединяем клиента и его агенство (название):\n')
    for elem in request_5(clients):
        print(elem)

    print('\n')

    countries = Enumerable(create_countries('data/country.csv'))

    print({str(request_6(countries))})