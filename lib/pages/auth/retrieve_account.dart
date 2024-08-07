import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '啧啧啧',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: '首页'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late TabController _tabC;
  var tabs = ["美妆", "生活用品"];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _contentView(context, widget.title));
  }

  _contentView(context, title) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    double pinnedHeaderHeight = statusBarHeight + kToolbarHeight;
    return ExtendedNestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          //标题
          SliverAppBar(
              pinned: true,
              floating: true,
              backgroundColor: Colors.white,
              title: Container(
                alignment: Alignment.centerLeft,
                width: double.infinity,
                child: Text(
                  title,
                  style: const TextStyle(
                      fontSize: 18.0,
                      color: Colors.black,
                      fontFamily: "PingFang"),
                ),
              )),
          SliverToBoxAdapter(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16.1, 16.0, 16.0, 0.0),
                  child: Row(
                    children: [
                      //头像+姓名
                      Row(
                        children: [
                          Container(
                              //圆形图片
                              child: ClipOval(
                            child: Image.network(
                              "https://img0.baidu.com/it/u=2043226837,3088107037&fm=253&fmt=auto&app=138&f=JPEG?w=667&h=500",
                              width: 35.0,
                              height: 35.0,
                              fit: BoxFit.cover,
                            ),
                          )),
                          Container(
                            margin: EdgeInsets.only(left: 10.0),
                            child: Text(
                              "张三",
                              style: TextStyle(
                                  fontSize: 14.0, fontFamily: "PingFang"),
                            ),
                          )
                        ],
                      ),
                      //更多
                      Expanded(
                        child: Container(
                            color: Colors.white,
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              onTap: () {
                                print("点击了更多");
                              },
                              child: const Text(
                                "更多",
                                style: TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.black,
                                    fontFamily: "PingFang"),
                              ),
                            )),
                      ),
                    ],
                  ),
                ),
                //简介
                Container(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
                  color: Colors.white,
                  child: Container(
                    //边框设置
                    decoration: BoxDecoration(
                      //背景
                      color: const Color(0xFFE2E2E2),
                      //设置四周圆角 角度
                      borderRadius:
                          const BorderRadius.all(Radius.circular(10.0)),
                      //设置四周边框
                      border: Border.all(width: 1, color: Colors.black26),
                    ),
                    padding: const EdgeInsets.fromLTRB(10.0, 12.0, 10.0, 20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: double.infinity,
                          child: Text("简介",
                              style: TextStyle(
                                  fontSize: 15.0, color: Colors.black)),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 10.0),
                          child: const Text(
                            "先帝创业未半而中道崩殂，今天下三分，益州疲弊，此诚危急存亡之秋也。然侍卫之臣不懈于内，忠志之士忘身于外者，盖追先帝之殊遇，欲报之于陛下也。诚宜开张圣听，以光先帝遗德，恢弘志士之气，不宜妄自菲薄，引喻失义，以塞忠谏之路也。宫中府中，俱为一体，陟罚臧否，不宜异同。若有作奸犯科及为忠善者，宜付有司论其刑赏，以昭陛下平明之理，不宜偏私，使内外异法也。侍中、侍郎郭攸之、费祎、董允等，此皆良实，志虑忠纯，是以先帝简拔以遗陛下。愚以为宫中之事，事无大小，悉以咨之，然后施行，必能裨补阙漏，有所广益。",
                            style: TextStyle(
                                fontSize: 15.0, color: Colors.black45),
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ];
      },
      pinnedHeaderSliverHeightBuilder: () {
        return pinnedHeaderHeight;
      },
      onlyOneScrollInBody: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _tabars(),
            _tarbarview(),
          ],
        ),
      ),
    );
  }

  //tabars设置
  _tabars() {
    return Row(
      children: [
        TabBar(
          labelColor: Colors.amberAccent,
          unselectedLabelColor: Colors.black,
          indicatorColor: Colors.amberAccent,

          // 选择的样式
          labelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          // 未选中的样式
          unselectedLabelStyle: const TextStyle(
            fontSize: 16,
          ),
          indicatorWeight: 5.0,
          isScrollable: true,
          indicatorSize: TabBarIndicatorSize.label,
          indicatorPadding: EdgeInsets.only(left: 10.0, right: 10.0),

          controller: _tabC,
          tabs: tabs
              .map(
                (label) => Padding(
                  padding: EdgeInsets.only(right: 1.0),
                  child: Tab(text: "$label"),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  //tab下的view
  _tarbarview() {
    return Expanded(
      child: TabBarView(
          controller: _tabC,
          physics: NeverScrollableScrollPhysics(),
          children: [
            //因为有两个tabar所以写死了两个Container
            //在实际开发中我们通过接口获取tabar和children的数量 用list存储
            Container(child: _setListData()),
            Container(
              child: Text(
                "呵呵哈哈哈",
                style: const TextStyle(fontSize: 18.0, color: Colors.black),
              ),
            ),
          ]),
    );
  }

  //tabarView里边的列表展示
  _setListData() {
    List myLists = [];
    myLists.add({
      "img":
          "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg9.doubanio.com%2Fview%2Frichtext%2Flarge%2Fpublic%2Fp151324064.jpg&refer=http%3A%2F%2Fimg9.doubanio.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1648865031&t=8c56e7b36dbdf8c413ead7973f8ab522",
      "name": "心宽方能事达，心静才能人和",
      "desc": "不惧他人的嘲讽，不惧人性的苍凉，不惧命运的无常，他用脚步丈量广袤的土地，用双手托起生命的光亮。",
    });
    myLists.add({
      "img":
          "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg1.doubanio.com%2Fview%2Frichtext%2Flarge%2Fpublic%2Fp241945378.jpg&refer=http%3A%2F%2Fimg1.doubanio.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1648865031&t=3743225355e7b0b1128db64a85b585d7",
      "name": "心宽方能事达，心静才能人和",
      "desc": "不惧他人的嘲讽，不惧人性的苍凉，不惧命运的无常，他用脚步丈量广袤的土地，用双手托起生命的光亮。",
    });
    myLists.add({
      "img":
          "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg1.doubanio.com%2Fview%2Frichtext%2Flarge%2Fpublic%2Fp159958728.jpg&refer=http%3A%2F%2Fimg1.doubanio.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1648865031&t=aab5f2636fc27d47089546757f1204e8",
      "name": "心宽方能事达，心静才能人和",
      "desc": "古希腊人那里，良好生活与行动不可分离，良古希腊人那里，良好生活与行动不可分离，良行动不可分离，良好行动不可分离，良好",
    });
    myLists.add({
      "img":
          "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg9.doubanio.com%2Fview%2Frichtext%2Flarge%2Fpublic%2Fp151324064.jpg&refer=http%3A%2F%2Fimg9.doubanio.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1648865031&t=8c56e7b36dbdf8c413ead7973f8ab522",
      "name": "心宽方能事达，心静才能人和",
      "desc": "不惧他人的嘲讽，不惧人性的苍凉，不惧命运的无常，他用脚步丈量广袤的土地，用双手托起生命的光亮。",
    });
    myLists.add({
      "img":
          "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg1.doubanio.com%2Fview%2Frichtext%2Flarge%2Fpublic%2Fp241945378.jpg&refer=http%3A%2F%2Fimg1.doubanio.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1648865031&t=3743225355e7b0b1128db64a85b585d7",
      "name": "心宽方能事达，心静才能人和",
      "desc": "当生活出现重大磨难，挑战人性的时候，任何举措似乎都无可厚非离，良好古希腊人那里，良好生活与行动不可分离，良行动不可分离，良好",
    });
    myLists.add({
      "img":
          "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg1.doubanio.com%2Fview%2Frichtext%2Flarge%2Fpublic%2Fp159958728.jpg&refer=http%3A%2F%2Fimg1.doubanio.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1648865031&t=aab5f2636fc27d47089546757f1204e8",
      "name": "心宽方能事达，心静才能人和",
      "desc": "当生活出现重大磨难，挑战人性的时候，任何举措似乎都无可厚非",
    });
    myLists.add({
      "img":
          "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg9.doubanio.com%2Fview%2Frichtext%2Flarge%2Fpublic%2Fp151324064.jpg&refer=http%3A%2F%2Fimg9.doubanio.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1648865031&t=8c56e7b36dbdf8c413ead7973f8ab522",
      "name": "心宽方能事达，心静才能人和",
      "desc": "不惧他人的嘲讽，不惧人性的苍凉，不惧命运的无常，他用脚步丈量广袤的土地，用双手托起生命的光亮。",
    });
    myLists.add({
      "img":
          "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg1.doubanio.com%2Fview%2Frichtext%2Flarge%2Fpublic%2Fp241945378.jpg&refer=http%3A%2F%2Fimg1.doubanio.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1648865031&t=3743225355e7b0b1128db64a85b585d7",
      "name": "心宽方能事达，心静才能人和",
      "desc": "不惧他人的嘲讽，不惧人性的苍凉，不惧命运的无常，他用脚步丈量广袤的土地，用双手托起生命的光亮。",
    });

    return Container(
      child: ListView.builder(
          itemCount: myLists.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            var listBean = myLists[index];
            return InkWell(
              onTap: () {
                print("列表点击");
              },
              child: Container(
                  padding:
                      EdgeInsets.only(left: 15.0, right: 15.0, bottom: 15.0),
                  child: Column(
                    children: [
                      //分割线
                      Container(
                        margin: EdgeInsets.only(bottom: 16.0),
                        child: Divider(
                          color: Colors.black26,
                          height: 1.0,
                          thickness: 1,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            child: Image.network(
                              '${listBean["img"]}',
                              width: 60.0,
                              height: 80.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.only(left: 10.0),
                              //  height: 124.0,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      "${listBean["name"]}",
                                      style: TextStyle(
                                          fontSize: 16.0, color: Colors.black),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 5.0),
                                    child: Text(
                                      "${listBean["desc"]}",
                                      style: const TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.black26),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )),
            );
          }),
    );
  }

  void _tabController() {
    _tabC = TabController(
      length: tabs.length,
      initialIndex: 0,
      vsync: this,
    );
  }
}
