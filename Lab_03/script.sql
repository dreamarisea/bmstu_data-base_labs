--1. Скалярная функция
--возвращает максимальное ко-во ночей в туре
CREATE OR REPLACE FUNCTION get_max_nights_count()
RETURNS INT AS $$
    SELECT MAX(count_nights)
    FROM tour_table;
$$ LANGUAGE sql;

DROP FUNCTION get_max_nights_count();

SELECT get_max_nights_count() AS max_nights;
--проверка
SELECT MAX(count_nights)
FROM tour_table;

--2. Подставляемая табличная функция
--вывести информацию о клиенте под заданным номером
CREATE OR REPLACE FUNCTION get_client(cl_id INT = 1) --по умолчанию == 1
RETURNS TABLE (id int, name_cl text, phone numeric) AS $$
    SELECT id int, name_cl text, phone numeric
    FROM client_table
    WHERE id = cl_id;
$$ LANGUAGE sql;

DROP FUNCTION get_client(integer);

SELECT *
FROM get_client(22);
--проверка
SELECT id, name_cl, phone
FROM client_table
WHERE id = 22;

--3. Многооператорная табличная функция
--считает avg, max, min значения кол-ва номеров в отелях
--выводит отели с id < 20 или кол-вом номеров между заданными значениями
--RETURN QUERY добавляет результат выполнения запроса к результату функции
CREATE OR REPLACE FUNCTION get_info_about_hotels(start INT = 150, finish INT = 300)
RETURNS TABLE (id int,
               name_h text,
               count_rooms_avg int,
               count_rooms_min int,
               count_rooms_max int)
LANGUAGE plpgsql
AS
$$
DECLARE
    count_rooms_avg INT;
    count_rooms_min INT;
    count_rooms_max INT;
BEGIN
    SELECT AVG(count_rooms::INT)
    INTO count_rooms_avg
    FROM hotel_table
    WHERE hotel_table.count_rooms BETWEEN start AND finish;

    SELECT MIN(count_rooms::INT)
    INTO count_rooms_min
    FROM hotel_table
    WHERE hotel_table.count_rooms BETWEEN start AND finish;

    SELECT MAX(count_rooms::INT)
    INTO count_rooms_max
    FROM hotel_table
    WHERE hotel_table.count_rooms BETWEEN start AND finish;

    RETURN query
            SELECT hotel_table.id,
                 hotel_table.name_h,
                 count_rooms_avg,
                 count_rooms_min,
                 count_rooms_max
            FROM hotel_table
            WHERE hotel_table.id < 20;

    RETURN query
            SELECT hotel_table.id,
                 hotel_table.name_h,
                 count_rooms_avg,
                 count_rooms_min,
                 count_rooms_max
            FROM hotel_table
            WHERE hotel_table.count_rooms BETWEEN start AND finish;
END;
$$;

DROP FUNCTION get_info_about_hotels(start INT, finish INT);

SELECT *
FROM get_info_about_hotels(100, 200);

--4. Рекурсивная функция или функция с ОТВ
--создаем таблицу
CREATE TABLE workers
(
    id int NOT NULL PRIMARY KEY,
    working_with int,
    name VARCHAR(32)
);

SELECT * FROM workers;
--сама функция
--вывести рекурсивно всех работников
--начиная с какого-то id.
CREATE OR REPLACE FUNCTION find_workers(in_id INT)
RETURNS TABLE
(
    out_id INT,
    out_working_with_id INT,
    out_name VARCHAR
)
AS $$
DECLARE
    elem INT;
BEGIN
    RETURN QUERY
    SELECT *
    FROM workers
    WHERE id = in_id;
    FOR elem IN
        SELECT *
        FROM workers
        WHERE working_with = in_id
    LOOP
            RETURN QUERY
            SELECT *
            FROM find_workers(elem);
    END LOOP;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION find_workers(in_id INT);

SELECT *
FROM find_workers(1);

--5. Хранимая процедура без параметров или с параметрами
--с параметрами, вставить новую страну в таблицу
CREATE OR REPLACE PROCEDURE insert_country(
    id_c int,
    name text,
    are int,
    seasons text,
    language text
)
AS $$
BEGIN
    INSERT INTO country_table
    VALUES (id_c, name, are, seasons, language);
END;
$$ LANGUAGE plpgsql;

CALL insert_country(2000, 'North Korea', 200000, 'summer', 'Korean');

CREATE OR REPLACE PROCEDURE insert_client(
    id int,
    name_cl text,
    surname text,
    phone int,
    agency int
)
AS $$
BEGIN
    INSERT INTO client_table
    VALUES (id, name_cl, surname, phone, agency);
END;
$$ LANGUAGE plpgsql;

--без параметров, заменить рейтинг тура с 1 на 2
CREATE OR REPLACE PROCEDURE change_rat()
AS $$
BEGIN
    UPDATE tour_table
    SET rating_tour = 2
    WHERE rating_tour = 1;
END;
$$ LANGUAGE plpgsql;

CALL change_rat();

--6. Рекурсивная хранимая процедура или хранимая процедура с рекурсивным ОТВ
-- Получить награду за каждого приглашенного клиента.
-- За самого себя получает 500, что пришел
-- Далее, чем ниже по дереву, тем меньше вознаграждение.
-- Т.е. за пользователя, которого пригласил ты, получишь 450
-- За пользователя, которого ппригласил пользователь,
-- Которого пригласил ты 400 и тд....
CREATE OR REPLACE PROCEDURE get_reward
(
    res INOUT INT,
    in_id INT,
    coef FLOAT DEFAULT 1
)
AS $$
DECLARE
    elem INT;
BEGIN
    IF coef <= 0 THEN
        coef = 0.1;
    END IF;
    res = res + 500 * coef;
    FOR elem IN
        SELECT *
        FROM workers
        WHERE working_with = in_id
        LOOP
            CALL get_reward(res, elem, coef - 0.1);
        END LOOP;
END;
$$ LANGUAGE plpgsql;

DROP PROCEDURE get_reward(res INT, in_id INT, coef FLOAT);

CALL get_reward(0, 4);

--7. Хранимая процедура с курсором
-- Отладочная печать: RAISE NOTICE 'Вызов %', in_id;
-- Одним из способов возврата результатов работы хранимых процедур является
-- формирование результирующего множества. Данное множество формируется при
-- выполнении оператора SELECT. Оно записывается во временную таблицу - курсор.
-- Меняет агенство всех клиентов, которые состоят в агенстве с id равным in_agency_id
CREATE OR REPLACE PROCEDURE proc_update_cursor
(
    in_agency_id INT,
    new_agency_id INT
)
AS $$
DECLARE
    myCursor CURSOR FOR
        SELECT *
        FROM client_table
        WHERE agency = in_agency_id;
    tmp client_table;
BEGIN
    OPEN myCursor;
    LOOP
        -- FETCH - Получает следующую строку из курсора
        -- И присваевает в переменную, которая стоит после INTO.
        -- Если строка не найдена (конец), то присваевается значение NULL.
        FETCH myCursor
        INTO tmp;
        -- Выходим из цикла, если нет больше строк (Т.е. конец).
        EXIT WHEN NOT FOUND;
        UPDATE client_table
        SET agency = new_agency_id
        WHERE client_table.id = tmp.id;
    END LOOP;
    CLOSE myCursor;
END;
$$ LANGUAGE  plpgsql;

CALL proc_update_cursor(45, 20);

--8. Хранимая процедура доступа к метаданным
--информация о столбцах
CREATE OR REPLACE PROCEDURE metadata(name VARCHAR) -- Получает название таблицы
AS $$
    DECLARE
        myCursor CURSOR FOR
            SELECT column_name,
                   data_type
           -- INFORMATION_SCHEMA обеспечивает доступ к метаданным о базе данных.
           -- columns - данные о столбацах.
            FROM information_schema.columns
            WHERE table_name = name;
        -- RECORD - переменная, которая подстравивается под любой тип.
        tmp RECORD;
BEGIN
        OPEN myCursor;
        LOOP
            FETCH myCursor
            INTO tmp;
            EXIT WHEN NOT FOUND;
            RAISE NOTICE 'column name = %; data type = %', tmp.column_name, tmp.data_type;
        END LOOP;
        CLOSE myCursor;
END;
$$ LANGUAGE plpgsql;

CALL metadata('client_table');

--без курсора
CREATE OR REPLACE PROCEDURE metadata2(name VARCHAR)
AS $$
DECLARE
    elem RECORD;
BEGIN
    FOR elem IN
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_name = name
    LOOP
            RAISE NOTICE 'elem = % ', elem;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

CALL metadata2('client_table');

--информация о размерах
CREATE OR REPLACE PROCEDURE get_table_size(
	my_table_name VARCHAR
)
AS $$
DECLARE
    s RECORD;
BEGIN
FOR s IN
	select my_table_name,
	pg_relation_size(my_table_name) as size
	from information_schema.tables
	where table_name = my_table_name
LOOP
    RAISE NOTICE 'size = % ', s;
END LOOP;
END;
$$ LANGUAGE plpgsql;

CALL get_table_size('client_table');

--9. Триггер AFTER
-- Сработает, если измениться id какой-либо страны
SELECT *
INTO country_copy
FROM country_table;

CREATE OR REPLACE FUNCTION update_trigger()
RETURNS TRIGGER
AS $$
BEGIN
    RAISE NOTICE 'New = %', new;
    RAISE NOTICE 'Old = %', old;
    UPDATE country_copy
    SET id = new.id
    WHERE country_copy.id = old.id;
    --Для операций INSERT и UPDATE возвращаемым значением должно быть NEW.
    RETURN new;
END;
$$ LANGUAGE plpgsql;

-- AFTER - оперделяет, что заданная функция будет вызываться после события.
CREATE TRIGGER log_update
AFTER UPDATE ON country_copy
-- Триггер с пометкой FOR EACH ROW вызывается один раз для каждой строки,
-- изменяемой в процессе операции.
FOR EACH ROW
EXECUTE PROCEDURE update_trigger();

DROP TRIGGER log_update ON country_copy;

UPDATE country_copy
SET id = 2000
WHERE id = 1;

--10. Триггер INSTEAD OF
-- INSTEAD OF - Сработает вместо указанной операции
-- Заменяем удаление на мягкое удаление
CREATE VIEW agency_copy AS
SELECT *
FROM agency_table;

DROP VIEW agency_copy;

CREATE OR REPLACE FUNCTION delete_agency()
RETURNS TRIGGER
AS $$
BEGIN
    RAISE NOTICE 'New = %', new;
    UPDATE agency_copy
    SET name_ag = 'none'
    WHERE agency_copy.name_ag = old.name_ag;
    RETURN new;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER delete_agency_trigger
INSTEAD OF DELETE ON agency_copy
FOR EACH ROW
EXECUTE PROCEDURE delete_agency();

DELETE FROM agency_copy
WHERE agency_copy.id = 5;

