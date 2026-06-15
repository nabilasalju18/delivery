import 'package:delivery/profil/favorit/favoritprovider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:delivery/home/keranjang/keranjangprovider.dart';
import 'package:delivery/home/detail_produk.dart';
import 'package:delivery/home/keranjang/keranjang.dart';

class FavoritPage extends StatelessWidget {
  const FavoritPage({super.key});

  String formatRupiah(num harga) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(harga);
  }
  //ga mau liat kamu bikin pusing tau ga
  @override
  Widget build(BuildContext context) {
    final favoritProvider = context.watch<FavoritProvider>();
    final listFavorit = favoritProvider.favoritItem;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 149, 220, 246),
      appBar: AppBar(
        title: const Text('Produk Favorit'),
      ),
      body: listFavorit.isEmpty
        ? _buildEmptyState()
        : _buildFavoritList(context, listFavorit,favoritProvider),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Belum ada produk yang kamu sukai',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFavoritList(
    BuildContext context,
    List<Map<String, dynamic>> items,
    FavoritProvider provider,
  ) {
    final keranjangProvider = Provider.of<KeranjangProvider>(
      context,
      listen: false,
    );
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.87,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.68,
        ),
        itemBuilder: (context, index) {
          final product = items[index];

          return Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailProdukPage(product: product),
                  ),
                );
              },         
              child: Column(               
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // IMAGE
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      child: Image.network(
                        product["gambar"]?? "",
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 40,
                              color: Colors.grey,
                            ),
                          );
                        }
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product["nama"],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Text(
                          formatRupiah(product["harga"] ?? 0),
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(
                          width: double.infinity,
                          child: Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  final Map<String, dynamic> dataUntukKeranjang = {
                                    'id': product['id'],
                                    'nama': product['nama'],
                                    'harga': product['harga'],
                                    'gambar': product['gambar'],
                                    'jumlah': 1,
                                    'terpilih': false,
                                  };
                                  keranjangProvider.tambahKeranjang(dataUntukKeranjang);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("${product['nama']} ditambahkan ke keranjang")),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  elevation: 2,
                                  padding: const EdgeInsets.all(10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12),
                                        side: const BorderSide(
                                          color: Colors.blue,
                                        )
                                  ),
                                ),
                                child: const Icon(
                                  Icons.shopping_cart_outlined,
                                  color: Colors.blue,
                                  size: 18,
                                ), 
                              ),
                            
                              const SizedBox(width: 6),

                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    keranjangProvider.tambahKeranjang({
                                      'id': product['id'],
                                      'nama': product['nama'],
                                      'harga': product['harga'],
                                      'gambar': product['gambar'],
                                      'jumlah': 1,
                                      'terpilih': true,
                                    });
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const KeranjangPage(), 
                                      ),
                                    );
                                  },
                                  
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    elevation: 2,
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)
                                    ),
                                  ),
                                  child: Text(
                                    "beli",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      )
    );
  }
}