import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'tambahalamat.dart';

class AlamatPage extends StatefulWidget {
  const AlamatPage({super.key});

  @override
  State<AlamatPage> createState() => _AlamatPageState();
}

class _AlamatPageState extends State<AlamatPage> {

  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> daftarAlamat = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getAlamat();
  }
  
  Future<void> getAlamat() async {
    final userLogin = supabase.auth.currentUser;

    if (userLogin == null) {
      setState((){
        daftarAlamat = [];
        isLoading = false;
      });
      return;
    }

    setState(() => isLoading = true);
      
    try {
      final dataUser = await supabase
        .from('users')
        .select('kode_user')
        .eq('user_id', userLogin.id)
        .maybeSingle();
      
      if (dataUser == null || dataUser['kode_user'] == null) {
        throw "Kode user tidak ditemukan";
      }

      final String kodeUser = dataUser['kode_user'];
      final dataAlamat = await supabase
        .from('alamat')
        .select()
        .eq('kode_user', kodeUser);

      setState(() {
        daftarAlamat = List<Map<String, dynamic>>.from(dataAlamat);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal mengambil data: $e")),
      );
    }

  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Alamat Pengiriman", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : daftarAlamat.isEmpty
            ? _buildAlamatKosong()
            : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: daftarAlamat.length,
              itemBuilder: (context, index) {
                final alamat = daftarAlamat[index];
                return _buildCardAlamat(alamat);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final hasil = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TambahAlamatPage()),
          );

          if (hasil == true){
            getAlamat();
          }
        },
        label: const Text("Tambah Alamat"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildAlamatKosong() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text("Belum ada alamat tersimpan", style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildCardAlamat(Map<String, dynamic> alamat){
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Text(
                alamat['label_alamat'] ?? 'Alamat',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              )
            ],
          ),
          const Divider(height: 20),
          Text(
            "${alamat['nama_penerima']} (${alamat['no_telpon']})",
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            alamat['alamat_lengkap'] ?? '',
            style: TextStyle(color: Colors.grey[700], fontSize: 13),
          ),
          if (alamat['catatan'] != null && alamat['catatan'].toString().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              "Catatan: ${alamat['catatan']}",
              style: const TextStyle(
                color: Colors.orange,
                fontSize: 12, 
                fontStyle: FontStyle.italic
              ),
            ),
          ],
        ],
      ), 
    );
  }
}