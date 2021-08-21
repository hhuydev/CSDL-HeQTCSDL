use AdventureWorks2008R2
go

--1
alter proc Cau1 @ten varchar(50), @nam int, @tien money out
as
select @tien = sum(SubTotal) from Sales.Store s join Sales.SalesPerson p
on s.SalesPersonID = p.BusinessEntityID
join Sales.SalesOrderHeader h
on h.SalesPersonID = p.BusinessEntityID
where YEAR(OrderDate) = @nam and Name = @ten


declare @tien money, @ten varchar(30) = 'Bike Boutique'
exec Cau1 @ten, 2008, @tien out
print @tien

--2
alter function SubTotalOfEmty(@EmpID int, @MonthOrder int, @YearOrder int)
returns money
as
begin 
	declare @tongtien money
	--return (
	--select sum(UnitPrice*OrderQty) 
	select @tongtien = sum(UnitPrice*OrderQty) 
	from Sales.SalesOrderHeader h join Sales.SalesOrderDetail od
	on od.SalesOrderID = h.SalesOrderID
	where h.SalesOrderID = @EmpID and MONTH(OrderDate) = @MonthOrder and YEAR(OrderDate) = @YearOrder
	--)
	return @tongtien
end

select *
	from Sales.SalesOrderHeader h join Sales.SalesOrderDetail od
	on od.SalesOrderID = h.SalesOrderID
	

select dbo.SubTotalOfEmty(43659, 7, 2005)

--3
alter function Discount_Func ()
returns table
as 
return (
	select CustomerID, TongTien = SUM(SubTotal), Discount = case 
		when SUM(SubTotal) < 10000 then 0
		when sum(SubTotal) >= 10000 and SUM(SubTotal) < 150000 then SUM(SubTotal) * 0.1
		else SUM(SubTotal) * 0.15
		end		
	from Sales.SalesOrderHeader 
	group by CustomerID)

select *from Discount_Func()