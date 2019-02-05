import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import '../route/index.dart';
import 'package:fluro/fluro.dart';
import '../model/psData.dart';
import '../store/index.dart';
import '../components/card.dart';

class PopVal {
  static DialogAction dialogAction;
  static int index = 0;
}

class Home extends StatefulWidget {
  Home({Key key, this.title}) : super(key: key);
  final String title;

  @override
  HomeState createState() => new HomeState();
}

class HomeState extends State<Home> {
  String keyStr = '';

  int get starCount {
    PsData data = GState.of(context).data;
    int count = 0;
    data.list.forEach((item) {
      if (item.status == 1) {
        count += 1;
      }
    });
    return count;
  }



  @override
  void initState() {
    super.initState();
  }

  bool filter(PsItem item) {
    if (item.title.contains(keyStr)) {
      return true;
    } else if (keyStr == null || keyStr.isEmpty) {
      return true;
    } else {
      return false;
    }
  }

  textChange(String val) {
    print(val);
    setState(() {
      keyStr = val;
    });
  }

  obscurePassword(String password) {
    String frontStr = password.isNotEmpty ? password.substring(0, 2) : '';
    return '$frontStr********';
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: TextField(
          style: TextStyle(
            color: Colors.white,
            height: 1.0,
            fontSize: 16.0,
          ),
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.white,
              ),
              borderRadius: BorderRadius.all(Radius.circular(17.0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.white30,
              ),
              borderRadius: BorderRadius.all(Radius.circular(17.0)),
            ),
            hintText: 'Enter query keyword',
            hintStyle: TextStyle(
              color: Colors.cyan,
              height: 1.0,
              fontSize: 16.0,
            ),
            contentPadding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
          ),
          onChanged: textChange,
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add_circle),
            iconSize: 36.0,
            onPressed: () {
              Application.router.navigateTo(
                context,
                '/detail/?type=new',
                transition: TransitionType.inFromRight,
              );
            },
          ),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            _sliverAppBar(),
          ];
        },
        body: _psList(),
      ),
    );
  }

  // TODO: implement build
  _sliverAppBar() => ScopedModelDescendant<GState>(
        builder: (context, child, model) => SliverAppBar(
              expandedHeight: 105.0,
              pinned: false,
              flexibleSpace: SafeArea(
                child: FlexibleSpaceBar(
                  background: Container(
                    padding: EdgeInsets.fromLTRB(30.0, 5.0, 20.0, 0.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'total',
                          style: TextStyle(color: Colors.white, fontSize: 16.0),
                        ),
                        RichText(
                          text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                text: model.data.list.length
                                    .toString()
                                    .padLeft(2, '0'),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 32.0,
                                ),
                              ),
                              TextSpan(
                                text: '    个',
                                style: TextStyle(
                                  fontSize: 14.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(fontSize: 14.0),
                            children: [
                              TextSpan(text: 'important'),
                              TextSpan(text: '$starCount个'),
                              TextSpan(text: '，normal'),
                              TextSpan(
                                text: '${model.data.list.length - starCount}个',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      );


  _psItem(int index, PsItem item) => ScopedModelDescendant<GState>(
        builder: (context, child, model) {
          final card = PsCard(
            index: index,
            item: item,
            duration: Duration(milliseconds: 1000),
            onTap: () {
              Application.router.navigateTo(context, '/detail/$index',
                 transition: TransitionType.nativeModal);
            },
            onLongPress: () {

            },
            onTapStar: () {
              model.starItem(
                index: index,
                status: item.status == 0 ? 1 : 0,
              );
              print(item.status);
              model.savePsData().then((_) {});
            },
          );
          return card;
        },
      );

  _psList() => new ScopedModelDescendant<GState>(
        builder: (context, child, model) => Container(
              padding: EdgeInsets.only(top: 10.0),
              color: Color(0xfff9f9f9),
              child: model.data.list.length > 0
                  ? ListView.builder(
                      itemCount: model.data.list.length,
                      itemBuilder: (BuildContext context, int index) {
                        PsItem item = model.data.list[index];
                        if (filter(item)) {
                          return _psItem(index, item);
                        } else {
                          return Offstage(
                            offstage: true,
                          );
                        }
                      },
                    )
                  : Center(
                      child: Container(
                        padding: EdgeInsets.only(top: 20.0),
                        child: Column(
                          children: <Widget>[
                            Image.asset(
                              'assets/imgs/nothing/nothing.png',
                              width: 100.0,
                              height: 100.0,
                              fit: BoxFit.contain,
                            ),
                            Text(
                              'No data yet~!',
                              style: TextStyle(
                                fontSize: 16.0
                              ),
                              textAlign: TextAlign.center,
                            )
                          ],
                        ),
                      ),
                    ),
            ),
      );
}
