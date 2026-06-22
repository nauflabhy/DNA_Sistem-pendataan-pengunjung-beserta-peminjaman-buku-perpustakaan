using System;
using System.Data;
using System.Data.SqlClient;
using System.Windows.Forms;

namespace ProjectAplikasiPerpustakaan
{
    public partial class CetakLaporan : Form
    {

        private BindingSource bsLaporan = new BindingSource();
        private DataTable dtLaporan;
        private readonly string connectionString = DAL.GetConnectionString();

        public CetakLaporan()
        {
            InitializeComponent();
        }

        private void CetakLaporan_Load(object sender, EventArgs e)
        {
            bindingNavigator1.BindingSource = bsLaporan;
            bsLaporan.PositionChanged += bsLaporan_PositionChanged;

            dtpTanggalDipinjam.Format = DateTimePickerFormat.Custom;
            dtpTanggalDipinjam.CustomFormat = "dd MMMM yyyy";
            dtpTanggalDipinjam.ShowUpDown = false;
            dtpTanggalDipinjam.MinDate = new DateTime(2000, 1, 1);
            dtpTanggalDipinjam.MaxDate = DateTime.Now.AddYears(10);

            // ✅ Pasang event SETELAH setup selesai
            txtCari.TextChanged += TxtCari_TextChanged;
            dtpTanggalDipinjam.ValueChanged += DtpTanggalDipinjam_ValueChanged;

            // Load awal tanpa filter tanggal
            LoadDataLaporan();  // keyword=null, tanggal=null → semua data tampil
        }

        private void TxtCari_TextChanged(object sender, EventArgs e)
        {
            LoadDataLaporan(txtCari.Text.Trim(), null); // null dulu
        }

        private void DtpTanggalDipinjam_ValueChanged(object sender, EventArgs e)
        {
            LoadDataLaporan(txtCari.Text.Trim(), dtpTanggalDipinjam.Value);
        }

        private void bsLaporan_PositionChanged(object sender, EventArgs e)
        {
            // ✅ Tambah pengecekan Position valid
            if (dgvLaporan.Rows.Count > 0
                && bsLaporan.Position >= 0
                && bsLaporan.Position < dgvLaporan.Rows.Count)
            {
                dgvLaporan.ClearSelection();
                dgvLaporan.Rows[bsLaporan.Position].Selected = true;
            }
        }

        // ================== LOAD DATA DARI STORED PROCEDURE ==================
        private void LoadDataLaporan(string keyword = null, DateTime? tanggal = null)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand("sp_Report", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;

                        // Ganti baris AddWithValue sebelumnya dengan ini:

                        // Misal @inStatus itu VARCHAR
                        cmd.Parameters.Add(new SqlParameter("@inStatus", SqlDbType.VarChar) { Value = DBNull.Value });

                        // Misal @inTahun itu INT atau VARCHAR (sesuaikan dengan isi Stored Procedure)
                        cmd.Parameters.Add(new SqlParameter("@inTahun", SqlDbType.Int) { Value = DBNull.Value });

                        // Parameter Keyword
                        cmd.Parameters.AddWithValue("@Keyword", (object)keyword ?? DBNull.Value);

                        // === PERBAIKAN UTAMA ===
                        SqlParameter paramTanggal = new SqlParameter("@TanggalDipinjam", SqlDbType.Date);
                        paramTanggal.Value = (object)tanggal?.Date ?? DBNull.Value;
                        cmd.Parameters.Add(paramTanggal);

                        using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
                        {
                            dtLaporan = new DataTable();
                            dtLaporan.TableName = "LaporanPeminjaman";
                            adapter.Fill(dtLaporan);

                            bsLaporan.DataSource = dtLaporan;
                            dgvLaporan.DataSource = bsLaporan;

                            // Format kolom ...
                            if (dgvLaporan.Columns.Count > 0)
                            {
                                // kode format kolom kamu tetap sama
                                dgvLaporan.Columns["idpeminjaman"].HeaderText = "ID Peminjaman";
                                dgvLaporan.Columns["namalengkap"].HeaderText = "Nama Lengkap";
                                dgvLaporan.Columns["judulbuku"].HeaderText = "Judul Buku";
                                dgvLaporan.Columns["kodebuku"].HeaderText = "Kode Buku";
                                dgvLaporan.Columns["tanggaldipinjam"].HeaderText = "Tanggal Dipinjam";
                                dgvLaporan.Columns["tanggalkembali"].HeaderText = "Tanggal Kembali";
                                dgvLaporan.Columns["kondisibuku"].HeaderText = "Kondisi Buku";
                                dgvLaporan.Columns["status"].HeaderText = "Status";

                                dgvLaporan.Columns["tanggaldipinjam"].DefaultCellStyle.Format = "dd MMM yyyy";
                                dgvLaporan.Columns["tanggalkembali"].DefaultCellStyle.Format = "dd MMM yyyy";

                                dgvLaporan.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.AllCells;
                                dgvLaporan.Columns["judulbuku"].AutoSizeMode = DataGridViewAutoSizeColumnMode.Fill;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Terjadi kesalahan saat memuat data:\n" + ex.Message,
                    "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        // ================== TOMBOL ==================
        private void btnCetak_Click_1(object sender, EventArgs e)
        {
            if (dtLaporan == null || dtLaporan.Rows.Count == 0)
            {
                MessageBox.Show("Tidak ada data untuk dicetak!", "Peringatan",
                    MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            // ✅ Kirim dtLaporan langsung, tidak perlu query ulang
            FormCrystalLaporan frm = new FormCrystalLaporan(dtLaporan);
            frm.ShowDialog();
        }

        private void btnRefresh_Click_1(object sender, EventArgs e)
        {
            LoadDataLaporan();   // refresh semua data
        }

        private void btnTutup_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void btnKembali_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void btnLoad_Click(object sender, EventArgs e)
        {
            string keyword = txtCari.Text.Trim();

            // Hanya filter tanggal kalau user memang mau filter
            // Misal: tambahkan CheckBox cbFilterTanggal di form
            DateTime? tanggal = null; // atau: cbFilterTanggal.Checked ? dtpTanggalDipinjam.Value : (DateTime?)null

            LoadDataLaporan(keyword, tanggal);
            btnCetak.Enabled = (dtLaporan?.Rows.Count > 0);
        }
    }
}