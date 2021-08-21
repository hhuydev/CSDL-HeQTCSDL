USE Northwind 
GO

--1: With ties: sẽ lấy những giá trùng với giá trị nằm trong top3
SELECT TOP 3 WITH TIES OrderID, Freight
FROM dbo.Orders
ORDER BY Freight DESC
--2
SELECT * FROM dbo.Products
WHERE ProductID LIKE 'B%1'
--3: 1d
SELECT * FROM dbo.Products
WHERE UnitPrice BETWEEN 2000 AND 3000
--4: 1d
SELECT * FROM dbo.Orders JOIN dbo.Customers 
ON Customers.CustomerID = Orders.CustomerID
WHERE Customers.CustomerID IS NULL
--5: 1d
SELECT * FROM dbo.Orders JOIN dbo.Customers 
ON Customers.CustomerID = Orders.CustomerID
WHERE Customers.CustomerID NOT IN ('BB01', 'BC02')
--6: 1d
SELECT * from dbo.Products
ORDER BY nuocsx DESC, UnitPrice ASC
--7: 1d
SELECT MAX(diemthi) FROM ketquathi
--8: 1d
SELECT MAX(diemthi), MIN(diemthi), AVG(diemthi) FROM ketquathi
--9: 
SELECT COUNT(masv) FROM sinhvien 
WHERE diemthi>5 AND mon='csdl'
--10: 
SELECT mahv, MAX(diemthi) FROM sinhvien
GROUP BY mahv
--11: 1d
SELECT COUNT(stipendio) FROM stipendio
WHERE sele = 'S01'
--12: 
SELECT mahv,MAX(diemthi) FROM sinhvien
GROUP BY mahv
HAVING MAX(diemthi) > 8.5
--13: 1d
SELECT mahv, tenhv, mamh FROM hovien JOIN monhoc
ON hocvien.mahv = monhoc.mahv
where mahv='001'
--14: 
SELECT mahv,tenhv FROM hocvien
WHERE (SELECT MAX(diem) FROM diemthi JOIN hocvien wwhere hocvien.mahv = diemthi.mahv)
GROUP BY mahv
--15:
SELECT mahv,tenhv FROM hocvien
WHERE mahv = ANY (SELECT diemthi FROM diemthi 
	where diemthi=8.5)
GROUP BY mahv
--16: 1d
SELECT * FROM khachhang
WHERE makh exist (SELECT makh, mahd FROM makh JOIN mahd ON khachang.makh = hoadon.makh)