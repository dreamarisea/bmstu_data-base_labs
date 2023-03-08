--вставить в таблицу отелей информацию о стране
SELECT row_to_json(co) result FROM country_table co;
SELECT row_to_json(h) result FROM hotel_table h;

CREATE TABLE IF NOT EXISTS country_copy
(
    id int NOT NULL PRIMARY KEY,
    name_c text,
    area int CHECK (area BETWEEN 300 AND 2000000),
    season text,
    lang text
);
DROP TABLE hotel_copy;

CREATE TABLE IF NOT EXISTS hotel_copy
(
    id int,
    country jsonb,
    count_rooms int,
    name_h text,
    cat_hotel int CHECK (cat_hotel > 0 AND cat_hotel < 6),
    night_price int
);

insert into hotel_copy SELECT (hotel_import.doc->>'id')::INT AS id, country_import.doc AS country, (hotel_import.doc->>'count_rooms')::INT as count_rooms, (hotel_import.doc->>'name_h')::TEXT as name_h, (hotel_import.doc->>'cat_hotel')::INT as cat_hotel, (hotel_import.doc->>'night_price')::INT as night_price
FROM hotel_import join country_import on hotel_import.doc->>'country' = country_import.doc->>'id';


COPY
(
    SELECT row_to_json(co) result FROM country_table co
)
TO 'C:/Uni/5sem/Data base/Lab_05/country.json';

COPY
(
    SELECT row_to_json(h) result FROM hotel_table h
)
TO 'C:/Uni/5sem/Data base/Lab_05/hotel.json';

CREATE TABLE IF NOT EXISTS country_import(doc json);

COPY country_import FROM 'C:/Uni/5sem/Data base/Lab_05/country.json';


CREATE TABLE IF NOT EXISTS hotel_import(doc json);

COPY hotel_import FROM 'C:/Uni/5sem/Data base/Lab_05/hotel.json';





