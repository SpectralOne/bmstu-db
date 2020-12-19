import os
import psycopg2
from dotenv import load_dotenv
from tabulate import tabulate
from py_linq import Enumerable

load_dotenv('/root/bmstu-db/.env')
con = psycopg2.connect(
    dbname = 'rk3',
    user = os.getenv("PG_USER"),
    host = os.getenv("PG_HOST"),
    password = os.getenv("PG_PASSWORD")
)

# Найти все отделы, в которых работает более 10 сотрудников (SQL)
def task_1_sql():
    cur = con.cursor()
    try:
        cur.execute('''
            select department from employee
            group by department
            having count(id) > 10;
        ''')
        headers = [desc[0] for desc in cur.description]
        print(tabulate(cur.fetchall(), headers = headers))
        
        con.commit()
        cur.close()
    except:
        con.rollback()

# Найти все отделы, в которых работает более 10 сотрудников (LINQ)
def task_1_linq():
    cur = con.cursor()
    try:
        cur.execute('''
            select * from employee;
        ''')

        emp = Enumerable(cur.fetchall())
        con.commit()
        cur.close()

        deps = (
            emp.group_by(key_names=['department'], key = lambda t: t[3])
        ).select(
            lambda c: {'department': c.key.department, 'count':c.count()}
        ).where(
            lambda f: f['count'] > 10
        ).to_list()

        print(deps)
        
    except:
        con.rollback()


# Найти сотрудников, которые не выходят с рабочего места в течение всего рабочего дня (SQL)
def task_2_sql():
    cur = con.cursor()
    try:
        cur.execute('''
            select id, name, department from employee
            where id not in (
                select id_emp from (
                    select id_emp, visit_type, count(*) from visits
                    group by id_emp, visit_type
                    having visit_type = 2 and count(*) > 1
                ) as not_exitors
            )
        ''')
        headers = [desc[0] for desc in cur.description]
        print(tabulate(cur.fetchall(), headers = headers))
        
        con.commit()
        cur.close()
    except:
        con.rollback()

# Найти сотрудников, которые не выходят с рабочего места в течение всего рабочего дня (LINQ)
def task_2_linq():
    cur = con.cursor()
    try:
        cur.execute('''
            select * from visits;
        ''')

        visits = Enumerable(cur.fetchall())
        con.commit()
        cur.close()

        non_exitors = (
            visits.group_by(key_names=['id_emp', 'visit_type'], key=lambda t: (t[0], t[4]))
        ).select(
            lambda a: {'visit_type':a.key.visit_type, 'id_emp':a.key.id_emp, 'count':a.count()}
        ).where (
            lambda r: r['visit_type'] == 2 and r['count'] > 1
        ).to_list()
            
        print(non_exitors)
        
    except:
        con.rollback()

# Найти все отделы, в которых есть сотрудники, опоздавшие в определенную дату (SQL)
def task_3_sql():
    cur = con.cursor()
    date = input('Input date > ')
    try:
        query = '''
            set datestyle to SQL,dmy;
            set datestyle = dmy;
            select distinct department from employee
            where id in (
                select id_emp from (
                    select id_emp, min(visit_time) from visits
                    where visit_type = 1 and visit_date = date (%s)
                    group by id_emp
                    having min(visit_time) > '9:00'::time
                ) as res
            );
        '''
        cur.execute(query, (date, ))
        headers = [desc[0] for desc in cur.description]
        print(tabulate(cur.fetchall(), headers = headers))
        
        con.commit()
        cur.close()
    except:
        con.rollback()

# Найти все отделы, в которых есть сотрудники, опоздавшие в определенную дату (LINQ)
def task_3_linq():
    cur = con.cursor()
    date = input('Input date > ')
    try:
        cur.execute('''
            select * from visits;
        ''')

        visits = Enumerable(cur.fetchall())
        con.commit()
        cur.close()

        cur = con.cursor()
        cur.execute('''
            select * from employee;
        ''')

        emp = Enumerable(cur.fetchall())
        con.commit()
        cur.close()

        laters = (
            visits.group_by(key_names=['id_emp', 'visit_date', 'visit_time', 'visit_type'], key=lambda t: (t[0], str(t[1]), str(t[3]), t[4]))
        ).select(
            lambda a: {'id_emp':a.key.id_emp, 'visit_date':a.key.visit_date, 'visit_time':a.key.visit_time, 'visit_type':a.key.visit_type}
        ).where(
            lambda r: r['visit_type'] == 1 and r['visit_date'] == date and r['visit_time'] > '9:00'
        ).to_list()

        laters = [l['id'] for l in laters]

        deps = (
            emp.group_by(key_names=['id', 'department'], key=lambda t: (t[0], t[3]))
        ).select(
            lambda a: {'id':a.key.id, 'department':a.key.department}
        ).where(
            lambda a: a['id'] in laters
        ).to_list()
        print(deps)
        
    except:
        con.rollback()

def print_menu():
    print("\n\
1.  Найти все отделы, в которых работает более 10 сотрудников (SQL) \n\
2.  Найти все отделы, в которых работает более 10 сотрудников (LINQ) \n\
3.  Найти сотрудников, которые не выходят с рабочего места в течение всего рабочего дня (SQL) \n\
4.  Найти сотрудников, которые не выходят с рабочего места в течение всего рабочего дня (LINQ) \n\
5.  Найти все отделы, в которых есть сотрудники, опоздавшие в определенную дату (SQL) \n\
6.  Найти все отделы, в которых есть сотрудники, опоздавшие в определенную дату (LINQ) \n\
7. Завершить работу\n"
    )

execute = [
    '__empty__',

    task_1_sql, task_1_linq,
    task_2_sql, task_2_linq,
    task_3_sql, task_3_linq,
    
    lambda: print('Bye!'),
]
__exit = len(execute) - 1

if __name__ == '__main__':
    choice = -1
    while choice != __exit:
        print_menu()
        choice = int(input('> '))
        execute[choice]()
