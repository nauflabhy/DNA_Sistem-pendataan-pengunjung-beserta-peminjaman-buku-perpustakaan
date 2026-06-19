using CrystalDecisions.CrystalReports.Engine;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Windows.Forms;

namespace ProjectAplikasiPerpustakaan
{
    public partial class FormCrystalLaporan : Form
    {
        static string connectionString =
            "Data Source=NAUFAL\\NZO2;Initial Catalog=db_perpustakaan;Integrated Security=True";

        SqlConnection conn = new SqlConnection(connectionString);
        SqlDataAdapter da;
        DataTable dtLaporan;

        // Objek Crystal Report
        CrystalReport2 laporanPeminjaman = new CrystalReport2();

        // Property dari parameter
        string keyword { get; set; }
        DateTime? tanggalDipinjam { get; set; }

        // ✅ Konstruktor dengan parameter (ikuti contoh)
        public FormCrystalLaporan(DataTable dtLaporan)
        {
            InitializeComponent();

            try
            {
                // ✅ Debug dulu
                MessageBox.Show("Row count: " + dtLaporan.Rows.Count);

                List<Class1> listData = new List<Class1>();
                foreach (DataRow row in dtLaporan.Rows)
                {
                    listData.Add(new Class1
                    {
                        IdPeminjaman = Convert.ToInt32(row["idpeminjaman"]),
                        NamaLengkap = row["namalengkap"].ToString(),
                        JudulBuku = row["judulbuku"].ToString(),
                        KodeBuku = row["kodebuku"].ToString(),
                        TanggalDipinjam = Convert.ToDateTime(row["tanggaldipinjam"]),
                        TanggalKembali = row["tanggalkembali"].ToString(),
                        KondisiBuku = row["kondisibuku"].ToString(),
                        Status = row["status"].ToString()
                    });
                }

                CrystalReport2 rpt = new CrystalReport2();
                rpt.SetDataSource(listData);
                crystalReportViewer1.ReportSource = rpt;
                crystalReportViewer1.Refresh();
            }
            catch (Exception ex)
            {
                MessageBox.Show("Gagal load data: " + ex.Message);
            }
        }
    }
}