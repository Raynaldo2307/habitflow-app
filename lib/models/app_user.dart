class AppUser {
  final String uid;
  final String email;
  final String ? displayName ;
  final String ? photoUrl;

AppUser({
  required this.uid,
  required this.email,
  this.displayName,
  this.photoUrl,
});

factory AppUser.fromMap(String uid,Map<String, dynamic> data){
  return AppUser(
    uid: uid,
    email: data['email']?? '',
    displayName: data ['displayName'],
    photoUrl : data [' photoUrl'],
  );
}
Map<String, dynamic> toMap(){
  return{
    'email': email,
    'displayedName': displayName,
    'photoUrl': photoUrl,

  };
}


}