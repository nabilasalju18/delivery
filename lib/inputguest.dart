import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InputGuestPage extends StatefulWidget {
  const InputGuestPage({super.key});

  @override
  State<InputGuestPage> createState() => _InputGuestPageState();
}

class _InputGuestPageState extends State<InputGuestPage> {

  final namaController = TextEditingController();
  final telponController = TextEditingController();
  final alamatController = TextEditingController();

  bool isLoading = false;

  Future<void> simpanGuest() async {
    if (namaController.text.isEmpty ||
        telponController.text.isEmpty ||
        alamatController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Semua field ajib diisi")
        ),
      );
      return;
    }

    setState((){
      isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;
      
      String kodeUser = "G${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}";

      await supabase
        .from('users')
        .insert({
          'kode_user': kodeUser,
          'nama_user': namaController.text,
        });

      final alamat = await supabase
        .from('alamat')
        .insert({
          'kode_user': kodeUser,
          'nama_penerima': namaController.text,
          'no_telpon': telponController.text,
          'alamat_lengkap': alamatController.text,
        })
        .select()
        .single();

      if (!mounted) return;

      Navigator.pop(context, alamat);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal simpan data $e")),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Masukkan Datamu"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: namaController,
              decoration: InputDecoration(
                labelText: "Nama penerima",
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: telponController,
              decoration: InputDecoration(
                labelText: "Nomor Telepon",
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: alamatController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Alamat lengkap",
                alignLabelWithHint: true,
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 55),
                  child: Icon(Icons.location_on),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: isLoading ? null : simpanGuest, 
                child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                    "Simpan",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ),
            )
          ],
        ),
      ),
    );
  }
}