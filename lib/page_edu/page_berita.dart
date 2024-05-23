import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../model_edu/model_berita.dart';



class PageBerita extends StatefulWidget {
  const PageBerita({Key? key}) : super(key: key);

  @override
  State<PageBerita> createState() => _PageBeritaState();
}

class _PageBeritaState extends State<PageBerita> {
  late Future<List<Datum>?> _beritaFuture;
  TextEditingController txtCari = TextEditingController();

  @override
  void initState() {
    super.initState();
    _beritaFuture = getBerita();
  }

  Future<List<Datum>?> getBerita() async {
    try {
      http.Response response = await http.get(
          Uri.parse("http://192.168.1.24/edukasi_server/getBerita.php"));
      return modelBeritaFromJson(response.body).data;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
      return null;
    }
  }

  List<Datum> filterBerita(List<Datum>? berita, String keyword) {
    if (berita == null) return [];
    if (keyword.isEmpty) return berita;
    return berita.where((item) =>
        item.judul.toLowerCase().contains(keyword.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'Berita Edukasi',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                controller: txtCari,
                decoration: InputDecoration(
                  hintText: 'Cari berita...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (_) {
                  setState(() {});
                },
              ),
            ),
            Expanded(
              child: FutureBuilder(
                future: _beritaFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Colors.orange,
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(snapshot.error.toString()),
                    );
                  } else if (snapshot.hasData) {
                    List<Datum>? berita = snapshot.data as List<Datum>?;
                    List<Datum> filteredBerita = filterBerita(
                        berita, txtCari.text); // Filter the news
                    return filteredBerita.isEmpty
                        ? Center(
                      child: Text('Tidak ada berita yang ditemukan.'),
                    )
                        : ListView.builder(
                      itemCount: filteredBerita.length,
                      itemBuilder: (context, index) {
                        Datum data = filteredBerita[index];
                        return Padding(
                          padding: const EdgeInsets.all(10),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetailBerita(data),
                                ),
                              );
                            },
                            child: Card(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: ClipRRect(
                                      borderRadius:
                                      BorderRadius.circular(10),
                                      child: Center(
                                        child: Image.network(
                                          'http://'
                                              '192.168.1.24/edukasi_server/gambar_berita/${data
                                              .gambar}',
                                          width: 250,
                                          height: 300,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  ListTile(
                                    title: Text(
                                      data.judul,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange,
                                        fontSize: 18,
                                      ),
                                    ),
                                    subtitle: Text(
                                      data.berita,
                                      maxLines: 2,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return Center(
                      child: Text('No data available.'),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}





class DetailBerita extends StatelessWidget {
  final Datum? data;
  const DetailBerita(this.data, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Berita Edukasi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: data != null
          ? ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                'http://192.168.1.24/edukasi_server/gambar_berita/${data?.gambar}',
                height: 300,
                fit: BoxFit.fill,
              ),
            ),
          ),
          ListTile(
            title: Text(
              data!.judul,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            trailing: const Icon(
              Icons.star,
              color: Colors.red,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16, bottom: 16, left: 16),
            child: Text(
              data!.berita,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              textAlign: TextAlign.justify,
            ),
          )
        ],
      )
          : Center(
        child: Text('Data tidak tersedia.'),
      ),
    );
  }
}
