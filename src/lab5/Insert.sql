
-- 3. Создать таблицу, в которой будет атрибут(-ы) с типом XML или JSON, или
-- добавить атрибут с типом XML или JSON к уже существующей таблице.
-- Заполнить атрибут правдоподобными данными с помощью команд INSERT
-- или UPDATE.

create table json_table(
    ConstellationId serial primary key,
    CName varchar(40) not null,
    Json_column json
);

insert into json_table(cname, json_column) values 
    ('Andromeda', '{"size": 4, "type": "constellation", "active":true}'::json),
    ('Twins', '{"size": 3, "type": "unknown", "active":true}'::json),
    ('Scale', '{"size": 2, "type": "test", "active":false}'::json);

select * from json_table;
drop table json_table;
