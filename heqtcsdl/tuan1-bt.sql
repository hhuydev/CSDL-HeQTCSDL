USE Northwind 
GO


--1) Liệt kê danh sách các hóa đơn (Orders) được lập trong quý 4
--năm 1997. Thông tin gồm OrderID, OrderDate, Customerid, EmployeeID. 
SELECT OrderID, OrderDate, Customers.CustomerID, EmployeeID 
FROM dbo.Orders JOIN dbo.Customers 
ON Customers.CustomerID = Orders.CustomerID
WHERE MONTH(OrderDate) IN (10,11,12) AND YEAR(OrderDate) = 1997

--2) Liệt kê danh sách các hóa đơn (Orders) được lập trong trong 
--ngày thứ 7 và chủ nhật của tháng 12 năm 1997. 
--Thông tin gồm OrderID, OrderDate, Customerid, EmployeeID, WeekDayOfOrdate (Ngày thứ mấy trong tuần). 
SELECT OrderID, OrderDate, Customers.CustomerID, EmployeeID, DATENAME(WEEKDAY, GETDATE()) WeekDayOfOrdate  
FROM dbo.Orders JOIN dbo.Customers
ON Customers.CustomerID = Orders.CustomerID
WHERE (DATENAME(DAY, GETDATE()) = 7 OR DATENAME(DAY, GETDATE()) = 1 ) AND MONTH(OrderDate) = 12 AND YEAR(OrderDate) = 1997

--3) Liệt kê danh sách 2 employees có tuổi lớn nhất. 
--Thông tin bao gồm EmployeeID, EmployeeName, Age. 
--Trong đó, EmployeeName được ghép từ LastName và FirstName; 
--Age là năm hiện hành trừ năm sinh.
SELECT TOP 2 EmployeeID, EmployeeName = FirstName + ' ' + LastName , Age =  DATEDIFF(YEAR, YEAR(BirthDate), GETDATE()) 
FROM dbo.Employees
ORDER BY DATEDIFF(YEAR, YEAR(BirthDate), GETDATE()) DESC 

--4) Liệt kê danh sách các Orders gồm OrderId, Productid, Quantity, 
--Unitprice, Discount, ToTal = Quantity * unitPrice – 20%*Discount. 
SELECT [Order Details].OrderID, ProductID, Quantity, UnitPrice,Total =  Discount, Quantity * UnitPrice - 0.2*Discount
FROM dbo.Orders JOIN dbo.[Order Details]
ON [Order Details].OrderID = Orders.OrderID

--5) Liệt kê danh sách các Orders gồm OrderId, Productid,Productname, Quantity, 
--Unitprice, Discount, ToTal = Quantity * unitPrice – 20%*Discount, QuaTang.
--QuaTang sẽ hiển thị tặng phiếu mua hàng 50000 nếu quantity >=10, 
--ngược lại không được tặng quà
SELECT Orders.OrderID, [Order Details].ProductID, ProductName, Quantity, [Order Details].UnitPrice,
 Discount, Total = Quantity*[Order Details].UnitPrice-0.2*Discount
 FROM dbo.Orders JOIN dbo.[Order Details] 
ON [Order Details].OrderID = Orders.OrderID
JOIN dbo.Products
ON Products.ProductID = [Order Details].ProductID
WHERE Quantity>=10

--6) Danh sách các sản phẩm bán trong ngày thứ 7 và chủ nhật 
--của tháng 12 năm 1996, thông tin gồm [ProductID], [ProductName], 
--OrderID, OrderDate, CustomerID, Unitprice, Quantity,  
--ToTal= Quantity*UnitPrice. 
--Được sắp xếp theo ProductID, cùng ProductID thì sắp xếp theo Quantity giảm dần.
SELECT [Order Details].ProductID, ProductName, [Order Details].OrderID ,OrderDate, CustomerID, [Order Details].UnitPrice, 
Quantity, Total = Quantity * [Order Details].UnitPrice
 FROM dbo.Products JOIN dbo.[Order Details] 
ON [Order Details].ProductID = Products.ProductID
JOIN dbo.Orders 
ON Orders.OrderID = [Order Details].OrderID
WHERE [Order Details].OrderID IN (SELECT OrderDate FROM dbo.Orders 
WHERE (DATENAME(DW, '199612') like N'Sunday' OR DATENAME(DW, '199612') like N'199612' ) AND MONTH(OrderDate) = 12 AND YEAR(OrderDate)=1996)
ORDER BY Products.ProductID, Quantity DESC

--7)Liệt kê bảng doanh thu của mỗi nhân viên theo từng hóa đơn 
--trong năm 1996 gồm EmployeeID, EmployName, OrderID, Orderdate, 
--Productid, quantity, unitprice, ToTal=quantity*unitprice. 
SELECT Employees.EmployeeID, [Order Details].OrderID, OrderDate, ProductID, Quantity,UnitPrice,Total = Quantity * UnitPrice
 FROM dbo.Employees JOIN dbo.Orders 
ON Orders.EmployeeID = Employees.EmployeeID
JOIN dbo.[Order Details]
ON [Order Details].OrderID = Orders.OrderID
WHERE YEAR(OrderDate) = 1996

--8)Danh sách các đơn hàng sẽ được giao trong các thứ 7 của tháng 12 năm 1996. 
SELECT *FROM dbo.Orders 
WHERE DATENAME(DW, OrderDate) LIKE 'Saturday' AND MONTH(OrderDate) = 12 AND YEAR(OrderDate) = 1996
	
--9)Liệt kê danh sách các nhân viên chưa lập hóa đơn (dùng LEFT JOIN/RIGHT JOIN).
SELECT Employees.EmployeeID, EmployeeName = FirstName + ' '+LastName, COUNT(OrderID)
FROM dbo.Employees LEFT JOIN dbo.Orders
ON Orders.EmployeeID = Employees.EmployeeID
GROUP BY Employees.EmployeeID, FirstName + ' '+LastName
HAVING count(OrderID) = 0

--10)Liệt kê danh sách các sản phẩm chưa bán được (dùng LEFT JOIN/RIGHT JOIN).
SELECT [Order Details].ProductID, ProductName,COUNT(OrderID) 
FROM dbo.Products LEFT JOIN dbo.[Order Details] 
ON [Order Details].ProductID = Products.ProductID
WHERE OrderID IS NULL
GROUP BY [Order Details].ProductID,ProductName
HAVING COUNT(OrderID) = 0

--11)Liệt kê danh sách các khách hàng chưa mua hàng lần nào (dùng LEFT JOIN/RIGHT JOIN)
SELECT C.CustomerID, C.ContactName, C.CompanyName, COUNT(OrderID) 
FROM dbo.Customers AS C 
LEFT JOIN dbo.Orders 
ON Orders.CustomerID = C.CustomerID
GROUP BY C.CustomerID, C.ContactName, C.CompanyName
HAVING COUNT(OrderID) = 0

--12)Danh sách các Customer ứng với tổng tiền của các hóa đơn 
--ở từng tháng. Thông tin bao gồm CustomerID, CompanyName, 
--Month_Year, Total. Trong đó Month_year là tháng và năm lập hóa đơn, 
--Total là tổng của Unitprice* Quantity.
SELECT Customers.CustomerID, CompanyName, Total = UnitPrice * Quantity FROM dbo.Customers JOIN dbo.Orders 
ON Orders.CustomerID = Customers.CustomerID
JOIN dbo.[Order Details]
ON [Order Details].OrderID = Orders.OrderID

--13)Cho biết Employees nào bán được nhiều tiền nhất trong 7 của năm 1997
SELECT TOP 1 E.*FROM dbo.Employees E JOIN dbo.Orders
ON Orders.EmployeeID = E.EmployeeID
JOIN dbo.[Order Details]
ON [Order Details].OrderID = Orders.OrderID
WHERE UnitPrice >= ALL (
SELECT UnitPrice FROM dbo.Orders WHERE MONTH(OrderDate) = 7 AND YEAR(OrderID) = 1997 )

--14)Danh sách 3 khách có nhiều đơn hàng nhất của năm 1996.
SELECT TOP 3 C.*FROM dbo.Customers C JOIN dbo.Orders 
ON Orders.CustomerID = C.CustomerID 
WHERE OrderID >= ALL (SELECT COUNT(OrderID) FROM dbo.Orders )

--15)Tính tổng số hóa đơn và tổng tiền của mỗi nhân viên đã bán 
--trong tháng 3/1997, có tổng tiền >4000, 
--thông tin gồm [EmployeeID],[LastName], [FirstName], countofOrderid, sumoftotal.

--SELECT Orders.EmployeeID,Name = LastName +' ' +FirstName, countoforderID = COUNT(Orders.OrderID), sumoftotal = SUM(COUNT(UnitPrice*Quantity))
 --FROM dbo.Orders JOIN dbo.[Order Details]
--ON [Order Details].OrderID = Orders.OrderID
--JOIN dbo.Employees
--ON Employees.EmployeeID = Orders.EmployeeID
--WHERE MONTH(OrderDate) = 3 AND YEAR(OrderDate) = 1997
--GROUP BY Orders.EmployeeID, LastName +' ' +FirstName
--HAVING SUM(COUNT(UnitPrice*Quantity)) > 4000



--16)Liệt kê danh sách các sản phẩm bán trong quý 1 năm 1998 
--có tổng số lương >200, thông tin gồm [ProductID], [ProductName], 
--SumofQuatity 
SELECT [Order Details].ProductID, ProductName FROM dbo.Products JOIN dbo.[Order Details] 
ON [Order Details].ProductID = Products.ProductID
JOIN dbo.Orders
ON Orders.OrderID = [Order Details].OrderID
WHERE MONTH(OrderDate) IN (1,2,3) AND YEAR(OrderDate) = 1998
GROUP BY [Order Details].ProductID, ProductName
HAVING sum(Quantity * [Order Details].UnitPrice) > 200

--17)Liệt kê các sản phẩm có trên 20 đơn hàng trong quí 3 năm 1998, 
--thông tin gồm [ProductID], [ProductName]
SELECT [Order Details].ProductID, ProductName FROM dbo.Products JOIN dbo.[Order Details]
ON [Order Details].ProductID = Products.ProductID
JOIN dbo.Orders
ON Orders.OrderID = [Order Details].OrderID
WHERE  MONTH(OrderDate) IN (7,8,9) AND YEAR(OrderDate) = 1998 
GROUP BY [Order Details].ProductID,ProductName
HAVING COUNT([Order Details].OrderID) > 20

--18)Liệt kê danh sách các sản phẩm Producrs chưa bán được trong tháng 6 năm 1996
SELECT *FROM dbo.Products
WHERE ProductID NOT IN  (SELECT  [Order Details].ProductID FROM dbo.Products JOIN dbo.[Order Details]
ON [Order Details].ProductID = Products.ProductID
JOIN dbo.Orders
ON Orders.OrderID = [Order Details].OrderID
WHERE MONTH(OrderDate) = 6 AND YEAR(OrderDate) = 1996)

--19)Liệt kê danh sách các Employes không lập hóa đơn vào ngày hôm nay
SELECT *FROM dbo.Employees JOIN dbo.Orders 
ON Orders.EmployeeID = Employees.EmployeeID
WHERE DAY(OrderDate) <> DAY(GETDATE())

--20)Liệt kê danh sách các Customers chưa mua hàng trong năm 1997
SELECT *FROM dbo.Customers JOIN dbo.Orders
ON Orders.CustomerID = Customers.CustomerID
WHERE YEAR(OrderDate) <> 1997

--21)Tìm tất cả các Customers mua các sản phẩm có tên bắt đầu bằng chữ T trong tháng 7.
SELECT *FROM dbo.Customers JOIN dbo.Orders
ON Orders.CustomerID = Customers.CustomerID
JOIN dbo.[Order Details]
ON [Order Details].OrderID = Orders.OrderID
JOIN dbo.Products
ON Products.ProductID = [Order Details].ProductID
WHERE ProductName LIKE 'T%' AND MONTH(OrderDate) = 7

--22)Danh sách các City có nhiều hơn 3 customer.
SELECT City FROM dbo.Customers JOIN dbo.Orders
ON Orders.CustomerID = Customers.CustomerID
GROUP BY City
having COUNT(City) > 3

--23)Dùng lệnh SELECT…INTO tạo bảng HDKH_71997 cho biết tổng tiền 
--khách hàng đã mua trong tháng 7 năm 1997 gổm CustomerID, 
--CompanyName, Address, ToTal =sum(quantity*Unitprice)
SELECT Customers.CustomerID, Address, Total = SUM(Quantity * UnitPrice) INTO HDKH_71997
FROM dbo.Customers JOIN dbo.Orders
ON Orders.CustomerID = Customers.CustomerID
JOIN dbo.[Order Details]
ON [Order Details].OrderID = Orders.OrderID
WHERE MONTH(OrderDate) = 7 AND YEAR(OrderDate)=1997
GROUP BY Customers.CustomerID, Address

--24)Dùng lệnh SELECT…INTO tạo bảng LuongNV cho biết tổng lương của 
--nhân viên trong tháng 12 năm 1996 gổm EmployeeID, Name là LastName
-- + FirstName, Address, ToTal =sum(quantity*Unitprice)
SELECT Employees.EmployeeID, Name = FirstName+' '+LastName, Address,Total=SUM(Quantity*UnitPrice) 
INTO LuongNV
FROM dbo.Employees JOIN dbo.Orders
ON Orders.EmployeeID = Employees.EmployeeID
JOIN dbo.[Order Details]
ON [Order Details].OrderID = Orders.OrderID
WHERE MONTH(OrderDate) = 12 AND YEAR(OrderDate) = 1996
GROUP BY Employees.EmployeeID, FirstName+' '+LastName,Address

--25)Liệt kê các khách hàng có đơn hàng chuyển đến các quốc gia 
--([ShipCountry]) là 'Germany' và 'USA' trong quý 1 năm 1998, 
--do công ty vận chuyển (CompanyName) Speedy Express thực hiện, 
--thông tin gồm [CustomerID], [CompanyName] (tên khách hàng), tổng tiền.
SELECT Customers.CustomerID,SUM(Quantity * UnitPrice) FROM dbo.Customers JOIN dbo.Orders 
ON Orders.CustomerID = Customers.CustomerID
JOIN dbo.[Order Details]
ON [Order Details].OrderID = Orders.OrderID
WHERE CompanyName like 'Speedy Express' AND ShipCountry IN ('Germany','USA') 
AND MONTH(OrderDate) IN (1,2,3) AND YEAR(OrderDate) = 1998
GROUP BY Customers.CustomerID



 














