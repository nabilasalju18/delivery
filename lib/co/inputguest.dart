import 'package:delivery/profil/alamat/alamatprovider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

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

  GoogleMapController? _mapController;

  LatLng _selectedLocation =
    const LatLng(-7.599533246164611, 112.10172199328949);

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

      double? latitudeHasil = _selectedLocation.latitude;
      double? longitudeHasil = _selectedLocation.longitude;

      
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
          'latitude': latitudeHasil,
          'longitude': longitudeHasil
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Alamat"),
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
            Container(
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey,
                )
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
                  )
                ],
              ),
            ),
            const SizedBox(height: 25),
            ElevatedButton.icon(
              onPressed: _getCurrentLocation, 
              icon: const Icon(Icons.my_location),
              label: const Text("Gunakan lokasi saat ini"),
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