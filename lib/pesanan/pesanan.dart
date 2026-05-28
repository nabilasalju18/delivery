import 'package:flutter/material.dart';
import 'package:delivery/pesanan/diantar.dart';
import 'package:delivery/pesanan/disiapkan.dart';
import 'package:delivery/pesanan/sampai.dart';

class PesananPage extends StatefulWidget {
  final int initialIndex;
  const PesananPage({super.key, required this.initialIndex});

  @override
  State<PesananPage> createState() => _PesananPageState();
}

class _PesananPageState extends State<PesananPage> {
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: widget.initialIndex, 
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Pesanan kamu"),
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.inventory_2_outlined),
                text: "Disiapkan",
              ),
              Tab(
                icon: Icon(Icons.delivery_dining),
                text: "Diantar",
              ),
              Tab(
                icon: Icon(Icons.check_circle),
                text: "Sampai",
              ),
            ]
          ),
        ),
        body: Expanded(
          child: TabBarView(
            children: [
              DisiapkanPage(),
              DiantarPage(),
              SampaiPage(),
            ],
          ),
        ),
      )
    );
  }   
}