import 'package:delivery/keranjang.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'detail_produk.dart';
import 'keranjangprovider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> products = [];

  @override
  void initState() {
    super.initState();
    getProduct();
  }

  Future<void> getProduct() async{
    try {
      final data = await supabase
      .from('barang')
      .select();
    setState(() {
      products = List<Map<String, dynamic>>.from(data);
    });

    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(     
      child: SingleChildScrollView(  
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildAlamat(),
            const SizedBox(height: 20),
            _buildSearchBar(),
            const SizedBox(height: 20),
            _buildProduct(),
            // R03 = hr, R04 = admin, R05 = kepala toko,
          ],
        ),
      ),
    );
  }
  
  Widget _buildAlamat() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_on,
              color: Colors.blue.shade700,
              size: 22,
            ),
          ),

          const SizedBox(width: 12),

          // TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tsamaniya terdekat",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 2),

                const Text(
                  "Tsamaniya Kertosono",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // KERANJANG
          Consumer<KeranjangProvider>(
            builder: (context, keranjangProvider, child) {

              int jumlahBarang = keranjangProvider.item.fold(
                0,
                (total, item) => total + (item['jumlah'] as int),
              );

              return Badge(
                isLabelVisible: jumlahBarang > 0,
                label: Text(
                  '$jumlahBarang',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
                backgroundColor: Colors.red,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const KeranjangPage(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.blue,
                      size: 22,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
 
  Widget _buildSearchBar(){
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: "Cari produk kebutuhan...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildProduct(){
    final keranjangProvider = Provider.of<KeranjangProvider>(
      context,
      listen: false,
    );
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Produk",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 14),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: products.length,
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.68,
          ),
          itemBuilder: (context, index) {
            final product = products[index];

            return Container(
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
                      padding: const EdgeInsets.all(12),
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
                            "Rp ${product["harga"]}",
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
                                    };
                                    Provider.of<KeranjangProvider>(context, listen: false)
                                    .tambahKeranjang(dataUntukKeranjang);
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
        ),
      ],
    );
  }

 
}