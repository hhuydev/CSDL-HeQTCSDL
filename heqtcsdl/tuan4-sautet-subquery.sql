use AdventureWorks2008R2
go

--1)Liệt kê các sản phẩm gồm các thông tin Product Names và Product ID có trên 100 đơn đặt hàng trong tháng 7 năm 2008
select ProductID, Name from Production.Product 
where ProductID in (select ProductID from Sales.SalesOrderDetail OD join Sales.SalesOrderHeader H
on OD.SalesOrderID = H.SalesOrderID
where MONTH(H.OrderDate) = 7 and YEAR(H.OrderDate)=2008
group by ProductID
having (count(ProductID) > 100))

--2)Liệt kê các sản phẩm (ProductID, Name) có số hóa đơn đặt hàng nhiều nhất trong tháng 7/2008
select ProductID, Name from Production.Product
where ProductID IN (select top 1 with ties ProductID
FROM Sales.SalesOrderDetail od join sales.SalesOrderHeader h 
on od.SalesOrderID = h.SalesOrderID
where MONTH(H.OrderDate) = 7 and YEAR(H.OrderDate)=2008
group by ProductID
having COUNT(ProductID) > 100
order by count(ProductID) DESC)

--3) Hiển thị thông tin của khách hàng có số đơn đặt hàng nhiều nhất, thông tin gồm: CustomerID, Name, CountOfOrder
SELECT  CustomerID, fullname=FirstName+' '+LastName FROM Sales.Customer JOIN Person.Person
ON Person.BusinessEntityID = Customer.PersonID
WHERE CustomerID IN (SELECT TOP 1 WITH TIES CustomerID FROM Sales.SalesOrderHeader
GROUP BY CustomerID
ORDER BY COUNT(CustomerID) DESC)


--4)Liệt kê các sản phẩm (ProductID, Name) thuộc mô hình sản phẩm áo dài tay với tên bắt đầu với 
--“Long-Sleeve Logo Jersey”, dùng phép IN và EXISTS, (sử dụng bảng Production.Product và Production.ProductModel)
select ProductID, name from Production.Product
where ProductID IN (select ProductID from Production.ProductModel where name='Long-Sleeve Logo Jersey') 

select ProductID, name from Production.Product
where exists (select ProductID from Production.ProductModel where name='Long-Sleeve Logo Jersey') 

--5) Tìm các mô hình sản phẩm (ProductModelID) mà giá niêm yết (list price) tối đa cao hơn giá trung bình của tất cả các 
--mô hình.
select ProductModelID , giamax = MAX(ListPrice) FROM  Production.Product
GROUP BY ProductModelID
HAVING MAX(ListPrice) > (select AVG(ListPrice) FROM Production.Product)

--6) Liệt kê các sản phẩm gồm các thông tin ProductID, Name, có tổng số lượng đặt hàng > 5000 (dùng IN, EXISTS)
SELECT ProductID, Name FROM Production.Product 
WHERE ProductID IN (SELECT ProductID FROM Sales.SalesOrderDetail JOIN Sales.SalesOrderHeader
ON SalesOrderHeader.SalesOrderID = SalesOrderDetail.SalesOrderID
GROUP BY ProductID
HAVING (COUNT(ProductID) > 5000))

SELECT ProductID, Name FROM Production.Product 
WHERE EXISTS (SELECT ProductID FROM Sales.SalesOrderDetail JOIN Sales.SalesOrderHeader
ON SalesOrderHeader.SalesOrderID = SalesOrderDetail.SalesOrderID
GROUP BY ProductID
HAVING (COUNT(ProductID) > 5000))

--7) Liệt kê những sản phẩm (ProductID, UnitPrice) có đơn giá (UnitPrice) cao nhất trong bảng Sales.SalesOrderDetail
SELECT ProductID, UnitPrice FROM Sales.SalesOrderDetail
GROUP BY ProductID, UnitPrice
having MAX(UnitPrice) >= all (SELECT UnitPrice FROM Sales.SalesOrderDetail)

--8) Liệt kê các sản phẩm không có đơn đặt hàng nào thông tin gồm ProductID, Nam; dùng 3 cách Not in, Not exists và Left join.
SELECT ProductID,Name FROM Production.Product
WHERE ProductID NOT IN (SELECT ProductID FROM Sales.SalesOrderDetail)

SELECT p.ProductID, p.Name FROM Production.Product p
WHERE NOT EXISTS (SELECT ProductID FROM Sales.SalesOrderDetail od 
WHERE od.ProductID = p.ProductID)

SELECT Product.ProductID,Name FROM Production.Product LEFT JOIN Sales.SalesOrderDetail
ON SalesOrderDetail.ProductID = Product.ProductID
WHERE SalesOrderDetail.ProductID IS NULL

--9) Liệt kê các nhân viên không lập hóa đơn từ sau ngày 1/5/2008, thông tin gồm EmployeeID, FirstName, LastName 
--(dữ liệu từ 2 bảng HumanResources.Employees và Sales.SalesOrdersHeader)
SELECT Employee.BusinessEntityID, FirstName, LastName  FROM HumanResources.Employee JOIN Person.Person
ON Person.BusinessEntityID = Employee.BusinessEntityID
WHERE Employee.BusinessEntityID NOT IN ( SELECT BusinessEntityID FROM Sales.SalesOrderHeader h JOIN Sales.SalesPerson
ON SalesPerson.BusinessEntityID = h.SalesPersonID
	WHERE DAY(OrderDate) = 1 AND MONTH(OrderDate) = 5 AND YEAR(OrderDate) = 2008
	GROUP BY BusinessEntityID
 )

--10)Liệt kê danh sách các khách hàng (CustomerID, Name) có hóa đơn dặt hàng trong năm 2007 nhưng không có hóa đơn đặt hàng trong năm 2008.
SELECT CustomerID, fullname=FirstName +' '+LastName  FROM Sales.Customer JOIN Person.Person
ON Person.BusinessEntityID = Customer.PersonID
WHERE CustomerID IN (SELECT CustomerID FROM Sales.SalesOrderHeader
WHERE YEAR(OrderDate) = 2007 AND YEAR(OrderDate) <> 2008
	
)