import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:delivery/profil/alamat/alamatprovider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';

class TambahAlamatPage extends StatefulWidget {
  const TambahAlamatPage({super.key});

  @override
  State<TambahAlamatPage> createState() => _TambahAlamatPageState();
}

class _TambahAlamatPageState extends State<TambahAlamatPage> {
  final _formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;

  final _labelController = TextEditingController();
  final _namaController = TextEditingController();
  final _teleponController = TextEditingController();
  final _alamatController = TextEditingController();
  final _catatanController = TextEditingController();

  bool isSimpanLoading = false;

  GoogleMapController? _mapController;

  LatLng _selectedLocation =
    const LatLng(-7.599533246164611, 112.10172199328949);

  Future<void> simpanAlamat() async {
    if (!_formKey.currentState!.validate()) return;
    
    final userLogin = supabase.auth.currentUser;
    if (userLogin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kamu belum login!")),
      );
      return;
    }

    setState(() => isSimpanLoading = true);

    try {
      final dataUser = await supabase
          .from('users')
          .select('kode_user')
          .eq('user_id', userLogin.id)
          .maybeSingle();

      if (dataUser == null || dataUser['kode_user'] == null) {
        throw "Gagal mengenali kode profil kamu.";
      }

      final String kodeUserAktif = dataUser['kode_user'];

      double latitudeHasil = _selectedLocation.latitude;
      double longitudeHasil = _selectedLocation.longitude;

      await supabase
        .from('alamat')
        .insert({
          'kode_user': kodeUserAktif,
          'label_alamat': _labelController.text.trim(),
          'nama_penerima': _namaController.text.trim(),
          'no_telpon': _teleponController.text.trim(),
          'alamat_lengkap': _alamatController.text.trim(),
          'catatan': _catatanController.text.trim(),
          'latitude': latitudeHasil,
          'longitude': longitudeHasil,
        });

      if (!mounted) return;
      setState(() => isSimpanLoading = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Alamat berhasil disimpan!")),
      );
      Navigator.pop(context, true);
    } catch (e, stacktrace) {
      setState(() => isSimpanLoading = false);
      
      // Cetak ke log vscode / android studio untuk melihat error asli dari Supabase
      debugPrint("ERROR SUPABASE: $e");
      debugPrint("STACKTRACE: $stacktrace");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menyimpan alamat: $e")),
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await context
          .read<CabangProvider>()
          .getCurrentLocation();

      final lokasiBaru = LatLng(
        position.latitude,
        position.longitude,
      );

      _selectedLocation = lokasiBaru;

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          lokasiBaru,
          14,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }


  @override
  void dispose() {
    _labelController.dispose();
    _namaController.dispose();
    _teleponController.dispose();
    _alamatController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Alamat Baru", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildInput("Label Alamat", _labelController, "Contoh: Rumah, Kantor, Kosan"),
              _buildInput("Nama Penerima", _namaController, "Masukkan nama lengkap"),
              _buildInput("No. Telepon / WhatsApp", _teleponController, "Contoh: 081234xxx", isAngka: true),
              _buildInput("Alamat Lengkap", _alamatController, "Nama jalan, nomor rumah, RT/RW, kecamatan", maxBaris: 3),
              _buildInput("Catatan Kurir (Opsional)", _catatanController, "Contoh: Pagar cat hitam / seberang warung", wajib: false),
              const SizedBox(height: 24),
              Container(
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    GoogleMap(
                      gestureRecognizers: {
                        Factory<OneSequenceGestureRecognizer>(
                          () => EagerGestureRecognizer(),
                        ),
                      },
                      initialCameraPosition: CameraPosition(
                        target: _selectedLocation,
                        zoom: 15,
                      ),
                      onMapCreated: (controller) {
                        _mapController = controller;
                      },
                      onCameraMove: (position) {
                        _selectedLocation = position.target;
                      },
                    ),

                    const Center(
                      child: Icon(
                        Icons.location_pin,
                        size: 45,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _getCurrentLocation, 
                icon:  const Icon(Icons.my_location),
                label: const Text("Gunakan lokasi saat ini"),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isSimpanLoading ? null : simpanAlamat,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: isSimpanLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Simpan Alamat", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller, String hint, {bool wajib = true, bool isAngka = false, int maxBaris = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16), // Diubah ke bottom agar jarak antar form lebih rapi
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          TextFormField(
              controller: controller,
              maxLines: maxBaris,
              keyboardType: isAngka ? TextInputType.number : TextInputType.text,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              validator: (value) {
                if (wajib && (value == null || value.trim().isEmpty)) {
                  return "$label tidak boleh kosong!";
                }
                return null;
              }),
        ],
      ),
    );
  }
}