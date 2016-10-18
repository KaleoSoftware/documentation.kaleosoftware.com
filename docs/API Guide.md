# API Guide

Kaleo offers a REST API for access to the content within each Kaleo Board.

## Online Docs

The API is documented at https://YOUR_TENANT.kaleosoftware.com/swagger/?url=%2Fapi%2Fv5%2Fswagger_doc

You will need to be logged in to your Kaleo instance to view the API docs.

## JWT-based Authentication

The Kaleo JWT implementation supports the HS256 algorithm. Kaleo maintains a Javascript JWT library here https://github.com/KaleoSoftware/KaleoJWT that can be used to authenticate access to the API and auto-provision users. This is applicable only in server-based integration scenarios where a shared secret is maintained between Kaleo and the target system, and not accessible to users via their browser. This technique requires a shared secret setting be created in the Kaleo Admin Panel at `/admin/setting` called `authentication.shared_secret`.

Using the KaleoJWT library, sample usage would be as follows:

```javascript
// This secret must also be created in Kaleo
var SHARED_SECRET = "sekret"
// Populate this with the authenticated users info on your system
var user_info = {
  email: "sally@x.com",
  firstname: "Sally",
  lastname: "Fields"
}

var KaleoJWT = PASTE IN MINIFIED CODE FROM KaleoJWT REPO HERE

var jwt = KaleoJWT.sign(user_info, SHARED_SECRET);
$.get('/api/v5/questions?ap_jwt='+jwt, function(data){
  console.log(data);
})

```

## Cookie-based Authentication

If the user is already logged in to Kaleo and has the Kaleo authentication cookie, you can make API calls in Javascript in the user's browser using our helper class `Kaleo.API` which will make AJAX REST calls using the users existing cookies, so no additional login or authentication is required.

The JS code is available here:

https://YOUR TENANT.kaleosoftware.com/assets/widgets/api-v5.js

So sample usage on your page is as follows:

```
  <!-- Kaleo.API requires jQuery but if you already have in on your page you dont need to include it again -->
  <script src="https://code.jquery.com/jquery-1.11.2.min.js"></script>

  <!-- These next 2 scripts are required and will load the Kaleo.API object into your page -->
  <script src="http://YOUR TENANT.kaleosoftware.com/easyxdm/easyXDM.min.js"></script>
  <script src="http://YOUR TENANT.kaleosoftware.com/assets/widgets/api-v5.js"></script>

  <script>
    $(function () {
      var opts = {};
      // This is the URL of your Kaleo tenant
      opts.host = "http://YOUR TENANT.kaleosoftware.com";
      opts.widgetToken = "123"; // Optional
      opts.useEasyXDM = true;

      var kaleoAPI = new window.Kaleo.API(opts);

      var doGet = function() {
        var url = "/api/v5/questions/trending"
        var success_cb = function(data){console.log(data)};
        var error_cb = function(xhr, err, msg){console.error(msg)};
        kaleoAPI.get(url, {}, success_cb, error_cb);
      };

      doGet()
    });
  </script>

```
