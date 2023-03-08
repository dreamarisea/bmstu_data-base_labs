--таблица с сортировкой туров
--слева название, справа количество

CREATE OR REPLACE FUNCTION get_id_tours_sort()
RETURNS TABLE(type_t text, cnt int) AS $$
    SELECT type_t text, COUNT(type_t) as cnt
    FROM tour_table
    GROUP BY type_t
    HAVING type_t = 'sports' OR type_t = 'beach';
$$ LANGUAGE sql;

DROP FUNCTION get_id_tours_sort();

SELECT *
FROM get_id_tours_sort();