import json
import os
import decimal
from tabulate import tabulate
from dotenv import load_dotenv

from sqlalchemy import create_engine, text, MetaData
from sqlalchemy.orm import mapper, Session

load_dotenv('/root/bmstu-db/.env')
connect_string = 'postgresql+psycopg2://' + os.getenv("PG_USER") + ':' + os.getenv("PG_PASSWORD")+ '@' + \
            os.getenv("PG_HOST") + ':5432/' + os.getenv("PG_DBNAME")
engine = create_engine(connect_string)
meta = MetaData()
meta.reflect(bind=engine, schema='stars')

class Constellation(object):
    def __init__(self, cname):
        self.cname = cname

    def __tuple(self):
        return (self.cname)
    
    @staticmethod
    def __headers__():
        return ['cname']

class Scientist(object):
    def __init__(self, sname, century):
        self.sname = sname
        self.century = century

class Country(object):
    def __init__(self, cname):
        self.cname = cname

class Star(object):
    def __init__(self, letter, sname, rightascension, declination, seestarvalue, color, constellation):
        self.letter = letter
        self.sname = sname
        self.rightascension = rightascension
        self.declination = declination
        self.seestarvalue = seestarvalue
        self.color = color
        self.constellationid = constellation.id

    def __tuple(self):
        return (self.letter, self.sname, self.rightascension, self.declination, self.seestarvalue,
                self.color, self.constellationid)
    
    @staticmethod
    def __headers__():
        return ['letter', 'sname', 'rightascension', 'declination', 'seestarvalue', 'color', 'constellationid']

class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, decimal.Decimal):
            return {'__Decimal__': str(obj)}
        return json.JSONEncoder.default(self, obj)

mapper(Constellation, meta.tables['stars.constellations'])
mapper(Scientist, meta.tables['stars.scientists'])
mapper(Country, meta.tables['stars.countries'])
mapper(Star, meta.tables['stars.stars'])

# Количество звёзд заданного типа
def count_stars_by_type():
    typestar = str(input('TypeStar [Dwarf, Giant, Supernova, Hypernova] > '))
    con = Session(bind = engine)
    query = text('select count(*)'
             'from stars.stars S1 join stars.extrainfo S2 on S1.starid = S2.starid '
             'join stars.constellations S3 on S1.constellationid = S3.constellationid '
             'where S2.typestar = :typestar').bindparams(typestar=typestar)
    cnt = con.execute(query).fetchone()[0]
    con.close()
    print(cnt)

# Список звёзд в созвездии
def stars_in_constellation():
    constellation = str(input('Constellation [Andromeda, Deva, Crow, Unicorn, ...] > '))
    con = Session(bind = engine)
    query = text(
            'select * from fdb.StarsInCOnstellation(:constellation) limit 10 '
        ).bindparams(constellation=constellation)
    stars = con.execute(query).fetchall()
    con.close()

    print(tabulate(stars, headers=['starid', 'sname', 'cname']))

# Среднее количество массы каждого типа звёзд
def mass_average():
    con = Session(bind = engine)
    query = text(
            'select typestar as "type", avg(Mass) as "avg()", sum(Mass) / count(*) as "calculated" ' 
            'from Stars.ExtraInfo group by typestar'
        )
    averages = con.execute(query).fetchall()
    con.close()

    print(tabulate(averages, headers=['type', 'avg()', 'calculated']))

# Список звёзд заданного цвета, упорядоченные по убыванию радиуса
def radius_by_color():
    color = str(input('Color [White, Orange, Red, Blue, Yellow] > '))
    con = Session(bind = engine)
    query = text(
            'select S.sname, EI.radius, S.color ' 
            'from Stars.Stars S join Stars.ExtraInfo EI on S.starid = EI.starid '
            'where color = :color order by EI.radius desc limit 10'
        ).bindparams(color=color)
    stars = con.execute(query).fetchall()
    con.close()

    print(tabulate(stars, headers=['sname', 'radius', 'color']))

# Получить Id звезд, у которых кол-во стран выше среднего, и их среднюю видимость
def avg_see():
    con = Session(bind = engine)
    query = text(
        'select StarId, avg(DaysInYear) as "Average see" '
        'from Stars.CountriesStars '
        'group by StarId '
        'having count(CountryId) > ('
                'select avg(countries) from ('
                        'select StarId, count(*) as countries '
                        'from Stars.CountriesStars '
                        'group by StarId '
                    ') as CountCountries ) limit 10')
    stars = con.execute(query).fetchall()
    con.close()

    print(tabulate(stars, headers=['starid', 'average see']))

# Получить список звёзд заданного цвета
def stars_by_color():
    color = str(input('Color [White, Orange, Red, Blue, Yellow] > '))
    conn = Session(bind=engine)
    stars = conn.query(Star).filter(text('color = :color')) \
        .params(color=color).all()[:10]
    conn.close()

    data = []
    for star in stars:
        data.append(star.__tuple())

    print(tabulate(data, headers=Star.__headers__()))

# Список звёзд в созвездии (многотабличная)
def stars_in_constellation_obj():
    cname = str(input('Constellation [Andromeda, Deva, Crow, Unicorn, ...] > '))
    conn = Session(bind=engine)
    stars = conn.query(Star, Constellation
    ).filter(
        # pylint: disable=no-member
        Star.constellationid == Constellation.constellationid
    ).filter(text('cname = :cname')).params(cname=cname).all()[:10]
    conn.close()

    data = []
    for star in stars:
        r = list(map(lambda c: c.__tuple(), star))
        data.append(r[0] + (r[1],))

    print(tabulate(data, headers=Star.__headers__() + Constellation.__headers__()))

# Добавить созвездие
def add_constellation():
    cname = str(input('Cname > '))
    conn = Session(bind=engine)
    conn.add(Constellation(cname))
    conn.commit()
    conn.close()

# Изменить созвездие
def upd_constellation():
    cname_old = str(input('Cname to find > '))
    cname_new = str(input('New cname > '))
    conn = Session(bind=engine)
    constellation = conn.query(Constellation).filter(
        # pylint: disable=no-member
        Constellation.cname == cname_old
    ).first()
    
    if constellation:
        constellation.cname = cname_new
    
    conn.commit()
    conn.close()

def del_constellation():
    cname = str(input('Cname to find > '))
    conn = Session(bind=engine)
    constellation = conn.query(Constellation).filter(
        # pylint: disable=no-member
        Constellation.cname == cname
    ).first()
    
    if constellation:
        conn.delete(constellation)
    
    conn.commit()
    conn.close()

def test_exist():
    cname_old = str(input('Cname to find > '))
    conn = Session(bind=engine)
    constellation = conn.query(Constellation).filter(
        # pylint: disable=no-member
        Constellation.cname == cname_old
    ).first()
    
    conn.close()

    exist = 'Exists' if constellation else 'Not exist'
    print(exist)

def to_json():
    con = Session(bind = engine)
    query = text(
            'select typestar as "type", avg(Mass) as "avg()", sum(Mass) / count(*) as "calculated" ' 
            'from Stars.ExtraInfo group by typestar')
    averages = con.execute(query).fetchall()
    con.close()

    j = [dict(r) for r in averages]
    print('JSON: ', json.dumps(j, indent=2, cls=DecimalEncoder))

    for entry in j:
        if entry["type"] == 'Hypernova':
            entry["calculated"] = 322

    print('Modified JSON: ', json.dumps(j, indent=2, cls=DecimalEncoder))
    j.append({"type":"New type", "avg()": {"__Decimal__": "1337.322"}, "Calculated":299})
    print('After add JSON: ', json.dumps(j, indent=2, cls=DecimalEncoder))

def print_menu():
    print("\n\
1.  Количество звёзд заданного типа \n\
2.  Список звёзд в созвездии \n\
3.  Средняя масса каждого типа звёзд \n\
4.  Список звёзд заданного цвета, упорядоченные по убыванию радиуса \n\
5.  Получить Id звезд, у которых кол-во стран выше среднего, и их среднюю видимость \n\
6.  Однотабличная \n\
7.  Многотабличная \n\
8.  Добавить созвездие \n\
9.  Изменить созвездие \n\
10. Удалить созвездие\n\
11. Тест к 8, 9, 10\n\
12. -> JSON\n\
13. Выход")

execute = [
    '__empty__',

    count_stars_by_type, stars_in_constellation, mass_average, radius_by_color, avg_see,
    stars_by_color, stars_in_constellation_obj, add_constellation, upd_constellation, del_constellation,
    test_exist, to_json,
    
    lambda: print('Bye!')
]
__exit = len(execute) - 1

if __name__ == '__main__':
    choice = -1
    while choice != __exit:
        print_menu()
        choice = int(input('> '))
        execute[choice]()