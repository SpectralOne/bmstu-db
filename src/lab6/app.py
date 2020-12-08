import psycopg2
import os
from tabulate import tabulate
from dotenv import load_dotenv

load_dotenv('/root/bmstu-db/.env')
con = psycopg2.connect(
    dbname = os.getenv("PG_DBNAME"),
    user = os.getenv("PG_USER"),
    host = os.getenv("PG_HOST"),
    password = os.getenv("PG_PASSWORD")
)

def task_1():
    print('\n--- Среднее значение массы всех звёзд ---')
    cur = con.cursor()
    try:
        cur.execute('''
            select avg(Mass) as "Average mass", sum(Mass) / count(*) as "Calc it"
            from Stars.ExtraInfo;
        ''')
        headers = [desc[0] for desc in cur.description]
        print(tabulate(cur.fetchall(), headers = headers))
        cur.close()
    except:
        con.rollback()
    else:
        con.commit()

def task_2():
    print('\n--- Получить имена звезд, открытых учеными, у которых в имени есть "Alex" ---')
    cur = con.cursor()
    try:
        cur.execute('''
            select S1.SName as Star, S3.SName as Scientist
            from Stars.Stars S1 join Stars.ExtraInfo S2 on S1.StarId = S2.StarId
            join Stars.Scientists S3 on S2.ScientistId = S3.ScientistId
            where S3.SName like '%Alex%';
        ''')
        headers = [desc[0] for desc in cur.description]
        print(tabulate(cur.fetchall(), headers = headers))
        cur.close()
    except:
        con.rollback()
    else:
        con.commit()

def task_3():
    print('\n--- Получить для каждого типа максимальную, среднюю и минимальную массу и тип следующей звезды по убыванию ---')
    cur = con.cursor()
    try:
        cur.execute('''
            with averages as (
                select TypeStar,
                avg(Mass) as AvgMass,
                max(Mass) as MaxMass,
                min(Mass) as MinMass 
                from Stars.ExtraInfo group by TypeStar
            )
            select TypeStar, AvgMass, MaxMass, MinMass,
            lead(TypeStar) over (order by AvgMass desc) as Next from averages;
        ''')
        headers = [desc[0] for desc in cur.description]
        print(tabulate(cur.fetchall(), headers = headers))
        cur.close()
    except:
        con.rollback()
    else:
        con.commit()

def task_4():
    print('\n--- Выводит все таблицы в текущей бд ---')
    cur = con.cursor()
    try:
        cur.execute('''
            select table_catalog as db, table_schema as schema, table_name as table 
            from information_schema.tables where table_catalog = 'starsky' and table_schema = 'stars';
        ''')
        headers = [desc[0] for desc in cur.description]
        print(tabulate(cur.fetchall(), headers = headers))
        cur.close()
    except:
        con.rollback()
    else:
        con.commit()

def task_5():
    print('\n--- Определеяет по склонению звезды в каком полушарии она находится ---')
    cur = con.cursor()
    try:
        cur.execute('''
            select SName, fdb.Hemisphere(Declination) from Stars.Stars limit 10;
        ''')
        headers = [desc[0] for desc in cur.description]
        print(tabulate(cur.fetchall(), headers = headers))
        cur.close()
    except:
        con.rollback()
    else:
        con.commit()

def task_6():
    print('\n--- Получить список звезд, ораниченный 10, открытых в 3 периода. x < 5; 5 <= x < 15; x >= 15 ---')
    cur = con.cursor()
    try:
        cur.execute('''
            select * from fdb.DiscoverBetween();
        ''')
        headers = [desc[0] for desc in cur.description]
        print(tabulate(cur.fetchall(), headers = headers))
        cur.close()
    except:
        con.rollback()
    else:
        con.commit()


def task_7():
    print('\n--- Выводит количество звёзд данного типа ---')
    cur = con.cursor()
    try:
        cur.execute('''
            call pdb.CountStarsOfType('Dwarf');
        ''')
        print(con.notices)
        cur.close()
    except:
        con.rollback()
    else:
        con.commit()

def task_8():
    print('\n--- Выводит имя текущей БД ---')
    cur = con.cursor()
    try:
        cur.execute('''
            select * from current_catalog;
        ''')
        headers = [desc[0] for desc in cur.description]
        print(tabulate(cur.fetchall(), headers = headers))
        cur.close()
    except:
        con.rollback()
    else:
        con.commit()

def task_9():
    print('\n--- Таблица, с каких планет видно какие звёзды ---')
    cur = con.cursor()
    try:
        cur.execute('''
            create table if not exists Stars.Planets(
                PlanetId serial primary key,
                PlanetName varchar(40) not null,
                StarId int,
                foreign key(StarId) references Stars.Stars(StarId)
            );
        ''')
        cur.close()
    except:
        con.rollback()
    else:
        con.commit()


def task_10():
    print('\n--- Вставка значений в ранее созданную таблицу ---')
    cur = con.cursor()
    try:
        cur.execute('''
            insert into Stars.Planets(PlanetName, StarId) values
                ('Mars', 1),
                ('Venus', 2),
                ('Venus', 1);
            select * from Stars.Planets;
        ''')
        headers = [desc[0] for desc in cur.description]
        print(tabulate(cur.fetchall(), headers = headers))
        cur.close()
    except:
        con.rollback()
    else:
        con.commit()


def check():
    cur = con.cursor()
    cur.execute('''
        drop table Stars.Planets;
    ''')
    con.commit()
    cur.close()

def print_menu():
    print("\n\
1.  Выполнить скалярный запрос \n\
2.  Выполнить запрос с несколькими соединениями (JOIN) \n\
3.  Выполнить запрос с ОТВ(CTE) и оконными функциями \n\
4.  Выполнить запрос к метаданным \n\
5.  Вызвать скалярную функцию (написанную в третьей лабораторной работе) \n\
6.  Вызвать многооператорную или табличную функцию (написанную в третьей лабораторной работе) \n\
7.  Вызвать хранимую процедуру (написанную в третьей лабораторной работе) \n\
8.  Вызвать системную функцию или процедуру \n\
9.  Создать таблицу в базе данных, соответствующую тематике БД \n\
10. Выполнить вставку данных в созданную таблицу с использованием инструкции INSERT или COPY\n\
11. Завершить работу\n"
    )

execute = [
    '__empty__',

    task_1, task_2, task_3, task_4, task_5, 
    task_6, task_7, task_8, task_9, task_10,
    
    lambda: print('Bye!'), check
]
__exit = len(execute) - 1

if __name__ == '__main__':
    choice = -1
    while choice != __exit:
        print_menu()
        choice = int(input('> '))
        execute[choice]()
    con.close()
