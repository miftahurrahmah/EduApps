import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../model_edu/model_update_user.dart';
import '../utils/session_manager.dart';


class PageProfileUser extends StatefulWidget {
  const PageProfileUser({Key? key}) : super(key: key);

  @override
  State<PageProfileUser> createState() => _PageProfileUserState();
}

class _PageProfileUserState extends State<PageProfileUser> {
  late SessionLatihanManager session;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    session = SessionLatihanManager();
    getDataSession();
  }

  Future<void> getDataSession() async {
    await session.getSession();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.grey,
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 55,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '${isLoading ? 'Loading...' : session.Nama ?? 'Data tidak tersedia'}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 5),
                Divider(
                  thickness: 2,
                  color: Colors.grey[300],
                ),
                SizedBox(height: 5),
                ListTile(
                  title: Text(
                    'Username',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '${isLoading ? 'Loading...' : session.userName ?? 'Data tidak tersedia'}',
                  ),
                  leading: Icon(Icons.person),
                ),
                ListTile(
                  title: Text(
                    'Email',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '${isLoading ? 'Loading...' : session.email ?? 'Data tidak tersedia'}',
                  ),
                  leading: Icon(Icons.email),
                ),
                ListTile(
                  title: Text(
                    'NoHP',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '${isLoading ? 'Loading...' : session.nohp ?? 'Data tidak tersedia'}',
                  ),
                  leading: Icon(Icons.phone),
                ),
                SizedBox(height: 20),
                // ElevatedButton(
                //   onPressed: () {
                //     Navigator.pushAndRemoveUntil(
                //       context, MaterialPageRoute(builder: (context) => PageEditProfile()),
                //           (route) => false,
                //     );
                //   },
                //   style: ElevatedButton.styleFrom(
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(10),
                //     ),
                //     padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                //   ),
                //   child: Text(
                //     'Edit Profile',
                //     style: TextStyle(
                //       fontSize: 15,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class PageEditProfile extends StatefulWidget {
  const PageEditProfile({Key? key}) : super(key: key);

  @override
  State<PageEditProfile> createState() => _PageEditProfileState();
}

class _PageEditProfileState extends State<PageEditProfile> {
  late SessionLatihanManager session;
  late TextEditingController txtUsername;
  late TextEditingController txtNama;
  late TextEditingController txtEmail;
  late TextEditingController txtNoHp;
  late GlobalKey<FormState> keyForm;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    session = SessionLatihanManager();
    txtUsername = TextEditingController();
    txtNama = TextEditingController();
    txtEmail = TextEditingController();
    txtNoHp = TextEditingController();
    keyForm = GlobalKey<FormState>();
    getDataSession(); // Panggil method untuk mengisi nilai controller dari sesi
  }

  Future<void> getDataSession() async {
    await session.getSession();
    setState(() {
      // Set nilai pada controller
      txtUsername.text = session.userName ?? '';
      txtNama.text = session.Nama ?? '';
      txtEmail.text = session.email ?? '';
      txtNoHp.text = session.nohp ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          'Edit Profil',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Form(
            key: keyForm,
            child: Column(
              children: [
                SizedBox(height: 20),
                TextFormField(
                  controller: txtNama,
                  decoration: InputDecoration(
                    hintText: 'Nama',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: txtUsername,
                  decoration: InputDecoration(
                    hintText: 'Username',
                    prefixIcon: Icon(Icons.account_circle),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Username tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: txtEmail,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: txtNoHp,
                  decoration: InputDecoration(
                    hintText: 'No HP',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'No HP tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                MaterialButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(width: 1, color: Colors.blueGrey),
                  ),
                  onPressed: () {
                    if (keyForm.currentState!.validate()) {
                      updateAccount();
                    }
                  },
                  child: Text('Simpan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> updateAccount() async {
    try {
      setState(() {
        isLoading = true;
      });

      http.Response response = await http.post(
        Uri.parse('http://192.168.1.24/edukasi_server/updateUser.php'),
        body: {
          "username": txtUsername.text,
          "email": txtEmail.text,
          "nama": txtNama.text,
          "nohp": txtNoHp.text,
        },
      );

      print('Response JSON: ${response.body}');

      ModelUpdateProfile data = modelUpdateProfileFromJson(response.body);

      if (data.value == 1) {
        setState(() {
          isLoading = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${data.message}')),
          );

          // Pindah ke halaman profil
          Navigator.pop(context);
        });
      } else {
        setState(() {
          isLoading = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${data.message}')),
          );
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      });
    }
  }

  @override
  void dispose() {
    // Pastikan untuk dispose controller
    txtUsername.dispose();
    txtNama.dispose();
    txtEmail.dispose();
    txtNoHp.dispose();
    super.dispose();
  }
}


