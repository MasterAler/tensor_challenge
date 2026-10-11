PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS item;

CREATE TABLE item
(
    id         INTEGER PRIMARY KEY,
    parent_id  INTEGER REFERENCES item (id),
    name       TEXT NOT NULL,
    short_name TEXT,
    name_key   TEXT GENERATED ALWAYS AS (
        replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
        replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
        replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
        lower(name),
            'А', 'а'), 'Б', 'б'), 'В', 'в'), 'Г', 'г'), 'Д', 'д'), 'Е', 'е'), 'Ё', 'ё'), 'Ж', 'ж'), 'З', 'з'), 'И', 'и'), 'Й', 'й'),
            'К', 'к'), 'Л', 'л'), 'М', 'м'), 'Н', 'н'), 'О', 'о'), 'П', 'п'), 'Р', 'р'), 'С', 'с'), 'Т', 'т'), 'У', 'у'), 'Ф', 'ф'),
            'Х', 'х'), 'Ц', 'ц'), 'Ч', 'ч'), 'Ш', 'ш'), 'Щ', 'щ'), 'Ъ', 'ъ'), 'Ы', 'ы'), 'Ь', 'ь'), 'Э', 'э'), 'Ю', 'ю'), 'Я', 'я')
    ) STORED,
    short_key  TEXT GENERATED ALWAYS AS (
        replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
        replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
        replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
        lower(short_name),
            'А', 'а'), 'Б', 'б'), 'В', 'в'), 'Г', 'г'), 'Д', 'д'), 'Е', 'е'), 'Ё', 'ё'), 'Ж', 'ж'), 'З', 'з'), 'И', 'и'), 'Й', 'й'),
            'К', 'к'), 'Л', 'л'), 'М', 'м'), 'Н', 'н'), 'О', 'о'), 'П', 'п'), 'Р', 'р'), 'С', 'с'), 'Т', 'т'), 'У', 'у'), 'Ф', 'ф'),
            'Х', 'х'), 'Ц', 'ц'), 'Ч', 'ч'), 'Ш', 'ш'), 'Щ', 'щ'), 'Ъ', 'ъ'), 'Ы', 'ы'), 'Ь', 'ь'), 'Э', 'э'), 'Ю', 'ю'), 'Я', 'я')
    ) STORED
);

CREATE INDEX item_parent ON item (parent_id);
CREATE INDEX item_name_key ON item (name_key);
CREATE INDEX item_short_key ON item (short_key);

INSERT INTO item (id, parent_id, name, short_name) VALUES
    (1,  NULL, 'Первый товар',     'П.товар'),
    (2,  1,    'Вторичный товар',  'В.товар'),
    (3,  2,    'Товар №1',         '№1'),
    (4,  2,    'Товар №2',         '№2'),
    (5,  1,    'Товар №3',         '№3'),
    (6,  1,    'Товар №4',         '№4'),
    (20, 1,    'товар без номера', NULL),

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
search (q) AS MATERIALIZED
(
    SELECT
        replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
        replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
        replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
        lower(phrase),
            'А', 'а'), 'Б', 'б'), 'В', 'в'), 'Г', 'г'), 'Д', 'д'), 'Е', 'е'), 'Ё', 'ё'), 'Ж', 'ж'), 'З', 'з'), 'И', 'и'), 'Й', 'й'),
            'К', 'к'), 'Л', 'л'), 'М', 'м'), 'Н', 'н'), 'О', 'о'), 'П', 'п'), 'Р', 'р'), 'С', 'с'), 'Т', 'т'), 'У', 'у'), 'Ф', 'ф'),
            'Х', 'х'), 'Ц', 'ц'), 'Ч', 'ч'), 'Ш', 'ш'), 'Щ', 'щ'), 'Ъ', 'ъ'), 'Ы', 'ы'), 'Ь', 'ь'), 'Э', 'э'), 'Ю', 'ю'), 'Я', 'я')
    FROM (SELECT 'това' AS phrase)
),
found (id) AS MATERIALIZED
(
    SELECT id FROM item
    WHERE name_key >= (SELECT q FROM search) AND name_key < (SELECT q || char(1114111) FROM search)
       OR short_key >= (SELECT q FROM search) AND short_key < (SELECT q || char(1114111) FROM search)
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
    SELECT i.id, i.parent_id, 0, i.name, i.short_name, i.name_key || char(1) || i.id
    FROM item i
    JOIN up ON up.id = i.id
    WHERE i.parent_id IS NULL
    UNION ALL
    SELECT i.id, i.parent_id, t.level + 1, i.name, i.short_name, t.path || char(2) || i.name_key || char(1) || i.id
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
