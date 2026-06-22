namespace ProjectAplikasiPerpustakaan
{
    partial class FormPengembalian
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.lblTanggalPengembalian = new System.Windows.Forms.Label();
            this.txtCatatan = new System.Windows.Forms.TextBox();
            this.label7 = new System.Windows.Forms.Label();
            this.btnKembalikan = new System.Windows.Forms.Button();
            this.btnBatal = new System.Windows.Forms.Button();
            this.lblTanggalAjuan = new System.Windows.Forms.Label();
            this.lblJudulBuku = new System.Windows.Forms.Label();
            this.lblKodeBuku = new System.Windows.Forms.Label();
            this.cmbKondisiBuku = new System.Windows.Forms.ComboBox();
            this.label6 = new System.Windows.Forms.Label();
            this.label5 = new System.Windows.Forms.Label();
            this.label4 = new System.Windows.Forms.Label();
            this.label3 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.label1 = new System.Windows.Forms.Label();
            this.SuspendLayout();
            // 
            // lblTanggalPengembalian
            // 
            this.lblTanggalPengembalian.AutoSize = true;
            this.lblTanggalPengembalian.Font = new System.Drawing.Font("Times New Roman", 10.2F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblTanggalPengembalian.Location = new System.Drawing.Point(854, 275);
            this.lblTanggalPengembalian.Name = "lblTanggalPengembalian";
            this.lblTanggalPengembalian.Size = new System.Drawing.Size(159, 19);
            this.lblTanggalPengembalian.TabIndex = 30;
            this.lblTanggalPengembalian.Text = "Tanggal Pengembalian";
            // 
            // txtCatatan
            // 
            this.txtCatatan.Location = new System.Drawing.Point(858, 363);
            this.txtCatatan.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.txtCatatan.Multiline = true;
            this.txtCatatan.Name = "txtCatatan";
            this.txtCatatan.Size = new System.Drawing.Size(247, 70);
            this.txtCatatan.TabIndex = 29;
            // 
            // label7
            // 
            this.label7.AutoSize = true;
            this.label7.Font = new System.Drawing.Font("Times New Roman", 10.2F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label7.Location = new System.Drawing.Point(657, 363);
            this.label7.Name = "label7";
            this.label7.Size = new System.Drawing.Size(64, 19);
            this.label7.TabIndex = 28;
            this.label7.Text = "Catatan:";
            // 
            // btnKembalikan
            // 
            this.btnKembalikan.BackColor = System.Drawing.Color.ForestGreen;
            this.btnKembalikan.Font = new System.Drawing.Font("Times New Roman", 10.2F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnKembalikan.ForeColor = System.Drawing.SystemColors.ButtonHighlight;
            this.btnKembalikan.Location = new System.Drawing.Point(875, 475);
            this.btnKembalikan.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.btnKembalikan.Name = "btnKembalikan";
            this.btnKembalikan.Size = new System.Drawing.Size(132, 44);
            this.btnKembalikan.TabIndex = 27;
            this.btnKembalikan.Text = "Kembalikan";
            this.btnKembalikan.UseVisualStyleBackColor = false;
            this.btnKembalikan.Click += new System.EventHandler(this.btnKembalikan_Click);
            // 
            // btnBatal
            // 
            this.btnBatal.BackColor = System.Drawing.Color.Crimson;
            this.btnBatal.Font = new System.Drawing.Font("Times New Roman", 10.2F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnBatal.ForeColor = System.Drawing.SystemColors.ButtonHighlight;
            this.btnBatal.Location = new System.Drawing.Point(660, 475);
            this.btnBatal.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.btnBatal.Name = "btnBatal";
            this.btnBatal.Size = new System.Drawing.Size(132, 44);
            this.btnBatal.TabIndex = 26;
            this.btnBatal.Text = "Batal";
            this.btnBatal.UseVisualStyleBackColor = false;
            this.btnBatal.Click += new System.EventHandler(this.btnBatal_Click);
            // 
            // lblTanggalAjuan
            // 
            this.lblTanggalAjuan.AutoSize = true;
            this.lblTanggalAjuan.Font = new System.Drawing.Font("Times New Roman", 10.2F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblTanggalAjuan.Location = new System.Drawing.Point(854, 231);
            this.lblTanggalAjuan.Name = "lblTanggalAjuan";
            this.lblTanggalAjuan.Size = new System.Drawing.Size(102, 19);
            this.lblTanggalAjuan.TabIndex = 25;
            this.lblTanggalAjuan.Text = "Tanggal Ajuan";
            // 
            // lblJudulBuku
            // 
            this.lblJudulBuku.AutoSize = true;
            this.lblJudulBuku.Font = new System.Drawing.Font("Times New Roman", 10.2F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblJudulBuku.Location = new System.Drawing.Point(854, 190);
            this.lblJudulBuku.Name = "lblJudulBuku";
            this.lblJudulBuku.Size = new System.Drawing.Size(89, 19);
            this.lblJudulBuku.TabIndex = 24;
            this.lblJudulBuku.Text = "Judul Buku:";
            // 
            // lblKodeBuku
            // 
            this.lblKodeBuku.AutoSize = true;
            this.lblKodeBuku.Font = new System.Drawing.Font("Times New Roman", 10.2F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblKodeBuku.Location = new System.Drawing.Point(854, 150);
            this.lblKodeBuku.Name = "lblKodeBuku";
            this.lblKodeBuku.Size = new System.Drawing.Size(85, 19);
            this.lblKodeBuku.TabIndex = 23;
            this.lblKodeBuku.Text = "Kode Buku";
            // 
            // cmbKondisiBuku
            // 
            this.cmbKondisiBuku.FormattingEnabled = true;
            this.cmbKondisiBuku.Location = new System.Drawing.Point(858, 316);
            this.cmbKondisiBuku.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.cmbKondisiBuku.Name = "cmbKondisiBuku";
            this.cmbKondisiBuku.Size = new System.Drawing.Size(108, 24);
            this.cmbKondisiBuku.TabIndex = 22;
            // 
            // label6
            // 
            this.label6.AutoSize = true;
            this.label6.Font = new System.Drawing.Font("Times New Roman", 10.2F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label6.Location = new System.Drawing.Point(657, 316);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(107, 19);
            this.label6.TabIndex = 21;
            this.label6.Text = "Kondisi Buku:";
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Font = new System.Drawing.Font("Times New Roman", 10.2F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label5.Location = new System.Drawing.Point(657, 275);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(159, 19);
            this.label5.TabIndex = 20;
            this.label5.Text = "Tanggal Pengembalian";
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Font = new System.Drawing.Font("Times New Roman", 10.2F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label4.Location = new System.Drawing.Point(657, 231);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(102, 19);
            this.label4.TabIndex = 19;
            this.label4.Text = "Tanggal Ajuan";
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Font = new System.Drawing.Font("Times New Roman", 10.2F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label3.Location = new System.Drawing.Point(657, 190);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(89, 19);
            this.label3.TabIndex = 18;
            this.label3.Text = "Judul Buku:";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Font = new System.Drawing.Font("Times New Roman", 10.2F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label2.Location = new System.Drawing.Point(657, 150);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(85, 19);
            this.label2.TabIndex = 17;
            this.label2.Text = "Kode Buku";
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Font = new System.Drawing.Font("Times New Roman", 16.2F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label1.Location = new System.Drawing.Point(678, 59);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(256, 32);
            this.label1.TabIndex = 16;
            this.label1.Text = "From Pengembalian";
            // 
            // FormPengembalian
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(1596, 668);
            this.Controls.Add(this.lblTanggalPengembalian);
            this.Controls.Add(this.txtCatatan);
            this.Controls.Add(this.label7);
            this.Controls.Add(this.btnKembalikan);
            this.Controls.Add(this.btnBatal);
            this.Controls.Add(this.lblTanggalAjuan);
            this.Controls.Add(this.lblJudulBuku);
            this.Controls.Add(this.lblKodeBuku);
            this.Controls.Add(this.cmbKondisiBuku);
            this.Controls.Add(this.label6);
            this.Controls.Add(this.label5);
            this.Controls.Add(this.label4);
            this.Controls.Add(this.label3);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.label1);
            this.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.Name = "FormPengembalian";
            this.Text = "VerifikasiPengembalian";
            this.Load += new System.EventHandler(this.FormPengembalian_Load);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label lblTanggalPengembalian;
        private System.Windows.Forms.TextBox txtCatatan;
        private System.Windows.Forms.Label label7;
        private System.Windows.Forms.Button btnKembalikan;
        private System.Windows.Forms.Button btnBatal;
        private System.Windows.Forms.Label lblTanggalAjuan;
        private System.Windows.Forms.Label lblJudulBuku;
        private System.Windows.Forms.Label lblKodeBuku;
        private System.Windows.Forms.ComboBox cmbKondisiBuku;
        private System.Windows.Forms.Label label6;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Label label1;
    }
}