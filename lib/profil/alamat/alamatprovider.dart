import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
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

class CabangProvider extends ChangeNotifier {
  int? selectedCabangId;
  String? selectedCabangNama;
  String? selectedAlamat;
  double? selectedLongitude;
  double? selectedLatitude;

  bool get sudahPilihCabang => selectedCabangId != null;

  Future<void> pilihCabang(
    int id,
    String nama,
    String alamat,
    double latitude,
    double longitude,
  ) async {
    if (selectedCabangId == id) return;

    selectedCabangId = id;
    selectedCabangNama = nama;
    selectedAlamat = alamat;
    selectedLatitude = latitude;
    selectedLongitude = longitude;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('cabang_id', id);
    await prefs.setString('cabang_nama', nama);
    await prefs.setString('cabang_alamat', alamat);
    await prefs.setDouble('cabang_latitude', latitude);
    await prefs.setDouble('cabang_longitude', longitude);
    notifyListeners();
  }

  Future<void> loadCabang() async {
    final prefs = await SharedPreferences.getInstance();

    selectedCabangId = prefs.getInt('cabang_id');
    selectedCabangNama = prefs.getString('cabang_nama');
    selectedAlamat = prefs.getString('cabang_alamat');
    selectedLatitude = prefs.getDouble('cabang_latitude');
    selectedLongitude = prefs.getDouble('cabang_longitude');

    notifyListeners();
  }

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('GPS Anda tidak aktif, silakan aktifkan GPS.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Izin lokasi ditolak.');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Izin lokasi ditolak permanen, silakan ubah di pengaturan HP.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<TsamaniyaModel?> getCabangTerdekat() async {
    try {
      final pos = await getCurrentLocation();

      final response = await Supabase.instance.client
        .from('lokasi_tsamaniya')
        .select();
      List<TsamaniyaModel> cabangList = response.map<TsamaniyaModel>((item) {
        return TsamaniyaModel(
          id: item['id'],
          namaCabang: item['nama_cabang'],
          latitude: item['latitude'] != null ? (item['latitude'] as num).toDouble() : 0.0,
          longitude: item['longitude'] != null ? (item['longitude'] as num).toDouble() : 0.0,
        );
      }).toList();

      if (cabangList.isEmpty) return null;

      for (final cabang in cabangList) {
        cabang.distance = Geolocator.distanceBetween(
          pos.latitude,
          pos.longitude,
          cabang.latitude!,
          cabang.longitude!,
        );
      }

      cabangList.sort((a, b) => a.distance!.compareTo(b.distance!));

      return cabangList.first;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> clearCabang() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('cabang_id');
    await prefs.remove('cabang_nama');
    await prefs.remove('cabang_alamat');
    await prefs.remove('cabang_latitude');
    await prefs.remove('cabang_longitude');

    selectedCabangId = null;
    selectedCabangNama = null;
    selectedAlamat = null;
    selectedLatitude = null;
    selectedLongitude = null;

    notifyListeners();
  }
  
}