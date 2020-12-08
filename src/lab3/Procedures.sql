drop schema pdb cascade;
create schema pdb;

-- 1) Хранимая процедура без параметров или с параметрами
--    Выводит количество звёзд данного типа
create or replace procedure pdb.CountStarsOfType(Type varchar(20))
language plpgsql as $$
declare
    cnt int;
begin 
    select count(*) 
    into cnt 
    from Stars.Stars S1 join Stars.ExtraInfo S2 on S1.StarId = S2.StarId
    join Stars.Constellations S3 on S1.ConstellationId = S3.ConstellationId
    where S2.TypeStar = Type;

    raise notice 'The number of % stars: %', Type, cnt;
end; $$;

call pdb.CountStarsOfType('Dwarf');
call pdb.CountStarsOfType('Giant');
call pdb.CountStarsOfType('Supernova');
call pdb.CountStarsOfType('Hypernova');

-- 2) Рекурсивная хранимая процедура
--    Выводит количество звезд, лежащих в промежутке масс от CurrentMass до EndMass
create or replace procedure pdb.CountStarsBetweenMasses(CurrentMass int, EndMass int, in cnt int)
language plpgsql as $$
declare
    c int;
begin
    if CurrentMass > EndMass then 
        raise notice '%', cnt;
        return; 
    end if;
    
    select count(*) into c
    from Stars.Stars S1 join Stars.ExtraInfo S2 on S1.StarId = S2.StarId
    where S2.Mass = CurrentMass;
    cnt := cnt + c;
    call pdb.CountStarsBetweenMasses(CurrentMass + 1, EndMass, cnt);
end; $$;

-- Интерфейс
create or replace procedure pdb.CountStarsBetweenMassesInterface(CurrentMass int, EndMass int)
language plpgsql as $$
begin 
    raise notice 'The number of stars between % and % mass: ', CurrentMass, EndMass;
    call pdb.CountStarsBetweenMasses(CurrentMass, EndMass, 0);
end; $$;

call pdb.CountStarsBetweenMassesInterface(1, 10);

-- 3) Хранимая процедура с курсором
--    Выводит имена 20 звезд
create or replace procedure pdb.PrintNames()
language plpgsql as $$
declare 
    CurrentName varchar(50);
    Cnt int;
    Cur refcursor;
begin
    Cnt := 0;
    open Cur for
        select SName from Stars.Stars;
    while Cnt < 20 loop
        fetch Cur into CurrentName;
        raise notice '[%]', CurrentName;
        Cnt := Cnt + 1;
    end loop;
    close Cur; -- проверить что делает
end; $$;

call pdb.PrintNames();

-- 4) Хранимая процедура доступа к метаданным
--    Вывести все таблицы в текущей БД
create or replace procedure pdb.MetaData()
language plpgsql as $$
declare r record;
begin
    for r in select table_catalog as db, table_schema as schema, table_name as table 
             from information_schema.tables where table_catalog = 'starsky' and table_schema = 'stars';
    loop
        raise info '%', r;
    end loop;
end; $$;

call pdb.MetaData();
