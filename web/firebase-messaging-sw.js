importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js");

   /*Update with yours config*/
  const firebaseConfig = {
    apiKey: "AIzaSyAkqJg0rQgR-ANy5xn9ff7j1LJP3pWSiGY",
    authDomain: "hsa-app-534ea.firebaseapp.com",
    projectId: "hsa-app-534ea",
    storageBucket: "hsa-app-534ea.appspot.com",
    messagingSenderId: "888835143892",
    appId: "1:888835143892:web:c75b99825a73023fa0e341",
    measurementId: "G-8Z35431T5Y"
  };
  firebase.initializeApp(firebaseConfig);
  const messaging = firebase.messaging();

  /*messaging.onMessage((payload) => {
  console.log('Message received. ', payload);*/
  messaging.onBackgroundMessage(function(payload) {
    console.log("Received background message ", payload);

    const notificationTitle = payload.notification.title;
    const notificationOptions = {
      body: payload.notification.body,
    };

    self.registration.showNotification(notificationTitle,
      notificationOptions);
  });