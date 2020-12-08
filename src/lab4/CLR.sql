create extension plpython3u;

drop schema clr cascade;
create schema clr;

-- 1) Определяемая пользователем скалярная функция CLR
--    Функция получения количества звёзд заданного типа

create or replace function clr.CountTypes(types varchar)
returns integer language plpython3u as $$
    res = plpy.execute(f"\
    select count(*) \
    from Stars.Stars S1 join Stars.ExtraInfo S2 on S1.StarId = S2.StarId \
    join Stars.Constellations S3 on S1.ConstellationId = S3.ConstellationId \
    where S2.TypeStar = '{types}';")

    return res[0]['count'];
$$;

select TypeStar, clr.CountTypes(TypeStar) as "Total count" from Stars.ExtraInfo GROUP by TypeStar;


-- 2) Пользовательская агрегатная функция CLR
--    Средняя температура звёзд

create or replace function clr.AvgTemp()
returns numeric language plpython3u as $$
    res = plpy.execute(" \
        SELECT sum(Temperature) as temp \
        FROM Stars.Extrainfo S1 \
        GROUP BY TypeStar;")
    return sum(map(lambda x: x['temp'], res)) / len(res)
$$;

select * from clr.AvgTemp();

-- 3) Определяемая пользователем табличная функция CLR
--    Звёзды, открытые в промежуток между заданных веком

create or replace function clr.DiscoverBetween(f int, s int)
returns table (
    starid int,
    sname varchar,
    century int
) language plpython3u as $$
    res = plpy.execute(f" \
        select S1.StarId, S1.SName, S3.Century \
        from Stars.Stars S1 join Stars.ExtraInfo S2 on S1.StarId = S2.StarId \
        join Stars.Scientists S3 on S2.ScientistId = S3.ScientistId \
        where S3.Century between {f} and {s} \
    ")
    for r in res:
        yield (r["starid"], r['sname'], r['century'])

$$ ;

select * from clr.DiscoverBetween(20, 21);

--- 

drop table if exists Stars.NotExistScientists;
create table Stars.NotExistScientists (
    ScientistId serial primary key,
    SName varchar(40) not null,
    Century int not null check(Century between -10 and 21)
);

-- 4) Хранимая процедура CLR
--    Функция удаляет всех несуществующих учёных, добавленных по триггеру

create or replace procedure clr.RemoveNotExist()
language plpython3u AS $$
    res = plpy.cursor(" \
        SELECT SName AS name \
        FROM Stars.NotExistScientists; \
    ")
    plan = plpy.prepare("delete from Stars.Scientists where SName = $1;", ["VARCHAR"])
    for name in map(lambda elem: elem['name'], res):
        plpy.execute(plan, [name])
    plpy.execute("DELETE from Stars.NotExistScientists;")
$$ ;


create or replace function clr.UpdateNotExist()
returns trigger language plpython3u as $$
    plpy.execute("insert into {} (sname, century) values ('{}', '{}');".format('Stars.NotExistScientists',
            TD['new']['sname'], TD['new']['century'])
    )
    return None
$$ ;

-- 5) Триггер CLR
--    Обновляет таблицу с недавно добавленными учёными

drop trigger if exists NotExist on Stars.Scientists;

create trigger NotExist
after insert on Stars.Scientists
for row execute procedure clr.UpdateNotExist();


insert into Stars.Scientists (SName, Century)
values
    ('NotExists first', 21),
    ('NotExists second', 21),
    ('NotExists third', 21);

select * from Stars.NotExistScientists;
call clr.RemoveNotExist();
select * from Stars.NotExistScientists;

-- 6) Определяемый пользователем тип данных CLR
--    Список звёзд в созвездии

drop type ConstellationCard;
create type ConstellationCard AS (
    starid int,
    sname varchar,
    cname varchar
);

create or replace function clr.ConstellationStarInfo(constellation varchar)
returns setof ConstellationCard language plpython3u as $$
    res = plpy.cursor(f"\
        select S1.StarId, S1.SName, S2.CName from \
            Stars.Stars S1 join Stars.Constellations S2 on S1.ConstellationId = S2.ConstellationId \
        where S2.CName = '{constellation}';")
    for c in map(lambda c: (c['starid'], c['sname'], c['cname']), res):
        yield c
$$ ;

select * from clr.ConstellationStarInfo('Andromeda');