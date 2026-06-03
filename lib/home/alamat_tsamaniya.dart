import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'cabangprovider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TsamaniyaModel {
  final int? id;
  final String? namaCabang;
  final String? alamat;
  final double? latitude;
  final double? longitude;
  final String? noTelpon;
  final String? jamBuka;
  final String? jamTutup;
  final bool? statusAktif;
  double? distance;
  TsamaniyaModel({
    this.id,
    this.namaCabang,
    this.alamat,
    this.latitude,
    this.longitude,
    this.noTelpon,
    this.jamBuka,
    this.jamTutup,
    this.statusAktif,
      this.distance = 0.0,
  });
}
class DaftarTokoPage extends StatefulWidget {
  const DaftarTokoPage({super.key});

  @override
  State<DaftarTokoPage> createState() => _DaftarTokoPageState();
}

class _DaftarTokoPageState extends State<DaftarTokoPage> {
  late Future<List<TsamaniyaModel>> futureCabang;

  @override
  void initState() {
    super.initState();
    futureCabang = getCabangWithDistance();
  }

  Future<List<TsamaniyaModel>> getCabangWithDistance() async {
    final supabase = Supabase.instance.client;

    final response = await supabase
        .from('lokasi_tsamaniya')
        .select();

    final userPos = await getUserLocation();

    final List<TsamaniyaModel> list = (response as List).map((item) {
      return TsamaniyaModel(
        id: item['id'],
        namaCabang: item['nama_cabang'],
        alamat: item['alamat'],
        latitude: (item['latitude'] as num).toDouble(),
        longitude: (item['longitude'] as num).toDouble(),
        noTelpon: item['no_telpon'],
        jamBuka: item['jam_buka'],
        jamTutup: item['jam_tutup'],
        statusAktif: item['status_aktif'],
      );
    }).toList();

    for (var cabang in list) {
      if (cabang.latitude != null && cabang.longitude != null) {
       cabang.distance = Geolocator.distanceBetween(
        userPos.latitude,
        userPos.longitude,
        cabang.latitude!,
        cabang.longitude!,
       );
      }
    }

    list.sort((a, b) => a.distance!.compareTo(b.distance!));

    return list;
  }

  Future<Position> getUserLocation() async {
    bool serviceEnabled;
 
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if(!serviceEnabled) {
      throw Exception("GPS tidak aktif");
    }
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    final cabangProvider = context.watch<CabangProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pilih Toko"),
      ),
      body: FutureBuilder<List<TsamaniyaModel>>(
        future: futureCabang,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Gagal memuat data toko"));
          }

          final data = snapshot.data ?? [];

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final cabang = data[index];

              final isSelected =
                  cabangProvider.selectedCabangId == cabang.id;

              return Card(
                color: isSelected
                  ? Colors.blue.shade50
                  : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(12),
                  side: BorderSide(
                    color: isSelected
                      ? Colors.blue
                      : Colors. grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: ListTile(
                  title: Text(cabang.namaCabang ?? "-",  style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cabang.alamat ?? "-"),
                      const SizedBox(height: 4),
                      Text(
                        "${(cabang.distance! / 1000).toStringAsFixed(1)} km",
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ]
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () {
                    cabangProvider.pilihCabang(
                      cabang.id!,
                      cabang.namaCabang!,
                      cabang.alamat!,
                    );

                    Navigator.pop(context);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}