import 'package:flutter/material.dart';

class KeranjangProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _daftarKeranjang = [];
  List<Map<String, dynamic>> get item => _daftarKeranjang;
  
  int get totalHarga {
    int total = 0;
    for (var item in _daftarKeranjang) {
      if (item['terpilih'] == true) {
        final harga = item['harga'] is int ? item['harga'] : int.tryParse(item['harga'].toString()) ?? 0;
        final qty = item['jumlah'] is int ? item['jumlah'] : int.tryParse(item['jumlah'].toString()) ?? 1;
        total += (harga as int) * (qty as int);
      }
    }
    return total;
  }

  void tambahKeranjang(Map<String, dynamic> produkBaru) {
    int index = _daftarKeranjang.indexWhere((item) => item['id'] == produkBaru['id']);
    if (index>=0) {
      _daftarKeranjang[index]['jumlah']++;
    } else {
      final Map<String, dynamic> itemBaru = Map.from(produkBaru);
      itemBaru['terpilih'] = true;
      _daftarKeranjang.add(produkBaru);
    }
    notifyListeners();
  }

  void toggleCeklis(int index) {
    _daftarKeranjang[index]['terpilih'] = !(_daftarKeranjang[index]['terpilih'] ?? false);
    notifyListeners();
  }

  void tambahJumlah(int index) {
    _daftarKeranjang[index]['jumlah']++;
    notifyListeners();
  }

  void kurangJumlah(int index) {
    if (_daftarKeranjang[index]['jumlah'] > 1) {
      _daftarKeranjang[index]['jumlah']--;
      notifyListeners();
    }
  }

  void hapusItem(int index) {
    _daftarKeranjang.removeAt(index);
    notifyListeners();
  }

  void clearKeranjang() {
    _daftarKeranjang.clear();
    notifyListeners();
  }
}