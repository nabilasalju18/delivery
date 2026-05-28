import 'package:delivery/berhasil.dart';
import 'package:delivery/inputguest.dart';
import 'package:delivery/keranjangprovider.dart';
import 'package:delivery/login.dart';
import 'package:delivery/wa.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage>{
  String metodePembayaran = "COD (Cash On Delivery)";
  Map<String, dynamic>? alamat;
  
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getAlamat();
  }

  Future<void> getAlamat() async {
    final userLogin = await Supabase.instance.client.auth.currentUser;
    
    if (userLogin == null) {
      setState(() {
        alamat = null;
        isLoading = false;
      });
      return;
    }

    try {
      final dataUser = await Supabase.instance.client
        .from('users')
        .select('kode_user')
        .eq('user_id', userLogin.id)
        .maybeSingle();

      if (dataUser == null || dataUser['kode_user'] == null){
        setState(() {
          alamat = null;
          isLoading = false;
        });
        return;
      }

      final response = await Supabase.instance.client
        .from('alamat')
        .select()
        .eq('kode_user', dataUser['kode_user'])
        .limit(1)
        .maybeSingle();

      setState(() {
        alamat = response;
        isLoading = false;
      });
    } catch (e){
      ("Eror ambil alamat checkout: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Diantar ke",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            _buildAlamat(),
            const SizedBox(height: 20),
            const Text(
              "Pesanan Kamu",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            _buildPesanan(),
            const SizedBox(height: 20),
            const Text(
              "Pembayaran",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            _buildTotal(),
             const Divider(),
          ],
        ),
      ),
      bottomNavigationBar: _buildPembayaran(),
    );
  }

  Widget _buildAlamat() {
    if(alamat == null) {
      return _buildFormAlamatGuest();
    }
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: const Icon(Icons.location_on),
        title: Text(alamat!['nama_penerima'], style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(alamat!['no_telpon']),
            Text(alamat!['alamat_lengkap']),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit, size: 20),
          onPressed: () {
            
          },
        ),
      ),
    );
  }

  Widget _buildFormAlamatGuest() {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            "Belum ada alamat",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const InputGuestPage(),
                      ),
                    );

                    if (result != null) {
                      setState(() {
                        alamat = result;
                      });
                    }
                  }, 
                  child: const Text("Tambah Alamat"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context, 
                      MaterialPageRoute(
                        builder: (_) => const LoginPage(),
                      ),
                    );
                    if (result == true) {
                      setState(() {
                        isLoading = true;
                      });
                      await getAlamat();
                    }
                  }, 
                  child: const Text("Login"),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
 }
  
  Widget _buildPesanan() {
    final keranjangProvider = Provider.of<KeranjangProvider>(context);
    final keranjang = keranjangProvider.item.where((item) => item['terpilih'] == true).toList();
   
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: keranjang.length,
      itemBuilder: (context, index) {
        final item = keranjang[index];

        final int harga = item['harga'] as int? ?? 0;
        final int jumlah = item['jumlah'] as int? ?? 0;
        
        return Card(
          child: ListTile(
            title: Text(
              item['nama'] ?? 'Produk', 
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
            subtitle: Text(
              "Jumlah: ${item['jumlah'] as int}",
            ),
            trailing: Text(
              "Rp ${harga * jumlah}",
              style: TextStyle(fontSize: 14),
            ),
          ),   
        );
      }
      
    );
  }

  Widget _buildTotal() {
    final keranjangProvider = Provider.of<KeranjangProvider>(context);
    final keranjang = keranjangProvider.item.where((item) => item['terpilih'] == true).toList();
    int total= 0;

    for (var item in keranjang) {
      total += (item['harga'] as int) * (item['jumlah'] as int);
    }

    int ongkir = 5000;
    int subtotal = total;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Metode Pembayaran", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Text("COD (Cash On Delivery)"),
            const Text("Rincian pembayaran", style: TextStyle(fontSize: 16, fontWeight:FontWeight.bold)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Subtotal"),
                Text("Rp $subtotal"),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Ongkir"),
                Text("Rp $ongkir"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPembayaran() {
    final keranjangProvider = Provider.of<KeranjangProvider>(context);
    final keranjang = keranjangProvider.item.where((item) => item['terpilih'] == true).toList();
    int total = 0;

    for (var item in keranjang) {
      total += (item['harga'] as int) * (item['jumlah'] as int);
    }

    int ongkir = 5000;
    int subtotal = total;
    int grandTotal = ongkir + subtotal;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Total Pembayaran",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Rp $grandTotal",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 140,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () async {
                  if (alamat == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Isi alamat pengiriman dulu ya")),
                    );
                    return;
                  }

                  final supabase = Supabase.instance.client;
                  final userLogin = supabase.auth.currentUser;
                  
                  String? kodeUser;
                  String infoPembeli = "Tamu (Belum Login)";

        
                  if (userLogin != null) {
                  
                    try {
                      final dataUser = await supabase
                          .from('users')
                          .select('kode_user, nama_user')
                          .eq('user_id', userLogin.id)
                          .maybeSingle();
                      
                      if (dataUser != null && dataUser['kode_user'] != null) {
                        kodeUser = dataUser['kode_user'];
                        infoPembeli = "${dataUser['nama_user']} ($kodeUser)";
                      }
                    } catch (e) {
                      debugPrint("Gagal ambil profil user: $e");
                    }
                  }

                  if (kodeUser == null && alamat != null){
                    kodeUser = alamat!['kode_user'];
                    infoPembeli = "${alamat!['nama_penerima']} ($kodeUser)";
                  }

                  try {
                    // Insert ke tabel 'orders'
                    final order = await supabase
                        .from('orders')
                        .insert({
                          'kode_user': kodeUser,
                          'id_alamat': alamat!['id'],
                          'total': grandTotal,
                          'status': 'processing',
                        })
                        .select()
                        .single();

                    final orderId = order['id'];

                  // Insert list belanjaan ke tabel 'order_items'
                    String detailBarang = '';
                    for (var item in keranjang) {
                      await supabase.from('order_items').insert({
                        'id_order': orderId,   
                        'id_barang': item['id'], 
                        'nama': item['nama'],
                        'qty': item['jumlah'],
                        'harga': item['harga'],
                      });
                      detailBarang += '- ${item['nama']} (x${item['jumlah']})\n';
                    }

                    final String pesanUntukAdmin = '''
  -<{ ADA PESANAN BARU }>-

  Hallo Admin Tsamaniya, ada pesanan masuk nih. Yuk segera siapin pesanan dan struknya!

  RINGKASAN PESANAN
  ID Order   : #$orderId
  Tipe User  : $infoPembeli
  Total      : Rp $grandTotal
  =========================

  DAFTAR BARANG:
  $detailBarang
  =========================

  Mohon segera diproses ya min!
  ''';

                    keranjangProvider.clearKeranjang();

                    await WhatAppService.kirimKeAdmin(
                      pesanStruk: pesanUntukAdmin,
                    );

                    if (!mounted) return;
                    
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BerhasilPage(
                          totalPembayaran: grandTotal,
                          daftarBarang: keranjang,
                        ),
                      ),
                      (route) => false,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Pesanan berhasil dibuat")),
                    );
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Gagal memproses pesanan: $e")),
                    );
                  }
                },
                child: const Text("Checkout", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

}