import 'package:maring/utils/constant.dart';

class FirestoreConstants {
  /* Firestore */
  static String pathUserCollection =
      "users_${Constant.appName.toLowerCase().replaceAll(RegExp(r' '), '_')}";
  static String pathMessageCollection =
      "chatrooms_${Constant.appName.toLowerCase().replaceAll(RegExp(r' '), '_')}";

  /* User */
  static const id = "id";
  static const userid = "userid";
  static const name = "name";
  static const email = "email";
  static const profileurl = "profileurl";
  static const chattingWith = "chattingWith";
  static const pushToken = "pushToken";
  static const isOnline = "isOnline";
  static const createdAt = "createdAt";
  static const bioData = "biodata";
  static const username = "username";
  static const mobileNumber = "mobileNumber";

  /* Live Chat */
  static const idFrom = "idFrom";
  static const idTo = "idTo";
  static const timestamp = "timestamp";
  static const content = "content";
  static const type = "type";
  static const read = "read";

  /* Chats Document Fields */
  static const convId = "convid";
  static const users = "users";
  static const lastMessage = "lastMessage";
  static const chatproductdetails = "productdetails";

  /* Firebase Storage */
  static const pathImages = "images";
  static const pathVideos = "videos";
  static const pathGif = "gif";

  /*Product details in firebase */
  static const productImage = "productImage";
  static const productName = "productName";
}
