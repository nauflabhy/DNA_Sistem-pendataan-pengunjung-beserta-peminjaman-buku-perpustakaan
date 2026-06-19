using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ProjectAplikasiPerpustakaan
{
    public class Class1
    {
        public int IdPeminjaman { get; set; }
        public string NamaLengkap { get; set; }
        public string JudulBuku { get; set; }
        public string KodeBuku { get; set; }
        public DateTime TanggalDipinjam { get; set; }
        public string TanggalKembali { get; set; }     // string karena bisa '-'
        public string KondisiBuku { get; set; }        // string karena bisa '-'
        public string Status { get; set; }

        // Constructor kosong (diperlukan Crystal Report)
        public Class1() { }
    }
}
