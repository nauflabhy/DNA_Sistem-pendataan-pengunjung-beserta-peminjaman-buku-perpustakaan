using System;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Net;
using System.Net.Sockets;

namespace ProjectAplikasiPerpustakaan
{
    public class DAL
    {
        // ✅ Ambil IP otomatis untuk deploy
        /*
        public static string GetLocalIPAddress()
        {
            string localIP = string.Empty;
            try
            {
                var host = Dns.GetHostEntry(Dns.GetHostName());
                foreach (var ip in host.AddressList)
                {
                    if (ip.AddressFamily == AddressFamily.InterNetwork)
                    {
                        localIP = ip.ToString();
                        break;
                    }
                }
            }
            catch (Exception ex)
            {
                System.Windows.Forms.MessageBox.Show("Error getting IP: " + ex.Message);
            }
            return localIP;
        } */

        /* public static string GetConnectionString()
         {
         string connectionString = $"Data Source=192.168.1.19,1433;" +
                                "Initial Catalog=db_perpustakaan;" +
                                "User ID=sa;" +
                                "Password=nopall946;";
         return connectionString;
         } */ 

        public static string GetConnectionString()
        {
            try
            {
                // Cari config.txt di folder yang sama dengan .exe
                string configPath = Path.Combine(
                    AppDomain.CurrentDomain.BaseDirectory,
                    "config.txt"
                );

                if (!File.Exists(configPath))
                {
                    throw new Exception("File config.txt tidak ditemukan!\nPath: " + configPath);
                }

                // Baca semua baris
                string serverIP = "";
                string database = "";
                string userID = "";
                string password = "";
                string port = "1433";

                foreach (string line in File.ReadAllLines(configPath))
                {
                    if (line.StartsWith("ServerIP="))
                        serverIP = line.Replace("ServerIP=", "").Trim();
                    else if (line.StartsWith("Database="))
                        database = line.Replace("Database=", "").Trim();
                    else if (line.StartsWith("UserID="))
                        userID = line.Replace("UserID=", "").Trim();
                    else if (line.StartsWith("Password="))
                        password = line.Replace("Password=", "").Trim();
                    else if (line.StartsWith("Port="))
                        port = line.Replace("Port=", "").Trim();
                }

                string connectionString = $"Data Source={serverIP},{port};" +
                                         $"Initial Catalog={database};" +
                                         $"User ID={userID};" +
                                         $"Password={password};";

                return connectionString;
            }
            catch (Exception ex)
            {
                System.Windows.Forms.MessageBox.Show(
                    "Error membaca config: " + ex.Message,
                    "Config Error"
                );
                return "";
            }
        }

        SqlConnection conn = new SqlConnection(GetConnectionString());
        SqlDataAdapter da;
        DataTable dtBuku;

        // ================== BUKU ==================
        public DataTable GetBuku()
        {
            if (conn.State == ConnectionState.Closed) conn.Open();
            SqlCommand cmd = new SqlCommand("sp_GetBuku", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            da = new SqlDataAdapter(cmd);
            dtBuku = new DataTable();
            da.Fill(dtBuku);
            return dtBuku;
        }

        public void InsertBuku(string kodeBuku, string judul, string pengarang, string penerbit, int tahun, int stok)
        {
            if (conn.State == ConnectionState.Closed) conn.Open();
            SqlCommand cmd = new SqlCommand("sp_InsertBuku", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@KodeBuku", kodeBuku);
            cmd.Parameters.AddWithValue("@Judul", judul);
            cmd.Parameters.AddWithValue("@Pengarang", pengarang);
            cmd.Parameters.AddWithValue("@Penerbit", penerbit);
            cmd.Parameters.AddWithValue("@Tahun", tahun);
            cmd.Parameters.AddWithValue("@Stok", stok);
            cmd.ExecuteNonQuery();
            conn.Close();
        }

        public void ImportBukuFromExcel(string kodeBuku, string judul, string pengarang, string penerbit, int tahun, int stok)
        {
            if (conn.State == ConnectionState.Closed) conn.Open();

            // Cek duplikat sebelum insert
            string query = @"
                IF NOT EXISTS (SELECT 1 FROM BUKU WHERE kode_buku = @KodeBuku)
                BEGIN
                    INSERT INTO BUKU (kode_buku, judul, pengarang, penerbit, tahun, stok)
                    VALUES (@KodeBuku, @Judul, @Pengarang, @Penerbit, @Tahun, @Stok)
                END";

            SqlCommand cmd = new SqlCommand(query, conn);
            cmd.Parameters.AddWithValue("@KodeBuku", kodeBuku);
            cmd.Parameters.AddWithValue("@Judul", judul);
            cmd.Parameters.AddWithValue("@Pengarang", pengarang);
            cmd.Parameters.AddWithValue("@Penerbit", penerbit);
            cmd.Parameters.AddWithValue("@Tahun", tahun);
            cmd.Parameters.AddWithValue("@Stok", stok);
            cmd.ExecuteNonQuery();
        }

        // ================== LAPORAN ==================
        public DataTable GetDataLaporan(string keyword, DateTime? tanggal)
        {
            if (conn.State == ConnectionState.Closed) conn.Open();
            SqlCommand cmd = new SqlCommand("sp_Report", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Add(new SqlParameter("@inStatus", SqlDbType.VarChar) { Value = DBNull.Value });
            cmd.Parameters.Add(new SqlParameter("@inTahun", SqlDbType.Int) { Value = DBNull.Value });
            cmd.Parameters.Add(new SqlParameter("@Keyword", SqlDbType.NVarChar) { Value = (object)keyword ?? DBNull.Value });
            SqlParameter p = new SqlParameter("@TanggalDipinjam", SqlDbType.Date);
            p.Value = (object)tanggal?.Date ?? DBNull.Value;
            cmd.Parameters.Add(p);
            da = new SqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            da.Fill(dt);
            conn.Close();
            return dt;
        }
    }
}