from tkinter import *
from tkinter import messagebox as mb


def create_list_box(rows, title, count=15, row=None):
    root = Tk()

    root.title(title)
    root.resizable(width=False, height=False)

    size = (count + 3) * len(rows[0]) + 1

    list_box = Listbox(root, width=size, height=22,
                       font="monospace 10", bg="lavender", highlightcolor='lavender',
                       selectbackground='#59405c', fg="#59405c")

    list_box.insert(END, " " * size)

    if row:
        list_box.insert(END, row)

    for row in rows:
        string = (("  {:^" + str(count) + "} ") * len(row)).format(*row) + ' '
        list_box.insert(END, string)

    list_box.insert(END, " " * size)

    list_box.grid(row=0, column=0)

    root.configure(bg="lavender")

    root.mainloop()


def execute_task1(cur, agency_id):
    try:
        agency_id = int(agency_id.get())
    except:
        mb.showerror(title="Ошибка", message="Введите целое число!")
        return

    cur.execute(" \
        SELECT name_ag \
        FROM agency_table \
        WHERE id= %s", (agency_id,))

    row = cur.fetchone()

    mb.showinfo(title="Результат",
                message=f"Название агенства с id={agency_id}: '{row[0]}'")


def execute_task4(cur, table_name, con):
    table_name = table_name.get()

    try:
        cur.execute(f"SELECT * FROM {table_name}")
    except:
        # Откатываемся.
        con.rollback()
        mb.showerror(title="Ошибка", message="Такой таблицы нет!")
        return

    rows = [(elem[0],) for elem in cur.description]

    create_list_box(rows, "Задание 4", 17)


def execute_task6(cur, l_num, h_num):
    l_num = l_num.get()
    h_num = h_num.get()
    try:
        l_num = int(l_num)
        h_num = int(h_num)
    except:
        mb.showerror(title="Ошибка", message="Введите целые числа")
        return

    cur.execute(f"select * from get_info_about_hotels({l_num}, {h_num})")

    #Fetch all (remaining) rows of a query result, returning them as a list of tuples
    rows = cur.fetchall()
    row = '       '.join(list(elem[0] for elem in cur.description))

    create_list_box(rows, "Задание 6", 17, row=row)


def execute_task7(cur, param, con):
    try:
        country_id = int(param[0].get())
        name_c = param[1].get()
        area = int(param[2].get())
        season = param[3].get()
        language = param[4].get()
    except:
        mb.showerror(title="Ошибка", message="Некорректные параметры!")
        return

    if area < 300 or area > 2000000:
        mb.showerror(title="Ошибка", message="Неподходящие значения!")
        return

    print(country_id, name_c, area, season, language)

    # Выполняем запрос.
    try:
        cur.execute("CALL insert_country(%s, %s, %s, %s, %s);",
                    (country_id, name_c, area, season, language))
    except:
        mb.showerror(title="Ошибка", message="Некорректный запрос!")
        # Откатываемся.
        con.rollback()
        return

    # Фиксируем изменения.
    # Т.е. посылаем команду в бд.
    # Метод commit() помогает нам применить изменения,
    # которые мы внесли в базу данных,
    # и эти изменения не могут быть отменены,
    # если commit() выполнится успешно.
    con.commit()

    mb.showinfo(title="Информация!", message="Страна добавлена!")


def execute_task10(cur, param, con):
    try:
        tour = int(param[0].get())
        model = param[1].get()
        cost_for_flight = int(param[2].get())
    except:
        mb.showerror(title="Ошибка", message="Некорректные параметры!")
        return

    cur.execute("SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='plane_table'")

    if not cur.fetchone():
        mb.showerror(title="Ошибка", message="Таблица не создана!")
        return

    try:
        cur.execute("INSERT INTO plane_table VALUES(%s, %s, %s)",
                    (tour, model, cost_for_flight))
    except:
        mb.showerror(title="Ошибка!", message="Ошибка запроса!")
        # Откатываемся.
        con.rollback()
        return

    # Фиксируем изменения.
    con.commit()

    mb.showinfo(title="Информация!", message="Получилось")