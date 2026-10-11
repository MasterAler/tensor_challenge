PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS item;

CREATE TABLE item
(
    id         INTEGER PRIMARY KEY,
    parent_id  INTEGER REFERENCES item (id),
    name       TEXT NOT NULL COLLATE NOCASE,
    short_name TEXT COLLATE NOCASE
);

CREATE INDEX item_name ON item (name);
CREATE INDEX item_short_name ON item (short_name);

INSERT INTO item (id, parent_id, name, short_name) VALUES
    (1,  NULL, 'Первый товар',     'П.товар'),
    (2,  1,    'Вторичный товар',  'В.товар'),
    (3,  2,    'Товар №1',         '№1'),
    (4,  2,    'Товар №2',         '№2'),
    (5,  1,    'Товар №3',         '№3'),
    (6,  1,    'Товар №4',         '№4'),

    (7,  NULL, 'Третий товар',     'Т.товар'),
    (8,  7,    'Вторичный товар',  'В.товар'),
    (9,  8,    'Товар №1',         '№1'),
    (10, 8,    'Товар №2',         '№2'),
    (11, 7,    'Товар №3',         '№3'),
    (12, 7,    'Товар №4',         '№4'),

    (13, NULL, 'Товар №00',        '№00'),
    (14, NULL, 'Товар №01',        '№01');

SELECT id, parent_id, name, short_name
FROM item
WHERE name LIKE 'това%' OR short_name LIKE 'това%'
ORDER BY name;
