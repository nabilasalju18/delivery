import 'package:delivery/main.dart';
import 'package:flutter/material.dart';

class BerhasilPage extends StatefulWidget{
  final int totalPembayaran;
  final List<dynamic> daftarBarang;

  BerhasilPage({
    super.key,
    required this.totalPembayaran,
    required this.daftarBarang,
  });

  @override
  State<BerhasilPage> createState() => _BerhasilPageState();
}

class _BerhasilPageState extends State<BerhasilPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 149, 220, 246),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.blue,
                size: 100,
              ),
              const SizedBox(height: 20),
              const Text(
                "🎊Pesanan Berhasil Yuhuu!🎊",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Rincian Pesanan",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const Divider(),

                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.daftarBarang.length,
                        itemBuilder: (context, index) {
                          final item = widget.daftarBarang[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text("${item['nama']} (x${item['jumlah']})"),
                                ),
                                Text("Rp ${item['harga'] * item['jumlah']}"),
                              ],
                            ),
                          );
                        },
                      ),
                      const Divider(),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Metode"),
                          Text("COD (Cash On Delivery)", style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total Bayar"),
                          Text(
                            "Rp ${widget.totalPembayaran}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],      
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  child: Text("Kembali ke Home")
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}