from execute_tasks import *


def task1(cur, con = None):
    root_1 = Tk()

    root_1.title('Задание 1')
    root_1.geometry("300x200")
    root_1.configure(bg="lavender")
    root_1.resizable(width=False, height=False)

    Label(root_1, text="  Введите id:", bg="lavender").place(
        x=75, y=50)
    agency_id = Entry(root_1)
    agency_id.place(x=75, y=85, width=150)

    b = Button(root_1, text="Выполнить",
               command=lambda arg1=cur, arg2=agency_id: execute_task1(arg1, arg2),  bg="thistle3")
    b.place(x=75, y=120, width=150)

    root_1.mainloop()


def task2(cur, con = None):
    # Статистика по агенствам.
    # Сколько человек состоят в
    # том или ином агенстве.
    cur.execute("SELECT agency, COUNT(agency) \
                FROM client_table\
                JOIN agency_table \
                ON client_table.id = agency_table.id \
                GROUP BY agency \
                ORDER BY agency;")

    rows = cur.fetchall()

    create_list_box(rows, "Задание 2")


def task3(cur, con = None):
    # Добавить столбец с суммой ночей по рейтингу.
    cur.execute("\
    with otv (id, rating_tour, type_t, sum) \
    AS \
    ( \
        select id, rating_tour, type_t, count_nights, SUM(count_nights) OVER(PARTITION BY rating_tour) sum \
        from tour_table \
    ) \
    SELECT * FROM otv;")
    rows = cur.fetchall()
    create_list_box(rows, "Задание 3")


def task4(cur, con):

    root_1 = Tk()

    root_1.title('Задание 4')
    root_1.geometry("300x200")
    root_1.configure(bg="lavender")
    root_1.resizable(width=False, height=False)

    Label(root_1, text="Введите название таблицы:", bg="lavender").place(
        x=65, y=50)
    name = Entry(root_1)
    name.place(x=75, y=85, width=150)

    b = Button(root_1, text="Выполнить",
               command=lambda arg1=cur, arg2=name: execute_task4(arg1, arg2, con),  bg="thistle3")
    b.place(x=75, y=120, width=150)

    root_1.mainloop()


def task5(cur, con = None):
    cur.execute("SELECT get_max_nights_count() AS max_nights;")

    #Fetch the next row of a query result set, returning a single tuple, or None when no more data is available

    row = cur.fetchone()

    mb.showinfo(title="Результат",
                message=f"Максимальное кол-во ночей в туре: {row[0]}")

def task6(cur, con = None):
    root = Tk()

    root.title('Задание 6')
    root.geometry("300x200")
    root.configure(bg="lavender")
    root.resizable(width=False, height=False)

    Label(root, text="  Введите границы опыта:", bg="lavender").place(
        x=75, y=50)
    l_exp = Entry(root)
    l_exp.place(x=75, y=75, width=150)
    h_exp = Entry(root)
    h_exp.place(x=75, y=95, width=150)

    b = Button(root, text="Выполнить",
               command=lambda arg1=cur, arg2=l_exp, arg3=h_exp: execute_task6(arg1, arg2, arg3),  bg="thistle3")
    b.place(x=75, y=120, width=150)

    root.mainloop()


def task7(cur, con=None):
    root = Tk()

    root.title('Задание 7')
    root.geometry("300x400")
    root.configure(bg="lavender")
    root.resizable(width=False, height=False)

    names = ["идентификатор",
             "название страны",
             "площадь",
             "сезон для посещения",
             "язык"]

    param = list()

    i = 0
    for elem in names:
        Label(root, text=f"Введите {elem}:",
              bg="lavender").place(x=70, y=i + 25)
        elem = Entry(root)
        i += 50
        elem.place(x=70, y=i, width=150)
        param.append(elem)

    b = Button(root, text="Выполнить",
               command=lambda: execute_task7(cur, param, con),  bg="thistle3")
    b.place(x=70, y=300, width=150)

    root.mainloop()


def task8(cur, con = None):
    cur.execute(
        "SELECT pg_postmaster_start_time();")
    time = cur.fetchone()[0].strftime("%Y-%m-%d %H:%M:%S")
    mb.showinfo(title="Информация",
                message=f"Время запуска сервера:\n{time}")


def task9(cur, con):
    cur.execute("drop table if exists plane_table;")
    cur.execute(" \
        CREATE TABLE IF NOT EXISTS plane_table \
        ( \
            tour integer, \
            FOREIGN KEY (tour) REFERENCES tour_table(id), \
            model varchar, \
            cost_for_flight integer \
        ) ")

    con.commit()

    mb.showinfo(title="Информация",
                message="Таблица успешно создана!")


def task10(cur, con):
    root = Tk()

    root.title('Задание 10')
    root.geometry("400x300")
    root.configure(bg="lavender")
    root.resizable(width=False, height=False)

    names = ["номер тура",
             "модель самолета",
             "цена за полёт"]

    param = list()

    i = 0
    for elem in names:
        Label(root, text=f"Введите {elem}:",
              bg="lavender").place(x=70, y=i + 25)
        elem = Entry(root)
        i += 50
        elem.place(x=115, y=i, width=150)
        param.append(elem)

    b = Button(root, text="Выполнить",
               command=lambda: execute_task10(cur, param, con),  bg="thistle3")
    b.place(x=115, y=200, width=150)

    root.mainloop()