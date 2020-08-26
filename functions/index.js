const functions = require('firebase-functions');

var admin = require("firebase-admin");
admin.initializeApp({});

const db = admin.firestore();

exports.createUser = functions.auth.user().onCreate(
   user =>
   {
      var today = new Date();
      var day30 = new Date();
      db.doc('users/'+user.uid).set({
         name : user.displayName,
         uid : user.uid,
         phoneNum : null,
         userCount : [],
         accCreated : today.getFullYear(),
         homeId: null,
         buildings:[],
         buildingsPhoto:{},
         expDate: day30.setDate(today.getDate()+30),
         requests:[],
         upiId:null,
         rent:null,
         offlineBuildings:[]
      });
      db.collection('users/' + user.uid + '/payments').doc(payments);
   },
);