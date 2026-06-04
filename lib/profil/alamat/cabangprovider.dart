import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CabangProvider extends ChangeNotifier {
  int? selectedCabangId;
  String? selectedCabangNama;
  String? selectedAlamat;

  bool get sudahPilihCabang => selectedCabangId != null;

  Future<void> pilihCabang(
    int id,
    String nama,
    String alamat,
  ) async {
    if (selectedCabangId == id) return;

    selectedCabangId = id;
    selectedCabangNama = nama;
    selectedAlamat = alamat;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('cabang_id', id);
    await prefs.setString('cabang_nama', nama);
    await prefs.setString('cabang_alamat', alamat);

    notifyListeners();
  }

  Future<void> loadCabang() async {
    final prefs = await SharedPreferences.getInstance();

    selectedCabangId = prefs.getInt('cabang_id');
    selectedCabangNama = prefs.getString('cabang_nama');
    selectedAlamat = prefs.getString('cabang_alamat');

    notifyListeners();
  }

  Future<void> clearCabang() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('cabang_id');
    await prefs.remove('cabang_nama');
    await prefs.remove('cabang_alamat');

    selectedCabangId = null;
    selectedCabangNama = null;
    selectedAlamat = null;

    notifyListeners();
  }
}