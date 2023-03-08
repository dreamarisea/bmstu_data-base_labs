CREATE TABLE IF NOT EXISTS clients_json
(
    doc JSON
);

CREATE TABLE IF NOT EXISTS country_json
(
    doc JSON
);

INSERT INTO country_json
SELECT * FROM country_import;

INSERT INTO clients_json
SELECT * FROM clients_import;

SELECT * FROM clients_json;


SELECT * FROM client_table
WHERE agency > 18
ORDER BY name_cl
LIMIT 5;