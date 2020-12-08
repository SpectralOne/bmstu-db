-- 1) Инструкция SELECT, использующая предикат сравнения с квантором
--    Вывести такие предметы, у которых рейтинг ниже чем у предметов 2 семестра

select sname, srating from subj
where srating < all (
    select srating from subj where sterm = 2
);


-- 2) Инструкция SELECT, использующая агрегатные функции ввыражениях столбцов
--    Средний рейтинг всех предметов

select avg(srating) as "Average rating", 
sum(srating)/count(*) as "Calc"
from subj;


-- 3) Создание новой временной локальной таблицы из результирующего набора данных инструкции SELECT
--    Таблица со всеми преподавателями кафедры IU7
drop table IU7teachers;
create temp table IU7teachers as 
    select T.tname, D.dname from teachers T join department D on D.did = T.did
    where D.dname = 'IU7';
select * from IU7teachers;

-- Создать хранимую процедуру с входным параметром – имя таблицы,
-- которая выводит сведения об индексах указанной таблицы в текущей базе
-- данных. Созданную хранимую процедуру протестировать.

create or replace procedure info_schema(tablename text)
language plpgsql as $$
declare
    r record;
begin
    for r in select * from information_schema.tables where table_name = tablename
    loop
        raise info '%', r;
    end loop;
end; $$;

create or replace procedure info_pg_indexes(table_name text)
language plpgsql as $$
declare
    r record;
begin
    for r in select indexname, indexdef from pg_indexes where tablename = table_name
    loop
        raise info '%', r;
    end loop;
end; $$;


call info_pg_indexes('subj');
