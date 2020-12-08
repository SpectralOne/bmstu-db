-- 2. Выполнить загрузку и сохранение XML или JSON файла в таблицу.
-- Созданная таблица после всех манипуляций должна соответствовать таблице
-- базы данных, созданной в первой лабораторной работе.

-- 4. Выполнить следующие действия:
    -- 1. Извлечь XML/JSON фрагмент из XML/JSON документа
    -- 2. Извлечь значения конкретных узлов или атрибутов XML/JSON документа
    -- 3. Выполнить проверку существования узла или атрибута

begin;
create temporary table client_import (values text) on commit drop;
\copy client_import from '/root/bmstu-db/src/lab5/json/Constellations.json';
\o

create temp table json_test(
    ConstellationId serial primary key,
    CName varchar(40) not null
) on commit drop;

insert into json_test("constellationid", "cname")
select CAST(j->>'constellationid' as integer) as constellationid,
       j->>'cname' as cname
from   (
           select json_array_elements(replace(values,'\','\\')::json) as j 
           from   client_import
       ) a where j->'cname' is not null and j->>'cname' like 'A%';
select * from json_test;

    -- 4. Изменить XML/JSON документ

update json_test
set cname = cname || ' new'
where constellationid = 6;

select * from json_test;
commit;

    -- 5. Разделить XML/JSON документ на несколько строк по узлам

create table json_table(
    ConstellationId serial primary key,
    CName varchar(40) not null,
    Json_column json
);

insert into json_table(cname, json_column) values 
    ('Andromeda', '[{"size": 4, "t": "constellation", "active":true}]'::json),
    ('Twins', '[{"size": 3, "t": "unknown", "active":true}]'::json),
    ('Scale', '[{"size": 2, "t": "test", "active":false}]'::json);

select * from json_table;

create table parsed(
    ConstellationId serial primary key,
    CName varchar(40) not null,
    size int,
    test json
);

insert into parsed (cname, size, test)
select cname, (j.items->>'size')::integer, items #- '{size}'
from json_table, jsonb_array_elements(json_column::jsonb) j(items);
select * from parsed;

drop table parsed;
drop table json_table;
