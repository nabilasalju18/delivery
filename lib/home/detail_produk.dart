import 'package:delivery/home/keranjang/keranjangprovider.dart';
import 'package:delivery/profil/favorit/favoritprovider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'keranjang/keranjang.dart';

class DetailProdukPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const DetailProdukPage({
    super.key,
    required this.product,
  });

  @override
  State<DetailProdukPage> createState() => _DetailProdukPageState();
}

class _DetailProdukPageState extends State<DetailProdukPage> {

  void _showZoomableImage(
    BuildContext context,
    String? imageUrl,
  ) {
    if (imageUrl == null || imageUrl.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.product;
    final keranjangProvider = Provider.of<KeranjangProvider>(context, listen: false);
    
    return Scaffold(
        appBar: AppBar(
          title: const Text("Detail Produk"),
          actions: [
            Consumer<FavoritProvider>(
              builder: (context, favoritProvider, child) {
                final isLiked = favoritProvider.isFavorit(item);
                return IconButton(
                  onPressed: () {
                    favoritProvider.toggleFavorit(item);
                  }, 
                  icon: Icon(
                    isLiked
                      ? Icons.favorite
                      : Icons.favorite_border,
                    color: Colors.red,
                  )
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Consumer<KeranjangProvider>(
                builder: (context, keranjangProvider, child) {
                  int jumlahBarang = keranjangProvider.item.fold(
                    0,
                    (total, item) => total + (item['jumlah'] as int)
                  );
                
                  return Badge(
                    isLabelVisible: jumlahBarang > 0,
                    alignment: AlignmentDirectional.topEnd,
                    offset: const Offset(-3, 3),
                    backgroundColor: Colors.red,

                    label: Text(
                      '$jumlahBarang',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => KeranjangPage(),
                          ),
                        );
                      }, 
                      icon: const Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.blue,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),

        body: SingleChildScrollView(
          child: Column(
            children: [

              GestureDetector(
                onTap: () {
                  _showZoomableImage(
                    context,
                    item["gambar"],
                  );
                },

                child: Image.network(
                  item["gambar"] ?? "",

                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,

                  errorBuilder:
                      (context, error, stackTrace) {
                    return const SizedBox(
                      height: 300,
                      child: Icon(
                        Icons.broken_image,
                        size: 40,
                      ),
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Text(
                      item['nama'] ?? '',

                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Rp. ${item['harga'] ?? 0}",

                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      "Deskripsi Produk",

                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      item['deskripsi'] ?? '',

                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16),

          decoration: const BoxDecoration(
            color: Colors.white,

            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, -2),
              ),
            ],
          ),

          child: Row(
            children: [

              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final Map<String, dynamic> dataUntukKeranjang = {
                      'id': item['id']?? '',
                      'nama': item['nama'] ?? '',
                      'harga': item['harga'] ?? 0,
                      'gambar': item['gambar'] ?? '',
                      'jumlah': 1,
                    };

                    Provider.of<KeranjangProvider>(context, listen: false)
                      .tambahKeranjang(dataUntukKeranjang);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration:
                            const Duration(seconds: 1),

                        content: Text(
                          "${item['nama']} ditambahkan ke keranjang",
                        ),
                      ),
                    );
                  },

                  icon: const Icon(
                    Icons.shopping_cart_outlined,
                    size: 18,
                  ),

                  label: const Text("Tambah"),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue,

                    side: const BorderSide(
                      color: Colors.blue,
                    ),

                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 15,
                    ),

                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    keranjangProvider.tambahKeranjang({
                      'id': item['id'],
                      'nama': item['nama'],
                      'harga': item['harga'],
                      'gambar': item['gambar'],
                      'jumlah': 1,
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => KeranjangPage(), 
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,

                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 15,
                    ),

                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),

                  child: const Text(
                    "Beli Sekarang",

                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}