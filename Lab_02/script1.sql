--все агенства, которые отправляют в сирию
--в отели с одной звездой без питания
SELECT id
FROM agency_table
WHERE agency_table.id IN(
             SELECT id
             FROM client_table
             WHERE client_table.id IN(
                          SELECT id
                          FROM tour_table
                          WHERE eat_type = 2 and tour_table.id IN(
                                    SELECT country
                                    FROM hotel_table
                                    WHERE cat_hotel = 1 and country IN(
                                            SELECT id
                                            FROM country_table
                                            WHERE name_c = 'Lebanon'
                                            )
                                    )
                          )
             );
