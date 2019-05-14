import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contact/src/custom_circle_avatar.dart';
import 'package:flutter_contact/src/uuid.dart';

import 'package:sticky_headers/sticky_headers.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _key = GlobalKey<ScaffoldState>();
  final _controller = ScrollController();
  final _fullNameController = TextEditingController();
  List<InitialAndOffset> _initials;
  double _listTileSize = 50, _mainOffset = 0, _topPadding = 25;

  @override
  void initState() {
    _controller.addListener(() {});
    super.initState();
  }

  void animateList(double offset) {
    print("animate to $offset");
    _controller.animateTo(offset,
        curve: Curves.easeOut, duration: Duration(milliseconds: 200));
  }

  @override
  Widget build(BuildContext context) {
    _initials = [];
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: Text("Flutter Demo"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.add),
        label: Text("Add Contact"),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Padding(
                  child: Column(
                    children: <Widget>[
                      TextField(
                        onSubmitted: (t) => _onSave(),
                        controller: _fullNameController,
                        decoration: InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: "Full Name"),
                      ),
                      SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          _key.currentState.showSnackBar(SnackBar(
                            content: Text("Not Implemented yet."),
                            duration: Duration(seconds: 1),
                          ));
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 100,
                          color: Colors.grey[300],
                          alignment: Alignment.center,
                          child: Text("Upload your Profile pic"),
                        ),
                      ),
                      SizedBox(height: 20),
                      RaisedButton(
                          color: Theme.of(context).primaryColor,
                          textColor: Colors.white,
                          child: Text("Save"),
                          onPressed: _onSave)
                    ],
                  ),
                  padding: EdgeInsets.all(10));
            },
          );
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collection('users')
              .orderBy("full_name")
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Center(
                child: Text("Loading..."),
              );
            else {
              return Stack(
                children: <Widget>[
                  SingleChildScrollView(
                    controller: _controller,
                    child: Column(
                      children: _buildListItems(snapshot.data.documents),
                    ),
                  ),
                  Positioned(
                    right: 5,
                    child: SafeArea(
                      child: Container(
                        height: MediaQuery.of(context).size.height - 100,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: _initials
                              .map((i) => GestureDetector(
                                    child: Padding(
                                      padding:
                                          // EdgeInsets.fromLTRB(20, 10, 5, 10),
                                          EdgeInsets.all(10),
                                      child: Text(i.initial),
                                    ),
                                    onTap: () => animateList(i.offset),
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                  )
                ],
              );
            }
          }),
    );
  }

  List<Widget> _buildListItems(List<DocumentSnapshot> data) {
    List<Widget> list = [];
    List<Widget> charList = [];
    _initials = [];
    _mainOffset = 0;
    String pre = "";
    for (int i = 0; i < data.length; i++) {
      var item = data[i];
      String fullName = item["full_name"];
      String profilePic = item["profile_pic"];
      // String id = item["id"];

      // print(fullName);
      final initial = fullName.substring(0, 1).toUpperCase();
      if (pre.isEmpty) {
        pre = initial;
      }

      if (initial != pre && charList.isNotEmpty) {
        _initials.add(InitialAndOffset(pre, _mainOffset));
        _mainOffset =
            _mainOffset + (_topPadding + (charList.length * _listTileSize));
        list.add(StickyHeader(
          overlapHeaders: true,
          header: Container(
              color: Colors.white,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.fromLTRB(20, 10, 5, 5),
              child: Text(pre)),
          content: Padding(
            padding: EdgeInsets.only(top: _topPadding),
            child: Column(children: charList),
          ),
        ));
        charList = [];

        pre = initial;
      }
      charList.add(Container(
        height: _listTileSize,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: <Widget>[
            CustomCircleAvatar(
              imageUrl: profilePic,
              name: fullName,
            ),
            SizedBox(width: 20),
            Expanded(
                child: Text(
              fullName,
              maxLines: null,
            )),
          ],
        ),
      ));
      if (data.length - 1 == i && initial == pre && charList.isNotEmpty) {
        _initials.add(InitialAndOffset(initial, _mainOffset));
        _mainOffset =
            _mainOffset + (_topPadding + (charList.length * _listTileSize));
        list.add(StickyHeader(
          overlapHeaders: true,
          header: Container(
              color: Colors.white,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.fromLTRB(20, 10, 5, 5),
              child: Text(pre)),
          content: Padding(
            padding: EdgeInsets.only(top: _topPadding),
            child: Column(children: charList),
          ),
        ));
        charList = [];

        pre = initial;
      }
    }

    return list;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSave() {
    String id = Uuid().generateV4();
    final fullName = _fullNameController.text.substring(0, 1).toUpperCase() +
        _fullNameController.text.substring(1);
    Map<String, dynamic> data = {
      "id": id,
      "full_name": fullName,
      "profile_pic": null
    };
    Firestore.instance
        .collection("users")
        .document("$id")
        .setData(data, merge: true);
    Navigator.pop(context);
    _fullNameController.clear();
  }
}

class InitialAndOffset {
  final String initial;
  final double offset;

  InitialAndOffset(this.initial, this.offset);
}
