(function (){
  'use strict';

  require("./config")

  casper.test.begin('Home page looks sexy', 4, function suite(test) {
    casper.start("http://15.185.121.83:30001", function() {
      test.assertTitle("WeaveSocks", "homepage title is the one expected");
      test.assertTextExists("Login", "login link is present");
      test.assertNotVisible("ul.menu li.howdy", "user is not logged in");
      test.assertTextExists("0 items in cart", "cart is empty");
    });

    casper.run(function() {
      test.done();
    });
  });
}());
