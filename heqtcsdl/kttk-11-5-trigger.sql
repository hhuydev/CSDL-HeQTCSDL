--Phan 1:
--1		0.5
t2 = 501
t1 = 501

--2		0.5
t2 = 501
t1 = 501
t1 = 501

--3		0.5
t2 = 500
t1 = 501

--4		0.5
t2 = 500
t1 = 501

--5		0.5
t2 = 0
t1 = 4


 --Phan 2: trigger
create table lop (
	malop nchar(10) primary key,
	tenlop nvarchar(40),
	siso int 
)

 create table sv(
	masv char(10) primary key,
	tensv nvarchar(40),
	malop nchar(10) constraint fk_malop foreign key references lop(malop)
 )

 create trigger KTKNSV
 on sv
 for insert
 as
	if exists (select *from sv
	where masv in (select masv from inserted))
begin
	print N'Ma sinh vien da ton tai!'
	rollback
end
	if not exists (select *from lop
	where malop in (select malop from inserted))
begin
	print N'Ma lop khong ton tai!'
	rollback
end
	else 
	insert into sv select *from inserted

--drop trigger KTKNSV

select *from lop
select *from sv
insert into lop values ('A','DHHTTT15A',0)
insert into sv values ('1','Nguyen A','A')

--2
create trigger TinhLaiSiSoSV1
on sv
for insert, delete
as
	if exists (select * from deleted) AND 
	NOT exists (select * from inserted)
begin
	DELETE FROM sv WHERE malop IN 
	(SELECT malop FROM deleted)
end
else
	if exists (select * from inserted) AND not EXISTS (SELECT * FROM deleted)
begin
	update lop 
	set siso = siso - 1
	where malop in (select malop from deleted)

end

--3
create trigger TinhLaiSiSoSV2
on sv
for insert, delete
as
	if exists (select *from )


