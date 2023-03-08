from time import time

import matplotlib.pyplot as plt
import psycopg2
import redis
import json
import threading
from random import randint
from p import draw_plots

N_REPEATS = 5

def connection():
    # Подключаемся к БД.
    try:
        con = psycopg2.connect(
            database='postgres',
            user='postgres',
            password='postgres',
            host='127.0.0.1',
            port=5432
        )
    except:
        print("Ошибка при подключении к Базе Данных")
        return

    print("База данных успешно открыта")
    return con


# Написать запрос, получающий статистическую информацию на основе
# данных БД. Например, получение топ 10 самых покупаемых товаров или
# получение количества проданных деталей в каждом регионе.
# отель в заданной стране
def get_hotel_in_country(cur):
    redis_client = redis.Redis(host="localhost", port=6379, db=0)

    cache_value = redis_client.get("hotel_in_country")
    if cache_value is not None:
        redis_client.close()
        return json.loads(cache_value)

    cur.execute("select * from hotel_table where country = 844")
    res = cur.fetchall()

    redis_client.set("hotel_in_country", json.dumps(res))
    redis_client.close()

    return res


# 1. Приложение выполняет запрос каждые 5 секунд на стороне БД.
def task_02(cur, id):
    threading.Timer(5.0, task_02, [cur, id]).start()

    cur.execute(f"select * from hotel_table where country = {id}")

    result = cur.fetchall()

    return result


# 2. Приложение выполняет запрос каждые 5 секунд через Redis в качестве кэша.
def task_03(cur, id):
    threading.Timer(5.0, task_02, [cur, id]).start()

    redis_client = redis.Redis(host="localhost", port=6379, db=0)

    cache_value = redis_client.get(f"country{id}_hotel")
    if cache_value is not None:
        redis_client.close()
        return json.loads(cache_value)

    cur.execute(f"select * from hotel_table where country = {id}")

    result = cur.fetchall()
    data = json.dumps(result)
    redis_client.set(f"country{id}_hotel", data)
    redis_client.close()

    return result


def dont_do(cur):
    redis_client = redis.Redis()#host="localhost", port=6379, db=0)

    t1 = time()
    cur.execute("select * from hotel_table where country = 844")
    t2 = time()

    result = cur.fetchall()

    data = json.dumps(result)
    cache_value = redis_client.get("w1")
    if cache_value is not None:
        pass
    else:
        redis_client.set("w1", data)

    t11 = time()
    redis_client.get("w1")
    t22 = time()

    redis_client.close()

    return t2 - t1, t22 - t11


def del_hotel(cur, con):
    redis_client = redis.Redis()

    wid = randint(1, 1000)

    t1 = time()
    cur.execute(f"delete from hotel_table where id = {wid};")
    t2 = time()

    t11 = time()
    redis_client.delete(f"w{wid}")
    t22 = time()

    redis_client.close()

    con.commit()

    return t2 - t1, t22 - t11


def ins_hotel(cur, con, i):
    redis_client = redis.Redis()

    wid = 1

    t1 = time()
    cur.execute(f"insert into hotel_table (id, country, count_rooms, name_h, cat_hotel, night_price) "
                f"values ({i}, 536, 56, 'Paradise', 4, 675);")
    t2 = time()

    cur.execute(f"select * from hotel_table where id = {wid}")
    result = cur.fetchall()

    data = json.dumps(result)
    t11 = time()
    redis_client.set(f"w{wid}", data)
    t22 = time()

    redis_client.close()

    con.commit()

    return t2 - t1, t22 - t11


def upd_hotel(cur, con):
    redis_client = redis.Redis()
    # print("update\n")
    # threading.Timer(10.0, upd_tour, [cur, con]).start()

    wid = randint(1, 1000)

    t1 = time()
    cur.execute(f"UPDATE hotel_table SET country = 1 WHERE id = {wid}")
    t2 = time()

    cur.execute(f"select * from hotel_table where id = {wid};")

    result = cur.fetchall()
    data = json.dumps(result)

    t11 = time()
    redis_client.set(f"w{wid}", data)
    t22 = time()

    redis_client.close()

    con.commit()

    return t2 - t1, t22 - t11


# гистограммы
def task_04(cur, con):
    # simple
    t1 = 0
    t2 = 0
    for i in range(N_REPEATS):
        print(i)
        b1, b2 = dont_do(cur)
        t1 += b1
        t2 += b2
    print("simple 100 db redis", t1 / N_REPEATS, t2 / N_REPEATS)
    index = ["БД", "Redis"]
    values = [t1 / N_REPEATS, t2 / N_REPEATS]
    plt.bar(index, values)
    plt.title("Без изменения данных")
    plt.show()

    # delete
    t1 = 0
    t2 = 0
    for i in range(N_REPEATS):
        print(i)
        b1, b2 = del_hotel(cur, con)
        t1 += b1
        t2 += b2
    print("delete 100 db redis", t1 / N_REPEATS, t2 / N_REPEATS)

    index = ["БД", "Redis"]
    values = [t1 / N_REPEATS, t2 / N_REPEATS]
    plt.bar(index, values)
    plt.title("При удалении строк каждые 10 секунд")
    plt.show()

    # insert
    t1 = 0
    t2 = 0
    index = 10000
    for i in range(N_REPEATS):
        print(i)
        b1, b2 = ins_hotel(cur, con, index)
        index += 1
        t1 += b1
        t2 += b2
    print("ins_tour 100 db redis", t1 / N_REPEATS, t2 / N_REPEATS)

    index = ["БД", "Redis"]
    values = [t1 / N_REPEATS, t2 / N_REPEATS]
    plt.bar(index, values)
    plt.title("При добавлении строк каждые 10 секунд")
    plt.show()

    # updata
    t1 = 0
    t2 = 0
    for i in range(N_REPEATS):
        print(i)
        b1, b2 = upd_hotel(cur, con)
        t1 += b1
        t2 += b2
    print("updata 100 db redis", t1 / N_REPEATS, t2 / N_REPEATS)

    index = ["БД", "Redis"]
    values = [t1 / N_REPEATS, t2 / N_REPEATS]
    plt.bar(index, values)
    plt.title("При изменении строк каждые 10 секунд")
    plt.show()

if __name__ == '__main__':

    con = connection()
    cur = con.cursor()

    # do_cache(cur)
    #task_04(cur, con)

    print("1. Отели в стране 844 (задание 2)\n"
          "2. Приложение выполняет запрос каждые 5 секунд на стороне БД. (задание 3.1)\n"
          "3. Приложение выполняет запрос каждые 5 секунд через Redis в качестве кэша. (задание 3.2)\n"
          "4. Гистограммы (задание 3.3)\n\n"
          )

    while True:
        c = int(input("Выбор: "))

        if c == 1:
            res = get_hotel_in_country(cur)

            for elem in res:
                print(elem)

        elif c == 2:
            dep_id = int(input("Данные об отелях: "))

            res = task_02(cur, dep_id)

            for elem in res:
                print(elem)

        elif c == 3:
            dep_id = int(input("Данные об отелях: "))

            res = task_03(cur, dep_id)

            for elem in res:
                print(elem)

        elif c == 4:
            task_04(cur, con)
            #draw_plots()
        else:
            print("Ошибка\n")
            break

    cur.close()

    print("BY!")