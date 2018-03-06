
var firebase = require("firebase/app")
require("firebase/auth")
require("firebase/database")

var config = {
    apiKey: "AIzaSyBG1j63LtQxox-JdKLxifqgm99r6uHz3L4",
    authDomain: "gusto-deli.firebaseapp.com",
    databaseURL: "https://gusto-deli.firebaseio.com",
  };


firebase.initializeApp(config)

firebase.database().ref().on("value", function(snapshot){
  FirebaseContent = snapshot.val();
  console.log(FirebaseContent)
}, function (errorObject) {
  console.log("The read failed: " + errorObject.code);
});
//console.log(rootRef)
//console.log(rootRef);
