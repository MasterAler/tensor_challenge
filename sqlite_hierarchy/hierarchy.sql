PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS item;

CREATE TABLE item
(
    id         INTEGER PRIMARY KEY,
    parent_id  INTEGER REFERENCES item (id),
    name       TEXT NOT NULL COLLATE NOCASE,
    short_name TEXT COLLATE NOCASE
);

CREATE INDEX item_parent ON item (parent_id);
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
    (15, 8,    'Комплектующие',    'Компл.'),
    (16, 15,   'Товар №5',         '№5'),
    (17, 7,    'Услуга доставки',  'Дост.'),

    (13, NULL, 'Товар №00',        '№00'),
    (14, NULL, 'Товар №01',        '№01'),
    (18, NULL, 'Набор позиций',    'Товарный набор'),
    (19, NULL, 'Услуги',           NULL);

WITH RECURSIVE
found (id) AS
(
    SELECT id FROM item
    WHERE name LIKE 'Това%' OR short_name LIKE 'Това%'
),
up (id) AS
(
    SELECT id FROM found
    UNION
    SELECT i.parent_id
    FROM item i
    JOIN up ON up.id = i.id
    WHERE i.parent_id IS NOT NULL
),
tree (id, parent_id, level, name, short_name, path) AS
(
    SELECT i.id, i.parent_id, 0, i.name, i.short_name, i.name || char(1) || i.id
    FROM item i
    JOIN up ON up.id = i.id
    WHERE i.parent_id IS NULL
    UNION ALL
    SELECT i.id, i.parent_id, t.level + 1, i.name, i.short_name, t.path || char(2) || i.name || char(1) || i.id
    FROM tree t
    JOIN item i ON i.parent_id = t.id
    JOIN up ON up.id = i.id
)
SELECT
    id,
    parent_id,
    level,
    printf('%*s%s', level * 4, '', name) AS tree,
    short_name,
    id IN (SELECT id FROM found) AS found
FROM tree
ORDER BY path;
