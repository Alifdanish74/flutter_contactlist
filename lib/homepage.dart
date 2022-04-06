import 'dart:convert';
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:flutter_contactlist/Contact.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  runApp(const Homepage());
}

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => HomepageState();
}

class HomepageState extends State<Homepage> {
  // DateFormat dateTimeFormat = DateFormat("yyyy--MM-dd HH:mm:ss");
  DateFormat dateTimeFormat = DateFormat("dd-MM-yyyy HH:mm:ss");
  late Future<List<contact>> _contact;
  final ScrollController scrollController = ScrollController();
  int snapLength = 0;
  int half = 0;
  int totalLength = 0;
  List<String> timeAgoList = [];
  bool loadingVisible = false;
  bool endIndicatorVisible = false;
  int counter = 0;
  List<bool> isSelected = [true, false];

  @override
  void initState() {
    super.initState();
    _contact = _fetchContactData();
    getViewState();
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
              scrollController.position.maxScrollExtent &&
          scrollController.position.userScrollDirection ==
              ScrollDirection.reverse) {
        counter++;
        loadMoreData();
      }
    });
  }

//Function needed in build context

  saveViewState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(
      () {
        prefs.setStringList(
          "isSelected",
          isSelected.map((e) => e ? 'true' : 'false').toList(),
        );
      },
    );
  }

  getViewState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(
      () {
        isSelected = (prefs
                .getStringList('isSelected')
                ?.map((e) => e == 'true' ? true : false)
                .toList() ??
            [true, false]);
      },
    );
  }

  userLogo() {
    return const Icon(Icons.account_circle_sharp, size: 60, color: Colors.blue);
  }

  textField(String string) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Align(alignment: Alignment.centerLeft, child: Text(string)),
    );
  }

  listTileAction(String name, String phone, String dateTime, String timeAgo) {
    return IconButton(
      icon: const Icon(Icons.share),
      tooltip: 'Share Information',
      onPressed: () {
        onShareData(name, phone, dateTime, timeAgo);
      },
    );
  }

  onShareData(
      String name, String phone, String dateTime, String timeago) async {
    Share.share(name + "\n" + phone + "\n" + dateTime + "\n" + timeago);
  }

  // Function to fetch contact data from URL
  Future<List<contact>> _fetchContactData() async {
    List<contact> _newContact = [];

    var url = 'https://contactlistdata.000webhostapp.com/';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var listOfContact = json.decode(response.body);
      _newContact = await listOfContact
          .map<contact>((json) => contact.fromJson(json))
          .toList();

      snapLength = _newContact.length;
      half = (_newContact.length / 2).round();
      totalLength = _newContact.length < half ? _newContact.length : half;

      for (int i = 0; i < snapLength; i++) {
        String dateTimedataString;

        dateTimedataString = _newContact[i].getCheckInDate()!;
        DateTime datadateTime = dateTimeFormat.parse(dateTimedataString);

        Duration diff = DateTime.now().difference(datadateTime);
        String msg = '';

        if (diff.inDays >= 1) {
          msg = '${diff.inDays} day(s) ago';
        } else if (diff.inHours >= 1) {
          msg = '${diff.inHours} hour(s) ago';
        } else if (diff.inMinutes >= 1) {
          msg = '${diff.inMinutes} minute(s) ago';
        } else if (diff.inSeconds >= 1) {
          msg = '${diff.inSeconds} second(s) ago';
        } else {
          msg = 'just now';
        }
        timeAgoList.add(msg);
      }

      setState(() {
        timeAgoList = timeAgoList;
      });

      return _newContact;
    }
    return _newContact;
  }

  loadMoreData() {
    setState(() {
      loadingVisible = true;
    });

    Future.delayed(Duration(seconds: 2), () {
      if (totalLength != snapLength) {
        totalLength = snapLength;
        setState(() {
          loadingVisible = false;
        });
      } else {
        setState(() {
          loadingVisible = false;
          endIndicatorVisible = true;

          Future.delayed(Duration(seconds: 2), () {
            setState(() {
              endIndicatorVisible = false;
            });
          });
        });
      }
    });
  }

  toggleButtons() {
    return ToggleButtons(
      children: const <Widget>[
        // first toggle button
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Original Time',
          ),
        ),
        // second toggle button
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Time ago',
          ),
        )
      ],
      // logic for button selection below
      onPressed: (int index) {
        setState(() {
          for (int i = 0; i < isSelected.length; i++) {
            if (i == index) {
              isSelected[i] = true;
            } else {
              isSelected[i] = false;
            }
          }
          saveViewState();
        });
      },
      isSelected: isSelected,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact List'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              margin: EdgeInsets.all(5),
              height: 50,
              child: Align(
                alignment: Alignment.topRight,
                child: toggleButtons(),
              ),
            ),
          ),
          Positioned.fill(
            top: 60,
            bottom: 60,
            child: Align(
              alignment: Alignment.center,
              child: FutureBuilder(
                initialData: [],
                future: _contact,
                builder: (context, AsyncSnapshot snapshot) {
                  return snapshot.hasData
                      ? ListView.builder(
                          physics: const BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics()),
                          controller: scrollController,
                          itemCount: totalLength,
                          itemBuilder: (context, index) {
                            return Card(
                              child: ListTile(
                                leading: userLogo(),
                                trailing: listTileAction(
                                    snapshot.data[index].getName(),
                                    snapshot.data[index].getPhone(),
                                    snapshot.data[index].getCheckInDate(),
                                    timeAgoList[index]),
                                title: Text(
                                  snapshot.data[index].getName(),
                                  style: TextStyle(fontSize: 20),
                                ),
                                subtitle: Column(children: [
                                  textField(snapshot.data[index].getPhone()),
                                  Visibility(
                                      visible: isSelected[0],
                                      child: textField(snapshot.data[index]
                                          .getCheckInDate())),
                                  Visibility(
                                      visible: isSelected[1],
                                      child: textField(timeAgoList[index]))
                                ]),
                              ),
                            );
                          })
                      : const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ),
          Positioned.fill(
            bottom: 20,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Visibility(
                visible: endIndicatorVisible,
                child: const Text('You have reached end of the list'),
              ),
            ),
          ),
          Positioned.fill(
            bottom: 20,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Visibility(
                visible: loadingVisible,
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
