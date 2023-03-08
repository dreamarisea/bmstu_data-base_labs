CREATE DATABASE RK2;

-- (1)

DROP TABLE IF EXISTS excursion;
DROP TABLE IF EXISTS customer;
DROP TABLE IF EXISTS excursion_customer;
DROP TABLE IF EXISTS stend;
DROP TABLE IF EXISTS excursion_stend;

CREATE TABLE IF NOT EXISTS excursion(
    id INT PRIMARY KEY,
    name_ex TEXT NOT NULL,
    description TEXT NOT NULL,
    date_open DATE,
    date_close DATE
);

CREATE TABLE IF NOT EXISTS customer(
    id INT PRIMARY KEY,
    fio TEXT NOT NULL,
    address TEXT NOT NULL,
    phone INT
);

CREATE TABLE IF NOT EXISTS excursion_customer(
    excursion_id INT,
    customer_id INT,
    FOREIGN KEY(excursion_id) REFERENCES excursion(id) ON DELETE CASCADE,
    FOREIGN KEY(customer_id) REFERENCES customer(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS stend(
    id INT PRIMARY KEY,
    name_s TEXT NOT NULL,
    area TEXT,
    small_desc TEXT
);

CREATE TABLE IF NOT EXISTS excursion_stend(
    excursion_id INT,
    stend_id INT,
    FOREIGN KEY(excursion_id) REFERENCES excursion(id) ON DELETE CASCADE,
    FOREIGN KEY(stend_id) REFERENCES stend(id) ON DELETE CASCADE
);

-- Заполнение таблиц текущей базы данных
INSERT INTO excursion VALUES (1, 'star', 'standard', '20200901', '20200925'),
                           (2, 'reflection', 'to the moon', '20201201', '20201213'),
                           (3, 'explore_world', 'watch all the world', '20140504', '10140601'),
                           (4, 'adventure', 'lots of parks', '20170701', '20170710'),
                           (5, 'zoomak', 'see animals', '20180701', '20180710'),
                           (6, 'fly me', 'know new about planes', '20190701', '20190710'),
                           (7, 'attention', 'look at the sky', '20200701', '20200710'),
                           (8, 'sand beaches', 'standard', '20220901', '20220925'),
                           (9, 'clever trip', 'for smart people', '20220501', '20220725'),
                           (10, 'min wait', 'not long excursion', '20210901', '20211025');

INSERT INTO customer VALUES (1, 'Kiseleva Marina Sergeevna', 'Unit 7573 Box 8214=DPO AE 00598', '6822'),
                            (2, 'Smirnova Alena Alekseevna', '389 Jennings Passage Apt. 996=East Aimeefort, TX 86849', '5410'),
                            (3, 'Sharapova Ksenia Andreevna', '505 Lyons Parks Apt. 657=Richardview, NV 63474', '4732'),
                            (4, 'Lebedeva Ekaterina Sergeevna', '256 Crane Burgs Suite 485=Katrinastad, MA 38969', '1261'),
                            (5, 'Voronov Pavel Aleksendrovich', '840 James Fields Suite 817=West Kylefurt, ND 65845', '8553'),
                            (6, 'Ivanov Sergey Fedorovich', '9449 Hill Squares Apt. 918=Lake Eric, CA 77989', '4944'),
                            (7, 'Fedor Dmitriy Ivanovich', 'Unit 4734 Box 0038=DPO AP 59519', '9097'),
                            (8, 'Frolova Vicktoria Nickolaevna', '198 Williams Vista=Port Samantha, CA 99576', '1423'),
                            (9, 'Chernyshova Anastasia Andreevna', '79271 Tyler Divide Suite 101=Gillespietown, KS 21747', '6268'),
                            (10, 'Aleckseev Rydolf Yackovlev', 'PSC 4702, Box 8808=APO AE 41787', '9012');

INSERT INTO stend VALUES (1, 'Travel days', 'history', 'learning something'),
                        (2, 'Universe', 'physics', 'experiments'),
                        (3, 'Levels', 'sky', 'see new things'),
                        (4, 'Chic', 'helicopter', 'flying'),
                        (5, 'Pineapple', 'islands', 'fruits'),
                        (6, 'New idea', 'history', 'call somebody'),
                        (7, 'Petek', 'biology', 'human design'),
                        (8, 'Alfreda', 'biology', 'snowflakes'),
                        (9, 'Double life', 'languages', 'english time'),
                        (10, 'Fantastic', 'chemistry', 'clean up');

insert into excursion_customer
values (1, 2),
       (2, 4),
       (9, 4),
       (3, 7),
       (6, 5),
       (10, 9),
       (8, 3),
       (7, 1),
       (6, 9),
       (10, 1),
       (3, 6);

insert into excursion_stend
values (8, 2),
       (2, 3),
       (9, 4),
       (3, 1),
       (6, 5),
       (10, 9),
       (5, 3),
       (7, 6),
       (6, 9),
       (2, 1),
       (3, 6);

-- (2)

-- 1) Инструкцию SELECT, использующую поисковое выражение CASE

-- Вывести список экскурсий с пометкой - стандартная или нет. Если да, то в столбце true, если нет - false.
-- Сортируем по этому столбцу, сначала с true.
select name_ex,
       (case
       when description = 'standard' and id > 5 then true
       else false
       end) is_standard_excursion
from excursion order by is_standard_excursion desc;

-- Вывести информацию об id, опираясь на сред.арифм.
SELECT *,
       CASE
           WHEN id < (SELECT AVG(id) FROM customer) THEN 'SMALL'
           WHEN id > (SELECT AVG(id) FROM customer) THEN 'BIG'
           ELSE 'AVERAGE'
       END
FROM customer;

-- 2) Инструкция UPDATE со скалярным подзапросом в предложении SET
-- Изменить номер телефона на средний по людям, у человека с заданным адресом
UPDATE customer
SET phone = (
    SELECT AVG(phone)
    FROM customer)
WHERE address = '256 Crane Burgs Suite 485=Katrinastad, MA 38969';

-- 3) Инструкцию SELECT, консолидирующую данные с помощью предложения GROUP BY и предложения HAVING
-- Вывести количество предметных областей, которых в таблице стендов больше 2.
SELECT area, count(*) as count
FROM stend
GROUP BY area
having count(*) > 1;

-- (3)
--- Создать хранимую процедуру с выходным параметром, которая уничтожает
--- все представления в текущей базе данных, которые не были зашифрованы.
--  Выходной параметр возвращает количество уничтоженных представлений.
--- Созданную хранимую процедуру протестировать.

-- Создания View
CREATE VIEW customer_view
AS SELECT * FROM customer;

CREATE VIEW excursion_view
AS SELECT * FROM excursion;

CREATE VIEW stend_view
AS SELECT * FROM stend;

DROP VIEW customer_view;
DROP VIEW excursion_view;
DROP VIEW stend_view;

SELECT *
FROM information_schema.views
WHERE table_schema = 'public';

DROP PROCEDURE delete_views();
CREATE OR REPLACE PROCEDURE delete_views(count inout int)
AS $$
DECLARE
    rec RECORD;
    cur CURSOR FOR
        SELECT table_name as view_name
        FROM information_schema.views
        WHERE table_schema = 'public';
BEGIN
    OPEN cur;
    LOOP
        FETCH cur INTO rec;
        EXIT WHEN NOT FOUND;
        count = count + 1;
        RAISE NOTICE 'DROP VEIW: %', rec.view_name;
        EXECUTE 'DROP VIEW ' || rec.view_name || ';';
    END LOOP;
    CLOSE cur;
END;
$$ LANGUAGE PLPGSQL;

CALL delete_views(0);