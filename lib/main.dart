import 'package:flutter/material.dart';
import 'package:flutter_app_sqflite/database_helper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sqflite/sqflite.dart';
import 'model/Contact.dart';

enum ConfirmAction { CANCEL, ACCEPT }

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DatabaseHelper dbHelper = DatabaseHelper.instance;
  List<Contact> contacts = new List();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dbHelper.getAllContacts().then((rows) {
      setState(() {
        rows.forEach((row) {
          contacts.add(Contact.map(row));
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: contacts.length,
          padding: const EdgeInsets.all(14.0),
          itemBuilder: (context, position) {
            return Column(
              children: <Widget>[
                Divider(
                  height: 5.0,
                ),
                Material(
                  color: Colors.white,
                  child: ListTile(
                    title: Text(
                      '${contacts[position].email}',
                      style:
                          TextStyle(fontSize: 20.0, color: Colors.deepPurple),
                    ),
                    subtitle: Text(
                      '${contacts[position].name}',
                      style:
                          TextStyle(fontSize: 18.0, color: Colors.deepOrange),
                    ),
                    trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _deleteItem(contacts[position]);
                        }),
                    leading: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(8.0),
                        ),
                        CircleAvatar(
                          backgroundColor: Colors.red,
                          radius: 16.0,
                          child: Text(
                            '${contacts[position].email.substring(0, 1)}',
                            style:
                                TextStyle(fontSize: 22.0, color: Colors.white),
                          ),
                        )
                      ],
                    ),
                    onTap: () async {
                      final Contact currentContact =
                          await _showUpdateDialog(context, contacts[position]);
                      _update(currentContact, position);
                    },
                  ),
                )
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final Contact currentContact = await _inputValueDialog(context);
          if (currentContact != null) _insert(currentContact);
        },
        tooltip: 'Add',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<Contact> _showUpdateDialog(
      BuildContext context, Contact contact) async {
    // Default Text
    TextEditingController _emailController =
        new TextEditingController(text: contact.email);
    TextEditingController _nameController =
        new TextEditingController(text: contact.name);

    return showDialog<Contact>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Add new Contact'),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                    child: TextField(
                  readOnly: true,
                  controller: _emailController,
                  autofocus: false,
                  decoration: InputDecoration(
                      labelText: 'Email', hintText: 'eddydn@gmail.com'),
                )),
                Expanded(
                    child: TextField(
                  controller: _nameController,
                  autofocus: false,
                  decoration:
                      InputDecoration(labelText: 'Name', hintText: 'Eddy Lee'),
                )),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text('UPDATE', style: TextStyle(color: Colors.blueAccent)),
                onPressed: () {
                  //Check value
                  if (_emailController.text.isEmpty) {
                    Fluttertoast.showToast(
                        msg: "Email must not be null",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  } else {
                    contact.email = _emailController.text;
                    contact.name = _nameController.text;
                    Navigator.of(context).pop(contact);
                  }
                },
              ),
            ],
          );
        });
  }

  Future<Contact> _inputValueDialog(BuildContext context) async {
    Contact contact;

    TextEditingController _emailController = new TextEditingController();
    TextEditingController _nameController = new TextEditingController();

    return showDialog<Contact>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Add new Contact'),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                    child: TextField(
                  controller: _emailController,
                  autofocus: true,
                  decoration: InputDecoration(
                      labelText: 'Email', hintText: 'eddydn@gmail.com'),
                )),
                Expanded(
                    child: TextField(
                  controller: _nameController,
                  autofocus: false,
                  decoration:
                      InputDecoration(labelText: 'Name', hintText: 'Eddy Lee'),
                )),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text('Add', style: TextStyle(color: Colors.blueAccent)),
                onPressed: () {
                  //Check value
                  if (_emailController.text.isEmpty) {
                    Fluttertoast.showToast(
                        msg: "Email must not be null",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  } else {
                    contact = new Contact();
                    contact.email = _emailController.text;
                    contact.name = _nameController.text;
                    Navigator.of(context).pop(contact);
                  }
                },
              ),
            ],
          );
        });
  }

  void _insert(Contact currentContact) async {
    //Row to insert
    Map<String, dynamic> row = {
      DatabaseHelper.columnEmail: currentContact.email,
      DatabaseHelper.columnName: currentContact.name
    };

    try {
      await dbHelper.insert(row).then((id) {
        print('inserted row id $id');
        setState(() {
          contacts.add(currentContact);
        });
      });
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        Fluttertoast.showToast(
            msg: "Email already existing!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      } else if (e.isSyntaxError()) {
        Fluttertoast.showToast(
            msg: "Query syntax error",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      } else if (e.isReadOnlyError()) {
        Fluttertoast.showToast(
            msg: "Database is read only mode",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      } else if (e.isOpenFailedError()) {
        Fluttertoast.showToast(
            msg: "Open database failed",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      } else if (e.isNoSuchTableError()) {
        Fluttertoast.showToast(
            msg: "Table doesn't available",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      } else if (e.isDatabaseClosedError()) {
        Fluttertoast.showToast(
            msg: "Database was closed!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        Fluttertoast.showToast(
            msg: e.toString(),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }
  }

  void _deleteItem(Contact contact) async {
    final result = await _confirmDialog(context);
    if (result == ConfirmAction.ACCEPT) deleteItem(contact);
  }

  Future<ConfirmAction> _confirmDialog(BuildContext context) async {
    return showDialog<ConfirmAction>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Delete Item'),
            content: const Text('This will delete item from your Database'),
            actions: <Widget>[
              FlatButton(
                  child: Text('CANCEL'),
                  onPressed: () {
                    Navigator.of(context).pop(ConfirmAction.CANCEL);
                  }),
              FlatButton(
                  child: Text(
                    'DELETE',
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(ConfirmAction.ACCEPT);
                  }),
            ],
          );
        });
  }

  void deleteItem(Contact contact) async {
    try {
      await dbHelper.delete(contact.email).then((id) {
        print('delete row id $id');
        setState(() {
          contacts.remove(contact);
        });
      });
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        Fluttertoast.showToast(
            msg: "Email already existing!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      } else if (e.isSyntaxError()) {
        Fluttertoast.showToast(
            msg: "Query syntax error",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      } else if (e.isReadOnlyError()) {
        Fluttertoast.showToast(
            msg: "Database is read only mode",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      } else if (e.isOpenFailedError()) {
        Fluttertoast.showToast(
            msg: "Open database failed",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      } else if (e.isNoSuchTableError()) {
        Fluttertoast.showToast(
            msg: "Table doesn't available",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      } else if (e.isDatabaseClosedError()) {
        Fluttertoast.showToast(
            msg: "Database was closed!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        Fluttertoast.showToast(
            msg: e.toString(),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }
  }

  void _update(Contact currentContact, int position) async{
    
    //Row to insert
    Map<String, dynamic> row = {
      DatabaseHelper.columnEmail: currentContact.email,
      DatabaseHelper.columnName: currentContact.name
    };

    try {
      await dbHelper.update(row).then((id) {
        print('update row id $id');
        setState(() {
          contacts[position] = currentContact;
        });
      });
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        Fluttertoast.showToast(
            msg: "Email already existing!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      } else if (e.isSyntaxError()) {
        Fluttertoast.showToast(
            msg: "Query syntax error",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      } else if (e.isReadOnlyError()) {
        Fluttertoast.showToast(
            msg: "Database is read only mode",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      } else if (e.isOpenFailedError()) {
        Fluttertoast.showToast(
            msg: "Open database failed",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      } else if (e.isNoSuchTableError()) {
        Fluttertoast.showToast(
            msg: "Table doesn't available",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      } else if (e.isDatabaseClosedError()) {
        Fluttertoast.showToast(
            msg: "Database was closed!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        Fluttertoast.showToast(
            msg: e.toString(),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }
  }
}
