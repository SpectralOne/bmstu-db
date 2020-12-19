-- Написать скалярную функцию, возвращающую количество сотрудников в возрастеот 18 до 40, выходивших более 3 храз.
create or replace function latecomers(dt date)
returns int language plpgsql as $$
begin
    return (
        select count(*) from (
            select distinct id from employee where
            extract(year from dt) - extract(year from birthdate) between 18 and 40 and id in (
                select id_emp from (
                    select id_emp, visit_date, visit_type, count(*) from visits where
                    visit_date = dt group by id_emp, visit_date, visit_type 
                    having visit_type = 2 and count(*) > 3
                ) as latecomers
            )
        ) as res
    );
end; $$;

select * from latecomers('20-12-2020'::date);

