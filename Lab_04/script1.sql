--сравнить 2 тура, вывести одинаковые они или разные
DROP TABLE IF EXISTS res;
CREATE TABLE res(
    id int,
    rating_tour int,
    count_nights int,
    type_t text,
    eat_type int
);

create or replace function compare_tours(in tour_id1 int, in tour_id2 int, in error int, in error1 text)
returns table(id int, rating_tour int, count_nights int, type_t text, eat_type int)
as $$
    tours = plpy.execute("select * from tour_table")

    for i in range(len(tours)):
        if ((tours[i]['id'] == tour_id1) or (tours[i]['id'] == tour_id2)):
            plan = plpy.prepare("insert into res values ($1, $2, $3, $4, $5)", ["int", "int", "int", "text", "int"])
            plpy.execute(plan, [tours[i]['id'], tours[i]['rating_tour'], tours[i]['count_nights'], tours[i]['type_t'], tours[i]['eat_type']])

    newt = plpy.execute("select * from res")

    if (newt[0]['rating_tour'] == newt[1]['rating_tour']):
        plan = plpy.prepare("update res set rating_tour = $1 where id = $2", ["int", "int"])
        plpy.execute(plan, [error, tour_id1])
        plpy.execute(plan, [error, tour_id2])
    if (newt[0]['count_nights'] == newt[1]['count_nights']):
        plan = plpy.prepare("update res set count_nights = $1 where id = $2", ["int", "int"])
        plpy.execute(plan, [error, tour_id1])
        plpy.execute(plan, [error, tour_id2])
    if (newt[0]['eat_type'] == newt[1]['eat_type']):
        plan = plpy.prepare("update res set eat_type = $1 where id = $2", ["int", "int"])
        plpy.execute(plan, [error, tour_id1])
        plpy.execute(plan, [error, tour_id2])
    if (newt[0]['type_t'] == newt[1]['type_t']):
        plan = plpy.prepare("update res set type_t = $1 where id = $2", ["text", "int"])
        plpy.execute(plan, [error1, tour_id1])
        plpy.execute(plan, [error1, tour_id2])

    plpy.notice(f"{newt}")
    res = plpy.execute("select * from res")

    return res

$$ language plpython3u;

select * from compare_tours(15, 16, 0, 'same');