drop table Stars.StarsAudit cascade;
drop trigger StarsAuditInsert on Stars.Stars;

create table Stars.StarsAudit(
    operation varchar(10) not null,
    executed timestamp not null,
    SName varchar(50) not null
);

create view StarsAuditView as
    select S.SName, SA.executed as LastUpdated 
    from Stars.Stars S
    left join Stars.StarsAudit SA on SA.SName = S.SName
group by 2, 1;

create or replace function InsertStarsAudit() 
returns trigger language plpgsql as $$
begin
    if (tg_op = 'INSERT') then
        insert into Stars.StarsAudit values ('Insert', now(), NEW.SName);
        return NEW;
    end if;
end; $$;

create or replace function UpdateStarsAuditView() 
returns trigger language plpgsql as $$
begin
    if (tg_op = 'DELETE') then
        delete from Stars.Stars where SName = OLD.SName;
        if not found then 
            return null;
        end if;
        OLD.LastUpdated = now();
        insert into Stars.StarsAudit values ('Delete', now(), OLD.SName);
            RETURN OLD;
        return NEW;
    end if;
end; $$;

create or replace function CheckInsertData()
returns trigger language plpgsql as $$
begin
    if (tg_op = 'INSERT') then
        if (NEW.Color != 'Orange' or NEW.Color != 'Red' or NEW.Color != 'Blue') then
            NEW.Color := 'Yellow';
            return NEW;
        end if;
    end if;
end; $$;

-- 1) after insert
create trigger StarsAuditInsert
after insert
on Stars.Stars
for each row execute procedure InsertStarsAudit();

-- 2) instead of delete
create trigger StarsAuditDelete
instead of delete
on StarsAuditView
for each row execute procedure UpdateStarsAuditView();

-- триггер на проверку check перед вставкой
create trigger CheckInsert
before insert
on Stars.Stars
for each row execute procedure CheckInsertData();

insert into Stars.Stars(Letter, SName, RightAscension, Declination, SeeStarValue, Color, ConstellationId)
values
    ('asdsadasd', 'sadasdasd', 12, 12, 2, 'Red', 30),
    ('test', 'asd', 12, 12, 2, 'Black', 30);

delete from StarsAuditView where SName = 'sadasdasd';

select * from Stars.StarsAudit; 
select * from Stars.Stars where Letter = 'test';

delete from Stars.Stars where Letter = 'test';
