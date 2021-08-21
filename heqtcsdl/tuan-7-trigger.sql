use AdventureWorks2008R2
go

--Trigger

--1
CREATE TABLE M_Department (
  DepartmentID int NOT NULL PRIMARY KEY,
  Name nvarchar(50),
  GroupName nvarchar(50)
)

CREATE TABLE M_Employees (
  EmployeeID int NOT NULL PRIMARY KEY,
  Firstname nvarchar(50),
  MiddleName nvarchar(50),
  LastName nvarchar(50),
  DepartmentID int FOREIGN KEY REFERENCES M_Department (DepartmentID)
)

create view EmpDepart_View
as
	select e.EmployeeID, Firstname, MiddleName, LastName, d.DepartmentID, Name, GroupName 
	from M_Employees e join M_Department d
	on e.DepartmentID = d.DepartmentID

create trigger InsteadOf_Trigger
on EmpDepart_View
instead of insert
as
	insert into M_Department (DepartmentID, Name, GroupName)
	select DepartmentID, Name, GroupName from inserted
	insert into M_Employees (EmployeeID, Firstname, MiddleName, LastName,DepartmentID)
	select EmployeeID, Firstname, MiddleName, LastName,DepartmentID from inserted

insert into EmpDepart_View values(1,N'Tran',N'Dan','cute',23, 'ABC','abc')

select *from M_Employees
select *from M_Department

--2
create table MCustomer
(
	CustomerID int not null primary key,
	CustPriority int
)

create table MSalesOrders
(
	SalesOrderID int not null primary key,
	OrderDate date,
	SubTotal money,
	CustomerID int foreign key references MCustomer(CustomerID) 
)

select *from Sales.Customer

insert into MCustomer (CustomerID, CustPriority)
select CustomerID, null from Sales.Customer
where CustomerID between 30101 and 30117

INSERT into MSalesOrders
	(SalesOrderID, OrderDate, SubTotal, CustomerID)
select s.SalesOrderID, s.OrderDate, s.SubTotal, s.CustomerID
from Sales.SalesOrderHeader as s
WHERE s.CustomerID BETWEEN 30101 and 30117

--3
create table MDepartment
(
DepartmentID int not null primary key,
Name nvarchar(50),
NumOfEmployee int
)
create table MEmployees
(
EmployeeID int not null,
FirstName nvarchar(50),
MiddleName nvarchar(50),
LastName nvarchar(50),
DepartmentID int foreign key references MDepartment(DepartmentID),
constraint pk_emp_depart primary key(EmployeeID, DepartmentID)
)

create trigger Cau3
on MEmployees
instead of insert
as
	if exists (select *from inserted ins join MDepartment de
	on ins.DepartmentID = de.DepartmentID and NumOfEmployee > 200)
begin
	print N'So luong nhan vien trong phong da du!'
	rollback
end
	else
	update MDepartment
	set NumOfEmployee = NumOfEmployee + 1
	where DepartmentID in (select DepartmentID from inserted)

insert into MDepartment values(1, 'XYZ', 50),(2, 'XXX', 100),(3, 'AAA', 250)
insert into MEmployees values (1, N'Tran',N'Anh',N'Minh',1),(2, N'Tran',N'Anh',N'Minh',2),(3, N'Tran',N'Anh',N'Minh',3)		

select *from MDepartment

--4

select CreditRating from Purchasing.Vendor --30

create table ncc(
	mancc int primary key,
	name nvarchar(50),
	muctindung int
)

create table hoadon(
	mahd int primary key,
	account_number nvarchar(50),
	ncc int foreign key references ncc(mancc)
)

create trigger Cau4
on hoadon
after insert
as
	if exists (select *from inserted ins join ncc n
	on ins.ncc = n.mancc where muctindung = 5)
begin
	print N'Khong the them hoa don!'
	rollback transaction
return
end

insert into ncc values(1,'Kinh Do', 3),(2,'Kim Long', 5),(3,'Thanh Phat', 1)
insert into hoadon values(4,123, 1),(2,322,3)

select *from hoadon
select *from ncc

--5
create table cthd (
	saleorderid int primary key,
	orderqty int,
	productid int
)

insert into cthd values (1,20, 1)

create table sanpham (
	productid int primary key,
	name nvarchar(50),
	color nvarchar(50)
)

insert into sanpham values (1,'Banh AFC', 'Xanh')

create table kho (
	productid int primary key,
	quantity int,
	
)

insert into kho values (2,0)

create trigger Cau5
on cthd
after insert
as
	declare @quantity int, @orderqty int, @productid int
	select @orderqty = orderqty, @productid = productid from inserted 

	select @quantity = quantity from kho
	where @productid = productid

	if(@quantity = 0)
	begin
		print N'Kho het hang!'
		rollback 
	end
	else if (@quantity > @orderqty)
	begin
		update kho
		set quantity = quantity - @orderqty
		where @productid = productid
	end

--nsert into cthd values(4, 24, 2) 

select *from cthd

--Cau 6
create table M_SalesPerson
(
SalePSID int not null primary key,
TerritoryID int,
BonusPS money
)

insert into M_SalesPerson values (1,1,10),(2,1,40),(3,2,30)

create table M_SalesOrderHeader
(
SalesOrdID int not null primary key,
OrderDate date,
SubTotalOrd money,
SalePSID int foreign key references M_SalesPerson(SalePSID)
)

insert into M_SalesOrderHeader values (1,'2020-2-2',100000,1),(2,'2020-5-5',163000,1),(3,'2020-5-1',234000,2)

create trigger Cau6
on M_SalesOrderHeader
after insert
as
	declare @tongtien money, @manv int
	select @manv = SalePSID from inserted

	select @tongtien = sum(SubTotalOrd) from M_SalesOrderHeader
	where @manv = SalePSID

	if(@tongtien > 10000000)
	begin
		update M_SalesPerson
		set BonusPS = BonusPS + 0.1*BonusPS
		where @manv = SalePSID
	end
