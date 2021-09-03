drop database if exists task2;
create database task2;
\c task2;

create table if not exists empls_visits (
    department varchar,
    fio varchar,
    day_date date,
    status varchar
);

insert into empls_visits (department, fio, day_date, status) values
    ('ИТ', 'Иванов Иван Иванович', '2020-01-15', 'Больничный'),
    ('ИТ', 'Иванов Иван Иванович', '2020-01-16', 'На работе'),
    ('ИТ', 'Иванов Иван Иванович', '2020-01-17', 'На работе'),
    ('ИТ', 'Иванов Иван Иванович', '2020-01-18', 'На работе'),
    ('ИТ', 'Иванов Иван Иванович', '2020-01-19', 'Оплачиваемый отпуск'),
    ('ИТ', 'Иванов Иван Иванович', '2020-01-20', 'Оплачиваемый отпуск'),
    ('Бухгалтерия', 'Петрова Ирина Ивановна', '2020-01-15', 'Оплачиваемый отпуск'),
    ('Бухгалтерия', 'Петрова Ирина Ивановна', '2020-01-16', 'На работе'),
    ('Бухгалтерия', 'Петрова Ирина Ивановна', '2020-01-17', 'На работе'),
    ('Бухгалтерия', 'Петрова Ирина Ивановна', '2020-01-18', 'На работе'),
    ('Бухгалтерия', 'Петрова Ирина Ивановна', '2020-01-19', 'Оплачиваемый отпуск'),
    ('Бухгалтерия', 'Петрова Ирина Ивановна', '2020-01-20', 'Оплачиваемый отпуск');

with numbered AS (
    select row_number() over(
        partition by fio, status
        order by day_date
    ) as i, fio, status, day_date
    from empls_visits
)
select fio, status, min(day_date) as date_from,
max(day_date) as date_to
FROM numbered n
group by fio, status, day_date - make_interval(days => i::int);

\c postgres;
drop database task2;