USE AdventureWorks2008R2
GO
--1) Tạo hai bảng mới trong cơ sở dữ liệu AdventureWorks2008 theo cấu trúc sau:
create table
MyDepartment (
DepID smallint not null primary
key, DepName nvarchar(50),
GrpName NVARCHAR(50))

create table MyEmployee (
EmpID int not null PRIMARY KEY, 
FrstName nvarchar(50),
MidName nvarchar(50),
LstName
nvarchar(50),
DepID smallint not null foreign KEY REFERENCES MyDepartment(DepID))

DROP TABLE dbo.MyEmployee

--2) Dùng lệnh insert <TableName1> select <fieldList> FROM <TableName2> chèn dữ liệu cho bảng MyDepartment, lấy dữ liệu từ bảng [HumanResources].[Department].
INSERT INTO   dbo.MyDepartment(DepID, DepName, GrpName)  SELECT DepartmentID, Name, GroupName FROM  HumanResources.Department

--3) Tương tự câu 2, chèn 20 dòng dữ liệu cho bảng MyEmployee lấy dữ liệu từ 2 bảng [Person].[Person] và [HumanResources].[EmployeeDepartmentHistory]
INSERT INTO dbo.MyEmployee (EmpID, FrstName, MidName,LstName, DepID)
SELECT EmployeeDepartmentHistory.BusinessEntityID, FirstName, MiddleName, LastName, DepartmentID FROM Person.Person JOIN HumanResources.EmployeeDepartmentHistory
ON EmployeeDepartmentHistory.BusinessEntityID = Person.BusinessEntityID

--4) Dùng lệnh delete xóa 1 record trong bảng MyDepartment với DepID=1, có thực hiện được không? Vì sao?
DELETE FROM dbo.MyDepartment WHERE DepID=1

--5) Thêm một default constraint vào field DepID trong bảng MyEmployee, với giá trị mặc định là 1
ALTER TABLE dbo.MyEmployee ADD CONSTRAINT fk_defid DEFAULT 1 FOR DepID

--6) Nhập thêm một record mới trong bảng MyEmployee, theo cú pháp sau: INSERT into MyEmployee (EmpID, FrstName, MidName, LstName) 
--VALUES(1, 'Nguyen','Nhat','Nam'). Quan sát giá trị trong field depID của record mới thêm.
 INSERT INTO dbo.MyEmployee
 (
     EmpID,
     FrstName,
     MidName,
     LstName
 )
 VALUES
 (   1,   -- EmpID - int
     N'Nguyen', -- FrstName - nvarchar(50)
     N'Nhat', -- MidName - nvarchar(50)
     N'Nam' -- LstName - nvarchar(50)
       -- DepID - smallint
    )

--7) Xóa foreign key constraint trong bảng MyEmployee, thiết lập lại khóa ngoại DepID tham chiếu đến DepID của bảng MyDepartment với thuộc tính
-- ON DELETE set default
ALTER TABLE dbo.MyEmployee DROP CONSTRAINT fk_defid

ALTER TABLE dbo.MyEmployee ADD FOREIGN KEY (DepID) REFERENCES dbo.MyDepartment(DepID)
ALTER TABLE dbo.MyEmployee ADD CONSTRAINT  fk_defid FOREIGN KEY (DepID) REFERENCES dbo.MyDepartment(DepID)

--8) Xóa một record trong bảng MyDepartment có DepID=7, quan sát kết quả trong hai bảng MyEmployee và MyDepartment
DELETE FROM dbo.MyDepartment WHERE DepID=7

--9) Xóa foreign key trong bảng MyEmployee. Hiệu chỉnh ràng buộc khóa ngoại DepID trong bảng MyEmployee, thiết lập thuộc tính
-- on DELETE cascade và on update cascade
ALTER TABLE dbo.MyEmployee DROP CONSTRAINT fk_defid
ALTER TABLE dbo.MyEmployee ADD CONSTRAINT fk_defid FOREIGN KEY(DepID) REFERENCES dbo.MyDepartment(DepID) ON DELETE CASCADE ON UPDATE CASCADE

--10)Thực hiện xóa một record trong bảng MyDepartment với DepID =3, có thực hiện được không?
DELETE FROM dbo.MyDepartment WHERE DepID = 3

--11)Thêm ràng buộc check vào bảng MyDepartment tại field GrpName, chỉ cho phép nhận thêm những Department thuộc group Manufacturing
ALTER TABLE dbo.MyDepartment ADD CHECK (GrpName IN Manufacturing)

--12)Thêm ràng buộc check vào bảng [HumanResources].[Employee], tại cột BirthDate, chỉ cho phép nhập 
--thêm nhân viên mới có tuổi từ 18 đến 60
ALTER TABLE HumanResources.Employee ADD CHECK(BirthDate BETWEEN 18 AND 60)