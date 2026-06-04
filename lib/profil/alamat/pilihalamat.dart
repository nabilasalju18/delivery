import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
 
class PilihAlamatPage extends StatefulWidget {
  const PilihAlamatPage({super.key});

  @override
  State<PilihAlamatPage> createState() => _PilihAlamatPageState();
}

class _PilihAlamatPageState extends State<PilihAlamatPage> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> daftarAlamat = [];
  bool isLoading = true;
  String? selectAlamatId;
  @override
  void initState() {
    super.initState();
    getAlamat();
  }

  Future<void> getAlamat() async {
    final userLogin = supabase.auth.currentUser;
    if (userLogin == null) {
      setState(() {
        daftarAlamat = [];
        isLoading = false;
      });
      return;
    }

    try {
      final dataUser = await supabase
        .from('users')
        .select('kode_user')
        .eq('user_id', userLogin.id)
        .maybeSingle();
      if (dataUser == null) {
        throw "User tidak ditemukan";
      } 
      final kodeUser = dataUser['kode_user'];

      final dataAlamat = await supabase
        .from('alamat')
        .select()
        .eq('kode_user', kodeUser);
      
      setState(() {
        daftarAlamat = List<Map<String, dynamic>>.from(dataAlamat);
        isLoading = false;
      });
    } catch (e) {
      setState(() => false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal mengambil alamat: $e"),
          ),
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pilih Alamat"),
      ),
      body: isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : daftarAlamat.isEmpty
            ? const Center(
                child: Text("blm ada alamat"),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: daftarAlamat.length,
                itemBuilder: (context, index) {
                  final alamat = daftarAlamat[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                    
                      leading: const Icon(Icons.location_on),
                      title: Text(
                        alamat['nama_penerima'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(alamat['no_telpon'] ?? ''),
                          Text(alamat['alamat_lengkap'] ?? ''),
                        ],
                      ),
                      onTap: () {
                        Navigator.pop(context, alamat);
                      },
                    ),
                  );
                }
              )   
    );
  }
}