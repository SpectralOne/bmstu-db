drop schema fdb cascade;
create schema fdb;

-- 1) Скалярная функция
--    Определеяет по склонению звезды в каком полушарии она находится

create or replace function fdb.Hemisphere(in Declination float)
returns varchar(10) language plpgsql as $$
begin
    if Declination between 0 and 90 then 
        return 'North'; 
    end if;
    
    return 'South';
end; $$;

select SName, fdb.Hemisphere(Declination) from Stars.Stars limit 10;

-- 2) Подставляемая табличная функция
--    Получить список звезд в созвездии

create or replace function fdb.StarsInConstellation(Constellation varchar(50))
returns table (StarId int, SName varchar(40), CName varchar(50)) language plpgsql 
as $$
declare r record;
begin 
    for r in (
        select S1.StarId, S1.SName, S2.CName from 
            Stars.Stars S1 join Stars.Constellations S2 on S1.ConstellationId = S2.ConstellationId
        where S2.CName = Constellation
    ) loop StarId := r.StarId;
           SName := r.SName;
           CName := r.CName;
        return next;
    end loop;
end; $$;

select * from fdb.StarsInCOnstellation('Andromeda') limit 10;
select * from fdb.StarsInCOnstellation('Unicorn') limit 10;

-- 3) Многооператорная табличная функция
--    Получить список звезд, ораниченный 10, открытых в 3 периода. x < 5; 5 <= x < 15; x >= 15
create or replace function fdb.DiscoverBetween()
returns table (
    StarId int,
    SName  varchar(20),
    Century int
) language plpgsql as $$
declare
    r record;
begin
    for r in (
        select S1.StarId, S1.SName, S3.Century
        from Stars.Stars S1 join Stars.ExtraInfo S2 on S1.StarId = S2.StarId
        join Stars.Scientists S3 on S2.ScientistId = S3.ScientistId
        where S3.Century < 5 limit 10
    ) loop StarId := r.StarId;
           SName := r.SName;
           Century := r.Century;
        return next;
    end loop;
    for r in (
        select S1.StarId, S1.SName, S3.Century
        from Stars.Stars S1 join Stars.ExtraInfo S2 on S1.StarId = S2.StarId
        join Stars.Scientists S3 on S2.ScientistId = S3.ScientistId
        where S3.Century >= 5 and S3.Century < 15 limit 10
    ) loop StarId := r.StarId;
           SName := r.SName;
           Century := r.Century;
        return next;
    end loop;
    for r in (
        select S1.StarId, S1.SName, S3.Century
        from Stars.Stars S1 join Stars.ExtraInfo S2 on S1.StarId = S2.StarId
        join Stars.Scientists S3 on S2.ScientistId = S3.ScientistId
        where S3.Century >= 15 limit 10
    ) loop StarId := r.StarId;
           SName := r.SName;
           Century := r.Century;
        return next;
    end loop;
end; $$;

select * from fdb.DiscoverBetween();

-- 4) Рекурсивная функция или функция с рекурсивным ОТВ
--    Вычисляет сумму масс звезд в таблице между CurrentId и EndId
create or replace function fdb.SumMass(CurrentId int, EndId int)
returns int language plpgsql as $$
declare
    m int;
begin
    if CurrentId > EndId then 
        return 0; 
    end if;
    select Mass into m from Stars.ExtraInfo where StarId = CurrentId;
    return m + fdb.SumMass(CurrentId + 1, EndId);
end; $$;

select fdb.SumMass(1, 10) as "Sum of mass";
select fdb.SumMass(50, 73) as "Sum of mass";
select fdb.SumMass(326, 327) as "Sum of mass";