import 'dart:convert';
import 'package:edu_apps/model_edu/model_add_karyawan.dart';
import 'package:edu_apps/page_edu/page_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../model_edu/model_karyawan.dart';


//list karyawan

class PageKaryawan extends StatefulWidget {
  @override
  State<PageKaryawan> createState() => _PageKaryawanState();
}

class _PageKaryawanState extends State<PageKaryawan> {
  List<Datum> pegawaiList = [];
  List<Datum> filteredPegawaiList = [];
  TextEditingController txtCari = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(
          Uri.parse("http://192.168.1.24/edukasi_server/getPegawai.php"));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['isSuccess'] == true) {
          setState(() {
            pegawaiList = List<Datum>.from(
                jsonResponse['data'].map((x) => Datum.fromJson(x)));
            filteredPegawaiList = List<Datum>.from(pegawaiList);
          });
        } else {
          throw Exception('Failed to load data: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }

  void filterPegawaiList(String keyword) {
    setState(() {
      filteredPegawaiList = pegawaiList
          .where((pegawai) =>
      pegawai.nama.toLowerCase().contains(keyword.toLowerCase()) ||
          pegawai.nobp.toLowerCase().contains(keyword.toLowerCase()) ||
          pegawai.email.toLowerCase().contains(keyword.toLowerCase()) ||
          pegawai.nohp.toLowerCase().contains(keyword.toLowerCase()) ||
          (pegawai.tanggalInput != null &&
              pegawai.tanggalInput
                  .toString()
                  .toLowerCase()
                  .contains(keyword.toLowerCase())))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Data Karyawan',
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
                hintText: 'Cari karyawan...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                filterPegawaiList(value);
              },
            ),
          ),
          Expanded(
            child: filteredPegawaiList.isEmpty
                ? Center(
              child: Text('Data tidak ditemukan'),
            )
                : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: <DataColumn>[
                  DataColumn(
                    label: Text(
                      'Nama',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                    tooltip: 'Nama',
                  ),
                  DataColumn(
                    label: Text(
                      'No BP',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                    tooltip: 'No BP',
                  ),
                  DataColumn(
                    label: Text(
                      'Email',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                    tooltip: 'Email',
                  ),
                  DataColumn(
                    label: Text(
                      'No. HP',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                    tooltip: 'No. HP',
                  ),
                  DataColumn(
                    label: Text(
                      'Tanggal Daftar',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                    tooltip: 'Tanggal Daftar',
                  ),
                  DataColumn(
                    label: Text(
                      'Aksi',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                    tooltip: 'Aksi',
                  ),
                ],
                rows: filteredPegawaiList
                    .asMap()
                    .entries
                    .map(
                      (entry) => DataRow(
                    cells: [
                      DataCell(Text(entry.value.nama)),
                      DataCell(Text(entry.value.nobp)),
                      DataCell(Text(entry.value.email)),
                      DataCell(Text(entry.value.nohp)),
                      DataCell(
                        Text(
                          entry.value.tanggalInput != null
                              ? entry.value.tanggalInput.toString()
                              : '',
                        ),
                      ),
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Hapus Data'),
                                    content: Text(
                                        'Apakah Anda yakin ingin menghapus data ini?'
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop();
                                        },
                                        child: Text('Batal'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          // Kirim request untuk menghapus data karyawan
                                          http.post(
                                            Uri.parse('http://192.168.1.24/edukasi_server/delPegawai.php'),
                                            body: {'id': entry.value.id.toString()}, // Kirim ID karyawan yang akan dihapus
                                          ).then((response) {
                                            // Memeriksa respons dari server
                                            if (response.statusCode == 200) {
                                              var jsonResponse = json.decode(response.body);
                                              if (jsonResponse['isSuccess'] == true) {
                                                // Jika penghapusan berhasil, hapus data dari daftar
                                                setState(() {
                                                  filteredPegawaiList.removeAt(entry.key);
                                                });
                                              } else {
                                                // Jika penghapusan gagal, tampilkan pesan kesalahan
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      title: Text("Berhasil"),
                                                      content: Text("${jsonResponse['message']}"),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.pushAndRemoveUntil(
                                                              context,
                                                              MaterialPageRoute(builder: (context) => PageBottomNavigationBar()),
                                                                  (route) => false,
                                                            );
                                                          },
                                                          child: Text("OK"),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              }
                                            } else {
                                              // Jika respons server tidak berhasil, tampilkan pesan kesalahan umum
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: Text("Gagal"),
                                                    content: Text("Terjadi kesalahan saat mengirim data ke server"),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(context);
                                                        },
                                                        child: Text("OK"),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            }
                                          }).catchError((error) {
                                            // Tangani kesalahan koneksi atau lainnya
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: Text("Gagal"),
                                                  content: Text("Terjadi kesalahan: $error"),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text("OK"),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          });
                                          Navigator.of(context).pop(true); // Tutup dialog
                                        },
                                        child: Text('Ya'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              icon: Icon(Icons.delete),
                            ),
                            IconButton(
                              onPressed: () {
                                _editData(entry.value); // Edit data
                              },
                              icon: Icon(Icons.edit),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PageTambahKaryawan()),
          ).then((value) {
            if (value == true) {
              // Jika berhasil menambahkan data, perbarui tampilan
              fetchData();
            }
          });
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _deleteData(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Konfirmasi"),
          content: Text("Apakah Anda yakin ingin menghapus data ini?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                _performDelete(id); // Panggil metode untuk menghapus data
              },
              child: Text("Hapus"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performDelete(int id) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.24/edukasi_server/deletePegawai.php'),
        body: {'id': id.toString()},
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['is_success'] == true) {
          // Jika penghapusan berhasil, perbarui tampilan
          fetchData();
          Navigator.pop(context);
        } else {
          // Jika gagal, tampilkan pesan kesalahan
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Gagal"),
                content:
                Text("Terjadi kesalahan: ${jsonResponse['message']}"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("OK"),
                  ),
                ],
              );
            },
          );
        }
      } else {
        // Jika gagal, tampilkan pesan kesalahan umum
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Gagal"),
              content:
              Text("Terjadi kesalahan saat mengirim data ke server"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      }
    } catch (error) {
      // Tangani kesalahan koneksi atau lainnya
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Gagal"),
            content: Text("Terjadi kesalahan: $error"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  void _editData(Datum data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PageEditKaryawan(data: data),
      ),
    ).then((value) {
      if (value == true) {
        // Jika berhasil mengedit data, perbarui tampilan
        fetchData();
      }
    });
  }
}



//add karyawan
class PageTambahKaryawan extends StatefulWidget {
  const PageTambahKaryawan({Key? key}) : super(key: key);

  @override
  State<PageTambahKaryawan> createState() => _PageTambahKaryawanState();
}

class _PageTambahKaryawanState extends State<PageTambahKaryawan> {
  TextEditingController txtNama = TextEditingController();
  TextEditingController txtNobp = TextEditingController();
  TextEditingController txtNohp = TextEditingController();
  TextEditingController txtEmail = TextEditingController();
  TextEditingController tanggalInput = TextEditingController();

  GlobalKey<FormState> keyForm = GlobalKey<FormState>();

  bool isLoading = false;

  Future<void> registerPegawai() async {
    try {
      setState(() {
        isLoading = true;
      });

      http.Response response = await http.post(
        Uri.parse('http://192.168.1.24/edukasi_server/addPegawai.php'),
        body: {
          "nama": txtNama.text,
          "nobp": txtNobp.text,
          "nohp": txtNohp.text,
          "email": txtEmail.text,
          "tanggal_input": tanggalInput.text,
        },
      );

      ModelAddPegawai data = modelAddPegawaiFromJson(response.body);

      setState(() {
        isLoading = false;
      });

      if (data.value == 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${data.message}')),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => PageBottomNavigationBar()),
              (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${data.message}')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: ${e.toString()}')),
        );
      });
    }
  }

  Future<void> selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        tanggalInput.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          'Tambah Karyawan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: keyForm,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20),
                TextFormField(
                  validator: (val) {
                    return val!.isEmpty ? "Tidak boleh kosong" : null;
                  },
                  controller: txtNama,
                  decoration: InputDecoration(
                    hintText: 'Nama Lengkap',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  validator: (val) {
                    return val!.isEmpty ? "Tidak boleh kosong" : null;
                  },
                  controller: txtNobp,
                  decoration: InputDecoration(
                    hintText: 'No BP',
                    prefixIcon: Icon(Icons.people_outline_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  validator: (val) {
                    return val!.isEmpty ? "Tidak boleh kosong" : null;
                  },
                  controller: txtEmail,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  validator: (val) {
                    return val!.isEmpty ? "Tidak boleh kosong" : null;
                  },
                  controller: txtNohp,
                  decoration: InputDecoration(
                    hintText: 'No HP',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  onTap: () {
                    selectDate();
                  },
                  validator: (val) {
                    return val!.isEmpty ? "Tidak boleh kosong" : null;
                  },
                  controller: tanggalInput,
                  decoration: InputDecoration(
                    hintText: 'Tanggal Input',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (keyForm.currentState?.validate() == true) {
                      await registerPegawai();
                    }
                  },
                  child: Text('SIMPAN'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


//edit karyawan
class PageEditKaryawan extends StatefulWidget {
  final Datum data;

  const PageEditKaryawan({Key? key, required this.data}) : super(key: key);

  @override
  State<PageEditKaryawan> createState() => _PageEditKaryawanState();
}

class _PageEditKaryawanState extends State<PageEditKaryawan> {
  late TextEditingController txtNamaLengkap;
  late TextEditingController txtEmail;
  late TextEditingController txtNoBP;
  late TextEditingController txtNoHP;
  GlobalKey<FormState> keyForm = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    txtNamaLengkap = TextEditingController(text: widget.data.nama);
    txtEmail = TextEditingController(text: widget.data.email);
    txtNoBP = TextEditingController(text: widget.data.nobp);
    txtNoHP = TextEditingController(text: widget.data.nohp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          'Edit Data Karyawan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: keyForm,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20),
                TextFormField(
                  validator: (val) {
                    return val!.isEmpty ? "Tidak boleh kosong" : null;
                  },
                  controller: txtNamaLengkap,
                  decoration: InputDecoration(
                    hintText: 'Nama Lengkap',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  validator: (val) {
                    return val!.isEmpty ? "Tidak boleh kosong" : null;
                  },
                  controller: txtNoBP,
                  decoration: InputDecoration(
                    hintText: 'No BP',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  validator: (val) {
                    return val!.isEmpty ? "Tidak boleh kosong" : null;
                  },
                  controller: txtEmail,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  validator: (val) {
                    return val!.isEmpty ? "Tidak boleh kosong" : null;
                  },
                  controller: txtNoHP,
                  decoration: InputDecoration(
                    hintText: 'No HP',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (keyForm.currentState?.validate() == true) {
                      // Kirim data perubahan ke server
                      http.post(
                        Uri.parse('http://192.168.1.24/edukasi_server/updatePegawai.php'),
                        body: {
                          'id': widget.data.id.toString(),
                          'nama': txtNamaLengkap.text,
                          'nobp': txtNoBP.text,
                          'email': txtEmail.text,
                          'nohp': txtNoHP.text,
                        },
                      ).then((response) {
                        if (response.statusCode == 200) {
                          var jsonResponse = json.decode(response.body);
                          if (jsonResponse['is_success'] == true) {
                            // Jika pembaruan berhasil, kembalikan data yang diperbarui ke halaman sebelumnya
                            Navigator.pop(context, true); // Sinyal perubahan berhasil
                          } else {
                            // Jika pembaruan gagal, tampilkan pesan kesalahan
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text("Gagal"),
                                  content: Text("Terjadi kesalahan: ${jsonResponse['message']}"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text("OK"),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        } else {
                          // Jika respons server tidak berhasil, tampilkan pesan kesalahan umum
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text("Gagal"),
                                content: Text("Terjadi kesalahan saat mengirim data ke server"),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text("OK"),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      }).catchError((error) {
                        // Tangani kesalahan koneksi atau lainnya
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("Gagal"),
                              content: Text("Terjadi kesalahan: $error"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text("OK"),
                                ),
                              ],
                            );
                          },
                        );
                      });
                    }
                  },
                  child: const Text("SIMPAN"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Pastikan untuk membersihkan controller
    txtNamaLengkap.dispose();
    txtEmail.dispose();
    txtNoBP.dispose();
    txtNoHP.dispose();
    super.dispose();
  }
}



