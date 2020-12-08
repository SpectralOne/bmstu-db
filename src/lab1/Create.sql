drop database if exists starsky;
create database starsky;
\c starsky;

create schema Stars;

-- Созвездия
create table Stars.Constellations(
    ConstellationId serial primary key,
    CName varchar(40) not null
);

-- Ученые
create table Stars.Scientists(
    ScientistId serial primary key,
    SName varchar(40) not null,
    Century int not null check(Century between -10 and 21)
);

-- Страны
create table Stars.Countries(
    CountryId serial primary key,
    CName varchar(50) not null
);

-- Звезды
create table Stars.Stars(
    StarId serial primary key,
    Letter varchar(20) not null,
    SName varchar(20) not null,
    RightAscension float not null,
    Declination float not null,
    SeeStarValue float null,
    Color varchar(30) check(
        Color = 'White'
        or Color = 'Orange'
        or Color = 'Red'
        or Color = 'Blue'
        or Color = 'Yellow'
    ),
    ConstellationId int not null,
    foreign key (ConstellationId) references Stars.Constellations(ConstellationId)
);

-- Дополнительная информация о звезде
create table Stars.ExtraInfo(
    StarId int not null,
    TypeStar varchar(10) null check(
        TypeStar = 'Dwarf'
        or TypeStar = 'Giant'
        or TypeStar = 'Supernova'
        or TypeStar = 'Hypernova'
    ),
    Distance int check(Distance is null or Distance > -1),
    Mass int check(Mass is null or Mass > 0),
    Radius bigint check(Radius is null or Radius > 0),
    AbsStarValue float null,
    Temperature int null,
    ScientistId int null,
    foreign key (StarId) references Stars.Stars(StarId),
    foreign key (ScientistId) references Stars.Scientists(ScientistId)
);

-- В каких странах какие звезды видны
create table Stars.CountriesStars(
    StarId int not null,
    CountryId int not null,
    DaysInYear int not null check(
        DaysInYear between 1 and 366
    ),
    foreign key(StarId) references Stars.Stars(StarId),
    foreign key(CountryId) references Stars.Countries(CountryId)
);

\copy Stars.Constellations(CName) from '~/bmstu-db/data/csv/Constellations.csv' delimiter ';' csv;
\copy Stars.Scientists(SName, Century) from '~/bmstu-db/data/csv/Scientists.csv' delimiter ';' csv;
\copy Stars.Countries(CName) from '~/bmstu-db/data/csv/Countries.csv' delimiter ';' csv;
\copy Stars.Stars(Letter, SName, RightAscension, Declination, SeeStarValue, Color, ConstellationId) from '~/bmstu-db/data/csv/Stars.csv' delimiter ';' csv;
\copy Stars.ExtraInfo from '~/bmstu-db/data/csv/ExtraInfo.csv' delimiter ';' csv;
\copy Stars.CountriesStars from '~/bmstu-db/data/csv/CountriesStars.csv' delimiter ';' csv;
