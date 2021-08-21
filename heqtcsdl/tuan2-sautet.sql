--T-SQL
--Khai bao bien: DECLARE @TENBIEN, set gia tri set @tenbien = value or select @tenbien = value
--Khi muon lay gia tri tu mot bang chi dung dc select khong dung dc lenh set
--VD: select @ma = ID from employee where employeeID = 'a'
DECLARE @name NVARCHAR(10), @custID CHAR(5)
SET @name = 'huy' SET @custID = '001'
DECLARE @tempTable TABLE (ma INT, ten NVARCHAR(40))
SELECT *FROM @tempTable


SELECT @name  = customername FROM Customer WHERE customerid = 'a1'

-------------------------------------------
USE Northwind
--1: 1d
DECLARE @id INT = 10311
SELECT @id =OrderID FROM dbo.Orders WHERE OrderID > @id
SELECT @id

--2: 1d
DECLARE @Maxid INT, @MinID INT
SELECT @Maxid =  OrderID FROM dbo.Orders WHERE OrderID >= ALL(SELECT OrderID FROM dbo.Orders )
SELECT @Maxid --print 'Max: ' +convert(varchar(10),@Maxid)
SELECT @MinID =  OrderID FROM dbo.Orders WHERE OrderID = (SELECT MIN(OrderID) FROM dbo.Orders )
SELECT @MinID

--3: 1d
--Write a script that declares three variables, one integer 
--variable called @ID, an NVARCHAR(50) variable called @FirstName, 
--and an NVARCHAR(50) variable called @LastName. Use a SELECT
--statement to set the value of the variables with the row from 
--the Employees table with Emplyeeid = 1. Print a statement in the
--“EmployeeID: FirstName LastName” format.

DECLARE @maID INT, @FirstName NVARCHAR(50), @LastName NVARCHAR(50)
SELECT @maID = EmployeeID,@FirstName = FirstName,@LastName = LastName  FROM dbo.Employees WHERE EmployeeID = 1
PRINT CONVERT(NVARCHAR(10),@maID) + ':' +@FirstName +' '+@LastName

--4: 0d
--*Khai bao bien toan cuc @@ten bien (chi khai bao khong set gia tri)
DECLARE @year INT = YEAR(GETDATE())
IF @year %2 = 0 	
	PRINT 'nam chan';
ELSE
	PRINT 'nam le';	
