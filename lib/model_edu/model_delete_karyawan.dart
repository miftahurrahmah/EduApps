import 'dart:convert';

List<Pegawai> pegawaiFromJson(String str) =>
    List<Pegawai>.from(json.decode(str).map((x) => Pegawai.fromJson(x)));

String pegawaiToJson(List<Pegawai> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Pegawai {
  Pegawai({
    required this.id,
    required this.nama,
    required this.nobp,
    required this.email,
    required this.nohp,
    required this.tanggalInput,
  });

  String id;
  String nama;
  String nobp;
  String email;
  String nohp;
  String tanggalInput;

  factory Pegawai.fromJson(Map<String, dynamic> json) => Pegawai(
    id: json["id"],
    nama: json["nama"],
    nobp: json["nobp"],
    email: json["email"],
    nohp: json["nohp"],
    tanggalInput: json["tanggal_input"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "nama": nama,
    "nobp": nobp,
    "email": email,
    "nohp": nohp,
    "tanggal_input": tanggalInput,
  };
}
