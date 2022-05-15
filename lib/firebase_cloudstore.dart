import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CloudDB extends StatefulWidget {
  final String title;
  const CloudDB({Key? key, required this.title}) : super(key: key);

  @override
  State<CloudDB> createState() => _CloudDBState();
}

class _CloudDBState extends State<CloudDB> {
  late FirebaseFirestore _firestore;
  StreamSubscription? userSub;
  @override
  void initState() {
    super.initState();
    _firestore = FirebaseFirestore.instance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            ElevatedButton(
                onPressed: () {
                  createData();
                },
                style: ElevatedButton.styleFrom(primary: Colors.red),
                child: const Text("Create")),
            ElevatedButton(
                onPressed: () {
                  readData();
                },
                style: ElevatedButton.styleFrom(primary: Colors.blue),
                child: const Text("Update")),
            ElevatedButton(
                onPressed: () {
                  getData();
                },
                style: ElevatedButton.styleFrom(primary: Colors.green),
                child: const Text("get data realtime")),
            ElevatedButton(
                onPressed: () {
                  getDataCancel();
                },
                style: ElevatedButton.styleFrom(primary: Colors.grey),
                child: const Text("get data realtime cancel")),
            ElevatedButton(
                onPressed: () {
                  updateBatch();
                },
                style: ElevatedButton.styleFrom(primary: Colors.brown),
                child: const Text("Update Range Banch")),
            ElevatedButton(
                onPressed: () {
                  updateTransaction();
                },
                style: ElevatedButton.styleFrom(primary: Colors.amber.shade100),
                child: const Text("Update Transaction")),
            ElevatedButton(
                onPressed: () {
                  queryWhere();
                },
                style: ElevatedButton.styleFrom(primary: Colors.blue.shade300),
                child: const Text("Query")),
            ElevatedButton(
                onPressed: () {
                  fileManage();
                },
                style: ElevatedButton.styleFrom(
                    primary: const Color.fromARGB(255, 174, 190, 29)),
                child: const Text("File Manager")),
          ],
        ),
      ),
    );
  }

  void createData() async {
    Map<String, dynamic> user = {};
    user['name'] = 'Kamal';
    user['surname'] = 'Mirza';
    user['age'] = 32;
    user['createAt'] = FieldValue.serverTimestamp();
    user['money'] = 100;
    user['skills'] = FieldValue.arrayUnion(['c#', '.Net', 'Oracle']);
    await _firestore.collection('users').add(user);
  }

  void readData() async {
    _firestore
        .doc('users/BhBgrnYyDVtRcA1ulDew')
        .set({'money': 1000}, SetOptions(merge: true));
  }

  void getData() async {
    var userStream = await _firestore.collection('users').snapshots();
    userSub = userStream.listen((event) {
      var docc = event.docChanges.single.doc;
      debugPrint(docc.data().toString());
    });
  }

  void getDataCancel() async {
    await userSub?.cancel();
  }

  void updateBatch() async {
    WriteBatch _batch = _firestore.batch();
    CollectionReference _counterRef = _firestore.collection("collection");

    // for (var i = 0; i < 100; i++) {
    //   var newDoc = _counterRef.doc();
    //   _batch.set(newDoc, {"counter": i, "id": newDoc.id});
    // }

    // var _counterDocs = await _counterRef.get();
    // _counterDocs.docs.forEach((element) {
    //   _batch.update(
    //       element.reference, {"createAt": FieldValue.serverTimestamp()});
    // });

    var _counterDocs = await _counterRef.get();
    _counterDocs.docs.forEach((element) {
      _batch.delete(element.reference);
    });

    _batch.commit();
  }

  void updateTransaction() async {
    _firestore.runTransaction((transaction) async {
      DocumentReference<Map<String, dynamic>> kamranRef =
          _firestore.doc('users/BhBgrnYyDVtRcA1ulDew');
      DocumentReference<Map<String, dynamic>> kamalRef =
          _firestore.doc('users/J3aFgBYYE3WJ6nckcvkb');

      var _mK = await transaction.get(kamranRef);
      var kMoney = _mK.data()!['money'];
      var money = kMoney - 100;
      transaction.update(kamranRef, {'money': money});
      transaction.update(kamalRef, {'money': FieldValue.increment(100)});
    });
  }

  void queryWhere() async {
    var userRef = await _firestore.collection('users');

    var data = await userRef.where('money', isEqualTo: 900).get();
    for (var item in data.docs) {
      debugPrint(item.data().toString());
    }
  }

  void fileManage() async {
    final ImagePicker _picker = ImagePicker();

    XFile? _file = await _picker.pickImage(source: ImageSource.camera);
    var _profileRef = FirebaseStorage.instance.ref("users/profile_image");
    var _task = _profileRef.putFile(File(_file!.path));
    _task.whenComplete(() async {
      var _url = await _profileRef.getDownloadURL();
      _firestore
          .doc('users/BhBgrnYyDVtRcA1ulDew')
          .set({'profile_pic': _url.toString() },SetOptions(merge: true));
      debugPrint(_url.toString());
    });
  }
}
