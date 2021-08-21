USE AdventureWorks2008R2
GO

--1) Tính tổng trị giá của những hóa đơn với Mã theo dõi giao hàng
--(CarrierTrackingNumber) có 3 ký tự đầu là 4BD, thông tin bao gồm
--SalesOrderID, CarrierTrackingNumber, SubTotal=sum(OrderQty*UnitPrice)

select H.SalesOrderID, OrderDate, SubTotal = sum (OrderQty*UnitPrice) 
from [Sales].[SalesOrderDetail] S join [Sales].[SalesOrderHeader] H
on S.SalesOrderID = H.SalesOrderID
where MONTH(OrderDate) = 6 and YEAR(OrderDate)=2008
group by H.SalesOrderID, OrderDate
having  sum (OrderQty*UnitPrice) > 70000


--2) Đếm tổng số khách hàng và tổng tiền của những khách hàng thuộc các quốc gia
--có mã vùng là US (lấy thông tin từ các bảng SalesTerritory, Sales.Customer,
--Sales.SalesOrderHeader, Sales.SalesOrderDetail). Thông tin bao gồm
--TerritoryID, tổng số khách hàng (countofCus), tổng tiền (Subtotal) với Subtotal = SUM(OrderQty*UnitPrice)

SELECT S.TerritoryID, CountofCust = COUNT(C.CustomerID), Subtotal = SUM(OrderQty*UnitPrice) 
FROM  [Sales].[SalesTerritory] S join [Sales].[Customer] C
ON S.TerritoryID = C.TerritoryID join [Sales].[SalesOrderHeader] H on C.CustomerID = H.CustomerID
join [Sales].[SalesOrderDetail] D on H.SalesOrderID = D.SalesOrderID
where CountryRegionCode = 'US'
group by S.TerritoryID

--3) Tính tổng trị giá của những hóa đơn với Mã theo dõi giao hàng
--(CarrierTrackingNumber) có 3 ký tự đầu là 4BD, thông tin bao gồm
--SalesOrderID, CarrierTrackingNumber, SubTotal=sum(OrderQty*UnitPrice)

SELECT SalesOrderID, CarrierTrackingNumber, SubTotal=SUM(OrderQty*UnitPrice) from [Sales].[SalesOrderDetail] 
WHERE CarrierTrackingNumber like '4bd%'
GROUP by SalesOrderID, CarrierTrackingNumber

--4) Liệt kê các sản phẩm (product) có đơn giá (unitPrice) < 25 và số lượng bán trung
--bình > 5, thông tin gồm ProductID, name, AverageofQty

SELECT P.ProductID, PP.Name from [Sales].[SalesOrderDetail] OD join [Sales].[SpecialOfferProduct] SP
on OD.ProductID = SP.ProductID join [Production].[ProductProductPhoto] P 
on OD.ProductID = P.ProductID join [Production].[Product] PP on PP.ProductID = P.ProductID
where UnitPrice < 25
group by P.ProductID,PP.Name
having AVG(OrderQty)  > 5

--5) Liệt kê các công việc (JobTitle) có tổng số nhân viên >20 người, thông tin gồm
--JobTitle, countofPerson=count(*)
SELECT JobTitle, countofperson = COUNT(*) FROM HumanResources.Employee
GROUP BY JobTitle
HAVING COUNT(*) > 20

--6) Tính tổng số lượng và tổng trị giá của các sản phẩm do các nhà cung cấp có tên
--kết thúc bằng ‘Bicycles’ và tổng trị giá >80000, thông tin gồm
--BusinessEntityID, Vendor_name, ProductID, sumofQty, SubTotal
--(sử dụng các bảng [Purchasing].[Vendor] [Purchasing].[PurchaseOrderHeader] và [Purchasing].[PurchaseOrderDetail])
SELECT DISTINCT BusinessEntityID, Name, ProductID, SubTotal 
FROM Purchasing.Vendor JOIN Purchasing.PurchaseOrderHeader
ON PurchaseOrderHeader.VendorID = Vendor.BusinessEntityID
JOIN Purchasing.PurchaseOrderDetail
ON PurchaseOrderDetail.PurchaseOrderID = PurchaseOrderHeader.PurchaseOrderID
WHERE Name LIKE '%Bicycles'
GROUP BY BusinessEntityID, Name, ProductID, SubTotal
HAVING SubTotal > 80000

--7) Liệt kê các sản phẩm có trên 500 đơn đặt hàng trong quí 1 năm 2008 và có tổng
--trị giá >10000, thông tin gồm ProductID, Product_name, countofOrderID và Subtotal
SELECT PurchaseOrderDetail.ProductID, Name, countofOrderID = sum(OrderQty), SubTotal
FROM Production.Product JOIN Purchasing.PurchaseOrderDetail
ON PurchaseOrderDetail.ProductID = Product.ProductID
JOIN Purchasing.PurchaseOrderHeader
ON PurchaseOrderHeader.PurchaseOrderID = PurchaseOrderDetail.PurchaseOrderID
WHERE MONTH(OrderDate) IN (1,2,3) AND YEAR(OrderDate) = 2008 AND SubTotal > 10000
GROUP BY PurchaseOrderDetail.ProductID, Name, SubTotal
HAVING sum(OrderQty) > 500

--8) Liệt kê danh sách các khách hàng có trên 25 hóa đơn đặt hàng từ năm 2007 đến
--2008, thông tin gồm mã khách (PersonID) , họ tên (FirstName +' '+ LastName
--as fullname), Số hóa đơn (CountOfOrders).
SELECT BusinessEntityID, fullname = FirstName+' '+LastName, CountOfOrders = count(OrderQty) FROM Person.Person JOIN Purchasing.PurchaseOrderHeader 
ON PurchaseOrderHeader.ModifiedDate = Person.ModifiedDate
JOIN Purchasing.PurchaseOrderDetail
ON PurchaseOrderDetail.PurchaseOrderID = PurchaseOrderHeader.PurchaseOrderID
WHERE YEAR(OrderDate) BETWEEN 2007 AND 2008
GROUP BY BusinessEntityID, FirstName+' '+LastName
HAVING count(OrderQty) > 25


--9) Liệt kê những sản phẩm có tên bắt đầu với ‘Bike’ và ‘Sport’ có tổng số lượng
--bán trong mỗi mỗi năm trên 500 sản phẩm, thông tin gồm ProductID, Name,
--CountofOrderQty, year. (dữ liệu lấy từ các bảng Sales.SalesOrderHeader,
--Sales.SalesOrderDetail, and Production.Product)
SELECT PurchaseOrderDetail.ProductID, Name, countorderqty = sum(OrderQty), YEAR(OrderDate) FROM Production.Product JOIN Purchasing.PurchaseOrderDetail
ON PurchaseOrderDetail.ProductID = Product.ProductID
JOIN Purchasing.PurchaseOrderHeader
ON PurchaseOrderHeader.PurchaseOrderID = PurchaseOrderDetail.PurchaseOrderID
WHERE Name like  'Bike%' OR  Name LIKE 'Sport%'
GROUP BY PurchaseOrderDetail.ProductID, Name,YEAR(OrderDate)
HAVING sum(OrderQty) > 50


--10)Liệt kê những phòng ban có lương (Rate: lương theo giờ) trung bình >30, thông
--tin gồm Mã phòng ban (DepartmentID), tên phòng ban (name), Lương trung bình
--(AvgofRate). Dữ liệu từ các bảng [HumanResources].[Department],
--[HumanResources].[EmployeeDepartmentHistory],
--[HumanResources].[EmployeePayHistory
SELECT Department.DepartmentID, Name, avgofrate = AVG(Rate)
FROM HumanResources.Department JOIN HumanResources.EmployeeDepartmentHistory
ON EmployeeDepartmentHistory.DepartmentID = Department.DepartmentID
JOIN HumanResources.Employee
ON Employee.BusinessEntityID = EmployeeDepartmentHistory.BusinessEntityID
JOIN HumanResources.EmployeePayHistory
ON EmployeePayHistory.BusinessEntityID = Employee.BusinessEntityID
GROUP BY Department.DepartmentID, Name
HAVING AVG(Rate) > 30


