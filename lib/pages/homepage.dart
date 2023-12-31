
import 'package:chatscreen/services/database.dart';
import 'package:chatscreen/services/functions.dart';
import 'package:chatscreen/pages/group_tile.dart';
import 'package:chatscreen/services/service.dart';
import 'package:chatscreen/services/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class homepage extends StatefulWidget {
  const homepage({super.key});

  @override
  State<homepage> createState() => _homepageState();
}

class _homepageState extends State<homepage> {
  Stream? groups;
  String userName="";
  String email="";
  AuthService authService=AuthService();
  bool _isLoading =false;
  String groupName="";
  @override

  

   void initState() {
    super.initState();
    gettingUserData();
  }

  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  String getName(String res) {
    return res.substring(res.indexOf("_") + 1);
  }

 

  gettingUserData() async {
    await functions.getUserEmailFromSF().then((value) {
      setState(() {
        email = value!;
      });
    });
    await functions.getUserNameFromSF().then((val) {
      setState(() {
        userName = val!;
      });
    });
    // getting the list of snapshots in our stream
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getUserGroups()
        .then((snapshot) {
      setState(() {
        groups = snapshot;
      });
    });
  }

  
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
       
        elevation: 0,
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: Text("Groups",style: TextStyle(color: Colors.white,fontSize: 30,fontWeight: FontWeight.bold),),
      ),
      
      body: groupList(),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.pushNamed(context,"LoginPage");
        },
      
        elevation: 0,
        backgroundColor: Colors.blue,
        child: Icon(Icons.add,color: Colors.white,size: 30,),
      ),
      
    
    );
  }
  popUpDialog(BuildContext context){
    
    showDialog(
      barrierDismissible: false,
      context: context,
     builder:(context){
      
      
      return AlertDialog(title: Text("Create a group",textAlign: TextAlign.left,),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
            _isLoading==true ? Center(child: CircularProgressIndicator(color: Colors.blue,),):
            TextField(
              onChanged: (value) {
                setState(() {
                  groupName=value;
                });
              
              },
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(20))),
            )
        ],
      ),
      actions: [
        ElevatedButton(onPressed: (){
           Navigator.of(context).pop();

        },
        style:ElevatedButton.styleFrom(primary: Colors.blue), child: Text("cancel")),
        ElevatedButton(onPressed: (){
          if(groupName!=""){
            setState(() {
              _isLoading=true;
            });
            DatabaseService(uid:FirebaseAuth.instance.currentUser!.uid).createGroup(userName,FirebaseAuth.instance.currentUser!.uid, groupName).whenComplete((){
              _isLoading=false;
            });
            Navigator.of( context).pop();
            showSnackbar(context, Colors.green, "Group created successfully.");
          };
        },
        style:ElevatedButton.styleFrom(primary: Colors.blue), child: Text("create")
       
        ),
        
      ],
      );
     });
  }

  groupList() {
    return StreamBuilder(
      stream: groups,
      builder: (context, AsyncSnapshot snapshot) {
        // make some checks
        if (snapshot.hasData) {
          if (snapshot.data["groups"] != null) {
            if (snapshot.data["groups"].length != 0) {
              return ListView.builder(
                itemCount: snapshot.data["groups"].length,
                itemBuilder: (context, index) {
                  int reverseIndex = snapshot.data["groups"].length - index - 1;
                  return GroupTile(
                      groupId: getId(snapshot.data["groups"][reverseIndex]),
                      groupName: getName(snapshot.data["groups"][reverseIndex]),
                      userName: snapshot.data["fullName"]);
                },
              );
              
              
            } else {
              return noGroupWidget();
            }
          } else {
            return noGroupWidget();
          }
        } else {
          return Center(
            child: CircularProgressIndicator(
                color: Colors.blue),
          );
        }
      },
    );
  }



  
    

  
  noGroupWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              popUpDialog(context as BuildContext);
            },
            child: Center(
              child: Icon(
                Icons.add_circle,
                color: Colors.grey[700],
                size: 75,
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            " tap on the add icon to create a group .",
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}