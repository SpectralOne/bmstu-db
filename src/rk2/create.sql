-- Вариант 3

drop database if exists university;
create database university;
\c university;

create table department(
    did serial primary key,
    dname varchar(20),
    ddesc varchar(30)
);

insert into department(dname, ddesc) values
    ('IU7', 'ICS'),
    ('IU3', 'Not given'),
    ('IU5', 'Networks');

create table teachers(
    tid serial primary key,
    did int not null,
    tname varchar(40) not null,
    tdegree int not null check(tdegree between 1 and 4),
    tpost varchar(30) not null,
    -- tdepartment varchar(20) not null,
    foreign key (did) references department(did)
);

insert into teachers(did, tname, tdegree, tpost) values
    (1, 'Teacher1', 1, 'Starsh'),
    (1, 'Teacher2', 3, 'Fake'),
    (2, 'Teacher3', 2, 'Mladsh'),
    (2, 'Teacher4', 4, 'Fake'),
    (3, 'Teacher5', 2, 'Mladsh'),
    (3, 'Teacher6', 2, 'Mladsh'),
    (1, 'Teacher7', 1, 'Asistent'),
    (2, 'Teacher8', 3, 'Asistent'),
    (3, 'Teacher9', 3, 'Asistent'),
    (1, 'Teacher10', 2, 'Asistent');


create table subj(
    subjid serial primary key,
    sname varchar(30),
    shours int,
    sterm int,
    srating float
);

insert into subj(sname, shours, sterm, srating) values
    ('Math', 72, 2, 2.8),
    ('C', 56, 2, 8.8),
    ('C++', 42, 4, 0.1),
    ('Physics', 62, 3, 4.1),
    ('DB', 40, 5, 10),
    ('AA', 32, 5, 9.2),
    ('OS', 146, 5, -146.146),
    ('Web', 56, 3, 5.6),
    ('Networks', 76, 7, 6.1),
    ('Python', 52, 1, 3.22);

create table teachers_subjects(
    tid int,
    subjid int,
    foreign key (tid) references teachers(tid),
    foreign key (subjid) references subj(subjid)
);

insert into teachers_subjects(tid, subjid) values
    (1, 10),
    (2, 9),
    (3, 8),
    (4, 7),
    (5, 6),
    (6, 5),
    (7, 4),
    (8, 3),
    (9, 2),
    (10, 1);
