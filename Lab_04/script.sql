SELECT * FROM pg_language;
select name, default_version, installed_version from pg_catalog.pg_available_extensions ;

create extension if not exists plpython3u;

drop extension plpython3u;

--1. Определяемая пользователем скалярная функция CLR
--получить название агенства по id
create or replace function get_name_by_id(in ag_id INT) returns varchar
as $$
res = plpy.execute("SELECT name_ag FROM agency_table WHERE id = {};".format(ag_id))
if res:
    return res[0]['name_ag']
$$ language plpython3u;

SELECT get_name_by_id(15);

SELECT name_ag FROM agency_table WHERE id = 15;

--2. Пользовательская агрегатная функция CRL
--узнать среднее кол-во ночей по всем отелям
create or replace function get_avg_rooms()
returns decimal
as $$
res = plpy.execute("SELECT count_rooms FROM hotel_table")
length = len(res)

sum = 0
for i in range(length):
    sum += res[i]['count_rooms']
if (length == 0):
    avg = 0
else:
    avg = sum / length

return avg
$$ language plpython3u;

select get_avg_rooms();

CREATE OR REPLACE FUNCTION get_avg_rooms_count()
RETURNS decimal AS $$
    SELECT avg(count_rooms)
    FROM hotel_table;
$$ LANGUAGE sql;

SELECT get_avg_rooms_count();
--3. Определяемая пользователем табличная функция CLR
--вывести информацию о клиентах c номером агенства больше заданного
create or replace function get_info_client(in ag_id int)
returns table(id int, name_cl text, phone numeric, agency int)
as $$
    res = list()
    clients = plpy.execute("select * from client_table");
    for i in range(len(clients)):
        if (clients[i]['agency'] > ag_id):
            res.append(clients[i])
    return res
$$ language plpython3u;

select * from get_info_client(300);
--4. Хранимая процедура CRL
--обновить рейтинг тура по id
create or replace procedure update_rat_tours(in tour_id int, in new_rat int)
as $$
    plan = plpy.prepare("update tour_table set rating_tour = $2 where rating_tour = $1", ["int", "int"])
    plpy.execute(plan, [tour_id, new_rat])
$$ language plpython3u;

call update_rat_tours(3, 1);
--5. Триггер CRL
--триггер на изменение таблицы
CREATE OR REPLACE FUNCTION update_trigger()
RETURNS TRIGGER  as
$$
	plpy.notice("Some hotels changed")
$$ LANGUAGE plpython3u;

drop trigger update_my on hotel_table;

CREATE  trigger update_my
AFTER UPDATE ON hotel_table
FOR EACH ROW
EXECUTE PROCEDURE update_trigger();

UPDATE hotel_table
SET cat_hotel = 5
WHERE id = 9;
--6. Определяемый пользователем тип данных CRL
create type client_base_info as
(
    id int,
    name_cl text,
    phone numeric
);

create or replace function client_base_info(id INT)
returns setof client_base_info as
$$
	plan = plpy.prepare("SELECT id, name_cl, phone FROM client_table WHERE id = $1", ["int"])
	res = plpy.execute(plan, [id])
	if res is not None:
		return res
$$ language plpython3u;

select * from client_base_info(1);
--setof для множества параметров