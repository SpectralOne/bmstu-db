drop database if exists fact;
create database fact;
\c fact;

with recursive factorial (n, factorial) AS (
    select 1, 1 
    union all
    select n + 1, (n + 1) * factorial
    from factorial 
    where n < 13 
)
select n,factorial from factorial;

\c postgres;
drop database fact;