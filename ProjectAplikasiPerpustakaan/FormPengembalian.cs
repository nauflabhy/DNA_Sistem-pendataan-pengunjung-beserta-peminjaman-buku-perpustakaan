using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Windows.Forms;

namespace ProjectAplikasiPerpustakaan
{
    public partial class FormPengembalian : Form
    {

        private int idPeminjaman;
        private int idUser;
        private string namaAdmin;
        private string roleAdmin;

        private readonly string connectionString = DAL.GetConnectionString();

        public FormPengembalian(
            int idPeminjaman,
            string kodeBuku,
            string judulBuku,
            DateTime tanggalAjuan,
            int idUser)
        {
            InitializeComponent();

            this.idPeminjaman = idPeminjaman;
            this.idUser = idUser;

            // tampilkan data ke label
            lblKodeBuku.Text = kodeBuku;
            lblJudulBuku.Text = judulBuku;
            lblTanggalAjuan.Text =
                tanggalAjuan.ToString("dd MMM yyyy");

            lblTanggalPengembalian.Text =
                DateTime.Now.ToString("dd MMM yyyy");

            // isi pilihan kondisi buku
            cmbKondisiBuku.Items.Add("baik");
            cmbKondisiBuku.Items.Add("rusak ringan");
            cmbKondisiBuku.Items.Add("rusak berat");
            cmbKondisiBuku.Items.Add("hilang");

            // default pilihan
            cmbKondisiBuku.SelectedIndex = 0;
        }

        private void btnKembalikan_Click(object sender, EventArgs e)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // CEK SUDAH DIKEMBALIKAN
                    string checkQuery = "SELECT COUNT(*) FROM PENGEMBALIAN WHERE id_peminjaman = @id_peminjaman";
                    using (SqlCommand checkCmd = new SqlCommand(checkQuery, conn))
                    {
                        checkCmd.Parameters.AddWithValue("@id_peminjaman", idPeminjaman);
                        int jumlah = Convert.ToInt32(checkCmd.ExecuteScalar());
                        if (jumlah > 0)
                        {
                            MessageBox.Show("Buku ini sudah pernah dikembalikan.", "Informasi",
                                MessageBoxButtons.OK, MessageBoxIcon.Warning);
                            return;
                        }
                    }

                    // Hitung denda
                    decimal denda = 0;
                    switch (cmbKondisiBuku.Text.ToLower())
                    {
                        case "rusak ringan": denda = 10000; break;
                        case "rusak berat": denda = 50000; break;
                        case "hilang": denda = 100000; break;
                    }

                    // INSERT PENGEMBALIAN
                    string queryInsert = @"
                INSERT INTO PENGEMBALIAN
                (id_peminjaman, tanggal_kembali, kondisi_buku, denda, status, catatan)
                VALUES
                (@id_peminjaman, @tanggal_kembali, @kondisi_buku, @denda, 'diverifikasi', @catatan)";

                    using (SqlCommand cmd = new SqlCommand(queryInsert, conn))
                    {
                        cmd.Parameters.AddWithValue("@id_peminjaman", idPeminjaman);
                        cmd.Parameters.AddWithValue("@tanggal_kembali", DateTime.Now);
                        cmd.Parameters.AddWithValue("@kondisi_buku", cmbKondisiBuku.Text);
                        cmd.Parameters.AddWithValue("@denda", denda);
                        cmd.Parameters.AddWithValue("@catatan", "Buku telah dikembalikan");
                        cmd.ExecuteNonQuery();

                        // ✅ Trigger trg_TambahStokKembali otomatis berjalan saat INSERT
                        // ✅ Trigger juga otomatis update status PEMINJAMAN jadi 'selesai'
                        // Tidak perlu update stok & status manual lagi
                    }

                    MessageBox.Show("Buku berhasil dikembalikan!", "Sukses",
                        MessageBoxButtons.OK, MessageBoxIcon.Information);

                    CetakLaporan formLaporan = new CetakLaporan();
                    formLaporan.Show();
                    this.Close();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Terjadi kesalahan:\n" + ex.Message, "Error",
                    MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void btnBatal_Click(object sender, EventArgs e)
        {
            // kembali ke form daftar pengajuan
            btnKembali formPengajuan = new btnKembali(idUser, namaAdmin, roleAdmin);

            formPengajuan.Show();

            this.Close();
        }

        private void FormPengembalian_Load(object sender, EventArgs e)
        {
        }
    }
}