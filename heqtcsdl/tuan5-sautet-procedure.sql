use AdventureWorks2008R2
go

--HaGiaHuy_17031741_Thu4(7->10)_CoChi

--1) Viết một thủ tục tính tổng tiền thu (TotalDue) của mỗi khách hàng trong một
--tháng bất kỳ của một năm bất kỳ (tham số tháng và năm) được nhập từ bàn phím,
--thông tin gồm: CustomerID, SumOfTotalDue =Sum(TotalDue)
create proc Cau1 (@thang int, @nam int)
as
select CustomerID, sumoftotaldue = SUM(TotalDue) from [Sales].SalesOrderHeader
where MONTH(OrderDate) = @thang and YEAR(OrderDate) = @nam
group by CustomerID

exec Cau1 4,2008

drop proc Cau1

--2) Viết một thủ tục dùng để xem doanh thu từ đầu năm cho đến ngày hiện tại của
--một nhân viên bất kỳ, với một tham số đầu vào và một tham số đầu ra. Tham số
--@SalesPerson nhận giá trị đầu vào theo chỉ định khi gọi thủ tục, tham số
--@SalesYTD được sử dụng để chứa giá trị trả về của thủ tục.
create proc Cau2 (@salepersionID int, @doanhthu int output)
as
select @doanhthu = sum(TotalDue) from Sales.SalesOrderHeader
where SalesPersonID = @salepersionID and OrderDate between '1/1/2008' and '7/4/2008'
group by SalesPersonID

exec Cau2 274

drop proc Cau2
--3) Viết một thủ tục trả về một danh sách ProductID, ListPrice của các sản phẩm có
--giá bán không vượt quá một giá trị chỉ định (tham số input @MaxPrice).
create proc Cau3 (@maxprice money) 
as
select ProductID, ListPrice from Production.Product
where ListPrice < @maxprice

exec Cau3 300000

drop proc Cau3

--4) Viết thủ tục tên NewBonus cập nhật lại tiền thưởng (Bonus) cho 1 nhân viên bán
--hàng (SalesPerson), dựa trên tổng doanh thu của nhân viên đó. Mức thưởng mới
--bằng mức thưởng hiện tại cộng thêm 1% tổng doanh thu. Thông tin bao gồm
--[SalesPersonID], NewBonus (thưởng mới), SumOfSubTotal. Trong đó:
--SumOfSubTotal =sum(SubTotal)
--NewBonus = Bonus+ sum(SubTotal)*0.01
create proc NewBonus
as
begin 
update Sales.SalesPerson
set Bonus = Bonus + (select SUM(SubTotal)*0.01 from Sales.SalesOrderHeader
where SalesPersonID in (select BusinessEntityID from Sales.SalesPerson))

select SalesPersonID, Bonus NewBonus,SumOfSubTotal = SUM(SubTotal)  
from Sales.SalesPerson p join Sales.SalesOrderHeader h
on p.BusinessEntityID = h.SalesPersonID
group by SalesPersonID, Bonus
end
exec NewBonus 

drop proc NewBonus

--5) Viết một thủ tục dùng để xem thông tin của nhóm sản phẩm (ProductCategory)
--có tổng số lượng (OrderQty) đặt hàng cao nhất trong một năm tùy ý (tham số
--input), thông tin gồm: ProductCategoryID, Name, SumOfQty. Dữ liệu từ bảng
--ProductCategory, ProductSubCategory, Product và SalesOrderDetail. (Lưu ý: dùng Sub Query)

select c.ProductCategoryID, p.Name, sumofQty = sum(ProductID) from Production.ProductCategory c join [Production].ProductSubcategory s
on c.ProductCategoryID = s.ProductCategoryID
join Production.Product p 
on p.ProductSubcategoryID = s.ProductSubcategoryID
where ProductID in (select ProductID from Sales.SalesOrderDetail)
group by c.ProductCategoryID, p.Name
having SUM(ProductID) >= all (select sum(ProductID) from Sales.SalesOrderDetail od join
	Sales.SalesOrderHeader h
	on h.SalesOrderID = od.SalesOrderID
	where YEAR(OrderDate) = 2008)

create view vw_NhomSP
as
select c.ProductCategoryID, s.Name, sumofQty = sum(OrderQty), OrderDate 
from Production.ProductCategory c join [Production].ProductSubcategory s
on c.ProductCategoryID = s.ProductCategoryID
join Production.Product p 
on p.ProductSubcategoryID = s.ProductSubcategoryID
join Sales.SalesOrderDetail od
on od.ProductID = p.ProductID
join Sales.SalesOrderHeader h
on h.SalesOrderID = od.SalesOrderID
group by c.ProductCategoryID,s.Name,OrderDate 
go

select *from vw_NhomSP
go

create proc Cau5 (@nam int)
as 
begin 
select v.ProductCategoryID, v.Name, v.sumofQty from vw_NhomSP v
where v.sumofQty = (select max(v2.sumofQty) from vw_NhomSP v2 
	where YEAR(v2.orderdate) = @nam
)
end
go

exec Cau5 2008

drop proc Cau5

--6) Tạo thủ tục đặt tên là TongThu có tham số vào là mã nhân viên, tham số đầu ra
--là tổng trị giá các hóa đơn nhân viên đó bán được. Sử dụng lệnh RETURN để trả
--về trạng thái thành công hay thất bại của thủ tục.

create proc TongThu (@manv int, @tongtienhd money output)
as
select @tongtienhd = SUM(TotalDue) from Sales.SalesPerson p join Sales.SalesOrderHeader h
on p.BusinessEntityID = h.SalesPersonID
where h.SalesPersonID = @manv
if(@tongtienhd < 0) return -1
else return 1

DECLARE @kq money
EXEC TongThu 280, @kq output
print N'KQ:' + convert(nvarchar(20),@kq)
go

drop  proc TongThu

--7) Tạo thủ tục hiển thị tên và số tiền mua của cửa hàng mua nhiều hàng nhất theo năm đã cho.
create proc Cau7 (@nam int)
as
select top 1 s.Name, tongtien = SUM(TotalDue) from Sales.Store s join Sales.Customer c
on s.BusinessEntityID = c.StoreID
join Sales.SalesOrderHeader h
on h.CustomerID = c.CustomerID
where YEAR(OrderDate) = @nam
group by s.Name

exec Cau7 2008

drop proc Cau7


--8) Viết thủ tục Sp_InsertProduct có tham số dạng input dùng để chèn một mẫu tin
--vào bảng Production.Product. Yêu cầu: chỉ thêm vào các trường có giá trị not null 
--và các field là khóa ngoại.

select *from Production.Product


--9) Viết thủ tục XoaHD, dùng để xóa 1 hóa đơn trong bảng Sales.SalesOrderHeader
--khi biết SalesOrderID. Lưu ý : trước khi xóa mẫu tin trong
--Sales.SalesOrderHeader thì phải xóa các mẫu tin của hoá đơn đó trong Sales.SalesOrderDetail.

create proc Cau9 (@mahd int)
as
delete from Sales.SalesOrderDetail
where SalesOrderID = @mahd
delete from Sales.SalesOrderHeader
where SalesOrderID = @mahd

exec Cau9 43660

select *from Sales.SalesOrderHeader

drop proc Cau9

--10)Viết thủ tục Sp_Update_Product có tham số ProductId dùng để tăng listprice
--lên 10% nếu sản phẩm này tồn tại, ngược lại hiện thông báo không có sản phẩm này
create proc Sp_Update_Product (@productid int)
as

update Production.Product
set ListPrice = ListPrice + 0.1*ListPrice
where ProductID = @productid
if(@productid is null) print N'Không tìm thấy mã sản phẩm!'
else print N'Đã update, hãy kiểm tra lại!'

exec Sp_Update_Product 720

select *from Production.Product

drop proc Sp_Update_Product

