import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  Future<String?>? _kodeUserFuture;

  @override
  void initState() {
    super.initState();
    _kodeUserFuture = _getKodeUser();
  }

  Future<String?> _getKodeUser() async {
    final userLogin = Supabase.instance.client.auth.currentUser;
    if (userLogin == null) return null;

    try {
      final dataUser = await Supabase.instance.client
        .from('users')
        .select('kode_user')
        .eq('user_id', userLogin.id)
        .maybeSingle();
      return dataUser?['kode_user'];
    } catch (e) {
      debugPrint("Error ambil kode_user di Disiapkanpage: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _kodeUserFuture,
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final String? kodeUserLogin = userSnapshot.data;
        if (kodeUserLogin == null) {
          return const Scaffold(
            body: Center(
              child: Text("Silahkan login terlebih dahulu untuk melihat pesanan"),
            ),
          );
        }
         final Stream<List<Map<String, dynamic>>> _ordersStream =
          Supabase.instance.client
              .from('orders')
              .stream(primaryKey: ['id'])
              .eq('kode_user', kodeUserLogin)
              .map((data) => data
                  .where((item) => item['status'] == 'selesai')
                  .toList());
       
        return Scaffold(
          appBar: AppBar(
            title: const Text("Riwayat Pesanan"),
          ),
          body: StreamBuilder<List<Map<String, dynamic>>>(
            stream: _ordersStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text("Terjadi kesalahan: ${snapshot.error}"));
              }
              final orders = snapshot.data ?? [];
              if (orders.isEmpty) {
                return const Center(
                  child: Text("Anda belum melakukan pembelian"),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final int id = order['id'] ?? 0;
                  final int totalHarga = order['total'] ?? 0;
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.inventory_2_outlined,
                                    color: Colors.blue,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Pesanan #$id",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    )
                                  ),
                                ],
                              ),
                              Text(
                                "Rp $totalHarga",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 20, thickness: 1),
                          const Text(
                            "Pesanan",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          _BuildDaftarBarang(idOrder: id),
                          const Divider(height: 20, thickness: 1),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Status",
                                style: TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  "Beli lagi"
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),  
                  );
                } 
              ); 
            }
          ),
        );
      }
    );
  }
}

class _BuildDaftarBarang extends StatelessWidget {
  final int idOrder;
  const _BuildDaftarBarang({required this.idOrder});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Supabase.instance.client
        .from('order_items')
        .select('''
          qty,
          harga,
          id_barang,
          barang (
            nama,
            gambar
          )
        ''')
        .eq('id_order', idOrder),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasError || snapshot.data == null) {
          return const Text(
            "Gagal memuat detail barang",
            style: TextStyle(color: Colors.red, fontSize: 13),
          );
        }
        final items = snapshot.data!;
        if (items.isEmpty) {
          return const Text("Tidak ada detail item", style: TextStyle(fontSize: 13));
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index){
            final item = items[index];
            final Map<String, dynamic>? dataBarang = item['barang'] as Map<String, dynamic>?;
            final String namaBarang = dataBarang?['nama'] ?? 'Produk';
            final String? urlGambar = dataBarang?['gambar'] as String?;

            final int qty = item['qty'] ?? 0;
            final int harga = item['harga'] ?? 0;
            

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      urlGambar ?? 'https://via.placeholder.com/40',
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 40,
                          height: 40,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported, size: 20, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "$namaBarang x$qty",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  Text(
                    "Rp ${harga * qty}",
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            );
          }
        );
      }
    );
  }
}