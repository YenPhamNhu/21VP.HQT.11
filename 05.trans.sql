-- //0.Người dùng khách (người dùng chưa đăng nhập) 

-- 0.1/Có quyền đăng kí tài khoản (gọi giao tác TaoTaiKhoanBenhNhan) 
-- bằng cách cung cấp họ tên, ngày sinh, giới tính, số điện thoại
-- , địa chỉ, mật khẩu (mạnh). 
IF EXISTS (SELECT *
FROM sys.procedures
WHERE name = N'TaoTaiKhoanBenhNhan' AND type = 'P')
BEGIN
    DROP PROCEDURE TaoTaiKhoanBenhNhan;
    PRINT N'Đã hủy giao tác TaoTaiKhoanBenhNhan.';
END
ELSE
BEGIN
    PRINT N'Giao tác TaoTaiKhoanBenhNhan chưa được tạo.';
END
GO

CREATE PROCEDURE TaoTaiKhoanBenhNhan
    @HoTen NVARCHAR(50),
    @SDT VARCHAR(10),
    @GioiTinh NVARCHAR(5),
    @NgaySinh DATETIME,
    @DiaChi NVARCHAR(50),
    @MatKhau VARCHAR(8)
AS
BEGIN
    BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1
    FROM BENHNHAN
    WHERE SDT = @SDT)
    BEGIN
        INSERT INTO BENHNHAN
            (HoTen, SDT, GioiTinh, NgaySinh, DiaChi, MatKhau)
        VALUES
            (@HoTen, @SDT, @GioiTinh, @NgaySinh, @DiaChi, @MatKhau);
        PRINT N'Tạo tài khoản thành công';
        COMMIT TRANSACTION;
    END
    ELSE
    BEGIN
        -- SDT đã tồn tại, In ra màn hình
        ROLLBACK TRANSACTION;
        PRINT N'Số điện thoại đã tồn tại. Tạo tài khoản không thành công';
    END
END
GO

--//-------------------
-- 0.2/Có quyền đăng nhập vào tài khoản (gọi giao tác DangNhap)
IF EXISTS (SELECT *
FROM sys.procedures
WHERE name = N'DangNhap' AND type = 'P')
BEGIN
    DROP PROCEDURE DangNhap;
    PRINT N'Đã hủy giao tác DangNhap.';
END
ELSE
BEGIN
    PRINT N'Giao tác DangNhap chưa được tạo.';
END
GO

CREATE PROCEDURE DangNhap
    @UserName NVARCHAR(50),
    @Password NVARCHAR(50)
AS
BEGIN
    BEGIN TRANSACTION;

    -- Kiểm tra User là Quan Tri Vien (QTV)
    IF EXISTS (SELECT 1
    FROM QTV
    WHERE SDT = @UserName AND MatKhau = @Password)
    BEGIN
        -- Quan Tri Vien (QTV) login successful
        SELECT 'QTV' AS UserRole;
    END
    -- Kiểm tra User là Nhan Vien (NHANVIEN)
    ELSE IF EXISTS (SELECT 1
    FROM NHANVIEN
    WHERE SDT = @UserName AND MatKhau = @Password)
    BEGIN
        -- Nhan Vien (NHANVIEN) login successful
        SELECT 'NHANVIEN' AS UserRole;
    END
    -- Kiểm tra User là Nha Si (NHASI)
    ELSE IF EXISTS (SELECT 1
    FROM NHASI
    WHERE SDT = @UserName AND MatKhau = @Password)
    BEGIN
        -- Nha Si (NHASI) login successful
        SELECT 'NHASI' AS UserRole;
    END
    -- Kiểm tra User là Benh Nhan (BENHNHAN)
    ELSE IF EXISTS (SELECT 1
    FROM BENHNHAN
    WHERE SDT = @UserName AND MatKhau = @Password)
    BEGIN
        -- Benh Nhan (BENHNHAN) login successful
        SELECT 'BENHNHAN' AS UserRole;
    END
    ELSE
    BEGIN
        -- Login failed
        ROLLBACK TRANSACTION;
        SELECT 'INVALID' AS UserRole;
    END

    COMMIT TRANSACTION;
END;
GO

--//-------------------
-- //1.Bệnh nhân (đã có tài khoản) 
-- 1.1/Có quyền đăng nhập vào tài khoản (gọi giao tác DangNhap) : WROTE
-- 1.2/Có quyền đặt lịch hẹn: 
-- Được quyền chọn ngày giờ khám (gọi giao tác ChonThoiGianKham). 
-- Được quyền chọn nha sĩ khám (gọi giao tác ChonNhaSiKham). 
IF EXISTS (SELECT *
FROM sys.procedures
WHERE name = N'DatLichHen' AND type = 'P')
BEGIN
    DROP PROCEDURE DatLichHen;
    PRINT N'Đã hủy giao tác DatLichHen.';
END
ELSE
BEGIN
    PRINT N'Giao tác DatLichHen chưa được tạo.';
END
GO

CREATE PROCEDURE DatLichHen
    @Ngay DATETIME,
    @SDT VARCHAR(10),
    @MaNhaSi INT,
    @CaDangKy NVARCHAR(50)
AS
BEGIN
    BEGIN TRANSACTION;

    DECLARE @MaBenhNhan INT;

    -- Kiểm tra tài khoản hợp lệ dựa trên SDT
    SELECT @MaBenhNhan = MaBenhNhan
    FROM BENHNHAN BN
    WHERE BN.SDT = @SDT;

    IF @MaBenhNhan IS NOT NULL
    BEGIN
        -- Kiểm tra nếu có Ca trống
        IF EXISTS (
            SELECT 1
        FROM LICHLAMVIEC
        WHERE Ngay = @Ngay
            AND MaNhaSi = @MaNhaSi
            AND CaDangKy = @CaDangKy
        )
        BEGIN
            -- Khung giờ trống -> Đặt hẹn
            INSERT INTO LICHHEN
                (NgayGioKham, MaBenhNhan, MaNhaSi, TrangThaiLichHen)
            VALUES
                (@Ngay, @MaBenhNhan, @MaNhaSi, N'Đã đặt');

            PRINT N'Đã đặt hẹn thành công.';
        END
        ELSE
        BEGIN
            -- Khung giờ muốn đặt đã hết
            ROLLBACK TRANSACTION;
            PRINT N'Vui lòng chọn khung giờ khác.';
        END
    END
    ELSE
    BEGIN
        ROLLBACK TRANSACTION;
        PRINT N'Không tìm thấy bệnh nhân với số điện thoại đã nhập.';
    END

    COMMIT TRANSACTION;
END;

GO


-- Có quyền được xem thông tin cá nhân (gọi giao tác XemThongTinCaNhan) bao gồm họ tên, ngày sinh, địa chỉ, số điện thoại, giới tính. 
IF EXISTS (SELECT *
FROM sys.procedures
WHERE name = N'XemThongTinCaNhan' AND type = 'P')
BEGIN
    DROP PROCEDURE XemThongTinCaNhanBenhNhan;
    PRINT N'Đã hủy giao tác XemThongTinCaNhan.';
END
ELSE
BEGIN
    PRINT N'Giao tác XemThongTinCaNhan chưa được tạo.';
END
GO
CREATE PROCEDURE XemThongTinCaNhanBenhNhan
    @SDT VARCHAR(10)
AS
BEGIN
    -- Kiểm tra xem bệnh nhân có tồn tại trong hệ thống hay không
    IF EXISTS (SELECT 1
    FROM BENHNHAN
    WHERE SDT = @SDT)
    BEGIN
        -- Lấy thông tin cá nhân của bệnh nhân
        SELECT
            HoTen,
            NgaySinh,
            DiaChi,
            SDT,
            GioiTinh
        FROM BENHNHAN
        WHERE SDT = @SDT;
    END
    ELSE
    BEGIN
        PRINT N'Bệnh nhân không tồn tại trong hệ thống.';
    END
END;
GO
-- Có quyền được xem thông tin của nha sĩ (gọi giao tác XemThongTinNhaSi). 
IF EXISTS (SELECT *
FROM sys.procedures
WHERE name = N'XemThongTinNhaSi' AND type = 'P')
BEGIN
    DROP PROCEDURE XemThongTinNhaSi;
    PRINT N'Đã hủy giao tác XemThongTinNhaSi.';
END
ELSE
BEGIN
    PRINT N'Giao tác XemThongTinNhaSi chưa được tạo.';
END
GO

CREATE PROCEDURE XemThongTinNhaSi
    @MaNhaSi INT
AS
BEGIN
    -- Kiểm tra xem MaNhaSi có tồn tại không
    IF EXISTS (
        SELECT 1
    FROM NHASI
    WHERE MaNhaSi = @MaNhaSi
    )
    BEGIN
        -- Lấy thông tin của NhaSi
        SELECT
            HoTen AS 'Họ Tên',
            SDT AS 'Số Điện Thoại',
            GioiTinh AS 'Giới Tính',
            NgaySinh AS 'Ngày Sinh',
            DiaChi AS 'Địa Chỉ',
            ChuyenMon AS 'Chuyên Khoa',
            BangCap AS 'Bằng'
        FROM NHASI
        WHERE MaNhaSi = @MaNhaSi;
    END
    ELSE
    BEGIN
        -- Nếu MaNhaSi không tồn tại
        PRINT 'Không tìm thấy thông tin cho MaNhaSi = ' + CAST(@MaNhaSi AS NVARCHAR(10));
    END
END;
GO

-- Có quyền được cập nhật thông tin cá nhân của bệnh nhân (gọi giao tác CapNhatThongTin) 
IF EXISTS (SELECT *
FROM sys.procedures
WHERE name = N'CapNhatThongTin' AND type = 'P')
BEGIN
    DROP PROCEDURE CapNhatThongTin;
    PRINT N'Đã hủy giao tác CapNhatThongTin.';
END
ELSE
BEGIN
    PRINT N'Giao tác CapNhatThongTin chưa được tạo.';
END
GO

CREATE PROCEDURE CapNhatThongTin
    @SDT VARCHAR(10),
    @HoTen NVARCHAR(50),
    @GioiTinh NVARCHAR(5),
    @NgaySinh DATETIME,
    @DiaChi NVARCHAR(50)
AS
BEGIN
    BEGIN TRANSACTION;

    -- Kiểm tra xem bệnh nhân có tồn tại trong hệ thống hay không
    IF EXISTS (SELECT 1
    FROM BENHNHAN
    WHERE SDT = @SDT)
    BEGIN
        -- Cập nhật thông tin cá nhân của bệnh nhân
        UPDATE BENHNHAN
        SET
            HoTen = @HoTen,
            GioiTinh = @GioiTinh,
            NgaySinh = @NgaySinh,
            DiaChi = @DiaChi
        WHERE SDT = @SDT;

        COMMIT TRANSACTION;
        PRINT N'Cập nhật thông tin thành công.';
    END
    ELSE
    BEGIN
        -- Bệnh nhân không tồn tại
        ROLLBACK TRANSACTION;
        PRINT N'Bệnh nhân không tồn tại trong hệ thống. Cập nhật không thành công.';
    END
END;
GO

-- Có quyền được xem hồ sơ bệnh án (lịch sử khám chữa bệnh) được nha sĩ ghi nhận lại trong quá trình điều trị (gọi giao tác XemHoSoBenhAn) 
IF EXISTS (SELECT *
FROM sys.procedures
WHERE name = N'XemHoSoBenhAn' AND type = 'P')
BEGIN
    DROP PROCEDURE XemHoSoBenhAn;
    PRINT N'Đã hủy giao tác XemHoSoBenhAn.';
END
ELSE
BEGIN
    PRINT N'Giao tác XemHoSoBenhAn chưa được tạo.';
END
GO
CREATE PROCEDURE XemHoSoBenhAn
    @SDT VARCHAR(10)
AS
BEGIN
    BEGIN TRANSACTION;

    -- Kiểm tra xem bệnh nhân có tồn tại trong hệ thống hay không
    IF EXISTS (SELECT 1
    FROM BENHNHAN
    WHERE SDT = @SDT)
    BEGIN
        -- Lấy thông tin cá nhân của bệnh nhân
        SELECT
            BN.HoTen AS 'Họ Tên',
            BN.NgaySinh AS 'Ngày Sinh',
            BN.DiaChi AS 'Địa Chỉ',
            BN.SDT AS 'Số Điện Thoại',
            BN.GioiTinh AS 'Giới Tính',
            LSKB.MaNhaSiKham AS 'Mã Nha Sĩ Khám',
            NS.HoTen AS 'Nha Sĩ Khám',
            LSKB.GhiChu,
            LSKB.NgayKham
        FROM
            BENHNHAN BN
            INNER JOIN
            LICHSUKHAMBENH LSKB ON BN.MaBenhNhan = LSKB.MaBenhNhan
            INNER JOIN
            NHASI NS ON LSKB.MaNhaSiKham = NS.MaNhaSi
        WHERE
            BN.SDT = @SDT;
    END
    ELSE
    BEGIN
        -- Nếu không tìm thấy bệnh nhân
        ROLLBACK TRANSACTION;
        PRINT N'Bệnh nhân không tồn tại trong hệ thống.';
    END

    COMMIT TRANSACTION;
END;
GO

-- Có quyền xem thông tin hoá đơn (gọi giao tác XemThongTinHoaDon) 
IF EXISTS (SELECT *
FROM sys.procedures
WHERE name = N'XemThongTinHoaDon' AND type = 'P')
BEGIN
    DROP PROCEDURE XemThongTinHoaDon;
    PRINT N'Đã hủy giao tác XemThongTinHoaDon.';
END
ELSE
BEGIN
    PRINT N'Giao tác XemThongTinHoaDon chưa được tạo.';
END
GO

CREATE PROCEDURE XemThongTinHoaDon
    @SDT VARCHAR(10),
    @STTLichSuKB INT
AS
BEGIN
    BEGIN TRANSACTION;

    DECLARE @MaBenhNhan INT;
    DECLARE @MaNhaSiKham INT;

    -- Kiểm tra xem bệnh nhân có tồn tại trong hệ thống hay không
    SELECT @MaBenhNhan = MaBenhNhan
    FROM BENHNHAN
    WHERE SDT = @SDT;

    IF @MaBenhNhan IS NOT NULL
    BEGIN
        -- Kiểm tra xem lịch sử khám bệnh có tồn tại hay không
        SELECT @MaNhaSiKham = MaNhaSiKham
        FROM LICHSUKHAMBENH
        WHERE STT = @STTLichSuKB AND MaBenhNhan = @MaBenhNhan;

        IF @MaNhaSiKham IS NOT NULL
        BEGIN
            -- Hiển thị thông tin hoá đơn
            SELECT
                HD.MaHoaDon,
                HD.TongTien,
                HD.TinhTrangThanhToan,
                HD.NgayThanhToan,
                DT.MaDonThuoc,
                DT.NgaySuDung,
                DT.NgayHetHan,
                DT.LieuDung,
                DT.SoLuong,
                DVSD.MaPhieuDVSD,
                DV.TenDichVu,
                DV.DonGia 'Đơn giá Dịch vụ'
            FROM HOADON HD
                INNER JOIN DONTHUOC DT ON HD.MaDonThuoc = DT.MaDonThuoc
                LEFT JOIN DICHVUSUDUNG DVSD ON HD.MaPhieuDVSD = DVSD.MaPhieuDVSD
                LEFT JOIN DICHVU DV ON DVSD.MaDichVu = DV.MaDichVu
            WHERE HD.STTLichSuKB = @STTLichSuKB AND HD.MaBenhNhan = @MaBenhNhan;

            COMMIT TRANSACTION;
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT N'Không tìm thấy lịch sử khám bệnh với STT = ' + CAST(@STTLichSuKB AS NVARCHAR(10));
        END
    END
    ELSE
    BEGIN
        ROLLBACK TRANSACTION;
        PRINT N'Bệnh nhân không tồn tại trong hệ thống.';
    END
END;
GO

-- Có quyền được xem trạng thái thanh toán (gọi giao tác XemTrangThaiThanhToan) 
IF EXISTS (SELECT *
FROM sys.procedures
WHERE name = N'XemTrangThaiThanhToan' AND type = 'P')
BEGIN
    DROP PROCEDURE XemTrangThaiThanhToan;
    PRINT N'Đã hủy giao tác XemTrangThaiThanhToan.';
END
ELSE
BEGIN
    PRINT N'Giao tác XemTrangThaiThanhToan chưa được tạo.';
END
GO
CREATE PROCEDURE XemTrangThaiThanhToan
    @SDT VARCHAR(10),
    @STTLichSuKB INT
AS
BEGIN
    BEGIN TRANSACTION;

    DECLARE @MaBenhNhan INT;
    DECLARE @TinhTrangThanhToan NVARCHAR(50);

    -- Kiểm tra xem bệnh nhân có tồn tại trong hệ thống hay không
    SELECT @MaBenhNhan = MaBenhNhan
    FROM BENHNHAN
    WHERE SDT = @SDT;

    IF @MaBenhNhan IS NOT NULL
    BEGIN
        -- Kiểm tra xem hóa đơn có tồn tại không
        SELECT @TinhTrangThanhToan = TinhTrangThanhToan
        FROM HOADON
        WHERE MaBenhNhan = @MaBenhNhan AND STTLichSuKB = @STTLichSuKB;

        IF @TinhTrangThanhToan IS NOT NULL
        BEGIN
            -- In thông tin trạng thái thanh toán
            PRINT N'Trạng thái thanh toán: ' + @TinhTrangThanhToan;
        END
        ELSE
        BEGIN
            -- Nếu hóa đơn không tồn tại
            ROLLBACK TRANSACTION;
            PRINT N'Không tìm thấy hóa đơn cho bệnh nhân và lịch sử khám bệnh đã nhập.';
        END
    END
    ELSE
    BEGIN
        -- Nếu bệnh nhân không tồn tại
        ROLLBACK TRANSACTION;
        PRINT N'Bệnh nhân không tồn tại trong hệ thống.';
    END

    COMMIT TRANSACTION;
END;
GO

-- Có quyền đăng xuất khỏi tài khoản (gọi giao tác DangXuat) 

-- //2.Nha sĩ (đã có tài khoản) 

-- Có quyền cập nhật lịch làm việc của mình (gọi giao tác CapNhatLichLamViec) 
IF EXISTS (SELECT *
FROM sys.procedures
WHERE name = N'CapNhatLichLamViec' AND type = 'P')
BEGIN
    DROP PROCEDURE CapNhatLichLamViec;
    PRINT N'Đã hủy giao tác CapNhatLichLamViec.';
END
ELSE
BEGIN
    PRINT N'Giao tác CapNhatLichLamViec chưa được tạo.';
END
GO
CREATE PROCEDURE CapNhatLichLamViec
    @SDT_NhaSi VARCHAR(10),
    @Ngay DATE,
    @CaDangKy NVARCHAR(50)
AS
BEGIN
    BEGIN TRANSACTION;

    DECLARE @MaNhaSi INT;
    DECLARE @STT INT;

    -- Kiểm tra xem SDT của nha sĩ có tồn tại trong hệ thống hay không
    SELECT @MaNhaSi = MaNhaSi
    FROM NHASI
    WHERE SDT = @SDT_NhaSi;

    -- Kiểm tra xem có CaDangKy trống không
    IF @MaNhaSi IS NOT NULL
    BEGIN
        IF EXISTS (
            SELECT 1
        FROM LICHLAMVIEC
        WHERE Ngay = @Ngay
            AND MaNhaSi = @MaNhaSi
            AND CaDangKy = @CaDangKy
        )
        BEGIN
            -- Cập nhật lịch làm việc nếu CaDangKy trống
            UPDATE LICHLAMVIEC
            SET CaDangKy = @CaDangKy
            WHERE Ngay = @Ngay
                AND MaNhaSi = @MaNhaSi;

            SET @STT = (SELECT STT
            FROM LICHLAMVIEC
            WHERE Ngay = @Ngay
                AND MaNhaSi = @MaNhaSi
                AND CaDangKy = @CaDangKy);

            COMMIT TRANSACTION;
            PRINT N'Cập nhật lịch làm việc thành công. STT: ' + CAST(@STT AS NVARCHAR(10));
        END
        ELSE
        BEGIN
            -- Nếu CaDangKy đã có người đăng ký
            ROLLBACK TRANSACTION;
            PRINT N'Không thể cập nhật lịch làm việc. CaDangKy đã có người đăng ký.';
        END
    END
    ELSE
    BEGIN
        -- Nếu SDT của nha sĩ không tồn tại
        ROLLBACK TRANSACTION;
        PRINT N'Không tìm thấy thông tin nha sĩ với số điện thoại đã nhập.';
    END
END;

-- Có quyền được xem thông tin cá nhân (gọi giao tác XemThongTinCaNhan) bao gồm họ tên, ngày sinh, địa chỉ, số điện thoại, giới tinh. (NHÂN VIÊN)
IF EXISTS (SELECT *
FROM sys.procedures
WHERE name = 'XemThongTinCaNhanNhanVien' AND type = 'P')
    BEGIN
    DROP PROCEDURE XemThongTinCaNhanNhanVien;
    PRINT N'Đã huỷ giao tác XemThongTinCaNhanNhanVien';
END
ELSE
    BEGIN
    Print N'Giao tác XemThongTinCaNhanNhanVien chưa dược tạo';
END
GO
CREATE PROCEDURE XemThongTinCaNhanNhanVien
    @SDT VARCHAR(10)
AS
BEGIN
    BEGIN TRANSACTION
    -- ktra nhân viên có tồn tại trong hệ thống không
    IF EXISTS (SELECT 1
    FROM NHANVIEN
    WHERE SDT = @SDT)
        BEGIN
        -- Lấy thông tin cá nhân của nhân viên
        SELECT
            Hoten,
            SDT,
            GioiTinh,
            DiaChi,
            TinhTrangHoatDong,
            ViTri
        FROM NHANVIEN
        WHERE SDT = @SDT;

        COMMIT TRANSACTION;
    END
    ELSE
        BEGIN
        ROLLBACK TRANSACTION;
        PRINT N'Nhân viên không tồn tại trong hệ thống.';
    END
    COMMIT TRANSACTION;
END
GO
-- EXEC XemThongTinCaNhanNhanVien @SDT = "0123456788";
-- GO

-- Có quyền được xem thông tin của nha sĩ khác (gọi giao tác XemThongTinNhaSi) và nhân viên (gọi giao tác XemThongTinNhanVien) 

-- Có quyền được xem thông tin của bệnh nhân (gọi giao tác XemThongTinBenhNhan)  

-- Có quyền ghi nhận thông tin vào hồ sơ bệnh nhân gồm: ngày, tháng, người thực hiện khám, dịch vụ sử dụng, danh sách thuốc được kê cho mỗi lần khám (gọi giao tác GhiNhanHoSoBenhAn). 
-- Create the stored procedure
IF EXISTS (SELECT *
FROM sys.procedures
WHERE name = 'TaoHoSoBenhAn' AND type = 'P')
    BEGIN
    DROP PROCEDURE TaoHoSoBenhAn;
    PRINT N'Đã huỷ giao tác TaoHoSoBenhAn';
END
ELSE
    BEGIN
    Print N'Giao tác TaoHoSoBenhAn chưa dược tạo';
END
GO
CREATE PROCEDURE TaoHoSoBenhAn
    @SDT VARCHAR(10),
    @NgayGioKham DATETIME,
    @HoTenNhaSi NVARCHAR(50)
AS
BEGIN
    BEGIN TRANSACTION;

    DECLARE @MaBenhNhan INT;
    DECLARE @MaNhaSi INT;
    DECLARE @STTLichSuKB INT;

    -- Get patient ID based on phone number
    SELECT @MaBenhNhan = MaBenhNhan
    FROM BENHNHAN
    WHERE SDT = @SDT;

    -- Check if the patient exists
    IF @MaBenhNhan IS NOT NULL
    BEGIN
        -- Get dentist ID based on name
        SELECT @MaNhaSi = MaNhaSi
        FROM NHASI
        WHERE HoTen = @HoTenNhaSi;

        -- Check if the dentist exists
        IF @MaNhaSi IS NOT NULL
        BEGIN
            -- Insert into LICHSUKHAMBENH
            INSERT INTO LICHSUKHAMBENH
                (MaBenhNhan, MaNhaSiKham, NgayKham)
            VALUES
                (@MaBenhNhan, @MaNhaSi, @NgayGioKham);

            SET @STTLichSuKB = SCOPE_IDENTITY();

            -- Insert into DICHVUSUDUNG (if any)
            INSERT INTO DICHVUSUDUNG
                (NgaySuDung, STTLichSuKB, MaBenhNhan, MaDichVu, SoLuong)
            SELECT @NgayGioKham, @STTLichSuKB, @MaBenhNhan, MaDichVu, 1
            FROM DICHVU;
            COMMIT TRANSACTION;
            PRINT 'Tạo hồ sơ bệnh án thành công.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'Không tìm thấy thông tin nha sĩ với tên đã nhập.';
        END
    END
    ELSE
    BEGIN
        ROLLBACK TRANSACTION;
        PRINT 'Không tìm thấy thông tin bệnh nhân với số điện thoại đã nhập.';
    END
END;
GO

-- Có quyền xem danh mục thuốc (gọi giao tác XemDanhMucThuoc) 
IF EXISTS (SELECT *
FROM sys.procedures
WHERE name = 'XemDanhMucThuoc' AND type = 'P')
    BEGIN
    DROP PROCEDURE XemDanhMucThuoc;
    PRINT N'Đã huỷ giao tác XemDanhMucThuoc';
END
ELSE
    BEGIN
    Print 'Giao tác XemDanhMucThuoc chưa dược tạo';
END
GO
CREATE PROCEDURE XemDanhMucThuoc
    @MaThuoc INT
AS
BEGIN
    BEGIN TRANSACTION
    -- ktra mã thuốc có tồn tại trong hệ thống không
    IF EXISTS (SELECT 1
    FROM THUOC
    WHERE MaThuoc = @MaThuoc)
        BEGIN
        -- Lấy thông tin thuốc
        SELECT
            MaThuoc,
            NgayHetHan ,
            TenThuoc,
            DonViTinh,
            DonGia,
            ChiDinh,
            SoLuongTonKho
        FROM THUOC
        WHERE MaThuoc = @MaThuoc;

        COMMIT TRANSACTION;
    END
    ELSE
        BEGIN
        ROLLBACK TRANSACTION;
        PRINT N'Thuốc không tồn tại trong hệ thống.';
    END
    COMMIT TRANSACTION;
END

GO
-- Có quyền được xem danh sách lịch hẹn  (gọi giao tác XemDanhSachLichHen) 
IF EXISTS (SELECT *
FROM sys.procedures
WHERE name = N'XemDanhSachLichHen' AND type = 'P')
BEGIN
    DROP PROCEDURE XemThongTinCaNhan;
    PRINT N'Đã hủy giao tác XemDanhSachLichHen.';
END
ELSE
BEGIN
    PRINT N'Giao tác XemDanhSachLichHen chưa được tạo.';
END
GO
CREATE PROCEDURE XemDanhSachLichHen
AS
BEGIN
    BEGIN TRANSACTION;
    SELECT *
    FROM LICHHEN
    COMMIT TRANSACTION;
END;
GO
-- //3.Nhân viên (đã có tài khoản) 

-- Có quyền ghi nhận vào hệ thống thông tin đặt khám hoặc đăng kí cho khách hàng (gọi giao tiếp GhiNhanDatKhamBenh) 
IF EXISTS (SELECT *
FROM sys.procedures
WHERE name = 'GhiNhanDatKhamBenh' AND type = 'P')
    BEGIN
    DROP PROCEDURE GhiNhanDatKhamBenh;
    PRINT N'Đã huỷ giao tác GhiNhanDatKhamBenh';
END
ELSE
    BEGIN
    Print N'Giao tác GhiNhanDatKhamBenh chưa dược tạo';
END
GO
CREATE PROCEDURE GhiNhanDatKhamBenh
    @SDT VARCHAR(10),
    @NgayGioKham DATETIME,
    @TenNhaSi NVARCHAR(50)
AS
BEGIN
    BEGIN TRANSACTION;

    DECLARE @MaBenhNhan INT;
    DECLARE @MaNhaSi INT;
    DECLARE @CaDangKy NVARCHAR(50);

    -- Kiểm tra xem bệnh nhân có tồn tại không
    SELECT @MaBenhNhan = MaBenhNhan
    FROM BENHNHAN
    WHERE SDT = @SDT;

    IF @MaBenhNhan IS NOT NULL
    BEGIN
        -- Kiểm tra xem nha sĩ có tồn tại không
        SELECT @MaNhaSi = MaNhaSi
        FROM NHASI
        WHERE HoTen = @TenNhaSi;

        IF @MaNhaSi IS NOT NULL
        BEGIN
            -- Kiểm tra xem nha sĩ có đăng ký ca làm việc trong ngày không
            SELECT @CaDangKy = CaDangKy
            FROM LICHLAMVIEC
            WHERE MaNhaSi = @MaNhaSi AND Ngay = CONVERT(DATE, @NgayGioKham);

            IF @CaDangKy IS NOT NULL
            BEGIN
                -- Kiểm tra xem có thể đặt hẹn vào thời gian đó không
                IF EXISTS (
                    SELECT 1
                FROM LICHHEN
                WHERE MaNhaSi = @MaNhaSi
                    AND NgayGioKham = @NgayGioKham
                )
                BEGIN
                    -- Thời gian đã có người đặt
                    ROLLBACK TRANSACTION;
                    PRINT N'Không thể đặt hẹn vào thời gian này. Thời gian đã có người đặt.';
                END
                ELSE
                BEGIN
                    -- Thêm thông tin đặt khám vào bảng LICHHEN
                    INSERT INTO LICHHEN
                        (NgayGioKham, MaBenhNhan, MaNhaSi, TrangThaiLichHen)
                    VALUES
                        (@NgayGioKham, @MaBenhNhan, @MaNhaSi, N'Đã đặt');

                    PRINT N'Đã đặt hẹn thành công.';
                    COMMIT TRANSACTION;
                END
            END
            ELSE
            BEGIN
                -- Nha sĩ không đăng ký ca làm việc trong ngày
                ROLLBACK TRANSACTION;
                PRINT N'Nha sĩ không đăng ký ca làm việc trong ngày.';
            END
        END
        ELSE
        BEGIN
            -- Nha sĩ không tồn tại
            ROLLBACK TRANSACTION;
            PRINT N'Nha sĩ không tồn tại.';
        END
    END
    ELSE
    BEGIN
        -- Bệnh nhân không tồn tại
        ROLLBACK TRANSACTION;
        PRINT N'Bệnh nhân không tồn tại.';
    END
END;

GO
-- Có quyền tìm kiếm hồ sơ khám bệnh của bệnh nhân (gọi giao tác TimKiemHoSoBenhNhan) 
IF EXISTS (SELECT *
FROM sys.procedures
WHERE name = N'TimKiemHoSoKhamBenh' AND type = 'P')
BEGIN
    DROP PROCEDURE TimKiemHoSoKhamBenh;
    PRINT N'Đã hủy giao tác TimKiemHoSoKhamBenh.';
END
ELSE
BEGIN
    PRINT N'Giao tác TimKiemHoSoKhamBenh chưa được tạo.';
END
GO
CREATE PROCEDURE TimKiemHoSoKhamBenh
    @MaBenhNhan INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Your SELECT statement to search for medical examination records
        SELECT *
        FROM LICHSUKHAMBENH
        WHERE MaBenhNhan = @MaBenhNhan;

        -- Your additional logic can go here

        COMMIT;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        PRINT N'Không thể tìm kiếm hồ sơ khám bệnh của bệnh nhân.';
    END CATCH;
END;
EXEC TimKiemHoSoKhamBenh @MaBenhNhan = 1001;
GO
-- Có quyền thông báo (in) cho khách hàng lịch đăng kí (gọi giao tác ThongBaoLichKham) 
IF EXISTS (SELECT *
FROM sys.procedures
WHERE name = N'ThongBaoLichKham' AND type = 'P')
BEGIN
    DROP PROCEDURE ThongBaoLichKham;
    PRINT N'Đã hủy giao tác ThongBaoLichKham.';
END
ELSE
BEGIN
    PRINT N'Giao tác ThongBaoLichKham chưa được tạo.';
END
GO
CREATE PROCEDURE ThongBaoLichKham
AS
BEGIN
    BEGIN TRANSACTION;

    DECLARE @NgayGioKhamTomorrow DATETIME;
    SET @NgayGioKhamTomorrow = DATEADD(DAY, 1, GETDATE());

    -- Kiểm tra có lịch hẹn nào vào ngày mai không
    IF EXISTS (
        SELECT 1
    FROM LICHHEN LH
        INNER JOIN BENHNHAN BN ON LH.MaBenhNhan = BN.MaBenhNhan
    WHERE CAST(LH.NgayGioKham AS DATE) = @NgayGioKhamTomorrow
    )
    BEGIN
        -- Có lịch hẹn, thực hiện thông báo (ở đây có thể sử dụng PRINT hoặc các cách thông báo khác)
        PRINT N'Bạn có lịch hẹn khám ngày mai. Vui lòng kiểm tra thông tin chi tiết trong ứng dụng.';

        -- Kết thúc giao tác nếu thành công
        COMMIT TRANSACTION;
    END
    ELSE
    BEGIN
        -- Không có lịch hẹn, hủy giao tác
        ROLLBACK TRANSACTION;
        PRINT N'Không có lịch hẹn khám vào ngày mai.';
    END
END;
GO


-- Có quyền xem danh mục thuốc (gọi giao tác XemDanhMucThuoc) gồm mã thuốc, tên thuốc, đơn vị tính, chỉ định, số lượng tồn trong kho và ngày hết hạn của thuốc. 

-- Có quyền tìm kiếm hồ sơ khám bệnh của bệnh nhân (gọi giao tác TimKiemHoSoBenhNhan) 
-- để lấy thông tin khám gồm dịch vụ, phí khám, đơn thuốc để lập hóa đơn thanh toán (gọi giao tác LapHoaDonThanhToan) 
IF EXISTS (SELECT *
FROM sys.procedures
WHERE name = N'TimKiemHoSoBenhNhan' AND type = 'P')
BEGIN
    DROP PROCEDURE TimKiemHoSoBenhNhan;
    PRINT N'Đã hủy giao tác TimKiemHoSoBenhNhan.';
END
ELSE
BEGIN
    PRINT N'Giao tác TimKiemHoSoBenhNhan chưa được tạo.';
END
GO
CREATE PROCEDURE TimKiemHoSoBenhNhan
    @TenBenhNhan NVARCHAR(50)
AS
BEGIN
    SELECT
        MaBenhNhan,
        HoTen,
        SDT,
        GioiTinh,
        NgaySinh,
        DiaChi
    FROM
        BENHNHAN
    WHERE
        HoTen LIKE '%' + @TenBenhNhan + '%';
END;
GO
EXEC TimKiemHoSoBenhNhan @TenBenhNhan = 'Benh Nhan';
GO

-- Có quyền thêm, xóa, sửa thông tin thuốc trong kho thuốc (gọi giao tác QuanLyKhoThuoc)  
IF EXISTS (SELECT *
FROM sys.procedures
WHERE name = N'QuanLyKhoThuoc' AND type = 'P')
BEGIN
    DROP PROCEDURE QuanLyKhoThuoc;
    PRINT N'Đã hủy giao tác QuanLyKhoThuoc.';
END
ELSE
BEGIN
    PRINT N'Giao tác QuanLyKhoThuoc chưa được tạo.';
END
GO
CREATE PROCEDURE QuanLyKhoThuoc
    @MaThuoc INT = NULL,
    @NgayHetHan DATETIME = NULL,
    @TenThuoc NVARCHAR(50) = NULL,
    @DonViTinh NVARCHAR(50) = NULL,
    @DonGia INT = NULL,
    @ChiDinh NVARCHAR(50) = NULL,
    @SoLuongTonKho INT = NULL,
    @ThaoTac NVARCHAR(50)
AS
BEGIN
    IF @ThaoTac = 'ThemMoi'
    BEGIN
        -- Add a new drug to the inventory
        INSERT INTO THUOC
            (MaThuoc, NgayHetHan, TenThuoc, DonViTinh, DonGia, ChiDinh, SoLuongTonKho)
        VALUES
            (@MaThuoc, @NgayHetHan, @TenThuoc, @DonViTinh, @DonGia, @ChiDinh, @SoLuongTonKho);
        PRINT 'Drug added to inventory successfully.';
    END
    ELSE IF @ThaoTac = 'CapNhat'
    BEGIN
        -- Update drug information in the inventory
        UPDATE THUOC
        SET
            NgayHetHan = @NgayHetHan,
            TenThuoc = @TenThuoc,
            DonViTinh = @DonViTinh,
            DonGia = @DonGia,
            ChiDinh = @ChiDinh,
            SoLuongTonKho = @SoLuongTonKho
        WHERE MaThuoc = @MaThuoc AND NgayHetHan = @NgayHetHan;
        PRINT 'Drug information updated successfully.';
    END
    ELSE IF @ThaoTac = 'XemTonKho'
    BEGIN
        -- View current inventory status
        SELECT *
        FROM THUOC;
    END
    ELSE
    BEGIN
        -- Invalid operation
        PRINT 'Invalid operation.';
    END
END;
GO

-- Có quyền thanh đổi trạng thái thanh toán của hóa đơn (gọi giao tác ThayDoiTrangThaiThanhToan).
CREATE PROCEDURE ThayDoiTrangThaiThanhToan
    @SDT VARCHAR(10),
    @STTLichSuKB INT
AS
BEGIN
    BEGIN TRANSACTION;
    -- Bắt đầu giao dịch

    -- Kiểm tra xem bệnh nhân có tồn tại không
    IF EXISTS (SELECT 1
    FROM BENHNHAN
    BEGIN
        -- Kiểm tra xem lịch sử khám bệnh có tồn tại không
        IF EXISTS (SELECT 1
        FROM LICHSUKHAMBENH
        WHERE STT = @STTLichSuKB AND MaBenhNhan = (SELECT MaBenhNhan
            FROM BENHNHAN
            WHERE SDT = @SDT))
        BEGIN
            -- Cập nhật trạng thái thanh toán của hóa đơn
            UPDATE HOADON
            SET TinhTrangThanhToan = N'Đã thanh toán'
            WHERE STTLichSuKB = @STTLichSuKB AND MaBenhNhan = (SELECT MaBenhNhan
                FROM BENHNHAN
                WHERE SDT = @SDT);

            PRINT N'Cập nhật trạng thái thanh toán thành công.';
            COMMIT TRANSACTION;
        -- Thực hiện giao dịch
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            -- Hủy giao dịch nếu lịch sử khám bệnh không tồn tại
            PRINT N'Lịch sử khám bệnh không tồn tại.';
        END
    END
    ELSE
    BEGIN
        ROLLBACK TRANSACTION;
        -- Hủy giao dịch nếu bệnh nhân không tồn tại
        PRINT N'Bệnh nhân không tồn tại trong hệ thống.';
    END
END;
GO

-- Có quyền chỉnh thêm, xóa, sửa tài khoản của nhân viên, nha sĩ, bệnh nhận (gọi giao tác QuanLyTaiKhoan) 
IF OBJECT_ID('dbo.QuanLyTaiKhoan', 'P') IS NOT NULL
    DROP PROCEDURE dbo.QuanLyTaiKhoan;
GO

CREATE PROCEDURE QuanLyTaiKhoan
    @SDT VARCHAR(10),
    @HoTen NVARCHAR(50),
    @GioiTinh NVARCHAR(5),
    @NgaySinh DATETIME,
    @DiaChi NVARCHAR(50),
    @MatKhau VARCHAR(8),
    @TinhTrangHoatDong NVARCHAR(20),
    @ViTri NVARCHAR(50),
    @ChuyenMon NVARCHAR(50),
    @BangCap NVARCHAR(50),
    @Email VARCHAR(255),
    @TinhTrangThanhToan NVARCHAR(50)
AS
BEGIN
    BEGIN TRANSACTION;

    DECLARE @ExistingUserCount INT;

    -- Kiểm tra xem tài khoản đã tồn tại chưa
    SELECT @ExistingUserCount = COUNT(*)
    FROM (
                                    SELECT SDT
            FROM QTV
        UNION
            SELECT SDT
            FROM NHANVIEN
        UNION
            SELECT SDT
            FROM NHASI
        UNION
            SELECT SDT
            FROM BENHNHAN
    ) AS Users
    WHERE SDT = @SDT;

    -- Nếu tài khoản đã tồn tại, in ra thông báo và rollback
    IF @ExistingUserCount > 0
    BEGIN
        ROLLBACK TRANSACTION;
        PRINT N'Tài khoản đã tồn tại. Thực hiện không thành công.';
        RETURN;
    END

    -- Thêm mới tài khoản dựa vào loại người dùng (QTV, NHANVIEN, NHASI, BENHNHAN)
    IF @ViTri IS NULL -- Đây là bệnh nhân
    BEGIN
        INSERT INTO BENHNHAN
            (HoTen, SDT, GioiTinh, NgaySinh, DiaChi, MatKhau)
        VALUES
            (@HoTen, @SDT, @GioiTinh, @NgaySinh, @DiaChi, @MatKhau);
    END
    ELSE IF @ChuyenMon IS NULL -- Đây là nhân viên
    BEGIN
        INSERT INTO NHANVIEN
            (HoTen, SDT, GioiTinh, DiaChi, TinhTrangHoatDong, ViTri, MatKhau)
        VALUES
            (@HoTen, @SDT, @GioiTinh, @DiaChi, @TinhTrangHoatDong, @ViTri, @MatKhau);
    END
    ELSE -- Đây là nha sĩ
    BEGIN
        INSERT INTO NHASI
            (HoTen, SDT, GioiTinh, NgaySinh, DiaChi, ChuyenMon, BangCap, MatKhau)
        VALUES
            (@HoTen, @SDT, @GioiTinh, @NgaySinh, @DiaChi, @ChuyenMon, @BangCap, @MatKhau);
    END

    -- Kiểm tra tài khoản đã thêm thành công
    IF @@ERROR <> 0
    BEGIN
        ROLLBACK TRANSACTION;
        PRINT N'Có lỗi khi thêm tài khoản. Thực hiện không thành công.';
        RETURN;
    END

    -- Thêm email cho Quan Tri Vien (QTV)
    IF @Email IS NOT NULL
    BEGIN
        UPDATE QTV
        SET Email = @Email
        WHERE SDT = @SDT;
    END

    -- Thêm thông tin cho hóa đơn của bệnh nhân
    IF @TinhTrangThanhToan IS NOT NULL
    BEGIN
        INSERT INTO HOADON
            (MaBenhNhan, STTLichSuKB, TinhTrangThanhToan)
        VALUES
            (
                (SELECT MaBenhNhan
                FROM BENHNHAN
                WHERE SDT = @SDT),
                (SELECT STT
                FROM LICHSUKHAMBENH
                WHERE MaBenhNhan = (SELECT MaBenhNhan
                FROM BENHNHAN
                WHERE SDT = @SDT)),
                @TinhTrangThanhToan
        );
    END

    -- Commit giao dịch nếu không có lỗi xảy ra
    COMMIT TRANSACTION;

    PRINT N'Thực hiện thành công.';
END;
GO

IF OBJECT_ID('dbo.DoiMatKhau', 'P') IS NOT NULL
    DROP PROCEDURE dbo.DoiMatKhau;
GO
-- Đổi mật khẩu
CREATE PROCEDURE DoiMatKhau
    @SDT VARCHAR(10),
    @OldPassword VARCHAR(8),
    @NewPassword VARCHAR(8)
AS
BEGIN

    BEGIN TRANSACTION;

    BEGIN TRY
        -- Kiểm tra xem mật khẩu cũ có khớp với mật khẩu hiện tại không
        DECLARE @CurrentPassword VARCHAR(8);
        SELECT @CurrentPassword = MatKhau 
        FROM (
            SELECT SDT, MatKhau
            FROM NHANVIEN
        UNION
            SELECT SDT, MatKhau
            FROM NHASI
        UNION
            SELECT SDT, MatKhau
            FROM BENHNHAN
        ) AS Users
        WHERE SDT = @SDT;

        -- Thay đổi mật khẩu
        IF @CurrentPassword <> @OldPassword
        BEGIN
            THROW 50001, 'Mật khẩu cũ không khớp', 1;
        END
        UPDATE NHANVIEN SET MatKhau = @NewPassword WHERE SDT = @SDT;
        UPDATE NHASI SET MatKhau = @NewPassword WHERE SDT = @SDT;
        UPDATE BENHNHAN SET MatKhau = @NewPassword WHERE SDT = @SDT;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Nếu xảy ra lỗi, rollback transaction
        ROLLBACK TRANSACTION;

        -- Giữ lại thông báo lỗi gốc
        THROW;
    END CATCH;
END
GO

EXEC DoiMatKhau @SDT = '0123456780', @OldPassword = '12345678', @NewPassword = 'qwe12345';


--QUên mật khẩu (gửi link qua email và truy cập bằng link)
CREATE PROCEDURE QuenMatKhau
    @SDT VARCHAR(10),
    @NewPassword VARCHAR(8)
AS
BEGIN

    BEGIN TRANSACTION;

    BEGIN TRY
        IF NOT EXISTS(SELECT * 
        FROM (
            SELECT SDT
            FROM NHANVIEN
        UNION
            SELECT SDT
            FROM NHASI
        UNION
            SELECT SDT
            FROM BENHNHAN
        ) AS Users
        WHERE SDT = @SDT)
        BEGIN
            THROW 50001, 'TAI KHOAN KHONG TON TAI', 1;
        END

        UPDATE NHANVIEN SET MatKhau = @NewPassword WHERE SDT = @SDT;
        UPDATE NHASI SET MatKhau = @NewPassword WHERE SDT = @SDT;
        UPDATE BENHNHAN SET MatKhau = @NewPassword WHERE SDT = @SDT;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Nếu xảy ra lỗi, rollback transaction
        ROLLBACK TRANSACTION;

        -- Giữ lại thông báo lỗi gốc
        THROW;
    END CATCH;
END
GO
--Xem thông tin cá nhân quản trị viên
CREATE PROCEDURE XemThongTinQTV
    @MaQTV INT
AS
BEGIN
    -- Kiểm tra xem MaQTV có tồn tại không
    IF EXISTS (
        SELECT 1
    FROM QTV
    WHERE MaNhanVien = @MaQTV
    )
    BEGIN
        -- Lấy thông tin của QTV
        SELECT
            HoTen AS 'Họ Tên',
            SDT AS 'Số Điện Thoại',
            EMAIL as 'Email'
        FROM QTV
        WHERE MaNhanVien = @MaQTV;
    END
    ELSE
    BEGIN
        -- Nếu MaQTV không tồn tại
        PRINT 'Không tìm thấy thông tin cho MaQTV = ' + CAST(@MaQTV AS int);
    END
END;
GO
-- caajp nhajat thoong tin nha six
CREATE PROCEDURE CapNhatThongTinNhaSi
    @SDT VARCHAR(10),
    @HoTen NVARCHAR(50),
    @GioiTinh NVARCHAR(5),
    @NgaySinh DATETIME,
    @DiaChi NVARCHAR(50),
    @ChuyenMon nvarchar(50),
	@BangCap nvarchar(50)
AS
BEGIN
    BEGIN TRANSACTION;

    -- Kiểm tra xem bệnh nhân có tồn tại trong hệ thống hay không
    IF EXISTS (SELECT 1
    FROM NHASI
    WHERE SDT = @SDT)
    BEGIN
        -- Cập nhật thông tin cá nhân của bệnh nhân
        UPDATE NHASI
        SET
            HoTen = @HoTen,
            GioiTinh = @GioiTinh,
            NgaySinh = @NgaySinh,
            DiaChi = @DiaChi,
            ChuyenMon = @ChuyenMon,
            BangCap = @BangCap
        WHERE SDT = @SDT;

        COMMIT TRANSACTION;
        PRINT N'Cập nhật thông tin thành công.';
    END
    ELSE
    BEGIN
        -- Nha sĩ không tồn tại
        ROLLBACK TRANSACTION;
        PRINT N'Nha sĩ không tồn tại trong hệ thống. Cập nhật không thành công.';
    END
END;
GO
--Cap nhat thong tin nhanvien
CREATE PROCEDURE CapNhatThongTinNhanVien
    @SDT VARCHAR(10),
    @HoTen NVARCHAR(50),
    @GioiTinh NVARCHAR(5),
    @DiaChi NVARCHAR(50),
	@ViTri nvarchar(50)
AS
BEGIN
    BEGIN TRANSACTION;

    -- Kiểm tra xem Nhân viên có tồn tại trong hệ thống hay không
    IF EXISTS (SELECT 1
    FROM NHANVIEN
    WHERE SDT = @SDT)
    BEGIN
        -- Cập nhật thông tin cá nhân của Nhân viên
        UPDATE NHANVIEN
        SET
            HoTen = @HoTen,
            GioiTinh = @GioiTinh,
            DiaChi = @DiaChi,
            ViTri = @ViTri
        WHERE SDT = @SDT;

        COMMIT TRANSACTION;
        PRINT N'Cập nhật thông tin thành công.';
    END
    ELSE
    BEGIN
        -- NNhân viên không tồn tại
        ROLLBACK TRANSACTION;
        PRINT N'Nhân viên không tồn tại trong hệ thống. Cập nhật không thành công.';
    END
END;
GO


--Cap nhat thong tin QTV
CREATE PROCEDURE CapNhatThongTinQTV
    @SDT VARCHAR(10),
    @HoTen NVARCHAR(50),
    @Email varchar(255)
AS
BEGIN
    BEGIN TRANSACTION;

    -- Kiểm tra xem QTV có tồn tại trong hệ thống hay không
    IF EXISTS (SELECT 1
    FROM QTV
    WHERE SDT = @SDT)
    BEGIN
        -- Cập nhật thông tin cá nhân của QTV 
        UPDATE QTV
        SET
            HoTen = @HoTen,
            Email = @Email
        WHERE SDT = @SDT;

        COMMIT TRANSACTION;
        PRINT N'Cập nhật thông tin thành công.';
    END
    ELSE
    BEGIN
        -- QTV không tồn tại
        ROLLBACK TRANSACTION;
        PRINT N'QTV không tồn tại trong hệ thống. Cập nhật không thành công.';
    END
END;
GO

--Cập nhật trạng thái lịch hẹn (Hủy lịch hẹn)
CREATE PROCEDURE CapNhatTrangThaiLichHen
    @MaLichHen INT,
    @TrangThaiMoi NVARCHAR(50)
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        -- Kiểm tra xem lịch hẹn có tồn tại hay không
        IF NOT EXISTS (SELECT * FROM LICHHEN WHERE MaLichHen = @MaLichHen)
        BEGIN
            THROW 50001, 'Lịch hẹn không tồn tại', 1;
        END

        -- Cập nhật trạng thái mới cho lịch hẹn
        UPDATE LICHHEN SET TrangThaiLichHen = @TrangThaiMoi WHERE MaLichHen = @MaLichHen;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Nếu xảy ra lỗi, rollback transaction
        ROLLBACK TRANSACTION;

        -- Giữ lại thông báo lỗi gốc
        THROW;
    END CATCH;
END;
GO

-- QTV có thể xóa lịch hẹn
CREATE PROCEDURE XoaLichHen
    @MaLichHen INT
AS
BEGIN
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Kiểm tra xem lịch hẹn có tồn tại hay không
        IF NOT EXISTS (SELECT * FROM LICHHEN WHERE MaLichHen = @MaLichHen)
        BEGIN
            THROW 50001, 'Lịch hẹn không tồn tại', 1;
        END

        -- Xóa lịch hẹn
        DELETE FROM LICHHEN WHERE MaLichHen = @MaLichHen;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Nếu xảy ra lỗi, rollback transaction
        ROLLBACK TRANSACTION;

        -- Giữ lại thông báo lỗi gốc
        THROW;
    END CATCH;
END;
GO
--Xem đơn thuốc
CREATE PROCEDURE XemDonThuoc
    @MaDonThuoc INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRANSACTION;

    BEGIN TRY
        -- Kiểm tra xem đơn thuốc có tồn tại hay không
        IF NOT EXISTS (SELECT * FROM DONTHUOC WHERE MaDonThuoc = @MaDonThuoc)
        BEGIN
            THROW 50001, 'Đơn thuốc không tồn tại', 1;
        END

        -- Lấy thông tin về đơn thuốc
        SELECT MaDonThuoc, MaThuoc, MaBenhNhan, NgaySuDung, NgayHetHan, LieuDung, STTLichSuKB, SoLuong
        FROM DONTHUOC
        WHERE MaDonThuoc = @MaDonThuoc;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Nếu xảy ra lỗi, rollback transaction
        ROLLBACK TRANSACTION;

        -- Giữ lại thông báo lỗi gốc
        THROW;
    END CATCH;
END;
go

--Xóa tài khoản
CREATE PROCEDURE XoaTaiKhoan
    @SDT varchar(10)
AS
BEGIN
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Kiểm tra xem tài khoản có tồn tại hay không
        IF NOT EXISTS (SELECT * FROM (
            SELECT SDT
            FROM NHANVIEN
        UNION
            SELECT SDT
            FROM NHASI
        UNION
            SELECT SDT
            FROM BENHNHAN
        ) AS Users
        WHERE SDT = @SDT)
        BEGIN
            THROW 50001, 'Tài khoản không tồn tại', 1;
        END

        -- Xóa tài khoản
        DELETE FROM NHANVIEN WHERE SDT = @SDT;
        DELETE FROM NHASI WHERE SDT = @SDT;
        DELETE FROM BENHNHAN WHERE SDT = @SDT;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Nếu xảy ra lỗi, rollback transaction
        ROLLBACK TRANSACTION;

        -- Giữ lại thông báo lỗi gốc
        THROW;
    END CATCH;
END;
GO

-- QTV cập nhật tình trạng thái hoạt động(khóa/kích hoạt)
CREATE PROCEDURE CapNhatTinhTrangHoatDongNhanVien
    @MaNhanVien INT,
    @TinhTrangHoatDong NVARCHAR(20)
AS
BEGIN
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Kiểm tra xem nhân viên có tồn tại hay không
        IF NOT EXISTS (SELECT * FROM NHANVIEN WHERE MaNhanVien = @MaNhanVien)
        BEGIN
            THROW 50001, 'Nhân viên không tồn tại', 1;
        END

        -- Cập nhật tình trạng hoạt động của nhân viên
        UPDATE NHANVIEN
        SET TinhTrangHoatDong = @TinhTrangHoatDong
        WHERE MaNhanVien = @MaNhanVien;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Nếu xảy ra lỗi, rollback transaction
        ROLLBACK TRANSACTION;

        -- Giữ lại thông báo lỗi gốc
        THROW;
    END CATCH;
END;
go

--Nha sĩ ghi nhận hồ sơ bệnh án
CREATE PROCEDURE CapNhatHoSoBenhAn
    @STT int,
    @MaBenhNhan INT,
    @MaNhaSiKham INT,
    @GhiChu NVARCHAR(50),
    @MaThuoc INT,
    @NgaySuDung DATETIME,
    @NgayHetHan DATETIME,
    @LieuDung NVARCHAR(50),
    @SoLuong INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRANSACTION;

    BEGIN TRY
        -- Kiểm tra xem bệnh nhân có tồn tại hay không
        IF NOT EXISTS (SELECT * FROM LICHSUKHAMBENH WHERE MaBenhNhan = @MaBenhNhan AND STT = @STT)
        BEGIN
            THROW 50001, 'Hồ sơ khám bệnh không tồn tại', 1;
        END

        -- Cập nhật thông tin lịch sử khám bệnh
        UPDATE LICHSUKHAMBENH
        SET GhiChu = @GhiChu,
            NgayKham = GETDATE()
        WHERE MaBenhNhan = @MaBenhNhan AND STT = @STT;

        -- Thêm đơn thuốc
        INSERT INTO DONTHUOC
                (@MaThuoc, @MaBenhNhan, @NgaySuDung, @NgayHetHan, @LieuDung, @STT, @SoLuong)
            SELECT @MaThuoc, @MaBenhNhan, @NgayGioKham, DATEADD(month, 1, GETDATE()), 'Lieu dung', @STT, 1
            FROM THUOC
            WHERE SoLuongTonKho > 0 AND NgayHetHan > GETDATE();

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Nếu xảy ra lỗi, rollback transaction
        ROLLBACK TRANSACTION;

        -- Giữ lại thông báo lỗi gốc
        THROW;
    END CATCH;
END;
GO

--Lập hóa đơn thanh toán
CREATE PROCEDURE LapHoaDonThanhToan
    @STTLichSuKB int
AS
BEGIN
    BEGIN TRANSACTION;
    
    DECLARE @MaBenhNhan int;
    DECLARE @MaPhieuDVSD int;
    DECLARE @TongTien int;
    DECLARE @MaDonThuoc int;
	DECLARE @MaHoaDon int;
    
    IF NOT EXISTS (SELECT 1 FROM LICHSUKHAMBENH WHERE STT = @STTLichSuKB)
    BEGIN
        RAISERROR('Không tìm thấy STTLichSuKB', 16, 1);
        ROLLBACK;
        RETURN;
    END
    
    -- Lấy thông tin mã bệnh nhân từ bảng LICHSUKHAMBENH
    SELECT @MaBenhNhan = MaBenhNhan
    FROM LICHSUKHAMBENH
    WHERE STT = @STTLichSuKB;
    
    -- Lấy thông tin mã phiếu dịch vụ sử dụng từ bảng DICHVUSUDUNG
    SELECT @MaPhieuDVSD = MaPhieuDVSD
    FROM DICHVUSUDUNG
    WHERE STTLichSuKB = @STTLichSuKB;
    
    -- Tính tổng tiền từ bảng DONTHUOC và DICHVUSUDUNG
    SELECT @TongTien = SUM(DT.SoLuong * T.DonGia) + SUM(DV.SoLuong * D.DonGia)
    FROM DONTHUOC DT
    INNER JOIN THUOC T ON DT.MaThuoc = T.MaThuoc
    LEFT JOIN DICHVUSUDUNG DV ON DT.STTLichSuKB = DV.STTLichSuKB
    LEFT JOIN DICHVU D ON DV.MaDichVu = D.MaDichVu
    WHERE DT.STTLichSuKB = @STTLichSuKB;

    -- Lấy mã hóa đơn mới
    SET @MaHoaDon = SCOPE_IDENTITY();
    
    -- Thêm hóa đơn vào bảng HOADON
    INSERT INTO HOADON (MaBenhNhan, STTLichSuKB, MaPhieuDVSD, TongTien, TinhTrangThanhToan, NgayThanhToan, MaDonThuoc)
	VALUES (@MaBenhNhan, @STTLichSuKB, @MaPhieuDVSD, @TongTien, N'Chưa thanh toán', GETDATE(), @MaDonThuoc);

    -- Commit transaction
    COMMIT TRANSACTION;
    
    -- Trả về thông tin mã hóa đơn mới
    SELECT @MaHoaDon AS MaHoaDon;
END

