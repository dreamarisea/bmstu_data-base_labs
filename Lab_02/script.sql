--1. Инструкция SELECT, использующая предикат сравнения
--вывести все отели с категорией 5
SELECT name_h, hotel_table.cat_hotel
FROM hotel_table
WHERE cat_hotel = 5;
--2. Инструкция SELECT, использующая предикат BETWEEN
--вывести всех клиентов, которые состоят в агенствах с id от 200 до 700
SELECT * FROM client_table
WHERE agency BETWEEN 200 AND 700;
--3. Инструкция SELECT, использующая предикат LIKE
--вывести все страны, которые начинаются с M
SELECT * FROM country_table
WHERE name_c LIKE 'M%';
--4. Инструкция SELECT, использующая предикат IN с вложенным подзапросом
--вывести название и страну отеля, если в этой стране сезон - весна
SELECT name_h, country
FROM hotel_table
WHERE country IN(
    SELECT id
    FROM country_table
    WHERE season = 'spring'
);
--5. Инструкция SELECT, использующая предикат EXISTS с вложенным подзапросом
--предикат EXISTS принимает значение TRUE, если подзапрос содержит любое количество строк, иначе его значение равно FALSE
--для NOT EXISTS все наоборот. этот предикат никогда не принимает значение UNKNOWN
--вывести все агенства, в которых есть клиенты
SELECT *
FROM agency_table
WHERE EXISTS(SELECT * FROM client_table
    WHERE client_table.agency = agency_table.id);
--6. Инструкция SELECT, использующая предикат сравнения с квантором
--получить все туры в которых самое большое кол-во ночей
SELECT *
FROM tour_table
WHERE count_nights >= ALL(
    SELECT count_nights
    FROM tour_table
);
--7. Инструкция SELECT, использующая агрегатные функции в выражениях столбцов
--узнать среднее кол-во ночей по всем отелям
SELECT AVG(count_nights)
FROM tour_table;
--8. Инструкция SELECT, использующая скалярные подзапросы в выражениях столбцов
--вывести информацию о странах с летним сезоном
--и средним значением кол-ва комнат в отеле, который находится в этой стране
--может быть NULL, тк в стране может не быть отелей
SELECT id,
       (SELECT avg(count_rooms)
        FROM hotel_table
        WHERE hotel_table.country = country_table.id)
FROM country_table
WHERE country_table.season = 'summer';
--9. Инструкция SELECT, использующая простое выражение CASE
--вывести информацию о типах питания в отдельный столбец
--с описанием (завтрак, полупансион, все включено)
SELECT *,
    CASE eat_type
        WHEN 1 THEN 'ONLY BREAKFAST'
        WHEN 2 THEN 'BREAKFAST + DINNER'
        WHEN 3 THEN 'ALL INCLUSIVE'
    END
FROM tour_table;
--10. Инструкция SELECT, использующая поисковое выражение CASE
--вывести информацию о размере стран, опираясь на сред.арифм.
SELECT *,
       CASE
           WHEN area < (SELECT AVG(area) FROM country_table) THEN 'SMALL'
           WHEN area > (SELECT AVG(area) FROM country_table) THEN 'BIG'
           ELSE 'AVERAGE'
       END
FROM country_table;
--11. Создание новой временной локальной таблицы из результирующего набора данных инструкции SELECT
--создаем таблицу с группировкой клиент и агенство, в котором он состоит
-- + номер и директор этого агенства
DROP TABLE IF EXISTS ag_client;
CREATE TEMPORARY TABLE ag_client(
    name text,
    phone numeric,
    id int,
    name_dir text
);

INSERT INTO ag_client(
SELECT client_table.name_cl,
       agency_table.phone,
       agency_table.id,
       agency_table.director
FROM agency_table JOIN client_table ON agency_table.id = client_table.agency);

SELECT * FROM ag_client;
--12. Инструкция SELECT, использующая вложенные коррелированные подзапросы в качестве производных таблиц в предложении FROM
--вывести все страны, в которых сезон - осень
SELECT hotel_table.id
FROM hotel_table
JOIN(
    SELECT id
    FROM country_table
    WHERE season = 'fall')
    AS D ON hotel_table.id = D.id;
--13. Инструкция SELECT, использующая вложенные подзапросы с уровнем вложенности 3
SELECT id, name_ag
FROM agency_table
WHERE id IN
    (
        SELECT agency
        FROM client_table
        WHERE id IN
            (
                SELECT id
                FROM tour_table
                WHERE type_t = 'beach'
                )
    );
--14. Инструкция SELECT, консолидирующая данные с помощью предложения GROUP BY, но без предложения HAVING
--вывести кол-во туров для каждого вида
--и min, max кол-во ночей в этих турах
SELECT type_t, COUNT(type_t) as cnt, MIN(count_nights), MAX(count_nights)
FROM tour_table
GROUP BY type_t;
--15. Инструкция SELECT, консолидирующая данные с помощью предложения GROUP BY и предложения HAVING
--вывести кол-во туров для каждого вида
--и у котрых кол-во не превышает 200
SELECT type_t, COUNT(type_t) as cnt
FROM tour_table
GROUP BY type_t
HAVING COUNT(type_t) < 200;
--16. Однострочная инструкция INSERT, выполняющая вставку в таблицу одной строки значений
--выполняется вставка одной строки в таблицу
INSERT INTO tour_table (id, rating_tour, count_nights, type_t, eat_type)
VALUES (1500, 5, 15, 'relax', 3);
--17. Многострочная инструкция INSERT, выполняющая вставку в таблицу результирующего набора данных вложенного подзапроса
--вставляет туры, при этом берутся старые строки(которые подходят под фильтрацию)
-- и копируются в новые те поля, которые заданы
INSERT INTO tour_table (id, count_nights, eat_type)
SELECT id * 100 as ID, count_nights as nig, eat_type as food
FROM tour_table
WHERE id > 100 AND id < 150 AND type_t = 'sports';
--18. Простая инструкция UPDATE
--уменьшить площадь стран, у которых площадь больше 100000 в 10 раз
UPDATE country_table
SET area = area / 10
WHERE area > 100000;
--19. Инструкция UPDATE со скалярным подзапросом в предложении SET
--изменить площадь страны с корейским языком на среднию по странам, к которых сезон - зима
UPDATE country_table
SET area = (
    SELECT AVG(area)
    FROM country_table
    WHERE season = 'winter')
WHERE lang = 'Korean';
--20. Простая инструкция DELETE
--удалить туры с типом - экскурсии
DELETE FROM tour_table
WHERE type_t = 'excursion';
--21. Инструкция DELETE с вложенным коррелированным подзапросом в предложении WHERE
--удалить туры с самым большим кол-вом ночей
DELETE FROM tour_table
WHERE count_nights >= ALL(
    SELECT count_nights
    FROM tour_table
);
--22. Инструкция SELECT, использующая простое обобщенное табличное выражение
--вывести id и тип туров
WITH lovely(id, type)
AS
(
    SELECT id, type_t FROM tour_table
)
SELECT * FROM lovely;
--23. Инструкция SELECT, использующая рекурсивное обобщенное табличное выражение
--создаем таблицу
CREATE TABLE workers
(
    id int NOT NULL PRIMARY KEY,
    working_with int,
    name VARCHAR(32)
);
--рекурсивный запрос
--вывести цепочку кто с кем работает
WITH RECURSIVE workwith(id, working_with, name, level)
AS
(
    --определение закрепленного элемента - якорь рекурсии
    SELECT id, working_with, name, 0 as level
    FROM workers
    WHERE workers.working_with is null
    UNION ALL
    --определение рекурсивного элемента
    SELECT workers.id, workers.working_with, workers.name, workwith.level + 1
    FROM workers
    INNER JOIN workwith ON workers.working_with = workwith.id
)
SELECT *
FROM workwith WHERE level = 2;
--24. Оконные функции. Использование конструкций MIN/MAX/AVG OVER()
--Order by
--Оператор Order by выполняет сортировку выходных значений, т.е. сортирует извлекаемое значение по определенному столбцу. Сортировку также можно применять по псевдониму столбца, который определяется с помощью оператора
--Сортировка по возрастанию применяется по умолчанию. Если хотите отсортировать столбцы по убыванию — используйте дополнительный оператор DESC
--OVER PARTITION BY(столбец для группировки) — это свойство для задания размеров окна. Здесь можно указывать дополнительную информацию, давать служебные команды, например добавить номер строки. Синтаксис оконной функции вписывается прямо в выборку столбцов
--Для цены за ночь в определенной стране среднее, мин, макс
--сначала сортировка по странам, потом по цене за ночь в этой стране
SELECT country,
    AVG(night_price) OVER(PARTITION BY country ORDER BY night_price) AS AvgPrice,
    MIN(night_price) OVER(PARTITION BY country ORDER BY night_price) AS MinPrice,
    MAX(night_price) OVER(PARTITION BY country ORDER BY night_price) AS MaxPrice
INTO newTable
FROM hotel_table;

SELECT * FROM newTable;
DROP TABLE newTable;
--25. Оконные функции для устранения дублей
CREATE TABLE jobs(
    name VARCHAR NOT NULL,
    age int,
    job VARCHAR NOT NULL
);
INSERT INTO jobs(name, age, job)
VALUES ('Marina', '20', 'programmer'),
       ('Sergei', '60', 'lawyer'),
       ('Elena', '45', 'economist'),
       ('Marina', '20', 'programmer'),
       ('Marina', '20', 'programmer'),
       ('Elena', '45', 'economist'),
       ('Marina', '20', 'programmer'),
       ('Sergei', '60', 'lawyer');

SELECT * FROM jobs;

WITH jobs_delete AS(DELETE FROM jobs RETURNING*),
     jobs_insert AS(SELECT name, age, job, row_number() over (partition by name, age, job ORDER BY name, age, job)
                    rownum FROM jobs_delete) INSERT INTO jobs SELECT name, age, job
                    FROM jobs_insert WHERE rownum = 1;

DROP TABLE jobs;