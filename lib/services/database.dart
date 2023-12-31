import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService{
  final String? uid;
  DatabaseService({this.uid});

  final CollectionReference usercollection= FirebaseFirestore.instance.collection("users");
  final CollectionReference groupcollection= FirebaseFirestore.instance.collection("groups");


  Future savingUserData (String fullname,String email)async{
    return await usercollection.doc(uid).set({
      "fullName":fullname,
      "e-mail":email,
      "groups":[],
      "uid":uid,
    });

  

  }
  Future gettingUserData(String email)async{
    QuerySnapshot snapshot = await usercollection.where("email",isEqualTo: email).get();
    return snapshot;
  }

  getUserGroups() async{
    return usercollection.doc(uid).snapshots();
  }


  Future createGroup(String userName, String id, String groupName) async {
    DocumentReference groupDocumentReference = await groupcollection.add({
      "groupName": groupName,
      "groupIcon": "",
      "admin": "${id}_$userName",
      "members": [],
      "groupId": "",
      "recentMessage": "",
      "recentMessageSender": "",
    });
    await  groupDocumentReference.update({
      "members":FieldValue.arrayUnion(["${uid}_$userName"]),
      "group id": groupDocumentReference.id,
    });

     DocumentReference userDocumentReference = usercollection.doc(uid);
    return await userDocumentReference.update({
      "groups":
          FieldValue.arrayUnion(["${groupDocumentReference.id}_$groupName"])
    });
  }

  getChats(String groupId) async {
    return groupcollection
        .doc(groupId)
        .collection("messages")
        .orderBy("time")
        .snapshots();
  }

  Future getGroupAdmin(String groupId) async {
    DocumentReference d = groupcollection.doc(groupId);
    DocumentSnapshot documentSnapshot = await d.get();
    return documentSnapshot["admin"];
  }

  // get group members
  getGroupMembers(groupId) async {
    return groupcollection.doc(groupId).snapshots();
  }

   searchByName(String groupName) {
    return groupcollection.where("groupName", isEqualTo: groupName).get();
  }

  Future<bool> isUserJoined(
      String groupName, String groupId, String userName) async {
    DocumentReference userDocumentReference =usercollection.doc(uid);
    DocumentSnapshot documentSnapshot = await userDocumentReference.get();

    List<dynamic> groups = await documentSnapshot["groups"];
    if (groups.contains("${groupId}_$groupName")) {
      return true;
    } else {
      return false;
    }
  }

  // toggling the group join/exit
  Future toggleGroupJoin(
      String groupId, String userName, String groupName) async {
    // doc reference
    DocumentReference userDocumentReference = usercollection.doc(uid);
    DocumentReference groupDocumentReference = groupcollection.doc(groupId);

    DocumentSnapshot documentSnapshot = await userDocumentReference.get();
    List<dynamic> groups = await documentSnapshot["groups"];

    // if user has our groups -> then remove then or also in other part re join
    if (groups.contains("${groupId}_$groupName")) {
      await userDocumentReference.update({
        "groups": FieldValue.arrayRemove(["${groupId}_$groupName"])
      });
      await groupDocumentReference.update({
        "members": FieldValue.arrayRemove(["${uid}_$userName"])
      });
    } else {
      await userDocumentReference.update({
        "groups": FieldValue.arrayUnion(["${groupId}_$groupName"])
      });
      await groupDocumentReference.update({
        "members": FieldValue.arrayUnion(["${uid}_$userName"])
      });
    }
  }

  sendMessage(String groupId, Map<String, dynamic> chatMessageData) async {
    groupcollection.doc(groupId).collection("messages").add(chatMessageData);
    groupcollection.doc(groupId).update({
      "recentMessage": chatMessageData["message"],
      "recentMessageSender": chatMessageData["sender"],
      "recentMessageTime": chatMessageData["time"].toString(),
    });
  }
}

    
    

  
