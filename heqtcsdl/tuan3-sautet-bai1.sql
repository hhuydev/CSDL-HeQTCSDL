--1
EXEC sp_addtype 'Mota', 'nvarchar(50)', 'null'
Exec sp_addtype 'IDKH', 'char(10)', 'not null'
Exec sp_addtype 'Dt', 'char(50)', 'null'

--2
CREATE TABLE KhachHanag (
	MaKH IDKH PRIMARY KEY,
	TenKH NVARCHAR(30) NOT NULL,
	DiaChi NVARCHAR(40) NOT NULL,
	Dienthoai DT
)

CREATE TABLE HoaDon(
	MaHD CHAR(10) PRIMARY KEY,
	NgayLap DATE,
	NgayGiao DATE,
	MaKH IDKH FOREIGN KEY REFERENCES dbo.KhachHanag(MaKH),
	DienGiai Mota
)

CREATE TABLE SanPham (
	Masp CHAR(6) PRIMARY KEY,
	TenSp VARCHAR(20) NOT NULL,
	NgayNhap DATE,
	DVT CHAR(10),
	SoLuongTon INT,
	DonGiaNhap MONEY
)

CREATE TABLE ChiTietHD (
	MaHD CHAR(10) FOREIGN KEY REFERENCES dbo.HoaDon(MaHD),
	Masp CHAR(6) FOREIGN KEY REFERENCES dbo.SanPham(Masp),
	SoLuong int
)

ALTER TABLE dbo.HoaDon ALTER COLUMN DienGiai NVARCHAR(100)

ALTER TABLE dbo.SanPham ADD TyLeHoaHong FLOAT

ALTER TABLE dbo.SanPham DROP COLUMN NgayNhap

ALTER TABLE dbo.HoaDon ADD CHECK (NgayGiao > NgayLap)
ALTER TABLE dbo.HoaDon ADD CONSTRAINT df_ngaylap  DEFAULT GETDATE() FOR NgayLap

ALTER TABLE dbo.SanPham ADD CHECK (SoLuongTon BETWEEN 0 AND 500)
ALTER TABLE dbo.SanPham ADD CHECK (DonGiaNhap > 0)
ALTER TABLE dbo.SanPham ADD CONSTRAINT df_ngaynhap  DEFAULT GETDATE() FOR NgayNhap
ALTER TABLE dbo.SanPham ADD CONSTRAINT loai_DVT CHECK (DVT IN ('KG', 'Thùng', 'Hộp', 'Cái'))

INSERT INTO dbo.KhachHanag
(
	MaKH,
    TenKH,
    DiaChi,
	Dienthoai
)
VALUES
(   
	'a1',
	N'Nguyen A', -- TenKH - nvarchar(30)
    N'123 Truong Dinh HCM',  -- DiaChi - nvarchar(40)
	'11234567890'
   )

   INSERT INTO dbo.HoaDon
   (
       MaHD,
       NgayLap,
       NgayGiao,
	   DienGiai,
	   MaKH
	   
   )
   VALUES
   (   'aaa',        -- MaHD - char(10)
       GETDATE(), -- NgayLap - date
       GETDATE(),  -- NgayGiao - date
	   'xyzada',
	   'a1'
 )

 INSERT INTO dbo.SanPham
 (
     Masp,
     TenSp,
     NgayNhap,
     DVT,
     SoLuongTon,
     DonGiaNhap
 )
 VALUES
 (   'b1',        -- Masp - char(6)
     'Banh A',        -- TenSp - varchar(20)
     GETDATE(), -- NgayNhap - date
     'xzzz',        -- DVT - char(10)
     3,         -- SoLuongTon - int
     3000       -- DonGiaNhap - money
     )

INSERT INTO dbo.ChiTietHD
(
    MaHD,
    Masp,
    SoLuong
)
VALUES
(   'aaa', -- MaHD - char(10)
    'b1', -- Masp - char(6)
    2   -- SoLuong - int
    )

Không xóa được bảng HoaDon do bảng đang chứa khóa ngoại đến bảng KhachHang. Muốn xóa thì xóa bảng ChiTietHoaDon trước r mới xóa bảng HoaDon
Không thêm vào bảng ChiTietHD với MaHD = ‘HD999999999’ và MaHD=’1234567890’ được vì đang tham chiếu đến 2 bảng KhachHang và SanPham. 
