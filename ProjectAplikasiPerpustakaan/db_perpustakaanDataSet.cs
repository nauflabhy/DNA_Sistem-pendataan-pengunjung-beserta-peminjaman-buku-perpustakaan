using System;

namespace ProjectAplikasiPerpustakaan
{


    partial class db_perpustakaanDataSet
    {
        partial class vw_LaporanPeminjamanDataTable
        {
            public int id_peminjaman { get; set; }

            public string nama_pengunjung { get; set; }

            public string kode_buku { get; set; }
            public string judul_buku { get; set; }

            public DateTime tanggal_pinjam { get; set; }
            public DateTime tanggal_kembali { get; set; }

            public string kondisi_buku { get; set; }
            public decimal denda { get; set; }
            public string status { get; set; }
            public string catatan { get; set; }
        }

        partial class DataTable1DataTable
        {
            public int id_peminjaman { get; set; }

            public string nama_pengunjung { get; set; }

            public string kode_buku { get; set; }
            public string judul_buku { get; set; }

            public DateTime tanggal_pinjam { get; set; }
            public DateTime tanggal_kembali { get; set; }

            public string kondisi_buku { get; set; }
            public decimal denda { get; set; }
            public string status { get; set; }
            public string catatan { get; set; }
        }
    }
}
