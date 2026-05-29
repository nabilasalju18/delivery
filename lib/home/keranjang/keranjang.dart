import 'package:delivery/co/cekout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'keranjangprovider.dart';

class KeranjangPage extends StatelessWidget {
  const KeranjangPage({super.key});

  @override
  Widget build(BuildContext context) {
    final keranjangProvider = Provider.of<KeranjangProvider>(context);
    final keranjang = keranjangProvider.item;
    return Scaffold(
      appBar: AppBar(title: const Text("Keranjang")),
      backgroundColor: const Color.fromARGB(255, 149, 220, 246),
      body: Column(
        children: [
          Expanded(
            child: keranjang.isEmpty
                ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 48,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Keranjang Kosong',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
                : ListView.builder(
                    itemCount: keranjang.length,
                    itemBuilder: (context, index) {
                      final item = keranjang[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          // Row utama untuk membagi Gambar, Detail text dan tombol
                          child: Row(
                            children: [
                              Checkbox(
                                value: item['terpilih'] ?? false,
                                activeColor: Colors.blue,
                                onChanged: (bool? value) {
                                  keranjangProvider.toggleCeklis(index);
                                }
                              ),
                              // Gambar
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  item['gambar'] ?? 'https://via.placeholder.com/70',
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Info Produk
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['nama'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text('Rp ${item['harga']}'),
                                  ],
                                ),
                              ),
                              // Sisi Kanan: Tombol Tambah/Kurang & Hapus
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () => keranjangProvider.kurangJumlah(index),
                                    icon: const Icon(Icons.remove_circle),
                                  ),
                                  Text(
                                    '${item['jumlah']}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  IconButton(
                                    onPressed: () => keranjangProvider.tambahJumlah(index),
                                    icon: const Icon(Icons.add_circle),
                                  ),
                                  IconButton(
                                    onPressed: () => keranjangProvider.hapusItem(index),
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (keranjang.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Total Harga",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    Text(
                      "Rp ${keranjangProvider.totalHarga}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black
                      ),
                    )
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CheckoutPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ), 
                  child: const Text(
                    "Beli Sekarang",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}