import random
import string
import json
from time import sleep
from datetime import datetime

scientists = [
'Abd Al-Rahman Al Sufi',
'Abraham bar Hiyya',
'Abraham Zacuto',
'Abu Said Gorgani',
'Abul Wáfa',
'Abulfazl Harawi',
'Adam Riess',
'Aden Baker Meinel',
'Adolph Friedrich',
'Adolphe Quetelet',
'Adriaan Blaauw',
'Al-Biruni',
'Al-fadl ibn Naubakht',
'Al-Khujandi',
'Alain Maury',
'Alan Hale',
'Alan Harvey Guth',
'Alastair G. W. Cameron',
'Albategnius',
'Albert Einstein',
'Albert Marth',
'Ernest Esclangon',
'Ernest William Brown',
'Ernst Friedrich Wilhelm Klinkerfues',
'Ernst Opik',
'Ernst Wilhelm Leberecht',
'Erwin Finlay-Freundlich',
'Eudoxus',
'Giuseppe Asclepi',
'Giuseppe Piazzi',
'Godefroy Wendelin',
'Gordon J. Garradd',
'Grigoriy Nikolaevich Neujmin',
'Jan Hendrik Oort',
'Jane Luu',
'Janet Akyüz Mattei',
'Janine Connes',
'Jay U. Gunter',
'Megh Nad Saha',
'Merieme Chadid',
'Michael',
'Michel Giacobini',
'Michel Mayor',
'Thomas William Webb',
'Thomas Wright',
'Thorvald Nicolai Thiele',
'Tobias Mayer',
'Zhang Yuzhe'
]

def gen_new_scientist():
    arr = []
    for _ in range(4):
        name = random.choice(scientists)
        while name in scientists:
            name = ''.join(random.choice(string.ascii_lowercase)
                                    for _ in range(15)).capitalize()
        century = random.randint(-10, 21)
        rec = {
            'sname': name,
            'century': century
        }
        arr.append(rec)
    
    return json.dumps(arr)


if __name__ == '__main__':
    file_id = 1
    table = 'scientists'
    while True:
        time = datetime.now().strftime('%Y-%m-%d_%H:%M:%S')
        with open(f'{file_id}_{table}_{time}.json', 'w') as file:
            file.write(gen_new_scientist())
        file_id += 1
        sleep(30)
