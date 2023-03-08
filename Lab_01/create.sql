DROP TABLE IF EXISTS agency_table CASCADE;
CREATE TABLE IF NOT EXISTS public.agency_table(
    id int NOT NULL PRIMARY KEY,
    name_ag text,
    addr text,
    phone numeric,
    mail text,
    director text
);

DROP TABLE IF EXISTS client_table CASCADE;
CREATE TABLE IF NOT EXISTS public.client_table(
    id int NOT NULL PRIMARY KEY,
    name_cl text,
    surname text,
    phone numeric,
    agency int CHECK (agency > 0),
    FOREIGN KEY (agency) REFERENCES agency_table(id) ON DELETE CASCADE
);

DROP TABLE IF EXISTS tour_table CASCADE;
CREATE TABLE IF NOT EXISTS public.tour_table(
    id int NOT NULL PRIMARY KEY,
    rating_tour int CHECK (rating_tour > 0 AND tour_table.rating_tour < 6),
    count_nights int,
    type_t text,
    eat_type int CHECK (eat_type > 0 AND eat_type < 4)
);

DROP TABLE IF EXISTS country_table CASCADE;
CREATE TABLE IF NOT EXISTS public.country_table(
    id int NOT NULL PRIMARY KEY,
    name_c text,
    area int CHECK (area BETWEEN 300 AND 2000000),
    season text,
    lang text
);

DROP TABLE IF EXISTS hotel_table CASCADE;
CREATE TABLE IF NOT EXISTS public.hotel_table(
    id int NOT NULL PRIMARY KEY,
    country int,
    FOREIGN KEY (country) REFERENCES country_table(id) ON DELETE CASCADE,
    count_rooms int,
    name_h text,
    cat_hotel int CHECK (cat_hotel > 0 AND cat_hotel < 6),
    night_price int
);