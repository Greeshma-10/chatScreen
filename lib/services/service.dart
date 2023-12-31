import 'package:chatscreen/services/database.dart';
import 'package:chatscreen/services/functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService{
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

   Future loginWithUserNameandPassword(String email, String password) async {
    try {
      User user = (await firebaseAuth.signInWithEmailAndPassword(
              email: email, password: password))
          .user!;

      if (user != null) {
        return true;
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future registerUserWithEmailandPassword(String fullname,String email,String password)async{
    try {
      User user = (await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password)).user!;
      if(user != null){
        await DatabaseService(uid:user.uid).savingUserData(fullname, email);
        return true;
      }
    }on FirebaseAuthException catch(e){
      
      return e ;
    }
  }



Future signOut() async {
    try {
      await functions.saveUserLoggedInStatus(false);
      await functions.saveUserEmailSF("");
      await functions.saveUserNameSF("");
      await firebaseAuth.signOut();
    } catch (e) {
      return null;
    }
  }
}