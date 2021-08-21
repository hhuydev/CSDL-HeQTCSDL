USE AdventureWorks2008R2
go

--1) Tạo view dbo.vw_Products hiển thị danh sách các sản phẩm từ bảng Production.Product và bảng Production.ProductCostHistory. Thông tin bao gồm
--ProductID, Name, Color, Size, Style, StandardCost, EndDate, StartDate
CREATE VIEW dbo.vw_Products AS
SELECT Product.ProductID, Name, Color, Size, Style, Product.StandardCost, EndDate, StartDate 
FROM Production.Product JOIN Production.ProductCostHistory
ON ProductCostHistory.ProductID = Product.ProductID

--2) Tạo view List_Product_View chứa danh sách các sản phẩm có trên 500 đơn đặt hàng trong quí 1 năm 2008 và có tổng trị giá >10000, 
--thông tin gồm ProductID, Product_Name, CountOfOrderID và SubTotal.
CREATE VIEW List_Product_View AS
SELECT p.[ProductID] FROM [Production].[Product] p JOIN Sales.SalesOrderDetail od
ON  od.ProductID =p.ProductID
JOIN Sales.SalesOrderHeader h
ON h.SalesOrderID = od.SalesOrderID
WHERE MONTH(h.OrderDate) IN (1,2,3) AND YEAR(h.OrderDate)=2008
GROUP BY p.ProductID
HAVING SUM(od.UnitPrice) > 10000

--3) Tạo view dbo.vw_CustomerTotals hiển thị tổng tiền bán được (total sales) từ cột TotalDue của mỗi khách hàng (customer) 
--theo tháng và theo năm. Thông tin gồm CustomerID, YEAR(OrderDate) AS OrderYear, MONTH(OrderDate) AS OrderMonth, SUM(TotalDue)
CREATE VIEW dbo.vw_CustomerTotals AS
SELECT Customer.CustomerID, OrderYear=YEAR(OrderDate),OrderMonth=MONTH(OrderDate), sum=COUNT(TotalDue) FROM Sales.Customer JOIN Sales.SalesOrderHeader
ON SalesOrderHeader.CustomerID = Customer.CustomerID
JOIN Sales.SalesOrderDetail
ON SalesOrderDetail.SalesOrderID = SalesOrderHeader.SalesOrderID
GROUP BY Customer.CustomerID, YEAR(OrderDate), MONTH(OrderDate)

--4) Tạo view trả về tổng số lượng sản phẩm (Total Quantity) bán được của mỗi nhân viên theo từng năm. Thông tin gồm 
--SalesPersonID, OrderYear, sumOfOrderQty
CREATE VIEW dbo.vw_TotalQuantity AS
SELECT SalesPersonID,OrderYear=YEAR(OrderDate),sumOfOrderQty=SUM(OrderQty)  FROM Sales.SalesPerson JOIN Sales.SalesOrderHeader
ON SalesOrderHeader.SalesPersonID = SalesPerson.BusinessEntityID
JOIN Sales.SalesOrderDetail
ON SalesOrderDetail.SalesOrderID = SalesOrderHeader.SalesOrderID
GROUP BY SalesPersonID, YEAR(OrderDate)

--5) Tạo view ListCustomer_view chứa danh sách các khách hàng có trên 25 hóa đơn đặt hàng từ năm 2007 đến 2008, thông tin gồm mã khách (PersonID) 
--, họ tên (FirstName +' '+ LastName as FullName), Số hóa đơn (CountOfOrders).
CREATE VIEW dbo.vw_ListCustomer_view AS
SELECT SalesPersonID, FullName=FirstName+' '+LastName,CountOfOrders=COUNT(SalesPersonID)  FROM Sales.Customer JOIN Sales.SalesOrderHeader
ON SalesOrderHeader.CustomerID = Customer.CustomerID
JOIN Person.Person
ON Person.BusinessEntityID = Customer.PersonID
GROUP BY SalesPersonID, FirstName+' '+LastName
HAVING COUNT(SalesPersonID) > 25


--6) Tạo view ListProduct_view chứa danh sách những sản phẩm có tên bắt đầu với ‘Bike’ và ‘Sport’ có tổng số lượng bán trong mỗi năm 
--trên 50 sản phẩm, thông tin gồm ProductID, Name, SumOfOrderQty, Year. (dữ liệu lấy từ các bảng Sales.SalesOrderHeader, 
--Sales.SalesOrderDetail, và Production.Product)
CREATE VIEW ListProduct_view AS
SELECT p.[ProductID], p.[Name], SumOfOrderQty = SUM([OrderQty]), YEAR = YEAR([OrderDate]) FROM Sales.SalesOrderHeader h JOIN Sales.SalesOrderDetail od
ON h.[SalesOrderID] = od.[SalesOrderID]
JOIN Production.Product p 
ON p.[ProductID] = od.[ProductID]
WHERE NAME IN ('Bike%', 'Sport%')
GROUP BY  p.[ProductID], p.[Name],YEAR([OrderDate])
HAVING SUM([OrderQty]) > 50

--7) Tạo view List_department_View chứa danh sách các phòng ban có lương (Rate: lương theo giờ) trung bình >30, 
--thông tin gồm Mã phòng ban (DepartmentID), tên phòng ban (Name), Lương trung bình (AvgOfRate). Dữ liệu từ các bảng
--[HumanResources].[Department], [HumanResources].[EmployeeDepartmentHistory], [HumanResources].[EmployeePayHistory].
CREATE VIEW List_department_View AS
SELECT e1.DepartmentID, d.Name,AvgOfRate = AVG(e2.Rate) 
FROM HumanResources.EmployeeDepartmentHistory e1 JOIN HumanResources.EmployeePayHistory e2
ON e2.BusinessEntityID = e1.BusinessEntityID
JOIN HumanResources.Department d
ON d.DepartmentID = e1.DepartmentID
GROUP BY  e1.DepartmentID, d.Name
HAVING AVG(e2.Rate) > 30

--8) Tạo view Sales.vw_OrderSummary với từ khóa WITH ENCRYPTION gồm OrderYear (năm của ngày lập), 
--OrderMonth (tháng của ngày lập), OrderTotal (tổng tiền). Sau đó xem thông tin và trợ giúp về mã lệnh của view này
CREATE VIEW Sales.vw_OrderSummary  WITH ENCRYPTION AS
SELECT OrderYear = YEAR(OrderDate),OrderMonth = MONTH(OrderDate), OrderTotal = SUM(OrderQty * UnitPrice)
FROM Sales.SalesOrderHeader JOIN Sales.SalesOrderDetail
ON SalesOrderDetail.SalesOrderID = SalesOrderHeader.SalesOrderID
GROUP BY  YEAR(OrderDate), MONTH(OrderDate)

