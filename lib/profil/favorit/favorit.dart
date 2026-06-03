import 'package:delivery/profil/favorit/favoritprovider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavoritPage extends StatelessWidget {
  const FavoritPage({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final favoritProvider = context.watch<FavoritProvider>();
    final listFavorit = favoritProvider.favoritItem;

    return Scaffold(
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
    return ListView.builder(
      itemCount: items.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final produk = items[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(10),
          ),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadiusGeometry.circular(8),
              child: produk['gambar'] != null
                ? Image.network(
                    produk['gambar'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 50,
                      height: 50,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image),
                  ),   
            ),
            title: Text(
              produk['nama'] ?? 'Nama Produk',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              produk['harga'] ?? 'nanti aku isi',
              style: TextStyle(color: Colors.blue),
            ),
            trailing: IconButton(
              onPressed: () {
                provider.toggleFavorit(produk);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${produk['name']} dihapus dari favorit'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              }, 
              icon: Icon(Icons.favorite, color: Colors.red),
            ),
          )
        );
      },
    );
  }
}