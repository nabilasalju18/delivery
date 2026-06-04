import 'package:delivery/profil/alamat/cabangprovider.dart';
import 'package:delivery/home/keranjang/keranjang.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'detail_produk.dart';
import 'keranjang/keranjangprovider.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../profil/alamat/alamat_tsamaniya.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

class TsamaniyaModel {
  final int? id;
  final String? namaCabang;
  final double? latitude;
  final double? longitude;
  double? distance;

  TsamaniyaModel({
    this.id,
    this.namaCabang,
    this.latitude,
    this.longitude,
    this.distance = 0.0,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final supabase = Supabase.instance.client;

  String formatRupiah(num harga) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(harga);
  }

  List<Map<String, dynamic>> products = [];

  @override
  void initState() {
    super.initState();
    getProduct();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      initCabang();
    });

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

  Future<void> initCabang() async {
    final provider = context.read<CabangProvider>();
    
    await provider.loadCabang();
    
    if (provider.sudahPilihCabang) return;
    
    final cabang = await getCabangTerdekat();
    
    if (cabang != null) {
      await provider.pilihCabang(
        cabang.id!,
        cabang.namaCabang!,
        "",
      );
    }
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception('GPS tidak aktif');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<List<TsamaniyaModel>> getCabang() async {
    final response = await supabase
        .from('lokasi_tsamaniya')
        .select();

    return response.map<TsamaniyaModel>((item) {
      return TsamaniyaModel(
        id: item['id'],
        namaCabang: item['nama_cabang'],
        latitude: (item['latitude'] as num).toDouble(),
        longitude: (item['longitude'] as num).toDouble(),
      );
    }).toList();
  }

  Future<TsamaniyaModel?> getCabangTerdekat() async {
    final cabangList = await getCabang();
    final pos = await _getCurrentLocation();

    for (final cabang in cabangList) {
      cabang.distance = Geolocator.distanceBetween(
        pos.latitude,
        pos.longitude,
        cabang.latitude!,
        cabang.longitude!,
      );
    }

    cabangList.sort(
      (a, b) => a.distance!.compareTo(b.distance!),
    );

    return cabangList.isNotEmpty
        ? cabangList.first
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final cabangProvider = context.watch<CabangProvider>();
      
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 149, 220, 246),
      bottomSheet:  _buildAlamatTsamaniya(
        cabangProvider.selectedCabangNama ??
        "Pilih Toko"
      ),
      body: SafeArea(     
        child: SingleChildScrollView(  
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildSearchBar(),
              const SizedBox(height: 16),
              _buildHighlight(),
              const SizedBox(height: 16),
              _buildProduct(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlamatTsamaniya(String namaCabang) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>  DaftarTokoPage(),
          ),
        );
      },
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                "Toko Terpilih: $namaCabang",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
            const Icon(
                Icons.chevron_right,
                color: Colors.white,
            ),
          ],
        ),
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
        const SizedBox(width: 4),
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
                    shape: BoxShape.circle,
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
    );
  }
  
  Widget _buildHighlight() {
    return CarouselSlider.builder(
      itemCount: products.length,
      options: CarouselOptions(
        height: 180,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 0.9,
      ),
      itemBuilder: (context, index, realIndex) {
        final product = products[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetailProdukPage(product: product),
              )
            );
          },
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white, width: 4), 
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    product['gambar'] ?? '',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.6),
                          Colors.transparent,
                        ],
                        begin: AlignmentGeometry.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    bottom: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product['nama'] ?? '',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          formatRupiah(product["harga"] ?? 0),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        );
      }
    );
  }
  
  Widget _buildProduct(){
    final keranjangProvider = Provider.of<KeranjangProvider>(
      context,
      listen: false,
    );
    final pages = (products.length / 6).ceil();
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

        const SizedBox(height: 10),

        SizedBox(
          height: MediaQuery.of(context).size.height * 0.87,
          child: PageView.builder(
            itemCount: pages,
            itemBuilder: (context, index) {
              final start = index * 6;
              final end = (start + 6 > products.length) 
                ? products.length 
                : start + 6;
              final pageProducts = products.sublist(start, end);

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: pageProducts.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.68,
                ),
                itemBuilder: (context, index) {
                  final product = pageProducts[index];

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
              );
            },
          ),
        ),
     
      ],
    );
  }
 
}