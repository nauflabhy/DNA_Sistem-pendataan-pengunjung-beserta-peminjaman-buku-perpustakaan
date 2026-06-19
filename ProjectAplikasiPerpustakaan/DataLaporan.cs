using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ProjectAplikasiPerpustakaan
{
    public class DataLaporan
    {
            public int IdLaporan { get; set; }
            public int IdUser { get; set; }
            public string Periode { get; set; }
            public int TotalKunjungan { get; set; }
            public int TotalPeminjaman { get; set; }
            public int TotalPengembalian { get; set; }
            public decimal TotalDenda { get; set; }
    }
}
