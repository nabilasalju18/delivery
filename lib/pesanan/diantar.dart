import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DiantarPage extends StatelessWidget {
  const DiantarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Stream<List<Map<String, dynamic>>> _ordersStream = Supabase.instance.client
      .from ('orders')
      .stream(primaryKey: ['id'])
      .eq('status', 'diantar')
      .order('id', ascending: false);
    return StreamBuilder<List<Map<String, dynamic>>>(
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
            child: Text("Tidak ada pesanan yg  sdang diantar"),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            final int id = order['id'] ?? 0;
            final String kodeUser = order['kode_user'] ?? 'Guest';
            final int totalHarga = order['total'] ?? 0;
            
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(
                  Icons.inventory_2_outlined,
                  color: Colors.blue,
                ),
                title: Text(
                  "Pesanan #$id ($kodeUser)",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text("Pesanan sedang diantar"),
                trailing: Text("Rp $totalHarga"),
              ),  
            );
          } 
        ); 
      }
    );
  }
}