COPY agency_table(id, name_ag, addr, phone, mail, director)
FROM 'C:\Uni\5sem\Data_base\Lab_01\agencies.csv'
DELIMITER ';'
CSV HEADER;


COPY client_table(id, name_cl, surname, phone, agency)
FROM 'C:\Uni\5sem\Data_base\Lab_01\clients.csv'
DELIMITER ';'
CSV HEADER;


COPY country_table(id, name_c, area, season, lang)
FROM 'C:\Uni\5sem\Data_base\Lab_01\countries.csv'
DELIMITER ';'
CSV HEADER;


COPY hotel_table(id, country, count_rooms, name_h, cat_hotel, night_price)
FROM 'C:\Uni\5sem\Data_base\Lab_01\hotels.csv'
DELIMITER ';'
CSV HEADER;


COPY tour_table(id, rating_tour, count_nights, type_t, eat_type)
FROM 'C:\Uni\5sem\Data_base\Lab_01\tours.csv'
DELIMITER ';'
CSV HEADER;