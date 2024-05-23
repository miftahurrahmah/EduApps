import 'package:edu_apps/page_edu/page_berita.dart';
import 'package:edu_apps/page_edu/page_karyawan.dart';
import 'package:edu_apps/page_edu/page_login.dart';
import 'package:edu_apps/page_edu/page_profil_user.dart';
import 'package:edu_apps/utils/session_manager.dart';
import 'package:flutter/material.dart';


class PageBottomNavigationBar extends StatefulWidget {
  const PageBottomNavigationBar({Key? key});

  @override
  State<PageBottomNavigationBar> createState() =>
      _PageBottomNavigationBarState();
}

class _PageBottomNavigationBarState extends State<PageBottomNavigationBar>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  Color? containerColor;
  late SessionLatihanManager sessionManager;

  @override
  void initState() {
    super.initState();
    sessionManager = SessionLatihanManager();
    sessionManager.getSession();
    tabController = TabController(length: 3, vsync: this);
    containerColor = Colors.transparent;
    tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    setState(() {
      containerColor = Colors.blue;
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Aplikasi'),
        actions: [
          TextButton(onPressed: (){}, child: Text('Hi ${sessionManager.userName}')),
          //logout
          IconButton(onPressed: (){
            //clear session
            setState(() {
              sessionManager.clearSession();
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)
              => PageLoginApi()
              ),
                      (route) => false);
            });
          },
            icon: Icon(Icons.exit_to_app), tooltip: 'Logout',)
        ],
      ),
      body: GestureDetector(
        onTap: () {
          setState(() {
            containerColor = Colors.blue;
          });
        },
        child: TabBarView(
          controller: tabController,
          children: [
            // content
            PageBerita(),
            PageKaryawan(),
            PageProfileUser()
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TabBar(
            controller: tabController,
            labelColor: Colors.blue,
            tabs: const [
              Tab(
                text: "Berita",
                icon: Icon(Icons.search),
              ),
              Tab(
                text: "Karyawan",
                icon: Icon(Icons.person_add),
              ),
              Tab(
                text: "Profil",
                icon: Icon(Icons.person),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
