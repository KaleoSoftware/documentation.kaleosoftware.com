# Kaleo / ServiceNow Deflection Mail Script

When a user sends an email to ServiceNow to create a new Incident, Kaleo/ServiceNow can be configured to immediately respond back to the user with an email with a few relevant answers that might solve their problem. Kaleo will append notes to the Incident to track each answer they view, and also allow them to close the incident if one of the Kaleo answers solves their problem.

## End-User Experience
The following screenshots show the flow from sending the initial email, through to closing the Incident.

![](/images/SNDeflectionMailScript1.jpg)

![](/images/SNDeflectionMailScript2.jpg)

![](/images/SNDeflectionMailScript3.jpg)

![](/images/SNDeflectionMailScript4.jpg)

![](/images/SNDeflectionMailScript5.jpg)

![](/images/SNDeflectionMailScript6.jpg)

![](/images/SNDeflectionMailScript7.jpg)

![](/images/SNDeflectionMailScript8.jpg)

## Implementation

### Email Script
In ServiceNow, create a new email script with the name `kaleo_incident_include_results` and the following code:

```javascript
(function runMailScript(current, template, email, email_action, event) {
  /* SEE BOTTOM OF THIS FILE FOR CONFIGURATION OPTIONS */

  /**
   * Construct Kaleo API object
   * @constructor
   * @param {Object} options
   * @param {Object} options.platform - The platform this server code is running on, servicenow or node or browser
   * @param {string} options.host - Kaleo host ie https://mytenant.kaleosoftware.com
   * @param {string} options.shared_secret - Should be the same as your Kaleo tenant's setting authentication.shared_secret
   * @param {string} options.widget_token - Kaleo widget to use to control which boards to search
   * @param {Object} options.getUser - Fn that should return an object with the current user's info {email: ..., firstname: ..., lastname: ...}
   *        i.e. in SN test console function() {return {email: gs.getUser().getEmail(), firstname: gs.getUser().getFirstName(), lastname: gs.getUser().getLastName()}}
   *        in SN email script, function() {return {email: '${caller_id.email}', firstname: '${caller_id.first_name}', lastname: '${caller_id.last_name}'}}
   * @param {string} options.source - What should the source of the API call be set to for reporting, i.e. 'servicenow'
   * @param {integer} options.relevance_threshold - Will only return results over this relevance threshold (0-100)
   * @param {integer} options.max_results - Only return at most this many results
   * @returns {Object}  KaleoAPI object
   */
  var KaleoAPI = function(options) {

    // Platform Specific Utils
    var PlatformUtils = {
      node: {
        getURL: function(url, params, success, failure) {
          var unirest = require('unirest');
          var Request = unirest.get(url);
          var handleResponse = function(response) {
            if (response.ok) {
              success(response.body);
            } else {
              failure(response.body);
            }
          };
          Request.query(params).end(handleResponse);
        },
        log: function(msg) {
          console.log(msg);
        }
      },
      browser: {
        // Depends on jQuery
        getURL: function(url, params, success, failure) {
          var handleResponse = function(response, status) {
            if (status == 'success') {
              success(response);
            } else {
              failure(response);
            }
          };
          jQuery.getJSON(url, params, handleResponse);
        },
        log: function(msg) {
          console.log(msg);
        }
      },
      servicenow: {
        getURL: function(url, params, success, failure) {
          var restMessage = new sn_ws.RESTMessageV2();
          restMessage.setHttpMethod("get");
          restMessage.setEndpoint(url);
          for (var prop in params) {
            restMessage.setQueryParameter(prop, params[prop]);
          }

          var response = restMessage.execute();
          var body = response.getBody();
          var result = {collection: [], meta: {}}
          if (response.getStatusCode() == 200 && response.getHeader('Content-Type') == 'application/json') {
            try {
              result = JSON.parse(body);
              success(result);
            } catch(err) {
              failure(body);
            }
          }
        },
        log: function(msg) {
          gs.log(JSON.stringify(msg));
        }
      }
    }

    var Utils = PlatformUtils[options.platform];

    // Set up defaults
    options.relevance_threshold = options.relevance_threshold || 5;
    options.source = options.source || 'kaleo_api';
    options.getUser = options.getUser || function(){return {email: 'test@example.com', firstname: 'Test', lastname: 'User'}}

    var KALEO_JWT_FN = function(){
      var global={};
      !function(r){global.KaleoJWT=r()}(function(){return function r(e,t,n){function o(f,i){if(!t[f]){if(!e[f]){var c="function"==typeof require&&require;if(!i&&c)return c(f,!0);if(a)return a(f,!0);var h=new Error("Cannot find module '"+f+"'");throw h.code="MODULE_NOT_FOUND",h}var u=t[f]={exports:{}};e[f][0].call(u.exports,function(r){var t=e[f][1][r];return o(t?t:r)},u,u.exports,r,e,t,n)}return t[f].exports}for(var a="function"==typeof require&&require,f=0;f<n.length;f++)o(n[f]);return o}({1:[function(r,e,t){e.exports={_keyStr:"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=",encode:function(r){var e,t,n,o,a,f,i,c="",h=0;for(r=this._utf8_encode(r);h<r.length;)e=r.charCodeAt(h++),t=r.charCodeAt(h++),n=r.charCodeAt(h++),o=e>>2,a=(3&e)<<4|t>>4,f=(15&t)<<2|n>>6,i=63&n,isNaN(t)?f=i=64:isNaN(n)&&(i=64),c=c+this._keyStr.charAt(o)+this._keyStr.charAt(a)+this._keyStr.charAt(f)+this._keyStr.charAt(i);return c},decode:function(r){var e,t,n,o,a,f,i,c="",h=0;for(r=r.replace(/[^A-Za-z0-9+\/=]/g,"");h<r.length;)o=this._keyStr.indexOf(r.charAt(h++)),a=this._keyStr.indexOf(r.charAt(h++)),f=this._keyStr.indexOf(r.charAt(h++)),i=this._keyStr.indexOf(r.charAt(h++)),e=o<<2|a>>4,t=(15&a)<<4|f>>2,n=(3&f)<<6|i,c+=String.fromCharCode(e),64!=f&&(c+=String.fromCharCode(t)),64!=i&&(c+=String.fromCharCode(n));return c=this._utf8_decode(c)},_utf8_encode:function(r){r=r.replace(/rn/g,"n");for(var e="",t=0;t<r.length;t++){var n=r.charCodeAt(t);n<128?e+=String.fromCharCode(n):n>127&&n<2048?(e+=String.fromCharCode(n>>6|192),e+=String.fromCharCode(63&n|128)):(e+=String.fromCharCode(n>>12|224),e+=String.fromCharCode(n>>6&63|128),e+=String.fromCharCode(63&n|128))}return e},_utf8_decode:function(r){for(var e="",t=0,n=c1=c2=0;t<r.length;)n=r.charCodeAt(t),n<128?(e+=String.fromCharCode(n),t++):n>191&&n<224?(c2=r.charCodeAt(t+1),e+=String.fromCharCode((31&n)<<6|63&c2),t+=2):(c2=r.charCodeAt(t+1),c3=r.charCodeAt(t+2),e+=String.fromCharCode((15&n)<<12|(63&c2)<<6|63&c3),t+=3);return e}}},{}],2:[function(r,e,t){e.exports={encode:function(r){return r=r.replace(/=+$/,""),r=r.replace(/\+/g,"-"),r=r.replace(/\//g,"_")},decode:function(r){return r=(r+"===").slice(0,r.length+r.length%4),r.replace(/-/g,"+").replace(/_/g,"/"),r}}},{}],3:[function(r,e,t){e.exports=function(){function r(r){var e,t,n,o="",a=-1;if(r&&r.length)for(n=r.length;(a+=1)<n;)e=r.charCodeAt(a),t=a+1<n?r.charCodeAt(a+1):0,55296<=e&&e<=56319&&56320<=t&&t<=57343&&(e=65536+((1023&e)<<10)+(1023&t),a+=1),e<=127?o+=String.fromCharCode(e):e<=2047?o+=String.fromCharCode(192|e>>>6&31,128|63&e):e<=65535?o+=String.fromCharCode(224|e>>>12&15,128|e>>>6&63,128|63&e):e<=2097151&&(o+=String.fromCharCode(240|e>>>18&7,128|e>>>12&63,128|e>>>6&63,128|63&e));return o}function e(r,e){var t=(65535&r)+(65535&e),n=(r>>16)+(e>>16)+(t>>16);return n<<16|65535&t}function t(r,e){for(var t,n=e?"0123456789ABCDEF":"0123456789abcdef",o="",a=0,f=r.length;a<f;a+=1)t=r.charCodeAt(a),o+=n.charAt(t>>>4&15)+n.charAt(15&t);return o}function n(r){var e,t=32*r.length,n="";for(e=0;e<t;e+=8)n+=String.fromCharCode(r[e>>5]>>>24-e%32&255);return n}function o(r){var e,t=8*r.length,n=Array(r.length>>2),o=n.length;for(e=0;e<o;e+=1)n[e]=0;for(e=0;e<t;e+=8)n[e>>5]|=(255&r.charCodeAt(e/8))<<24-e%32;return n}function a(r,e){var t,n,o,a,f,i,c,h,u=e.length,d=Array();for(i=Array(Math.ceil(r.length/2)),a=i.length,t=0;t<a;t+=1)i[t]=r.charCodeAt(2*t)<<8|r.charCodeAt(2*t+1);for(;i.length>0;){for(f=Array(),o=0,t=0;t<i.length;t+=1)o=(o<<16)+i[t],n=Math.floor(o/u),o-=n*u,(f.length>0||n>0)&&(f[f.length]=n);d[d.length]=o,i=f}for(c="",t=d.length-1;t>=0;t--)c+=e.charAt(d[t]);for(h=Math.ceil(8*r.length/(Math.log(e.length)/Math.log(2))),t=c.length;t<h;t+=1)c=e[0]+c;return c}function f(r,e){var t,n,o,a="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/",f="",i=r.length;for(e=e||"=",t=0;t<i;t+=3)for(o=r.charCodeAt(t)<<16|(t+1<i?r.charCodeAt(t+1)<<8:0)|(t+2<i?r.charCodeAt(t+2):0),n=0;n<4;n+=1)f+=8*t+6*n>8*r.length?e:a.charAt(o>>>6*(3-n)&63);return f}var i;return i={VERSION:"1.0.5",SHA256:function(i){function c(e,t){return e=t?r(e):e,n(y(o(e),8*e.length))}function h(e,t){e=_?r(e):e,t=_?r(t):t;var a,f=0,i=o(e),c=Array(16),h=Array(16);for(i.length>16&&(i=y(i,8*e.length));f<16;f+=1)c[f]=909522486^i[f],h[f]=1549556828^i[f];return a=y(c.concat(o(t)),512+8*t.length),n(y(h.concat(a),768))}function u(r,e){return r>>>e|r<<32-e}function d(r,e){return r>>>e}function l(r,e,t){return r&e^~r&t}function g(r,e,t){return r&e^r&t^e&t}function s(r){return u(r,2)^u(r,13)^u(r,22)}function C(r){return u(r,6)^u(r,11)^u(r,25)}function p(r){return u(r,7)^u(r,18)^d(r,3)}function A(r){return u(r,17)^u(r,19)^d(r,10)}function y(r,t){var n,o,a,f,i,c,h,u,d,y,m,v,_=[1779033703,-1150833019,1013904242,-1521486534,1359893119,-1694144372,528734635,1541459225],x=new Array(64);for(r[t>>5]|=128<<24-t%32,r[(t+64>>9<<4)+15]=t,d=0;d<r.length;d+=16){for(n=_[0],o=_[1],a=_[2],f=_[3],i=_[4],c=_[5],h=_[6],u=_[7],y=0;y<64;y+=1)y<16?x[y]=r[y+d]:x[y]=e(e(e(A(x[y-2]),x[y-7]),p(x[y-15])),x[y-16]),m=e(e(e(e(u,C(i)),l(i,c,h)),S[y]),x[y]),v=e(s(n),g(n,o,a)),u=h,h=c,c=i,i=e(f,m),f=a,a=o,o=n,n=e(m,v);_[0]=e(n,_[0]),_[1]=e(o,_[1]),_[2]=e(a,_[2]),_[3]=e(f,_[3]),_[4]=e(i,_[4]),_[5]=e(c,_[5]),_[6]=e(h,_[6]),_[7]=e(u,_[7])}return _}var S,m=!(!i||"boolean"!=typeof i.uppercase)&&i.uppercase,v=i&&"string"==typeof i.pad?i.pda:"=",_=!i||"boolean"!=typeof i.utf8||i.utf8;this.hex=function(r){return t(c(r,_))},this.b64=function(r){return f(c(r,_),v)},this.any=function(r,e){return a(c(r,_),e)},this.raw=function(r){return c(r,_)},this.hex_hmac=function(r,e){return t(h(r,e))},this.b64_hmac=function(r,e){return f(h(r,e),v)},this.any_hmac=function(r,e,t){return a(h(r,e),t)},this.vm_test=function(){return"900150983cd24fb0d6963f7d28e17f72"===hex("abc").toLowerCase()},this.setUpperCase=function(r){return"boolean"==typeof r&&(m=r),this},this.setPad=function(r){return v=r||v,this},this.setUTF8=function(r){return"boolean"==typeof r&&(_=r),this},S=[1116352408,1899447441,-1245643825,-373957723,961987163,1508970993,-1841331548,-1424204075,-670586216,310598401,607225278,1426881987,1925078388,-2132889090,-1680079193,-1046744716,-459576895,-272742522,264347078,604807628,770255983,1249150122,1555081692,1996064986,-1740746414,-1473132947,-1341970488,-1084653625,-958395405,-710438585,113926993,338241895,666307205,773529912,1294757372,1396182291,1695183700,1986661051,-2117940946,-1838011259,-1564481375,-1474664885,-1035236496,-949202525,-778901479,-694614492,-200395387,275423344,430227734,506948616,659060556,883997877,958139571,1322822218,1537002063,1747873779,1955562222,2024104815,-2067236844,-1933114872,-1866530822,-1538233109,-1090935817,-965641998]}}}()},{}],4:[function(r,e,t){e.exports=function(){function e(r){if(null==r.match(/^([^.]+)\.([^.]+)\.([^.]+)$/))throw"JWT token is not a form of 'Head.Payload.SigValue'.";return{header:RegExp.$1,payload:RegExp.$2,sig:RegExp.$3}}function t(r,e,t){var n=i.encode(f.encode(JSON.stringify(r))),o=i.encode(f.encode(JSON.stringify(e))),c=i.encode(a.b64_hmac(t,n+"."+o));return n+"."+o+"."+c}function n(r,t){var n=e(r),o=i.encode(a.b64_hmac(t,n.header+"."+n.payload));return o===n.sig}var o=r("./hashes-hs256.js"),a=new o.SHA256,f=r("./Base64.js"),i=r("./Base64url"),c={alg:"HS256",typ:"JWT"};return{sign:function(r,e){return r.exp=r.exp||Math.floor(Date.now()/1e3)+3600,t(c,r,e)},decode:function(r){var t=e(r);return f.decode(i.decode(t.payload))},verify:function(r,e){return n(r,e)}}}()},{"./Base64.js":1,"./Base64url":2,"./hashes-hs256.js":3}]},{},[4])(4)});
      return global.KaleoJWT;
    }();

    var getRelevantResults = function(term, ticket_id, success, failure) {
      var user = options.getUser();
      var url = options.host+"/api/v5/questions/relevant";
      success = success || function(response){Utils.log(response)};
      failure = failure || function(response){Utils.log(response)};
      var params = {
        term: term,
        ticket_id: ticket_id,
        relevance_threshold: options.relevance_threshold,
        widget_token: options.widget_token,
        ap_jwt: KALEO_JWT_FN.sign(user, options.shared_secret),
        source: options.source
      };
      Utils.getURL(url, params, success, failure);
    };

    return {
      getRelevantResults: getRelevantResults,
      Utils: Utils
    }
  }

  /**************************************************/
  var KALEO_CONFIG = {
    platform: "servicenow",
    source: 'servicenow',
    host: 'https://YOURTENANT.kaleosoftware.com',
    shared_secret: 'YOUR_SECRET',
    widget_token: 'YOUR_WIDGET_TOKEN',
    relevance_threshold: 1,
    getUser: function() {
      var userObject = gs.getUser().getUserByID(current.caller_id);
      return {
        email: userObject.email,
        firstname: userObject.getFirstName(),
        lastname: userObject.getLastName()}
      }
  };

  var TERM = current.short_description;
  var TICKET_ID = current.sys_id;

  var success = function(response){
    if (response.collection.length > 0)
      template.print(response.html);
  }

  if (current.contact_type == 'email') {
    var kaleo = KaleoAPI(KALEO_CONFIG);
    kaleo.getRelevantResults(TERM, TICKET_ID, success);
  }

})(current, template, email, email_action, event);

```

The `KALEO_CONFIG` var at the end of the file contains the configuration that should be used

  * host: the URL for your kaleo tenant, i.e. https://acme.kaleosoftware.com
  * shared_secret: The same value as in your tenant setting `authentication.shared_secret`
  * widget_token: If you want Kaleo results to pull from specific Boards only, you can specify a Kaleo Widget token here.
  * relevance_threshold: An integer from 1-100 that controls how "relevant" results have to be to be returned. Setting this too high will result in no results returned.

### Email Notification
ServiceNow by default has an email notification `Incident opened for me` that goes out to a user when an Incident has been opened on their behalf. We will add the Kaleo mail script to this notification. Add this line of code to the notification:

`${mail_script:kaleo_incident_include_results}`

![](/images/SNDeflectionMailScript9.jpg)

You can click the `Preview Notification` button and you should see the Kaleo results appended to the end of the email (if any results were found above the relevance_threshold).
