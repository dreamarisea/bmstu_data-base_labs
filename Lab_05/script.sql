-- 1. Из таблиц базы данных, созданной в первой
-- лабораторной работе, извлечь данные в JSON.

-- Функция row_to_json - Возвращает кортеж в виде объекта JSON.
SELECT row_to_json(a) result FROM agency_table a;
SELECT row_to_json(cl) result FROM client_table cl;
SELECT row_to_json(co) result FROM country_table co;
SELECT row_to_json(h) result FROM hotel_table h;
SELECT row_to_json(t) result FROM tour_table t;

-- 2. Выполнить загрузку и сохранение JSON файла в таблицу.
-- Созданная таблица после всех манипуляций должна соответствовать таблице
-- базы данных, созданной в первой лабораторной работе.

-- Создаем новую таблицу, чтобы сравнить ее со старой.
-- Да и вообще, чтобы не дропать старую таблицу...
CREATE TABLE IF NOT EXISTS client_copy
(
    id int NOT NULL PRIMARY KEY,
    name_cl text,
    surname text,
    phone numeric,
    agency int CHECK (agency > 0),
    FOREIGN KEY (agency) REFERENCES agency_table(id) ON DELETE CASCADE
);

-- Копируем данные из таблицы client_table в файл clients.json
-- (В начале нужно поставить \COPY).
COPY
(
    SELECT row_to_json(cl) result FROM client_table cl
)
TO 'C:/Uni/5sem/Data base/Lab_05/clients.json';

-- Подготовка данных завершена.
-- Собственно далее само задание.

-- Помещаем файл в таблицу БД.
-- Создаем таблицу, которая будет содержать json кортежи.
CREATE TABLE IF NOT EXISTS clients_import(doc json);

-- Теперь копируем данные в созданную таблицу.
-- (Но опять же делаем это с помощью \COPY).
COPY clients_import FROM 'C:/Uni/5sem/Data base/Lab_05/clients.json';

SELECT * FROM clients_import;

-- В принципе можно было сделать так, но т.к. в условии написано
-- Выгрузить из файла, так что нужно использовать copy.
-- CREATE TABLE IF NOT EXISTS clients_tmp(doc json);
-- INSERT INTO clients_tmp
-- SELECT row_to_json(cl) result FROM clients cl;
-- SELECT * FROM clients_tmp;

-- Данный запрос преобразует данные из строки в формате json
-- В табличное предстваление. Т.е. разворачивает объект из json в табличную строку.
SELECT * FROM clients_import, json_populate_record(null::client_copy, doc);
-- Преобразование одного типа в другой null::client_copy
SELECT * FROM clients_import, json_populate_record(CAST(null AS client_copy), doc);

-- Загружаем в таблицу сконвертированные данные из формата json из таблицы clients_import.
INSERT INTO client_copy
SELECT id, name_cl, surname, phone, agency
FROM clients_import, json_populate_record(null::client_copy, doc);

SELECT * FROM client_copy;

-- 3. Создать таблицу, в которой будет атрибут(-ы) с типом JSON, или
-- добавить атрибут с типом JSON к уже существующей таблице.
-- Заполнить атрибут правдоподобными данными с помощью команд INSERT или UPDATE

-- Создаем таблицу, которая будет содержать
-- Клиентов в json формате.
CREATE TABLE IF NOT EXISTS clients_json
(
    data json
);

SELECT * FROM clients_json;

-- Вставляем в нее json строку.
-- json_object - формирует объект JSON.
INSERT INTO clients_json
SELECT * FROM json_object('{user_id, agency_id, name_cl}', '{1,2, "Karina"}');

-- 4. Выполнить следующие действия:
-- 1. Извлечь XML/JSON фрагмент из XML/JSON документа
CREATE TABLE IF NOT EXISTS clients_id_name
(
    id INT,
    name_cl TEXT
);

-- Оператор -> возвращает поле объекта JSON как JSON.
-- -> - выдаёт поле объекта JSON по ключу.
SELECT * FROM clients_import;

SELECT doc->'id' AS id, doc->'name_cl' AS name_cl
FROM clients_import;

-- 2. Извлечь значения конкретных узлов или атрибутов XML/JSON документа
-- Получаем id и имена всех клиентов
-- У кроторых name_cl начинается с буквы 'A'
SELECT id, name_cl
FROM clients_import, json_populate_record(null::clients_id_name, doc)
WHERE name_cl LIKE 'A%';

-- 3. Выполнить проверку существования узла или атрибута
drop table if exists clients_import;
CREATE TABLE IF NOT EXISTS clients_import(doc json);
COPY clients_import FROM 'C:/Uni/5sem/Data base/Lab_05/clients.json';
SELECT * FROM clients_import;

CREATE OR REPLACE PROCEDURE check_attribute_existence()
    LANGUAGE PLPGSQL
AS
$$
DECLARE
    object_tmp TEXT;
BEGIN
    object_tmp = '';
	-- оператор #>> выдача объекта JSON в типе text
    SELECT doc #>> '{name_cl}'
    INTO object_tmp
    FROM clients_import;

    IF object_tmp IS NULL THEN raise notice 'Does not exist';
    ELSE raise notice 'Attribute exists - %', object_tmp;
    END IF;
END;
$$;

CALL check_attribute_existence();

-- 4. Изменить XML/JSON документ
drop table if exists cl;
CREATE TABLE cl(doc jsonb);
-- Отдел с сотрудниками
INSERT INTO cl VALUES ('{"agency_id":0, "agency_size":2, "client": {"client_id":0, "fisrt_name":"Bob"}}');
INSERT INTO cl VALUES ('{"agency_id":0, "agency_size":2, "client": {"client_id":1, "fisrt_name":"Alex"}}');
INSERT INTO cl VALUES ('{"agency_id":1, "agency_size":1, "client": {"client_id":2, "fisrt_name":"Mary"}}');

SELECT * FROM cl;

-- Особенность конкатенации json заключается в перезаписывании.
SELECT doc || '{"agency_id": 33}'::jsonb
FROM cl;

-- Перезаписываем значение json поля.
UPDATE cl
SET doc = doc || '{"agency_size": 10}'::jsonb
WHERE (doc->'client'->'client_id')::INT = 0;

SELECT * FROM cl;

-- 5. Разделить XML/JSON документ на несколько строк по узлам
CREATE OR REPLACE PROCEDURE split_json_file()
    LANGUAGE PLPGSQL
AS
$$
DECLARE
    object_tmp TEXT;
BEGIN
    SELECT jsonb_pretty(doc)
    INTO object_tmp
    FROM cl;

    raise notice '%', object_tmp;
END
$$;

CALL split_json_file();


CREATE TABLE IF NOT EXISTS cli(doc JSON);

INSERT INTO cli VALUES ('[{"cl_id": 0, "ag_id": 1},
  {"cl_id": 2, "ag_id": 2}, {"cl_id": 3, "ag_id": 1}]');

SELECT * FROM cli;

-- jsonb_array_elements - Разворачивает массив JSON в набор значений JSON.
SELECT jsonb_array_elements(doc::jsonb)
FROM cli;