-- ============================================================
-- QUERY SQL SERVER
-- Sistem Informasi Pendataan Pengunjung & Peminjaman Buku
-- Program Studi Teknologi Informasi - UMY
-- ============================================================

SELECT u.id_user, u.username, p.id_pengunjung, p.nik, p.nama_lengkap, p.no_hp, p.email
FROM Pengguna u
JOIN PENGUNJUNG p ON u.id_user = p.id_user

select * from Pengguna;
select * from PEMINJAMAN;

SELECT * FROM PEMINJAMAN WHERE status = 'menunggu';

DELETE FROM Pengguna 
WHERE id_user= '10';

-- Buat dan gunakan database
CREATE DATABASE db_perpustakaan;
USE db_perpustakaan;

DROP TABLE Pengguna;
DROP TABLE PENGUNJUNG;
DROP TABLE ADMIN;
DROP TABLE BUKU;
DROP TABLE PEMINJAMAN;
DROP TABLE PENGEMBALIAN;
DROP TABLE LAPORAN;

-- ============================================================
-- 1. TABEL USER (tabel induk semua pengguna)
-- ============================================================
CREATE TABLE Admin (
    id_user     INT IDENTITY(1,1) PRIMARY KEY,
    username    VARCHAR(100)    NOT NULL,
    password    VARCHAR(255)    NOT NULL,
    role        VARCHAR(20)     NOT NULL CHECK (role IN ('admin')),
    created_at  DATETIME        NOT NULL DEFAULT GETDATE()
);

EXEC sp_rename 'Pengguna', 'AD';

select * from Pengguna;

-- ============================================================
-- 2. TABEL PENGUNJUNG
-- ============================================================
ALTER TABLE PENGUNJUNG
ADD perguruan VARCHAR(100) NULL;

CREATE TABLE PENGUNJUNG (
    id_pengunjung   INT IDENTITY(1,1) PRIMARY KEY,
    id_user         INT             NOT NULL,
	nik          VARCHAR(20)     NULL,
    nama_lengkap VARCHAR(100)    NULL,
    no_hp        VARCHAR(15)     NULL,
    email        VARCHAR(100)    NULL,
	perguruan    VARCHAR(100)    NULL,
    CONSTRAINT FK_Pengunjung_User FOREIGN KEY (id_user)
        REFERENCES Admin(id_user) ON DELETE CASCADE

		ALTER TABLE PENGUNJUNG 
ALTER COLUMN id_user INT NULL;
);

-- ============================================================
-- 3. TABEL BUKU
-- ============================================================
CREATE TABLE BUKU (
    id_buku         INT IDENTITY(1,1) PRIMARY KEY,
    kode_buku       VARCHAR(20)     NOT NULL UNIQUE,
    judul           VARCHAR(200)    NOT NULL,
    pengarang       VARCHAR(100)    NOT NULL,
    penerbit        VARCHAR(100)    NULL,
    tahun_terbit    INT             NULL,
    kategori        VARCHAR(50)     NULL,
    stok_tersedia   INT             NOT NULL DEFAULT 1,
	lokasi          VARCHAR(50)     NULL,
);

ALTER TABLE BUKU
ADD CONSTRAINT CK_Buku_Kategori 
CHECK (kategori IN ('Fiksi', 'Non-Fiksi'));

select * from BUKU;

SELECT COUNT(*) AS jumlah_peminjaman_aktif 
FROM PEMINJAMAN p
JOIN BUKU b ON p.id_buku = b.id_buku;
-- ============================================================
-- 4. TABEL PEMINJAMAN
-- ============================================================
CREATE TABLE PEMINJAMAN (
    id_peminjaman       INT IDENTITY(1,1) PRIMARY KEY,
    id_pengunjung       INT             NOT NULL,
    id_user            INT             NULL,
    id_buku             INT             NOT NULL,
    tanggal_ajuan       DATETIME        NOT NULL DEFAULT GETDATE(),
    tanggal_disetujui   DATETIME        NULL,
    tanggal_pinjam      DATETIME        NULL,
    tanggal_jatuh_tempo DATETIME        NULL,
    status              VARCHAR(30)     NOT NULL DEFAULT 'menunggu'
                        CHECK (status IN ('menunggu', 'disetujui', 'ditolak', 'dipinjam', 'selesai')),
    alasan_tolak        VARCHAR(255)    NULL,
    CONSTRAINT FK_Peminjaman_Admin FOREIGN KEY (id_user)
        REFERENCES ADMIN(id_user),
    CONSTRAINT FK_Peminjaman_Buku FOREIGN KEY (id_buku)
        REFERENCES BUKU(id_buku)

		ALTER TABLE PENGEMBALIAN
DROP CONSTRAINT CK__PENGEMBAL__statu__369C13AA;

ALTER TABLE PENGEMBALIAN
ADD CONSTRAINT CK_Pengembalian_Status
CHECK (status IN ('menunggu', 'diverifikasi', 'ditolak', 'selesai'));
);

select * from PEMINJAMAN;



-- ============================================================
-- 5. TABEL PENGEMBALIAN
-- ============================================================
CREATE TABLE PENGEMBALIAN (
    id_pengembalian INT IDENTITY(1,1) PRIMARY KEY,
    id_peminjaman   INT             NOT NULL UNIQUE,
    id_user        INT             NULL,
    tanggal_ajuan   DATETIME        NOT NULL DEFAULT GETDATE(),
    tanggal_kembali DATETIME        NULL,
    kondisi_buku    VARCHAR(50)     NULL DEFAULT 'baik'
                    CHECK (kondisi_buku IN ('baik', 'rusak ringan', 'rusak berat', 'hilang')),
    denda           DECIMAL(10,2)   NOT NULL DEFAULT 0,
    status          VARCHAR(20)     NOT NULL DEFAULT 'menunggu'
                    CHECK (status IN ('menunggu', 'diverifikasi', 'ditolak')),
    catatan         VARCHAR(255)    NULL,
	CONSTRAINT FK_Pengembalian_Peminjaman FOREIGN KEY (id_peminjaman) REFERENCES PEMINJAMAN(id_peminjaman),
    CONSTRAINT FK_Pengembalian_Admin FOREIGN KEY (id_user) REFERENCES Admin(id_user),
);

-- ============================================================
-- 6. TABEL LAPORAN
-- ============================================================
CREATE TABLE LAPORAN (
    id_laporan          INT IDENTITY(1,1) PRIMARY KEY,
    id_user           INT             NOT NULL,
    periode             VARCHAR(20)     NOT NULL,  -- contoh: '2026-04'
    total_kunjungan     INT             NOT NULL DEFAULT 0,
    total_peminjaman    INT             NOT NULL DEFAULT 0,
    total_pengembalian  INT             NOT NULL DEFAULT 0,
    total_denda         DECIMAL(10,2)   NOT NULL DEFAULT 0,
    generated_at        DATETIME        NOT NULL DEFAULT GETDATE(),
	CONSTRAINT FK_Laporan_User FOREIGN KEY (id_user) 
        REFERENCES Admin(id_user)
);



-- ===========================================================================================================


SELECT *
INTO BUKU_BACKUP
FROM BUKU;


TRUNCATE TABLE BUKU_BACKUP;

INSERT INTO BUKU_BACKUP
SELECT * FROM BUKU;
-- ========================================================================================================


CREATE PROCEDURE sp_AjukanPeminjamanLengkap  -- SELECT (Form Pinjam)
    @id_user INT = NULL,
    @nik VARCHAR(20),
    @nama_lengkap VARCHAR(100),
    @no_hp VARCHAR(15),
    @email VARCHAR(100),
    @perguruan VARCHAR(100),
    @id_buku INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @id_pengunjung INT;

    -- Cek apakah pengunjung sudah ada
    SELECT @id_pengunjung = id_pengunjung
    FROM PENGUNJUNG
    WHERE nik = @nik;

    -- Jika belum ada, insert pengunjung baru
    IF @id_pengunjung IS NULL
    BEGIN
        INSERT INTO PENGUNJUNG
        (id_user, nik, nama_lengkap, no_hp, email, perguruan)
        VALUES
        (@id_user, @nik, @nama_lengkap, @no_hp, @email, @perguruan);

        SET @id_pengunjung = SCOPE_IDENTITY();
    END

    -- Cek stok buku
    IF EXISTS (
        SELECT 1
        FROM BUKU
        WHERE id_buku = @id_buku
        AND stok_tersedia > 0
    )
    BEGIN
        INSERT INTO PEMINJAMAN
        (id_pengunjung, id_buku, tanggal_ajuan, status)
        VALUES
        (@id_pengunjung, @id_buku, GETDATE(), 'menunggu');
    END
    ELSE
    BEGIN
        RAISERROR('Stok buku habis.',16,1);
    END
END;



CREATE OR ALTER PROCEDURE sp_AjukanPeminjamanLengkap
    @id_user INT = NULL,
    @nik VARCHAR(20),
    @nama_lengkap VARCHAR(100),
    @no_hp VARCHAR(15),
    @email VARCHAR(100),
    @perguruan VARCHAR(100),
    @id_buku INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @id_pengunjung INT;
    DECLARE @jumlah_aktif INT;

    -- ✅ T-SQL: Cek apakah pengunjung punya peminjaman aktif lebih dari 2
    SELECT @id_pengunjung = id_pengunjung
    FROM PENGUNJUNG WHERE nik = @nik;

    IF @id_pengunjung IS NOT NULL
    BEGIN
        SELECT @jumlah_aktif = COUNT(*)
        FROM PEMINJAMAN
        WHERE id_pengunjung = @id_pengunjung
          AND status IN ('menunggu', 'disetujui', 'dipinjam');

        IF @jumlah_aktif >= 2
        BEGIN
            RAISERROR('Pengunjung sudah memiliki 2 peminjaman aktif. Selesaikan dulu sebelum meminjam lagi.', 16, 1);
            RETURN;
        END
    END

    -- Insert pengunjung baru jika belum ada
    IF @id_pengunjung IS NULL
    BEGIN
        INSERT INTO PENGUNJUNG (id_user, nik, nama_lengkap, no_hp, email, perguruan)
        VALUES (@id_user, @nik, @nama_lengkap, @no_hp, @email, @perguruan);
        SET @id_pengunjung = SCOPE_IDENTITY();
    END

    -- ✅ T-SQL: Cek stok dengan IF-ELSE
    IF EXISTS (SELECT 1 FROM BUKU WHERE id_buku = @id_buku AND stok_tersedia > 0)
    BEGIN
        INSERT INTO PEMINJAMAN (id_pengunjung, id_buku, tanggal_ajuan, status)
        VALUES (@id_pengunjung, @id_buku, GETDATE(), 'menunggu');
    END
    ELSE
    BEGIN
        RAISERROR('Stok buku habis atau buku tidak ditemukan.', 16, 1);
    END
END;






CREATE VIEW vw_DaftarBuku -- VIEW (Form CariBuku)
AS
SELECT
    id_buku,
    kode_buku,
    judul,
    pengarang,
    penerbit,
    tahun_terbit,
    kategori,
    stok_tersedia,
    lokasi
FROM BUKU;



CREATE VIEW vw_BukuDipinjamPengunjung -- VIEW (From BukuDipinjamPengunjung)
AS
SELECT 
    pm.id_peminjaman,
    b.kode_buku AS Kode_Buku,
    b.judul AS Judul_Buku,
    b.pengarang AS Pengarang,
    pm.tanggal_pinjam AS Tanggal_Pinjam,
    pm.tanggal_jatuh_tempo AS Jatuh_Tempo,
    DATEDIFF(DAY, GETDATE(), pm.tanggal_jatuh_tempo) AS Sisa_Hari,
    pm.status AS Status
FROM PEMINJAMAN pm
JOIN PENGUNJUNG p ON pm.id_pengunjung = p.id_pengunjung
JOIN BUKU b ON pm.id_buku = b.id_buku
WHERE pm.status IN ('dipinjam', 'disetujui');



CREATE PROCEDURE sp_SearchBuku -- SEARCH (Form CariBuku)
    @keyword VARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        id_buku,
        kode_buku,
        judul,
        pengarang,
        penerbit,
        tahun_terbit,
        kategori,
        stok_tersedia,
        lokasi
    FROM BUKU
    WHERE
        judul LIKE '%' + @keyword + '%'
        OR pengarang LIKE '%' + @keyword + '%'
        OR kategori LIKE '%' + @keyword + '%'
        OR kode_buku LIKE '%' + @keyword + '%'
    ORDER BY judul ASC
END


CREATE VIEW vw_DetailBuku -- VIEW (Form DetailBuku)
AS
SELECT
    id_buku,
    kode_buku,
    judul,
    pengarang,
    penerbit,
    tahun_terbit,
    kategori,
    stok_tersedia,
    lokasi
FROM BUKU;



CREATE VIEW vw_AdminDaftarBuku -- VIEW (Form Admin)
AS
SELECT
    id_buku,
    kode_buku,
    judul,
    pengarang,
    penerbit,
    tahun_terbit,
    kategori,
    stok_tersedia,
    lokasi
FROM BUKU;



CREATE PROCEDURE sp_SearchAdminBuku -- SEARCH (Form Admin)
    @keyword VARCHAR(200)
AS
BEGIN
    SELECT *
    FROM vw_AdminDaftarBuku
    WHERE
        judul LIKE '%' + @keyword + '%'
        OR pengarang LIKE '%' + @keyword + '%'
        OR kategori LIKE '%' + @keyword + '%'
        OR kode_buku LIKE '%' + @keyword + '%'
END



CREATE PROCEDURE sp_DeleteBuku -- Delete (Form Admin)
    @id_buku INT
AS
BEGIN
    DELETE FROM BUKU
    WHERE id_buku = @id_buku
END


CREATE VIEW vw_BukuSedangDipinjam -- VIEW (Form Admin)
AS
SELECT
    id_buku,
    status
FROM PEMINJAMAN
WHERE status IN ('menunggu', 'disetujui', 'dipinjam');


CREATE VIEW vw_EditBuku -- VIEW (Form EditBuku)
AS
SELECT
    id_buku,
    kode_buku,
    judul,
    pengarang,
    penerbit,
    tahun_terbit,
    kategori,
    stok_tersedia,
    lokasi
FROM BUKU;





CREATE VIEW vw_LaporanPeminjaman AS -- VIEW (Form CetakLaporan)
SELECT
    pm.id_peminjaman,
    pjg.nama_lengkap AS nama_pengunjung,
    b.judul AS judul_buku,
    b.kode_buku,
    pm.tanggal_pinjam,
    pgb.tanggal_kembali,
    ISNULL(pgb.kondisi_buku, '-') AS kondisi_buku,
    ISNULL(pgb.denda, 0) AS denda,
    pm.status,

    CASE 
        WHEN pm.status = 'ditolak' 
        THEN pm.alasan_tolak
        ELSE ISNULL(pgb.catatan, '-')
    END AS catatan

FROM PEMINJAMAN pm
JOIN PENGUNJUNG pjg ON pm.id_pengunjung = pjg.id_pengunjung
JOIN BUKU b ON pm.id_buku = b.id_buku
LEFT JOIN PENGEMBALIAN pgb 
    ON pm.id_peminjaman = pgb.id_peminjaman;






CREATE VIEW vw_TotalLaporan AS -- VIEW (Form TotalLaporan)
SELECT 
    FORMAT(GETDATE(), 'MMMM yyyy') AS periode_tampil,
    FORMAT(GETDATE(), 'yyyy-MM') AS periode_simpan,

    (SELECT COUNT(*) 
     FROM PEMINJAMAN 
     WHERE status = 'selesai') AS total_kunjungan,

    (SELECT COUNT(*) 
     FROM PEMINJAMAN) AS total_peminjaman,

    (SELECT COUNT(*) 
     FROM PENGEMBALIAN) AS total_pengembalian,

    (SELECT ISNULL(SUM(denda), 0) 
     FROM PENGEMBALIAN) AS total_denda;




CREATE PROCEDURE sp_SimpanLaporan -- INSERT (Form TotalLaporan)
    @id_user INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @periode VARCHAR(20),
            @total_kunjungan INT,
            @total_peminjaman INT,
            @total_pengembalian INT,
            @total_denda DECIMAL(10,2);

    SELECT
        @periode = periode_simpan,
        @total_kunjungan = total_kunjungan,
        @total_peminjaman = total_peminjaman,
        @total_pengembalian = total_pengembalian,
        @total_denda = total_denda
    FROM vw_TotalLaporan;

    IF EXISTS (SELECT 1 FROM LAPORAN WHERE periode = @periode)
    BEGIN
        DELETE FROM LAPORAN WHERE periode = @periode;
    END

    INSERT INTO LAPORAN
    (
        id_user,
        periode,
        total_kunjungan,
        total_peminjaman,
        total_pengembalian,
        total_denda
    )
    VALUES
    (
        @id_user,
        @periode,
        @total_kunjungan,
        @total_peminjaman,
        @total_pengembalian,
        @total_denda
    );
END

SELECT * FROM vw_LaporanPeminjaman



CREATE PROCEDURE sp_Report
    @inStatus VARCHAR(30) = NULL,   -- Filter status (opsional)
    @inTahun INT = NULL             -- Filter tahun (opsional)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        p.id_peminjaman AS idpeminjaman,
        pg.nama_lengkap AS namalengkap,
        b.judul AS judulbuku,
        b.kode_buku AS kodebuku,
        p.tanggal_pinjam AS tanggaldipinjam,
        ISNULL(peng.tanggal_kembali, '-') AS tanggalkembali,
        ISNULL(peng.kondisi_buku, '-') AS kondisibuku,
        p.status
    FROM PEMINJAMAN p
    INNER JOIN PENGUNJUNG pg ON p.id_pengunjung = pg.id_pengunjung
    INNER JOIN BUKU b ON p.id_buku = b.id_buku
    LEFT JOIN PENGEMBALIAN peng ON p.id_peminjaman = peng.id_peminjaman
    WHERE 1 = 1
        AND (@inStatus IS NULL OR p.status = @inStatus)
        AND (@inTahun IS NULL OR YEAR(p.tanggal_ajuan) = @inTahun)
    ORDER BY p.tanggal_ajuan DESC;
END


CREATE OR ALTER PROCEDURE sp_Report
    @inStatus VARCHAR(30) = NULL,
    @inTahun INT = NULL,
    @Keyword NVARCHAR(100) = NULL,          -- Tambahan untuk txtCari
    @TanggalDipinjam DATE = NULL            -- Tambahan untuk dtpTanggalDipinjam
AS
BEGIN
    SET NOCOUNT ON;

SELECT
    p.id_peminjaman     AS IdPeminjaman,
    pg.nama_lengkap     AS NamaLengkap,
    b.judul             AS JudulBuku,
    b.kode_buku         AS KodeBuku,
    p.tanggal_pinjam    AS TanggalDipinjam,
    ISNULL(CONVERT(VARCHAR(20), peng.tanggal_kembali, 103), '-') AS TanggalKembali,
    ISNULL(peng.kondisi_buku, '-') AS KondisiBuku,
    p.status            AS Status
FROM PEMINJAMAN p
-- ... sisa WHERE tetap sama
    INNER JOIN PENGUNJUNG pg ON p.id_pengunjung = pg.id_pengunjung
    INNER JOIN BUKU b ON p.id_buku = b.id_buku
    LEFT JOIN PENGEMBALIAN peng ON p.id_peminjaman = peng.id_peminjaman
    WHERE 1 = 1
        AND (@inStatus IS NULL OR p.status = @inStatus)
        AND (@inTahun IS NULL OR YEAR(p.tanggal_ajuan) = @inTahun)
        
        -- Filter Keyword (Nama atau Judul Buku)
        AND (@Keyword IS NULL 
             OR pg.nama_lengkap LIKE '%' + @Keyword + '%' 
             OR b.judul LIKE '%' + @Keyword + '%')
        
        -- Filter Tanggal Dipinjam
        AND (@TanggalDipinjam IS NULL 
             OR CAST(p.tanggal_pinjam AS DATE) = @TanggalDipinjam)

    ORDER BY p.tanggal_ajuan DESC;
END

EXEC sp_Report NULL, NULL, NULL, NULL






CREATE OR ALTER PROCEDURE sp_DeleteBuku
    @id_buku INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Cek apakah masih ada peminjaman aktif
    IF EXISTS (
        SELECT 1 FROM PEMINJAMAN 
        WHERE id_buku = @id_buku 
        AND status IN ('menunggu', 'disetujui', 'dipinjam')
    )
    BEGIN
        RAISERROR('Buku tidak dapat dihapus karena sedang dalam proses peminjaman aktif.', 16, 1);
        RETURN;
    END

    -- Hapus pengembalian yang terkait riwayat peminjaman buku ini
    DELETE FROM PENGEMBALIAN
    WHERE id_peminjaman IN (
        SELECT id_peminjaman FROM PEMINJAMAN WHERE id_buku = @id_buku
    );

    -- Hapus riwayat peminjaman (yang sudah selesai/ditolak)
    DELETE FROM PEMINJAMAN WHERE id_buku = @id_buku;

    -- Baru hapus buku
    DELETE FROM BUKU WHERE id_buku = @id_buku;
END






---------------------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE sp_AjukanPeminjamanLengkap
    @id_user INT = NULL,
    @nik VARCHAR(20),
    @nama_lengkap VARCHAR(100),
    @no_hp VARCHAR(15),
    @email VARCHAR(100),
    @perguruan VARCHAR(100),
    @id_buku INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @id_pengunjung INT;
    DECLARE @jumlah_aktif INT;

    -- ✅ T-SQL: Cek apakah pengunjung punya peminjaman aktif lebih dari 2
    SELECT @id_pengunjung = id_pengunjung
    FROM PENGUNJUNG WHERE nik = @nik;

    IF @id_pengunjung IS NOT NULL
    BEGIN
        SELECT @jumlah_aktif = COUNT(*)
        FROM PEMINJAMAN
        WHERE id_pengunjung = @id_pengunjung
          AND status IN ('menunggu', 'disetujui', 'dipinjam');

        IF @jumlah_aktif >= 2
        BEGIN
            RAISERROR('Pengunjung sudah memiliki 2 peminjaman aktif. Selesaikan dulu sebelum meminjam lagi.', 16, 1);
            RETURN;
        END
    END

    -- Insert pengunjung baru jika belum ada
    IF @id_pengunjung IS NULL
    BEGIN
        INSERT INTO PENGUNJUNG (id_user, nik, nama_lengkap, no_hp, email, perguruan)
        VALUES (@id_user, @nik, @nama_lengkap, @no_hp, @email, @perguruan);
        SET @id_pengunjung = SCOPE_IDENTITY();
    END

    -- ✅ T-SQL: Cek stok dengan IF-ELSE
    IF EXISTS (SELECT 1 FROM BUKU WHERE id_buku = @id_buku AND stok_tersedia > 0)
    BEGIN
        INSERT INTO PEMINJAMAN (id_pengunjung, id_buku, tanggal_ajuan, status)
        VALUES (@id_pengunjung, @id_buku, GETDATE(), 'menunggu');
    END
    ELSE
    BEGIN
        RAISERROR('Stok buku habis atau buku tidak ditemukan.', 16, 1);
    END
END;


CREATE PROCEDURE sp_UpdateBuku -- UPDATE (Form EditBuku
    @idBuku INT,
    @kode VARCHAR(20),
    @judul VARCHAR(200),
    @pengarang VARCHAR(100),
    @penerbit VARCHAR(100),
    @tahun INT,
    @kategori VARCHAR(50),
    @stokTersedia INT,
    @lokasi VARCHAR(50)
AS
BEGIN
    UPDATE BUKU
    SET
        kode_buku = @kode,
        judul = @judul,
        pengarang = @pengarang,
        penerbit = @penerbit,
        tahun_terbit = @tahun,
        kategori = @kategori,
        stok_tersedia = @stokTersedia,
        lokasi = @lokasi
    WHERE id_buku = @idBuku
END



CREATE PROCEDURE sp_TambahBuku
    @kode_buku VARCHAR(20),
    @judul VARCHAR(200),
    @pengarang VARCHAR(100),
    @penerbit VARCHAR(100) = NULL,
    @tahun_terbit INT = NULL,
    @kategori VARCHAR(50),
    @stok_tersedia INT,
    @lokasi VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Validasi kode buku unik
    IF EXISTS (SELECT 1 FROM BUKU WHERE kode_buku = @kode_buku)
    BEGIN
        RAISERROR('Kode buku sudah ada!', 16, 1);
        RETURN;
    END

    -- Validasi stok
    IF @stok_tersedia < 0
    BEGIN
        RAISERROR('Stok tidak boleh negatif!', 16, 1);
        RETURN;
    END

    INSERT INTO BUKU
    (
        kode_buku,
        judul,
        pengarang,
        penerbit,
        tahun_terbit,
        kategori,
        stok_tersedia,
        lokasi
    )
    VALUES
    (
        @kode_buku,
        @judul,
        @pengarang,
        @penerbit,
        @tahun_terbit,
        @kategori,
        @stok_tersedia,
        @lokasi
    );
END

-- T-SQL diletakkan di Stored Procedure karena validasi dilakukan di sisi database, 
-- bukan di aplikasi. Ini mencegah data tidak valid masuk ke database meskipun aplikasi dilewati langsung.



CREATE OR ALTER TRIGGER trg_KurangiStokBuku
ON PEMINJAMAN
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Saat status berubah menjadi 'dipinjam', kurangi stok
    IF EXISTS (
        SELECT 1 FROM inserted i
        JOIN deleted d ON i.id_peminjaman = d.id_peminjaman
        WHERE i.status = 'dipinjam' AND d.status != 'dipinjam'
    )
    BEGIN
        UPDATE BUKU
        SET stok_tersedia = stok_tersedia - 1
        WHERE id_buku IN (
            SELECT i.id_buku
            FROM inserted i
            JOIN deleted d ON i.id_peminjaman = d.id_peminjaman
            WHERE i.status = 'dipinjam' AND d.status != 'dipinjam'
        );

        -- ✅ Cek jangan sampai stok negatif
        IF EXISTS (SELECT 1 FROM BUKU WHERE stok_tersedia < 0)
        BEGIN
            RAISERROR('Stok buku tidak mencukupi!', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
    END
END;



 CREATE OR ALTER TRIGGER trg_TambahStokKembali
ON PENGEMBALIAN
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Saat status pengembalian berubah jadi 'diverifikasi' (selesai)
    IF EXISTS (
        SELECT 1 FROM inserted i
        JOIN deleted d ON i.id_pengembalian = d.id_pengembalian
        WHERE i.status = 'diverifikasi' AND d.status != 'diverifikasi'
    )
    BEGIN
        -- Tambah stok buku
        UPDATE BUKU
        SET stok_tersedia = stok_tersedia + 1
        WHERE id_buku IN (
            SELECT pm.id_buku
            FROM inserted i
            JOIN PEMINJAMAN pm ON i.id_peminjaman = pm.id_peminjaman
            JOIN deleted d ON i.id_pengembalian = d.id_pengembalian
            WHERE i.status = 'diverifikasi' AND d.status != 'diverifikasi'
        );

        -- Update status peminjaman jadi 'selesai'
        UPDATE PEMINJAMAN
        SET status = 'selesai'
        WHERE id_peminjaman IN (
            SELECT i.id_peminjaman
            FROM inserted i
            JOIN deleted d ON i.id_pengembalian = d.id_pengembalian
            WHERE i.status = 'diverifikasi' AND d.status != 'diverifikasi'
        );
    END
END;




CREATE OR ALTER TRIGGER trg_TambahStokKembali
ON PENGEMBALIAN
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Tambah stok kecuali kondisi 'hilang'
    UPDATE BUKU
    SET stok_tersedia = stok_tersedia + 1
    WHERE id_buku IN (
        SELECT pm.id_buku
        FROM inserted i
        JOIN PEMINJAMAN pm ON i.id_peminjaman = pm.id_peminjaman
        WHERE i.kondisi_buku != 'hilang'
    );

    -- Update status peminjaman jadi 'selesai'
    UPDATE PEMINJAMAN
    SET status = 'selesai'
    WHERE id_peminjaman IN (SELECT id_peminjaman FROM inserted);
END;



-- Buat tabel log dulu
CREATE TABLE LOG_AKTIVITAS (
    id_log      INT IDENTITY(1,1) PRIMARY KEY,
    aksi        VARCHAR(50),
    keterangan  VARCHAR(255),
    waktu       DATETIME DEFAULT GETDATE()
);

-- Trigger log hapus buku
CREATE OR ALTER TRIGGER trg_LogHapusBuku
ON BUKU
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO LOG_AKTIVITAS (aksi, keterangan, waktu)
    SELECT 
        'DELETE',
        'Buku dihapus: [' + kode_buku + '] ' + judul,
        GETDATE()
    FROM deleted;
END;


select * from LOG_AKTIVITAS


USE master;

-- Aktifkan SA
ALTER LOGIN sa ENABLE;
ALTER LOGIN sa WITH PASSWORD = 'nopall946';

-- Ubah ke Mixed Mode Authentication
EXEC xp_instance_regwrite 
    N'HKEY_LOCAL_MACHINE', 
    N'Software\Microsoft\MSSQLServer\MSSQLServer',
    N'LoginMode', REG_DWORD, 2;
----------------------------------------------------------------------------------------------------------------------------------------



















select * from LAPORAN;
select * from Pengguna;
DELETE FROM Pengguna 
WHERE id_user = 5;
-- ============================================================
-- DATA AWAL (SEED DATA)
-- ============================================================

-- Admin default
INSERT INTO Admin (username, password, role)
VALUES ('Admin', 'admin123', 'admin');


-- Data buku contoh
INSERT INTO BUKU (kode_buku, judul, pengarang, penerbit, tahun_terbit, kategori, stok_tersedia, lokasi)
VALUES
    ('BK001', 'Pemrograman C# untuk Pemula', 'Agus Priyono', 'Elex Media', 2022, 'Pemrograman', 3, 'Rak A1'),
    ('BK002', 'Basis Data dengan SQL Server', 'Budi Raharjo', 'Informatika', 2021, 'Database', 2, 'Rak A2'),
    ('BK003', 'Rekayasa Perangkat Lunak', 'Roger Pressman', 'Andi Publisher', 2020, 'Software Engineering', 2, 'Rak B1'),
    ('BK004', 'Algoritma dan Pemrograman', 'Rinaldi Munir', 'Informatika', 2019, 'Algoritma', 4, 'Rak B2'),
    ('BK005', 'Jaringan Komputer', 'Andrew Tanenbaum', 'Pearson', 2021, 'Jaringan', 2, 'Rak C1'),
    ('BK006', 'Sistem Operasi Modern', 'Andrew Tanenbaum', 'Pearson', 2020, 'Sistem Operasi', 3, 'Rak C2'),
    ('BK007', 'Kecerdasan Buatan', 'Stuart Russell', 'Pearson', 2022, 'AI', 1, 'Rak D1'),
    ('BK008', 'Keamanan Sistem Informasi', 'William Stallings', 'Pearson', 2021, 'Keamanan', 2, 'Rak D2');

INSERT INTO BUKU (kode_buku, judul, pengarang, penerbit, tahun_terbit, kategori, stok_tersedia, lokasi)
VALUES
	('BK011', 'Matahari Minor', 'Tere Liye', 'Gramedia Pustaka Utama', 2021, 'Fiksi', 5, 'Rak A'),
    ('BK012', 'Sejarah Dunia yang Disembunyikan', 'Jonathan Black', 'Elex Media', 2019, 'Non-Fiksi', 4, 'Rak B'),
    ('BK013', 'Algoritma dan Struktur Data', 'Rinaldi Munir', 'Informatika', 2020, 'Non-Fiksi', 6, 'Rak E'),
    ('BK014', 'The Lord of the Rings', 'J.R.R. Tolkien', 'Gramedia', 2015, 'Fiksi', 3, 'Rak D'),
    ('BK015', 'Pendidikan Karakter', 'Doni Koesoema', 'Erlangga', 2022, 'Non-Fiksi', 7, 'Rak C');

INSERT INTO BUKU (kode_buku, judul, pengarang, penerbit, tahun_terbit, kategori, stok_total, stok_tersedia, lokasi)
VALUES
-- =========================
-- FIKSI IT
-- =========================
('BK009', 'Jejak Peretas Senja', 'Raka Mahendra', 'Nusa Digital Press', 2021, 'Fiksi IT', 4, 4, 'Rak F1'),
('BK010', 'Algoritma di Balik Hujan', 'Dian Lestari', 'Inovasi Pustaka', 2020, 'Fiksi IT', 3, 3, 'Rak F1'),
('BK011', 'Server Terakhir di Kota Tua', 'Bagas Pratama', 'Tekno Litera', 2022, 'Fiksi IT', 5, 5, 'Rak F1'),
('BK012', '404 Cinta Not Found', 'Nina Febriani', 'Nusa Digital Press', 2023, 'Fiksi IT', 4, 4, 'Rak F1'),
('BK013', 'Rahasia Source Code Merah', 'Arief Kurniawan', 'Litera Nusantara', 2021, 'Fiksi IT', 2, 2, 'Rak F1'),
('BK014', 'Malam di Pusat Data', 'Yoga Saputra', 'Tekno Litera', 2019, 'Fiksi IT', 3, 3, 'Rak F1'),
('BK015', 'Anak Magang dan Mesin AI', 'Fajar Nugroho', 'Inovasi Pustaka', 2024, 'Fiksi IT', 4, 4, 'Rak F1'),
('BK016', 'Bug di Ujung Semester', 'Sinta Maharani', 'Cakrawala Tech Books', 2022, 'Fiksi IT', 5, 5, 'Rak F1'),
('BK017', 'Firewall untuk Hati', 'Tara Wibowo', 'Litera Nusantara', 2020, 'Fiksi IT', 3, 3, 'Rak F2'),
('BK018', 'Kampus Siber Jam Nol', 'Rizky Aditya', 'Nusa Digital Press', 2023, 'Fiksi IT', 4, 4, 'Rak F2'),
('BK019', 'Skrip Rahasia dari Laboratorium 7', 'Galih Permana', 'Tekno Litera', 2021, 'Fiksi IT', 3, 3, 'Rak F2'),
('BK020', 'Login Tengah Malam', 'Mira Kinasih', 'Inovasi Pustaka', 2022, 'Fiksi IT', 4, 4, 'Rak F2'),
('BK021', 'Jaringan yang Menghilang', 'Dito Rahman', 'Cakrawala Tech Books', 2021, 'Fiksi IT', 2, 2, 'Rak F2'),
('BK022', 'Dari Terminal ke Masa Depan', 'Kevin Darmawan', 'Litera Nusantara', 2024, 'Fiksi IT', 4, 4, 'Rak F2'),
('BK023', 'Operator dan Kota Digital', 'Farhan Akbar', 'Nusa Digital Press', 2020, 'Fiksi IT', 5, 5, 'Rak F2'),
('BK024', 'Router untuk Kenangan', 'Putri Ayunda', 'Tekno Litera', 2019, 'Fiksi IT', 3, 3, 'Rak F2'),
('BK025', 'Misteri Folder Hilang', 'Ananda Putra', 'Inovasi Pustaka', 2021, 'Fiksi IT', 4, 4, 'Rak F3'),
('BK026', 'Komunitas Backend Bawah Tanah', 'Ilham Fadli', 'Cakrawala Tech Books', 2023, 'Fiksi IT', 3, 3, 'Rak F3'),
('BK027', 'Sinyal dari Node-13', 'Ayu Nirmala', 'Litera Nusantara', 2022, 'Fiksi IT', 4, 4, 'Rak F3'),
('BK028', 'Notebook Rahasia Sang Programmer', 'Rahmat Hidayat', 'Nusa Digital Press', 2020, 'Fiksi IT', 5, 5, 'Rak F3'),
('BK029', 'Serial Killer di Ruang Server', 'Bima Prakoso', 'Tekno Litera', 2021, 'Fiksi IT', 2, 2, 'Rak F3'),
('BK030', 'Cinta dalam Baris Kode', 'Larasati Dewi', 'Inovasi Pustaka', 2024, 'Fiksi IT', 4, 4, 'Rak F3'),
('BK031', 'Dokumen Enkripsi Kuno', 'Gilang Ramadhan', 'Cakrawala Tech Books', 2022, 'Fiksi IT', 3, 3, 'Rak F3'),
('BK032', 'Peta Siber Nusantara', 'Naufal Harsa', 'Litera Nusantara', 2021, 'Fiksi IT', 4, 4, 'Rak F3'),
('BK033', 'Debugging Takdir', 'Salsa Amelia', 'Nusa Digital Press', 2023, 'Fiksi IT', 5, 5, 'Rak F4'),
('BK034', 'Pahlawan Kecil di Lab Komputer', 'Reno Firmansyah', 'Tekno Litera', 2018, 'Fiksi IT', 4, 4, 'Rak F4'),
('BK035', 'Jejak Digital Aruna', 'Aruna Sasmita', 'Inovasi Pustaka', 2022, 'Fiksi IT', 3, 3, 'Rak F4'),
('BK036', 'Phantom dalam Sistem Operasi', 'Damar Surya', 'Cakrawala Tech Books', 2020, 'Fiksi IT', 2, 2, 'Rak F4'),
('BK037', 'Kota dengan Password Terkunci', 'Aldo Sapri', 'Litera Nusantara', 2021, 'Fiksi IT', 4, 4, 'Rak F4'),
('BK038', 'Jendela Biru di Monitor Lama', 'Rani Kusumawardani', 'Nusa Digital Press', 2019, 'Fiksi IT', 3, 3, 'Rak F4'),
('BK039', 'Pengintai di Balik Proxy', 'Fikri Zulfikar', 'Tekno Litera', 2023, 'Fiksi IT', 4, 4, 'Rak F4'),
('BK040', 'Mimpi Seorang Data Analyst', 'Nadya Putri', 'Inovasi Pustaka', 2024, 'Fiksi IT', 5, 5, 'Rak F4'),
('BK041', 'Tiga Hari Sebelum Server Down', 'Rafi Alamsyah', 'Cakrawala Tech Books', 2021, 'Fiksi IT', 3, 3, 'Rak F5'),
('BK042', 'Pulang Bersama Paket Data', 'Intan Pertiwi', 'Litera Nusantara', 2020, 'Fiksi IT', 4, 4, 'Rak F5'),
('BK043', 'Kloning Wajah di Kota Cerdas', 'Rama Adinata', 'Nusa Digital Press', 2022, 'Fiksi IT', 2, 2, 'Rak F5'),
('BK044', 'Sandi untuk Masa Lalu', 'Mila Kartika', 'Tekno Litera', 2021, 'Fiksi IT', 3, 3, 'Rak F5'),
('BK045', 'Terminal 5 dan Hantu Wi-Fi', 'Dewa Sanjaya', 'Inovasi Pustaka', 2019, 'Fiksi IT', 4, 4, 'Rak F5'),
('BK046', 'Robot Magang Divisi Inovasi', 'Hana Safitri', 'Cakrawala Tech Books', 2024, 'Fiksi IT', 5, 5, 'Rak F5'),
('BK047', 'Catatan Hacker Pemula', 'Iqbal Mahesa', 'Litera Nusantara', 2020, 'Fiksi IT', 4, 4, 'Rak F5'),
('BK048', 'Sore Terakhir di Startup Lama', 'Vina Melati', 'Nusa Digital Press', 2022, 'Fiksi IT', 3, 3, 'Rak F5'),
('BK049', 'Matriks Kampus Selatan', 'Bayu Pranoto', 'Tekno Litera', 2023, 'Fiksi IT', 2, 2, 'Rak F6'),
('BK050', 'Avatar untuk Ayah', 'Fira Zahra', 'Inovasi Pustaka', 2021, 'Fiksi IT', 4, 4, 'Rak F6'),
('BK051', 'Pencuri Database Nasional', 'Hendra Setiawan', 'Cakrawala Tech Books', 2022, 'Fiksi IT', 3, 3, 'Rak F6'),
('BK052', 'Kecerdasan Buatan Bernama Nara', 'Nara Kusuma', 'Litera Nusantara', 2024, 'Fiksi IT', 5, 5, 'Rak F6'),
('BK053', 'Kota yang Diatur Algoritma', 'Satrio Wicaksono', 'Nusa Digital Press', 2023, 'Fiksi IT', 4, 4, 'Rak F6'),
('BK054', 'Di Balik Kompilasi Terakhir', 'Dian Permatasari', 'Tekno Litera', 2020, 'Fiksi IT', 3, 3, 'Rak F6'),
('BK055', 'Pesan dari Cloud Tengah Malam', 'Rizal Fauzan', 'Inovasi Pustaka', 2021, 'Fiksi IT', 2, 2, 'Rak F6'),
('BK056', 'Jejak Bot di Koridor Timur', 'Tiara Maheswari', 'Cakrawala Tech Books', 2022, 'Fiksi IT', 4, 4, 'Rak F6'),
('BK057', 'Toko Buku dalam Dunia Virtual', 'Nabilah Khansa', 'Litera Nusantara', 2024, 'Fiksi IT', 5, 5, 'Rak F6'),
('BK058', 'Programmer yang Menunda Tamat', 'Ragil Pradana', 'Nusa Digital Press', 2019, 'Fiksi IT', 3, 3, 'Rak F6'),
('BK059', 'Misi Rahasia Tim Infrastruktur', 'Dimas Yudhistira', 'Tekno Litera', 2023, 'Fiksi IT', 4, 4, 'Rak F6'),
('BK060', 'Sistem yang Tak Pernah Tidur', 'Aisha Larasati', 'Inovasi Pustaka', 2022, 'Fiksi IT', 3, 3, 'Rak F6'),
('BK061', 'Orang Asing di Balik Webcam', 'Tomi Kurniadi', 'Cakrawala Tech Books', 2021, 'Fiksi IT', 2, 2, 'Rak F6'),
('BK062', 'Cerita dari Balik Keyboard Mekanik', 'Niken Ramadhani', 'Litera Nusantara', 2020, 'Fiksi IT', 4, 4, 'Rak F6'),
('BK063', 'Lompatan Quantum dan Anak TI', 'Reza Maulana', 'Nusa Digital Press', 2024, 'Fiksi IT', 5, 5, 'Rak F6'),
('BK064', 'Data Center di Bawah Laut', 'Yusuf Mahardika', 'Tekno Litera', 2023, 'Fiksi IT', 3, 3, 'Rak F6'),
('BK065', 'Paket Terakhir untuk Administrator', 'Amelinda Putri', 'Inovasi Pustaka', 2021, 'Fiksi IT', 4, 4, 'Rak F6'),
('BK066', 'Kronik Siber Anak Kos', 'Zaki Mubarak', 'Cakrawala Tech Books', 2022, 'Fiksi IT', 3, 3, 'Rak F6'),
('BK067', 'Intrusi di Hari Wisuda', 'Fauzia Rahmi', 'Litera Nusantara', 2023, 'Fiksi IT', 2, 2, 'Rak F6'),
('BK068', 'Memori yang Tak Bisa Dihapus', 'Gita Anggraini', 'Nusa Digital Press', 2024, 'Fiksi IT', 4, 4, 'Rak F6'),

-- =========================
-- NON-FIKSI IT
-- =========================
('BK100', 'Manajemen Data dan Backup', 'Taufik Akbar', 'Andi Publisher', 2021, 'Non-Fiksi IT', 3, 3, 'Rak NF3'),
('BK101', 'Pengantar Sistem Informasi', 'Novi Andriani', 'Informatika Media', 2022, 'Non-Fiksi IT', 6, 6, 'Rak NF4'),
('BK102', 'Analisis dan Perancangan Sistem', 'Zulfikar Ali', 'Tekno Edukasi', 2023, 'Non-Fiksi IT', 5, 5, 'Rak NF4'),
('BK103', 'UML untuk Pengembang Perangkat Lunak', 'Dian Sasmita', 'Andi Publisher', 2022, 'Non-Fiksi IT', 5, 5, 'Rak NF4'),
('BK104', 'Dokumentasi Kebutuhan Sistem', 'Mochammad Ilyas', 'Deepublish', 2021, 'Non-Fiksi IT', 4, 4, 'Rak NF4'),
('BK105', 'Business Process Modeling untuk TI', 'Rosa Amelia', 'Informatika Media', 2023, 'Non-Fiksi IT', 4, 4, 'Rak NF4'),
('BK106', 'Use Case dan User Story Praktis', 'Galang Pratama', 'Tekno Edukasi', 2024, 'Non-Fiksi IT', 5, 5, 'Rak NF4'),
('BK107', 'Pengujian Perangkat Lunak Dasar', 'Nina Kartika', 'Andi Publisher', 2022, 'Non-Fiksi IT', 5, 5, 'Rak NF4'),
('BK108', 'Manual Testing untuk Aplikasi Web', 'Hanif Maulana', 'Informatika Media', 2023, 'Non-Fiksi IT', 4, 4, 'Rak NF4'),
('BK109', 'Otomasi Testing dengan Selenium', 'Putra Mahesa', 'Tekno Edukasi', 2024, 'Non-Fiksi IT', 4, 4, 'Rak NF4'),
('BK110', 'Jaminan Mutu Perangkat Lunak', 'Lia Ramadhanti', 'Deepublish', 2021, 'Non-Fiksi IT', 3, 3, 'Rak NF4'),
('BK111', 'Pengantar Jaringan Komputer Praktis', 'Seno Aji', 'Andi Publisher', 2022, 'Non-Fiksi IT', 6, 6, 'Rak NF5'),
('BK112', 'TCP IP untuk Mahasiswa', 'Dina Pratiwi', 'Informatika Media', 2021, 'Non-Fiksi IT', 5, 5, 'Rak NF5'),
('BK113', 'Routing dan Switching Dasar', 'Arman Hakim', 'Tekno Edukasi', 2023, 'Non-Fiksi IT', 4, 4, 'Rak NF5'),
('BK114', 'Administrasi Jaringan Linux', 'Eko Budianto', 'Andi Publisher', 2022, 'Non-Fiksi IT', 5, 5, 'Rak NF5'),
('BK115', 'Cisco Networking untuk Pemula', 'Fikri Anwar', 'Informatika Media', 2024, 'Non-Fiksi IT', 4, 4, 'Rak NF5'),
('BK116', 'Virtualisasi Jaringan Modern', 'Mega Purnama', 'Tekno Edukasi', 2024, 'Non-Fiksi IT', 3, 3, 'Rak NF5'),
('BK117', 'Administrasi MikroTik Praktis', 'Ridho Saputra', 'Deepublish', 2023, 'Non-Fiksi IT', 4, 4, 'Rak NF5'),
('BK118', 'Wireless Networking dan Keamanannya', 'Nadia Paramita', 'Andi Publisher', 2022, 'Non-Fiksi IT', 4, 4, 'Rak NF5'),
('BK119', 'Troubleshooting Jaringan Kampus', 'Tegar Wibisono', 'Informatika Media', 2021, 'Non-Fiksi IT', 3, 3, 'Rak NF5'),
('BK120', 'Topologi dan Perencanaan LAN', 'Vero Arum', 'Tekno Edukasi', 2020, 'Non-Fiksi IT', 4, 4, 'Rak NF5'),
('BK121', 'Sistem Operasi Linux untuk Pemula', 'Joko Winarno', 'Andi Publisher', 2021, 'Non-Fiksi IT', 6, 6, 'Rak NF6'),
('BK122', 'Administrasi Windows Server', 'Rizal Tanjung', 'Informatika Media', 2023, 'Non-Fiksi IT', 4, 4, 'Rak NF6'),
('BK123', 'Konsep Kernel dan Proses', 'Niken Sari', 'Tekno Edukasi', 2022, 'Non-Fiksi IT', 4, 4, 'Rak NF6'),
('BK124', 'Manajemen File System', 'Wulan Cahyani', 'Deepublish', 2021, 'Non-Fiksi IT', 3, 3, 'Rak NF6'),
('BK125', 'Shell Scripting untuk Administrasi', 'Doni Saputro', 'Andi Publisher', 2024, 'Non-Fiksi IT', 5, 5, 'Rak NF6'),
('BK126', 'Bash dan Automasi Server', 'Salsa Putri', 'Informatika Media', 2024, 'Non-Fiksi IT', 4, 4, 'Rak NF6'),
('BK127', 'Dasar-Dasar Cloud Computing', 'Gerry Mahardika', 'Tekno Edukasi', 2023, 'Non-Fiksi IT', 6, 6, 'Rak NF6'),
('BK128', 'DevOps untuk Tim Kecil', 'Ria Kurniati', 'Deepublish', 2024, 'Non-Fiksi IT', 5, 5, 'Rak NF6'),
('BK129', 'Docker dan Containerization', 'Andra Wijaya', 'Andi Publisher', 2023, 'Non-Fiksi IT', 5, 5, 'Rak NF6'),
('BK130', 'Kubernetes untuk Infrastruktur Modern', 'Fauzan Aulia', 'Informatika Media', 2024, 'Non-Fiksi IT', 4, 4, 'Rak NF6'),
('BK131', 'Pengantar Keamanan Siber', 'Rama Kresnanda', 'Tekno Edukasi', 2022, 'Non-Fiksi IT', 6, 6, 'Rak NF7'),
('BK132', 'Etical Hacking untuk Pemula', 'Dian Kusnandar', 'Andi Publisher', 2023, 'Non-Fiksi IT', 5, 5, 'Rak NF7'),
('BK133', 'Kriptografi Modern', 'Anita Rahma', 'Informatika Media', 2022, 'Non-Fiksi IT', 4, 4, 'Rak NF7'),
('BK134', 'Keamanan Aplikasi Web', 'Faisal Damar', 'Tekno Edukasi', 2024, 'Non-Fiksi IT', 5, 5, 'Rak NF7'),
('BK135', 'Mitigasi Serangan SQL Injection', 'Rani Permata', 'Deepublish', 2023, 'Non-Fiksi IT', 4, 4, 'Rak NF7'),
('BK136', 'Digital Forensik Dasar', 'Wira Prakoso', 'Andi Publisher', 2021, 'Non-Fiksi IT', 3, 3, 'Rak NF7'),
('BK137', 'Manajemen Identitas dan Akses', 'Bunga Maharani', 'Informatika Media', 2024, 'Non-Fiksi IT', 4, 4, 'Rak NF7'),
('BK138', 'Blue Team dan Incident Response', 'Ardi Sapto', 'Tekno Edukasi', 2024, 'Non-Fiksi IT', 4, 4, 'Rak NF7'),
('BK139', 'Keamanan Jaringan Enterprise', 'Putu Arimbawa', 'Deepublish', 2022, 'Non-Fiksi IT', 3, 3, 'Rak NF7'),
('BK140', 'Audit Sistem Informasi', 'Meli Rahmadani', 'Andi Publisher', 2023, 'Non-Fiksi IT', 4, 4, 'Rak NF7'),
('BK141', 'Kecerdasan Buatan untuk Pemula', 'Roni Hapsara', 'Informatika Media', 2022, 'Non-Fiksi IT', 6, 6, 'Rak NF8'),
('BK142', 'Machine Learning Praktis', 'Dina Ayuningtyas', 'Tekno Edukasi', 2024, 'Non-Fiksi IT', 6, 6, 'Rak NF8'),
('BK143', 'Deep Learning dengan Python', 'Aldy Setiawan', 'Andi Publisher', 2024, 'Non-Fiksi IT', 5, 5, 'Rak NF8'),
('BK144', 'Data Science untuk Mahasiswa TI', 'Rifki Fadhilah', 'Informatika Media', 2023, 'Non-Fiksi IT', 5, 5, 'Rak NF8'),
('BK145', 'Pengolahan Data dengan Pandas', 'Lilis Nurhayati', 'Tekno Edukasi', 2024, 'Non-Fiksi IT', 4, 4, 'Rak NF8'),
('BK146', 'Visualisasi Data dengan Matplotlib', 'Dimas Aksara', 'Deepublish', 2023, 'Non-Fiksi IT', 4, 4, 'Rak NF8'),
('BK147', 'Statistik Dasar untuk Data Analyst', 'Rina Maharani', 'Andi Publisher', 2022, 'Non-Fiksi IT', 4, 4, 'Rak NF8'),
('BK148', 'Natural Language Processing Dasar', 'Hafidz Maulana', 'Informatika Media', 2024, 'Non-Fiksi IT', 3, 3, 'Rak NF8'),
('BK149', 'Computer Vision untuk Pemula', 'Nabila Siregar', 'Tekno Edukasi', 2024, 'Non-Fiksi IT', 4, 4, 'Rak NF8'),
('BK150', 'Membangun Model Prediksi Bisnis', 'Vina Kurnia', 'Deepublish', 2023, 'Non-Fiksi IT', 3, 3, 'Rak NF8'),
('BK151', 'Pemrograman Mobile Android Dasar', 'Asep Firmansyah', 'Andi Publisher', 2022, 'Non-Fiksi IT', 5, 5, 'Rak NF9'),
('BK152', 'Kotlin untuk Pengembang Android', 'Raisa Purnomo', 'Informatika Media', 2024, 'Non-Fiksi IT', 5, 5, 'Rak NF9'),
('BK153', 'Flutter untuk Aplikasi Multiplatform', 'Yudha Pratama', 'Tekno Edukasi', 2024, 'Non-Fiksi IT', 6, 6, 'Rak NF9'),
('BK154', 'Dart Praktis untuk Mobile App', 'Karina Dewi', 'Deepublish', 2023, 'Non-Fiksi IT', 4, 4, 'Rak NF9'),
('BK155', 'Desain UI UX untuk Aplikasi Mobile', 'Bella Kinasih', 'Andi Publisher', 2022, 'Non-Fiksi IT', 4, 4, 'Rak NF9'),
('BK156', 'Firebase untuk Pengembang Pemula', 'Guntur Haryono', 'Informatika Media', 2023, 'Non-Fiksi IT', 4, 4, 'Rak NF9'),
('BK157', 'Integrasi API pada Aplikasi Mobile', 'Shafa Ramadani', 'Tekno Edukasi', 2024, 'Non-Fiksi IT', 3, 3, 'Rak NF9'),
('BK158', 'Testing Aplikasi Android', 'Rifda Amelia', 'Deepublish', 2023, 'Non-Fiksi IT', 3, 3, 'Rak NF9'),
('BK159', 'Arsitektur MVVM di Android', 'Faris Alfarizi', 'Andi Publisher', 2024, 'Non-Fiksi IT', 4, 4, 'Rak NF9'),
('BK160', 'Publikasi Aplikasi ke Play Store', 'Nuri Anggraeni', 'Informatika Media', 2022, 'Non-Fiksi IT', 3, 3, 'Rak NF9'),
('BK161', 'Rekayasa Perangkat Lunak Agile', 'Luthfi Hanan', 'Tekno Edukasi', 2023, 'Non-Fiksi IT', 5, 5, 'Rak NF10'),
('BK162', 'Scrum untuk Tim Pengembang', 'Evi Marlina', 'Andi Publisher', 2022, 'Non-Fiksi IT', 4, 4, 'Rak NF10'),
('BK163', 'Kanban dalam Proyek TI', 'Rendy Saputra', 'Informatika Media', 2021, 'Non-Fiksi IT', 3, 3, 'Rak NF10'),
('BK164', 'Manajemen Proyek Sistem Informasi', 'Tania Prameswari', 'Tekno Edukasi', 2024, 'Non-Fiksi IT', 5, 5, 'Rak NF10'),
('BK165', 'Estimasi Waktu dan Risiko Proyek IT', 'Aji Gunawan', 'Deepublish', 2023, 'Non-Fiksi IT', 4, 4, 'Rak NF10'),
('BK166', 'Git dan GitHub untuk Kolaborasi', 'Zahra Kamilah', 'Andi Publisher', 2024, 'Non-Fiksi IT', 6, 6, 'Rak NF10'),
('BK167', 'Version Control untuk Pemula', 'Rahman Taufiq', 'Informatika Media', 2022, 'Non-Fiksi IT', 4, 4, 'Rak NF10'),
('BK168', 'CI CD untuk Deploy Modern', 'Nico Setiabudi', 'Tekno Edukasi', 2024, 'Non-Fiksi IT', 4, 4, 'Rak NF10'),
('BK169', 'Dokumentasi Teknis yang Efektif', 'Prita Savitri', 'Deepublish', 2023, 'Non-Fiksi IT', 3, 3, 'Rak NF10'),
('BK170', 'Presentasi Produk Digital', 'Yessy Handayani', 'Andi Publisher', 2021, 'Non-Fiksi IT', 3, 3, 'Rak NF10'),
('BK171', 'Dasar-Dasar Internet of Things', 'Arif Darmawan', 'Informatika Media', 2023, 'Non-Fiksi IT', 5, 5, 'Rak NF11'),
('BK172', 'Mikrokontroler untuk Sistem Cerdas', 'Hani Nurcahya', 'Tekno Edukasi', 2022, 'Non-Fiksi IT', 4, 4, 'Rak NF11'),
('BK173', 'Arduino untuk Pemula', 'Bagas Surono', 'Andi Publisher', 2021, 'Non-Fiksi IT', 5, 5, 'Rak NF11'),
('BK174', 'ESP32 dan Sensor Praktis', 'Kezia Maharani', 'Informatika Media', 2024, 'Non-Fiksi IT', 4, 4, 'Rak NF11'),
('BK175', 'Integrasi IoT dengan Cloud', 'Iqra Ramadhan', 'Tekno Edukasi', 2024, 'Non-Fiksi IT', 4, 4, 'Rak NF11'),
('BK176', 'Sistem Embedded untuk Mahasiswa', 'Randy Prabowo', 'Deepublish', 2023, 'Non-Fiksi IT', 3, 3, 'Rak NF11'),
('BK177', 'Protokol MQTT dan Implementasi', 'Nia Azzahra', 'Andi Publisher', 2024, 'Non-Fiksi IT', 3, 3, 'Rak NF11'),
('BK178', 'Pemrograman Sensor dan Aktuator', 'Hilman Setiadi', 'Informatika Media', 2023, 'Non-Fiksi IT', 4, 4, 'Rak NF11'),
('BK179', 'Smart Home Berbasis Mikrokontroler', 'Rifan Kuncoro', 'Tekno Edukasi', 2022, 'Non-Fiksi IT', 3, 3, 'Rak NF11'),
('BK180', 'Keamanan pada Perangkat IoT', 'Aulia Mardhatillah', 'Deepublish', 2024, 'Non-Fiksi IT', 4, 4, 'Rak NF11'),
('BK181', 'Dasar UI UX untuk Produk Digital', 'Maya Paramitha', 'Andi Publisher', 2022, 'Non-Fiksi IT', 5, 5, 'Rak NF12'),
('BK182', 'Riset Pengguna untuk Aplikasi', 'Fajar Akmal', 'Informatika Media', 2023, 'Non-Fiksi IT', 4, 4, 'Rak NF12'),
('BK183', 'Wireframing dan Prototyping', 'Desi Nurfadilah', 'Tekno Edukasi', 2024, 'Non-Fiksi IT', 4, 4, 'Rak NF12'),
('BK184', 'Desain Interaksi untuk Website', 'Ariella Putri', 'Deepublish', 2023, 'Non-Fiksi IT', 3, 3, 'Rak NF12'),
('BK185', 'Figma untuk Kolaborasi Tim', 'Hafizh Satrio', 'Andi Publisher', 2024, 'Non-Fiksi IT', 5, 5, 'Rak NF12'),
('BK186', 'Aksesibilitas dalam Produk Digital', 'Lana Wulandari', 'Informatika Media', 2023, 'Non-Fiksi IT', 3, 3, 'Rak NF12'),
('BK187', 'Tipografi untuk Antarmuka Digital', 'Seno Wibowo', 'Tekno Edukasi', 2022, 'Non-Fiksi IT', 3, 3, 'Rak NF12'),
('BK188', 'Warna dan Hirarki Visual UI', 'Qori Aisyah', 'Deepublish', 2024, 'Non-Fiksi IT', 3, 3, 'Rak NF12'),
('BK189', 'Desain Dashboard yang Informatif', 'Bramantyo Putra', 'Andi Publisher', 2024, 'Non-Fiksi IT', 4, 4, 'Rak NF12'),
('BK190', 'Evaluasi Heuristik Aplikasi', 'Shania Lestari', 'Informatika Media', 2023, 'Non-Fiksi IT', 3, 3, 'Rak NF12'),
('BK191', 'Dasar-Dasar Big Data', 'Rasyid Hanafiah', 'Tekno Edukasi', 2023, 'Non-Fiksi IT', 5, 5, 'Rak NF13'),
('BK192', 'Pemrosesan Data Skala Besar', 'Puspa Melati', 'Andi Publisher', 2024, 'Non-Fiksi IT', 4, 4, 'Rak NF13'),
('BK193', 'Hadoop untuk Pemula', 'Imam Syahputra', 'Informatika Media', 2022, 'Non-Fiksi IT', 3, 3, 'Rak NF13'),
('BK194', 'Spark untuk Analitik Data', 'Dhea Pramesti', 'Tekno Edukasi', 2024, 'Non-Fiksi IT', 4, 4, 'Rak NF13'),
('BK195', 'Data Warehouse dan ETL', 'Aditya Nugraha', 'Deepublish', 2023, 'Non-Fiksi IT', 4, 4, 'Rak NF13'),
('BK196', 'Business Intelligence Dasar', 'Cindy Maharani', 'Andi Publisher', 2022, 'Non-Fiksi IT', 4, 4, 'Rak NF13'),
('BK197', 'Dashboard Analitik dengan Power BI', 'Rendy Kurniawan', 'Informatika Media', 2024, 'Non-Fiksi IT', 5, 5, 'Rak NF13'),
('BK198', 'Analisis Data Penjualan Digital', 'Novianti Sari', 'Tekno Edukasi', 2023, 'Non-Fiksi IT', 3, 3, 'Rak NF13'),
('BK199', 'Dasar Statistik Terapan TI', 'Rangga Purnama', 'Deepublish', 2021, 'Non-Fiksi IT', 4, 4, 'Rak NF13'),
('BK200', 'Data Cleaning untuk Proyek Nyata', 'Pipit Oktavia', 'Andi Publisher', 2024, 'Non-Fiksi IT', 4, 4, 'Rak NF13'),
('BK201', 'Pemrograman PHP untuk Website Dinamis', 'Asep Nugroho', 'Informatika Media', 2021, 'Non-Fiksi IT', 5, 5, 'Rak NF14'),
('BK202', 'Laravel untuk Sistem Informasi', 'Riko Firmanda', 'Tekno Edukasi', 2024, 'Non-Fiksi IT', 5, 5, 'Rak NF14'),
('BK203', 'CodeIgniter untuk Pemula', 'Tami Puspitasari', 'Andi Publisher', 2022, 'Non-Fiksi IT', 4, 4, 'Rak NF14'),
('BK204', 'Membangun CMS dengan PHP', 'Ridwan Hakim', 'Deepublish', 2023, 'Non-Fiksi IT', 3, 3, 'Rak NF14'),
('BK205', 'Keamanan Login dan Session', 'Meylan Sari', 'Informatika Media', 2023, 'Non-Fiksi IT', 3, 3, 'Rak NF14'),
('BK206', 'Integrasi Payment Gateway', 'Gema Wirawan', 'Tekno Edukasi', 2024, 'Non-Fiksi IT', 3, 3, 'Rak NF14'),
('BK207', 'RESTful API dengan PHP', 'Aurel Pradipta', 'Andi Publisher', 2024, 'Non-Fiksi IT', 4, 4, 'Rak NF14'),
('BK208', 'Autentikasi dan Otorisasi Aplikasi', 'Zenia Rahma', 'Deepublish', 2022, 'Non-Fiksi IT', 3, 3, 'Rak NF14'),
('BK209', 'Deployment Website ke Hosting', 'Bimo Mahardika', 'Informatika Media', 2021, 'Non-Fiksi IT', 4, 4, 'Rak NF14'),
('BK210', 'Optimasi Performa Website', 'Syifa Nurhaliza', 'Tekno Edukasi', 2024, 'Non-Fiksi IT', 4, 4, 'Rak NF14'),
('BK211', 'Pengantar Pemrograman C untuk Embedded', 'Fachri Kurnia', 'Andi Publisher', 2022, 'Non-Fiksi IT', 4, 4, 'Rak NF15'),
('BK212', 'Pemrograman C++ Berorientasi Objek', 'M. Daffa Saputra', 'Informatika Media', 2023, 'Non-Fiksi IT', 5, 5, 'Rak NF15');

SELECT * FROM Pengguna

SELECT 
    u.id_user,
    u.username,
    u.role,
    u.created_at,
    ISNULL(p.nama_lengkap, u.nama_lengkap) AS nama_lengkap,
    ISNULL(p.no_hp, u.no_hp) AS no_hp,
    ISNULL(p.email, u.email) AS email,
    p.perguruan,
    p.nik
FROM Pengguna u
LEFT JOIN PENGUNJUNG p ON u.id_user = p.id_user
ORDER BY u.id_user DESC

SELECT * FROM LAPORAN;


-- 1. Hapus constraint foreign key lama
ALTER TABLE LAPORAN 
DROP CONSTRAINT FK_Laporan_Admin;

-- 2. Hapus kolom id_admin
ALTER TABLE LAPORAN 
DROP COLUMN id_admin;

-- 3. Tambah kolom id_user
ALTER TABLE LAPORAN 
ADD id_user INT NOT NULL;

-- 4. Tambah foreign key baru ke tabel Pengguna
ALTER TABLE LAPORAN 
ADD CONSTRAINT FK_Laporan_User 
FOREIGN KEY (id_user) REFERENCES Pengguna(id_user);