--Ha Gia Huy - 17031741

use AdventureWorks2008R2
go

--Scalar function

1) Viết hàm tên CountOfEmployees (dạng scalar function) với tham số @mapb,
giá trị truyền vào lấy từ field [DepartmentID], hàm trả về số nhân viên trong
phòng ban tương ứng. Áp dụng hàm đã viết vào câu truy vấn liệt kê danh sách các
phòng ban với số nhân viên của mỗi phòng ban, thông tin gồm: [DepartmentID],
Name, countOfEmp với countOfEmp= CountOfEmployees([DepartmentID]).
(Dữ liệu lấy từ bảng
[HumanResources].[EmployeeDepartmentHistory] và
[HumanResources].[Department])

create function COuntOfEmployees (@mapb smallint)
returns int
as
begin
return (
	
	select count(DepartmentID) 
	from HumanResources.EmployeeDepartmentHistory
	where DepartmentID = @mapb
	)
end

select DepartmentID, Name, countOfEmp = (dbo.COuntOfEmployees(D.DepartmentID)) 
from HumanResources.Department D


2) Viết hàm tên là InventoryProd (dạng scalar function) với tham số vào là
@ProductID và @LocationID trả về số lượng tồn kho của sản phẩm trong khu
vực tương ứng với giá trị của tham số
(Dữ liệu lấy từ bảng[Production].[ProductInventory])

create function IventoryProd (@ProductID int, @LocationID smallint)
returns smallint 
as
begin
	return (
		select Quantity from Production.ProductInventory
		where ProductID = @ProductID and LocationID = @LocationID
	)
end

select dbo.IventoryProd (1,1)

3) Viết hàm tên SubTotalOfEmp (dạng scalar function) trả về tổng doanh thu của
một nhân viên trong một tháng tùy ý trong một năm tùy ý, với tham số vào
@EmplID, @MonthOrder, @YearOrder
(Thông tin lấy từ bảng [Sales].[SalesOrderHeader])

create function SubTotalOfEmp (@EmplID int, @MonthOrder datetime, @YearOrder datetime)
returns real 
as
begin 
	return (
		select SUM(TotalDue) 
		from Sales.SalesOrderHeader
		WHERE SalesPersonID = @EmplID AND MONTH(OrderDate) = @MonthOrder and Year(OrderDate) = @YearOrder
	)
end

select dbo.SubTotalOfEmp(282, 7, 2005)

--table valued function

-- 4) Viết hàm SumOfOrder với hai tham số @thang và @nam trả về danh sách các 
-- hóa đơn (SalesOrderID) lập trong tháng và năm được truyền vào từ 2 tham số
-- @thang và @nam, có tổng tiền >70000, thông tin gồm SalesOrderID, OrderDate,
-- SubTotal, trong đó SubTotal =sum(OrderQty*UnitPrice).

create function SumOfOrder (@thang int, @nam int)
returns table
as
	return (
		select od.SalesOrderID, OrderDate, subtotal = sum(OrderQty * UnitPrice) 
		from Sales.SalesOrderHeader h join Sales.SalesOrderDetail od
		on h.SalesOrderID = od.SalesOrderID
		where MONTH(OrderDate) = @thang and YEAR(OrderDate) = @nam
		group by od.SalesOrderID, OrderDate
		having  sum(OrderQty * UnitPrice) > 70000
)

select *from SumOfOrder(9, 2005)

create function SumOfOrder_C2 (@thang int, @nam int)
returns @tb table (MANV INT, ngaylap datetime, tongtien money)
as begin
 insert @tb 
	select h.SalesOrderID, OrderDate, subtotal = sum(UnitPrice * OrderQty)
	from Sales.SalesOrderHeader h join Sales.SalesOrderDetail od
	on h.SalesOrderID = od.SalesOrderID 
	where month(OrderDate) = @thang and YEAR(OrderDate) = @nam
	group by h.SalesOrderID, OrderDate
	having sum(UnitPrice * OrderQty) > 70000
	return
end 

select *from SumOfOrder_C2(9,2005)


-- 5) Viết hàm tên NewBonus tính lại tiền thưởng (Bonus) cho nhân viên bán hàng 
-- (SalesPerson), dựa trên tổng doanh thu của mỗi nhân viên, mức thưởng mới bằng 
-- mức thưởng hiện tại tăng thêm 1% tổng doanh thu, thông tin bao gồm 
-- [SalesPersonID], NewBonus (thưởng mới), SumOfSubTotal. Trong đó:
--  SumOfSubTotal =sum(SubTotal),
--  NewBonus = Bonus+ sum(SubTotal)*0.01
-- view

create function NewBonus ()
returns table
as 
	 return (
		select h.SalesPersonID, sumofsubtotal = sum(SubTotal), newbonus = Bonus + (select SUM(SubTotal)*0.01  from Sales.SalesOrderHeader) 
		from Sales.SalesOrderHeader h join Sales.SalesPerson p
		on h.SalesPersonID = p.BusinessEntityID
		group by h.SalesPersonID, Bonus)

select *from NewBonus()

create function NewBonus_C2()
returns @tb table (manv int , tongtien money, tienthuong money)
as
begin	
	insert @tb
	select h.SalesPersonID, sumofsubtotal = sum(SubTotal), newbonus = Bonus + (select sum(SubTotal)*0.01 from Sales.SalesOrderHeader) 
	from Sales.SalesOrderHeader h join Sales.SalesPerson p 
	on h.SalesPersonID = p.BusinessEntityID
	group by h.SalesPersonID, Bonus
	return
end

select *from NewBonus_C2()

-- 6) Viết hàm tên SumOfProduct với tham số đầu vào là @MaNCC (VendorID),hàm dùng để tính tổng số lượng (SumOfQty) 
-- và tổng trị giá (SumOfSubTotal)
-- của các sản phẩm do nhà cung cấp @MaNCC cung cấp, thông tin gồm 
-- ProductID, SumOfProduct, SumOfSubTotal
-- (sử dụng các bảng [Purchasing].[Vendor] [Purchasing].[PurchaseOrderHeader] 
-- và [Purchasing].[PurchaseOrderDetail])

create function SumOfProduct(@mancc int)
returns table
as
	return (
		select ProductID, SumOfProduct = count(od.ProductID),  sumofsubtotal = sum(od.OrderQty * od.UnitPrice)
		from Purchasing.Vendor v join Purchasing.PurchaseOrderHeader h on v.BusinessEntityID = h.VendorID
		join Purchasing.PurchaseOrderDetail od on od.PurchaseOrderID = h.PurchaseOrderID
		where h.VendorID = @mancc
		group by ProductID
	)

select *from SumOfProduct(1658)


create function SumOfProduct_C2(@mancc int)
returns @tb table (msanpham int, tongsp int, tongtien money)
as 
begin
	insert @tb
	select ProductID, SumOfProduct = count(od.ProductID),  sumofsubtotal = sum(od.OrderQty * od.UnitPrice)
	from Purchasing.Vendor v join Purchasing.PurchaseOrderHeader h on v.BusinessEntityID = h.VendorID
	join Purchasing.PurchaseOrderDetail od on od.PurchaseOrderID = h.PurchaseOrderID
	where h.VendorID = @mancc
	group by ProductID
	return 
end

select *from SumOfProduct_C2(1658)

-- 7) Viết hàm tên Discount_Func tính số tiền giảm trên các hóa đơn(SalesOrderID), 
-- thông tin gồm SalesOrderID, [SubTotal], Discount; trong đó Discount được tính 
-- như sau:
-- Nếu [SubTotal]<1000 thì Discount=0 
-- Nếu 1000<=[SubTotal]<5000 thì Discount = 5%[SubTotal]
-- Nếu 5000<=[SubTotal]<10000 thì Discount = 10%[SubTotal] 
-- Nếu [SubTotal>=10000 thì Discount = 15%[SubTotal]
--Gợi ý: Sử dụng Case.. When … Then …

create function Discount_Func (@mahd int)
returns table
as
	return (
		select h.SalesOrderID, SubTotal, discount = (
			case 
				when SubTotal < 1000 then 0
				when SubTotal >= 1000 and SubTotal < 5000 then SubTotal*0.05
				when SubTotal >= 5000 and SubTotal < 10000 then SubTotal*0.1
				else SubTotal*0.15
			end
		)
		
		from Sales.SalesOrderDetail od join Sales.SalesOrderHeader h
		on od.SalesOrderID = h.SalesOrderID
		group by h.SalesOrderID, SubTotal
	)

select *from Discount_Func(43659)

create function  Discount_Func_C2 (@mahd int)
returns @tb table(mahd int, tongtien money, giamgia money)
as
begin
	insert @tb
	select h.SalesOrderID, SubTotal, discount = (
			case 
				when SubTotal < 1000 then 0
				when SubTotal >= 1000 and SubTotal < 5000 then SubTotal*0.05
				when SubTotal >= 5000 and SubTotal < 10000 then SubTotal*0.1
				else SubTotal*0.15
			end
		)	
		from Sales.SalesOrderDetail od join Sales.SalesOrderHeader h
		on od.SalesOrderID = h.SalesOrderID
		group by h.SalesOrderID, SubTotal
		return
end

select *from Discount_Func_C2(43659)


-- 8) Viết hàm TotalOfEmp với tham số @MonthOrder, @YearOrder để tính tổng 
-- doanh thu của các nhân viên bán hàng (SalePerson) trong tháng và năm được 
-- truyền vào 2 tham số, thông tin gồm [SalesPersonID], Total, với 
-- Total=Sum([SubTotal])

create function TotalOfEmp (@MonthOrder int, @YearOrder int)
returns table
as
	return (
		select SalesPersonID, total = SUM(SubTotal)
		from Sales.SalesOrderHeader
		where MONTH(orderdate) = @MonthOrder and YEAR(orderdate) = @YearOrder
		group by SalesPersonID
	)
select *from TotalOfEmp(1,2008)

create function TotalOfEmp_C2 (@MonthOrder int, @YearOrder int)
returns @tb table (manv int, tongtien money)
as
begin
	 insert @tb
	select SalesPersonID, total = SUM(SubTotal)
	from Sales.SalesOrderHeader
	where MONTH(orderdate) = @MonthOrder and YEAR(orderdate) = @YearOrder
	group by SalesPersonID
	return
	
end

select *from TotalOfEmp_C2(1,2008)

--9) Viết lại các câu 5,6,7,8 bằng Multi-statement table valued function


--10) Viết hàm tên SalaryOfEmp trả về kết quả là bảng lương của nhân viên, với tham
--số vào là @MaNV (giá trị của [BusinessEntityID]), thông tin gồm BusinessEntityID, FName, LName, Salary (giá trị của cột Rate).
-- Nếu giá trị của tham số truyền vào là Mã nhân viên khác Null thì kết quả là bảng lương của nhân viên đó.
--Kết quả là:  Nếu giá trị truyền vào là Null thì kết quả là bảng lương của tất cả nhân viên
--Ví dụ: thực thi hàm select * from SalaryOfEmp(Null)
--(Dữ liệu lấy từ 2 bảng [HumanResources].[EmployeePayHistory] và [Person].[Person] )
create function SalaryOfEmp (@manv int)
returns @tb table (manv int, ho nvarchar, ten nvarchar, luong money)
as
begin
		if (@manv is null)
		insert @tb
			select p.BusinessEntityID, p.FirstName, p.LastName, salary = SUM(rate) from HumanResources.EmployeeDepartmentHistory eh join Person.Person p
			on eh.BusinessEntityID = p.BusinessEntityID
			group by p.BusinessEntityID, p.FirstName, p.LastName
		else 
			select p.BusinessEntityID, p.FirstName, p.LastName, salary = SUM(rate) from HumanResources.EmployeeDepartmentHistory eh join Person.Person p
			on eh.BusinessEntityID = p.BusinessEntityID
			where p.BusinessEntityID = @manv
			group by p.BusinessEntityID, p.FirstName, p.LastName
		return
end
	

		