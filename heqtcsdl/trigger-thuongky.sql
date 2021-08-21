--Lam lai 3 cau trigger kt thuong ky - co Chi

--Cau 1:

create database sinhvien_lop
go

use sinhvien_lop

create table lop (
	malop nchar(10) primary key,
	tenlop nchar(40),
	siso int
)

create table sv (
	msv char(10) primary key,
	tensv nchar(40),
	malop nchar(10) constraint fk_lop foreign key (malop) references lop(malop)
)

insert into lop values (1,'DHXD13A',80),(2,'DHKT13B',100),(3,'DHCK13C',150)
insert into sv values (1,'Tran Dan',1),(2,'Nguyen Thi Ly',2),(3,'Dang Huu Chien',3)

--Cau 1
create trigger KTKNSV
on sv
instead of insert
as
begin
	declare @masv char(10), @malop nchar(10)
	select @masv = msv, @malop = malop from inserted
	if exists (select *from sv where msv = @masv)
	begin
		print N'Mã sinh viên đã tồn tại! Hãy nhập mã khác.'
		rollback
	end
else
begin
	if not exists (select *from lop where malop = @malop)
	begin
		print N'Mã lớp không tồn tại!'
		rollback
	end
	else insert sv select *from inserted
end
end

drop trigger KTKNSV

insert into sv values (4,'Tran Dang Khoa',3)

select *from sv

--Cau 2
create trigger TinhLaiSoSV1
on sv
after insert, delete
as
begin
	if exists (select *from inserted )
	begin
		update lop
		set siso = siso + 1
		where malop in (select malop from inserted)
	end
	 if exists (select *from deleted )
	begin
		update lop
		set siso = siso - 1
		where malop in (select malop from deleted)
	end
end

drop trigger TinhLaiSoSV1

select *from sv
delete from sv where msv = 4
select *from sv

--Cau 3
create trigger TinhLaiSoSV2
on sv
after insert, delete
as
begin
	if exists (select *from inserted)
	begin
		update lop
		set siso = siso + 1
		where malop in (select malop from inserted)
	end
	if exists (select *from deleted)
	begin
		update lop
		set siso = siso - 1
		where malop in (select malop from deleted)
	end
end

drop trigger TinhLaiSoSV2

select *from sv
select *from lop

insert into lop values(4, 'DHMT14E', 200),(5, 'DHNN', 250)
insert into sv values(6, 'Pham Ngoc Thai', 5)

delete from sv where malop = 2