import 'package:delivery/alamat.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final supabase = Supabase.instance.client;

  String namaUser = "Memuat...";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getUser();
  }

  Future<void> getUser() async{
    final user = supabase.auth.currentUser;
    if (user == null){
      setState(() {
        isLoading = false;
      });
      return;
    }

    try{
      final data = await supabase
        .from('users')
        .select('nama_user')
        .eq('user_id', user.id)
        .single();
      setState(() {
        namaUser = data['nama_user'] ?? "User";
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        namaUser = "Gagal memuat nama";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildDataUser(),
              const SizedBox(height: 20),
              _buildPesanan(),
              const SizedBox(height: 20),
              _buildMenuOpsi(),
              const SizedBox(height: 20),
              IconButton(
                onPressed: () async {
                  await Supabase.instance.client.auth.signOut();
                  if (mounted) {
                    setState(() {
                      namaUser = "Anda belum login";
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Berhasil logout"),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.logout),
              ),
            ],
          ),
        )
      ),
    );
  }

  Widget _buildStatusPesanan(
    IconData icon,
    String title,
    bool adaNotif,
  ) {
   return Column(
    children: [
      Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 32, color: Colors.blue),
          ),       
          if (adaNotif)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 4),
      Text(title, style: const TextStyle(fontSize: 12)),
    ],
   ); 
  }

  Widget _buildPesanan() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatusPesanan(
          Icons.inventory_2_outlined,
          "Disiapkan",
          true,
        ),
        _buildStatusPesanan(
          Icons.delivery_dining,
          "Diantar",
          true,
        ),
        _buildStatusPesanan(
          Icons.check_circle,
          "Sampai",
          false,
        ),
      ],
    );
  }

  Widget _buildDataUser() {
    final userLogin = supabase.auth.currentUser;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.blue.withValues(alpha: 0.2),
            child: const Icon(Icons.person, size: 45, color: Colors.blue,),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      namaUser,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                const SizedBox(height: 4),
                userLogin == null
                ? TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  onPressed: () async {
                    final suksesLogin = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginPage(),
                      ),
                    );
                    if (suksesLogin == true && mounted) {
                      setState(() {
                        isLoading = true;        
                      });
                      await getUser();
                    }
                  },
                  child: const Text("Login sekarang"),
                  )
                : const Text(
                  "Selamat datang kembali",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuOpsi() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(                  
                  decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 240, 240),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: 
                    _buildmenuItem(Icons.shopping_bag_outlined, "Riwayat", (){

                    }),
                ),
                const SizedBox(height: 14),
                Container(                 
                  decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 241, 255, 240),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                  _buildmenuItem(Icons.location_on, "Alamat", (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AlamatPage(),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 14),
                Container(
                  decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 247, 240, 255),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                  _buildmenuItem(Icons.shopping_bag_outlined, "Nanti", (){

                  }),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 255, 240),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: 
                    _buildmenuItem(Icons.shopping_bag_outlined, "Nanti", (){

                    }),
                ),
                const SizedBox(height: 14),
                Container(
                  decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 225, 240),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                  _buildmenuItem(Icons.shopping_bag_outlined, "nanti", (){

                  }),
                ),
                const SizedBox(height: 14),
                Container(
                  decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 227, 240, 255),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                  _buildmenuItem(Icons.shopping_bag_outlined, "Nanti", (){

                  }),
                ),
              ],
            ),
          ),
        ],
      )
    );
  }

  Widget _buildmenuItem(IconData icon, String title, VoidCallback onTap, {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.red : Colors.blue, size: 18),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isLogout ? Colors.red : Colors.black,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.blue, size: 18),
      onTap: onTap,
    );
  }
}