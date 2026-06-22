using System;
using System.Data;
using System.Data.SqlClient;
using System.Windows.Forms;
using ExcelDataReader;
using System.IO;

namespace ProjectAplikasiPerpustakaan
{
    public partial class Admin : Form
    {
        private readonly string namaAdmin;
        private readonly string roleAdmin;
        private readonly int idUser;

        // ✅ Pakai DAL.GetConnectionString() — satu tempat untuk semua
        private readonly string connectionString = DAL.GetConnectionString();

        private DataTable dtBuku;
        private BindingSource bsBuku = new BindingSource();

        public Admin(int idUser, string nama, string role)
        {
            InitializeComponent();
            this.namaAdmin = nama;
            this.roleAdmin = role;
            this.idUser = idUser;
        }

        public Admin()
        {
            InitializeComponent();
        }

        private void Admin_Load(object sender, EventArgs e)
        {
            this.vw_DaftarBukuTableAdapter.Fill(this.db_perpustakaanDataSet1.vw_DaftarBuku);
            this.bUKUTableAdapter.Fill(this.db_perpustakaanDataSet.BUKU);
            if (!string.IsNullOrEmpty(namaAdmin))
            {
                this.Text = $"Admin Panel - {namaAdmin}";
            }
            bindingNavigator1.BindingSource = bsBuku;
        }

        private void LoadDataBuku()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    string query = "SELECT * FROM vw_AdminDaftarBuku ORDER BY judul ASC";
                    using (SqlDataAdapter da = new SqlDataAdapter(query, conn))
                    {
                        dtBuku = new DataTable();
                        da.Fill(dtBuku);
                        bsBuku.DataSource = dtBuku;
                        dataGridView1.DataSource = bsBuku;
                    }

                    dataGridView1.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill;
                    dataGridView1.ReadOnly = true;
                    dataGridView1.AllowUserToAddRows = false;
                    dataGridView1.AllowUserToDeleteRows = false;
                    dataGridView1.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
                    dataGridView1.MultiSelect = false;

                    if (dataGridView1.Columns["id_buku"] != null)
                        dataGridView1.Columns["id_buku"].Visible = false;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Gagal memuat daftar buku:\n" + ex.Message);
            }
        }

        private void btnLoadDatabase_Click(object sender, EventArgs e)
        {
            txtCariBuku.Clear();
            LoadDataBuku();
        }

        private void btnEditBuku_Click(object sender, EventArgs e)
        {
            if (dataGridView1.SelectedRows.Count == 0)
            {
                MessageBox.Show("Pilih buku yang ingin diedit.", "Peringatan",
                    MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            int idBuku = Convert.ToInt32(dataGridView1.SelectedRows[0].Cells["id_buku"].Value);
            EditBuku formEdit = new EditBuku(idBuku);
            formEdit.ShowDialog();

            if (formEdit.DialogResult == DialogResult.OK)
                LoadDataBuku();
        }

        private void btnDaftarPengajuan_Click(object sender, EventArgs e)
        {
            try
            {
                btnKembali formPengajuan = new btnKembali(idUser, namaAdmin, roleAdmin);
                formPengajuan.ShowDialog();
                LoadDataBuku();
            }
            catch (Exception ex)
            {
                MessageBox.Show("Gagal membuka daftar pengajuan:\n" + ex.Message,
                    "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void btnLaporan_Click(object sender, EventArgs e)
        {
            try
            {
                CetakLaporan formLaporan = new CetakLaporan();
                formLaporan.ShowDialog();
            }
            catch (Exception ex)
            {
                MessageBox.Show("Gagal membuka form Laporan:\n" + ex.Message,
                    "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void btnLogout_Click(object sender, EventArgs e)
        {
            DialogResult konfirmasi = MessageBox.Show("Apakah Anda yakin ingin keluar?",
                "Konfirmasi Logout", MessageBoxButtons.YesNo, MessageBoxIcon.Question);

            if (konfirmasi == DialogResult.Yes)
            {
                LoginMenu formLogin = new LoginMenu();
                formLogin.Show();
                this.Close();
            }
        }

        private void dataGridView1_CellContentClick(object sender, DataGridViewCellEventArgs e) { }

        private void btnTambahBuku_Click(object sender, EventArgs e)
        {
            try
            {
                using (TambahBuku formTambah = new TambahBuku())
                {
                    DialogResult hasil = formTambah.ShowDialog();
                    if (hasil == DialogResult.OK)
                        LoadDataBuku();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Gagal membuka form Tambah Buku:\n" + ex.Message,
                    "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void btnHapusBuku_Click(object sender, EventArgs e)
        {
            if (dataGridView1.SelectedRows.Count == 0)
            {
                MessageBox.Show("Silakan pilih buku yang ingin dihapus terlebih dahulu.",
                    "Peringatan", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            DataGridViewRow row = dataGridView1.SelectedRows[0];
            int idBuku = Convert.ToInt32(row.Cells["id_buku"].Value);
            string kodeBuku = row.Cells["kode_buku"].Value?.ToString() ?? "-";
            string judulBuku = row.Cells["judul"].Value?.ToString() ?? "-";

            if (BukuSedangDipinjam(idBuku))
            {
                MessageBox.Show("Buku tidak dapat dihapus karena sedang dalam proses peminjaman aktif.",
                    "Tidak Dapat Dihapus", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            DialogResult konfirmasi = MessageBox.Show(
                $"Anda yakin ingin menghapus buku berikut?\n\n" +
                $"Kode Buku : {kodeBuku}\n" +
                $"Judul     : {judulBuku}\n\n" +
                "Tindakan ini tidak dapat dibatalkan!",
                "Konfirmasi Hapus Buku",
                MessageBoxButtons.YesNo,
                MessageBoxIcon.Warning);

            if (konfirmasi != DialogResult.Yes) return;

            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand("sp_DeleteBuku", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@id_buku", idBuku);
                        cmd.ExecuteNonQuery();
                        MessageBox.Show("Buku berhasil dihapus.", "Sukses",
                            MessageBoxButtons.OK, MessageBoxIcon.Information);
                        LoadDataBuku();
                    }
                }
            }
            catch (SqlException ex)
            {
                MessageBox.Show("Gagal menghapus buku:\n" + ex.Message,
                    "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            catch (Exception ex)
            {
                MessageBox.Show("Terjadi kesalahan:\n" + ex.Message,
                    "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private bool BukuSedangDipinjam(int idBuku)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    string query = @"
                        SELECT COUNT(*) FROM PEMINJAMAN 
                        WHERE id_buku = @id_buku
                        AND status IN ('menunggu', 'disetujui', 'dipinjam')";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@id_buku", idBuku);
                        return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
                    }
                }
            }
            catch { return true; }
        }

        private void CariBukuByKeyword()
        {
            string keyword = txtCariBuku.Text.Trim();
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    if (string.IsNullOrEmpty(keyword)) { LoadDataBuku(); return; }

                    using (SqlCommand cmd = new SqlCommand("sp_SearchAdminBuku", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@keyword", keyword);
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        {
                            dtBuku = new DataTable();
                            da.Fill(dtBuku);
                            bsBuku.DataSource = dtBuku;
                            dataGridView1.DataSource = bsBuku;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Gagal mencari buku:\n" + ex.Message);
            }
        }

        private void txtCariBuku_TextChanged(object sender, EventArgs e) => CariBukuByKeyword();

        private void btnCari_Click(object sender, EventArgs e)
        {
            CariBukuByKeyword();
            txtCariBuku.Focus();
        }

        private void btnTestDataInjection_Click(object sender, EventArgs e)
        {
            DialogResult konfirmasi = MessageBox.Show(
                "Jalankan simulasi SQL Injection?\nSemua data buku akan dimodifikasi.",
                "Test SQL Injection", MessageBoxButtons.YesNo, MessageBoxIcon.Warning);

            if (konfirmasi != DialogResult.Yes) return;

            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    string injectedQuery = @"
                        UPDATE BUKU SET
                            judul = 'HACKED', pengarang = 'HACKED',
                            penerbit = 'HACKED', tahun_terbit = 9999,
                            kategori = 'Fiksi', stok_tersedia = 999, lokasi = 'HACKED'";

                    using (SqlCommand cmd = new SqlCommand(injectedQuery, conn))
                    {
                        int result = cmd.ExecuteNonQuery();
                        MessageBox.Show($"{result} data berhasil dimodifikasi.",
                            "SQL Injection Berhasil", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    }
                }
                LoadDataBuku();
            }
            catch (Exception ex)
            {
                MessageBox.Show("Gagal menjalankan simulasi:\n" + ex.Message);
            }
        }

        private void btnReset_Click(object sender, EventArgs e)
        {
            DialogResult konfirmasi = MessageBox.Show("Kembalikan data buku dari backup?",
                "Restore Database", MessageBoxButtons.YesNo, MessageBoxIcon.Question);

            if (konfirmasi != DialogResult.Yes) return;

            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    string query = @"
                        UPDATE b SET
                            b.kode_buku = bb.kode_buku, b.judul = bb.judul,
                            b.pengarang = bb.pengarang, b.penerbit = bb.penerbit,
                            b.tahun_terbit = bb.tahun_terbit, b.kategori = bb.kategori,
                            b.stok_tersedia = bb.stok_tersedia, b.lokasi = bb.lokasi
                        FROM BUKU b
                        INNER JOIN BUKU_BACKUP bb ON b.id_buku = bb.id_buku";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        int result = cmd.ExecuteNonQuery();
                        MessageBox.Show($"{result} data berhasil dipulihkan.",
                            "Restore Berhasil", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    }
                }
                LoadDataBuku();
            }
            catch (Exception ex)
            {
                MessageBox.Show("Gagal restore:\n" + ex.Message);
            }
        }

        private void btnImpExcel_Click(object sender, EventArgs e)
        {
            using (OpenFileDialog ofd = new OpenFileDialog { Filter = "Excel Workbook|*.xlsx" })
            {
                if (ofd.ShowDialog() == DialogResult.OK)
                {
                    using (var stream = File.Open(ofd.FileName, FileMode.Open, FileAccess.Read))
                    using (var reader = ExcelReaderFactory.CreateReader(stream))
                    {
                        var result = reader.AsDataSet(new ExcelDataSetConfiguration()
                        {
                            ConfigureDataTable = (_) => new ExcelDataTableConfiguration()
                            { UseHeaderRow = true }
                        });

                        DataTable dt = result.Tables[0];
                        dataGridView1.DataSource = dt;
                        dataGridView1.Enabled = false;
                        btnImpDb.Enabled = true;
                        btnTambahBuku.Enabled = false;
                        btnEditBuku.Enabled = false;
                        btnHapusBuku.Enabled = false;

                        MessageBox.Show($"Preview berhasil! Total {dt.Rows.Count} data siap diimport.",
                            "Preview Excel", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    }
                }
            }
        }

        private void btnImpDb_Click(object sender, EventArgs e)
        {
            try
            {
                DataTable dt = (DataTable)dataGridView1.DataSource;
                if (dt == null || dt.Rows.Count == 0)
                {
                    MessageBox.Show("Tidak ada data untuk diimport.", "Peringatan",
                        MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }

                int sukses = 0, gagal = 0;

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    foreach (DataRow row in dt.Rows)
                    {
                        try
                        {
                            string kodeBuku = row["kode_buku"].ToString().Trim();
                            string judul = row["judul"].ToString().Trim();
                            string pengarang = row["pengarang"].ToString().Trim();
                            string penerbit = row["penerbit"].ToString().Trim();
                            string kategori = row["kategori"].ToString().Trim();
                            string lokasi = row["lokasi"].ToString().Trim();

                            if (string.IsNullOrEmpty(kodeBuku) || string.IsNullOrEmpty(judul))
                            { gagal++; continue; }

                            if (!int.TryParse(row["tahun_terbit"].ToString(), out int tahun))
                            { gagal++; continue; }

                            if (!int.TryParse(row["stok_tersedia"].ToString(), out int stok))
                            { gagal++; continue; }

                            string query = @"
                                IF NOT EXISTS (SELECT 1 FROM BUKU WHERE kode_buku = @KodeBuku)
                                BEGIN
                                    INSERT INTO BUKU (kode_buku, judul, pengarang, penerbit, tahun_terbit, kategori, stok_tersedia, lokasi)
                                    VALUES (@KodeBuku, @Judul, @Pengarang, @Penerbit, @Tahun, @Kategori, @Stok, @Lokasi)
                                END";

                            using (SqlCommand cmd = new SqlCommand(query, conn))
                            {
                                cmd.Parameters.AddWithValue("@KodeBuku", kodeBuku);
                                cmd.Parameters.AddWithValue("@Judul", judul);
                                cmd.Parameters.AddWithValue("@Pengarang", pengarang);
                                cmd.Parameters.AddWithValue("@Penerbit", penerbit);
                                cmd.Parameters.AddWithValue("@Tahun", tahun);
                                cmd.Parameters.AddWithValue("@Kategori", kategori);
                                cmd.Parameters.AddWithValue("@Stok", stok);
                                cmd.Parameters.AddWithValue("@Lokasi", lokasi);
                                cmd.ExecuteNonQuery();
                                sukses++;
                            }
                        }
                        catch { gagal++; }
                    }
                }

                MessageBox.Show($"Import selesai!\nBerhasil: {sukses}\nGagal/Skip: {gagal}",
                    "Hasil Import", MessageBoxButtons.OK, MessageBoxIcon.Information);

                dataGridView1.Enabled = true;
                btnTambahBuku.Enabled = true;
                btnEditBuku.Enabled = true;
                btnHapusBuku.Enabled = true;
                btnImpDb.Enabled = false;

                LoadDataBuku();
            }
            catch (Exception ex)
            {
                MessageBox.Show("Gagal import:\n" + ex.Message, "Error",
                    MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }
    }
}