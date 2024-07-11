import 'package:flutter/material.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          drawer: Drawer(
            child: ListView(
              children: [
                DrawerHeader(
                  child: Text('Drawer Header'),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                ),
                ListTile(
                  title: Text('Item 1'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text('Item 2'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          appBar: AppBar(
            leading: Builder(
              builder: (BuildContext context) {
                return IconButton(
                  icon: const Icon(
                    Icons.menu,
                    color: Colors.black87,
                    size: 30,
                  ),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                );
              },
            ),
            leadingWidth: 40,
            centerTitle: true,
            title: TabBar(
              tabAlignment: TabAlignment.center,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              enableFeedback: false,
              isScrollable: true,
              indicatorColor: Color(0xffFF2E4D),
              labelColor: Color(0xffFF2E4D),
              unselectedLabelColor: Color(0xffafafb0),
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: TextStyle(fontSize: 20),
              tabs: [
                Tab(
                  text: '关注',
                ),
                Tab(
                  text: '发现',
                ),
                Tab(
                  text: '南京',
                )
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.black87, size: 30),
                onPressed: () {},
              ),
            ],
            backgroundColor: const Color(0xffffffff),
          ),
          body: TabBarView(children: [
            ListView(
              children: [
                ListTile(
                  title: Text('第1个界面'),
                ),
                ListTile(
                  title: Text('第1个界面'),
                ),
                ListTile(
                  title: Text('第1个界面'),
                ),
              ],
            ),
            ListView(
              children: [
                ListTile(
                  title: Text('第2个界面'),
                ),
                ListTile(
                  title: Text('第2个界面'),
                ),
                ListTile(
                  title: Text('第2个界面'),
                ),
              ],
            ),
            ListView(
              children: [
                ListTile(
                  title: Text('第3个界面'),
                ),
                ListTile(
                  title: Text('第3个界面'),
                ),
                ListTile(
                  title: Text('第3个界面'),
                ),
              ],
            ),
          ]),
        ));
  }
}
