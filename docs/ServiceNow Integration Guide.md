# Kaleo ServiceNow Integration

Kaleo's API can be used to integrate Kaleo results into searches done in the ServiceNow system. This document describes how to integrate Kaleo into the ServiceNow Portal (Helinski) but the techniques and APIs are generally applicable across other SN products and versions.

![](/images/SN-typeahead.png)

## Kaleo Configuration

Kaleo has a concept of a Widget, and ServiceNow does as well.  In Kaleo, you need to first configure a Kaleo Widget by going to your Kaleo Admin `/admin/widget` and creating a new widget that has an `authentication_token` (you can make up your own or Kaleo will create one for you. It is just a long string of text that serves as an API key) and also specify Searchable Boards. What this does is allow you to make Kaleo API calls using this widget token and Kaleo will only return results from the Searchable Boards.

Also in your Kaleo Admin `/admin/setting`, create a setting called `authentication.shared_secret` and set it to a string of text that you will also use on the ServiceNow side of things to communicate securely.

## ServiceNow Configuration

### Server Script

ServiceNow allows you to write Server Scripts that run not in the user's browser, but on the ServiceNow server. The first snippet of code is a function that will get an array of results from a particular Kaleo Widget.  This script is self-contained and does not have any widget-specific dependencies, so it should be useable anywhere in ServiceNow where a Server Script can be run.

First, locate the ServiceNow Widget you want to edit, which in our case will be the Typeahead Search Widget (you will need to clone the default widget to make a copy). The best place to edit widget code is `https://YOUR_SN_INSTANCE/sp_config?id=widget_editor` and search for the widget name in the drop down. You will see a 3-panel editor with the HTML/Client/Server code ready for editing.

Now, lets add our code in the Server Script section. This code snippet has the default (as of Helinski) ServiceNow code, with comments as to where the Kaleo changes are. Note the CHANGEME section for entering configuration values specific to your environment. Obviously this should just be a jumping off point for your own customizations.


```javascript
(function() {


  data.searchType = $sp.getParameter("t");
	data.results = [];
  data.searchMsg = gs.getMessage("Search");
	data.limit = options.limit || 15;
	var textQuery = '123TEXTQUERY321';

	if (!input)
		return;

	data.q = input.q;

  // START KALEO ADDITIONS
	if (gs.isLoggedIn())
    Array.prototype.push.apply(data.results, getKaleoResults());
  // END KALEO ADDITIONS

	getKnowledge();

	if (gs.isLoggedIn())
		getCatalogItems();

  data.sqandaEnabled = gs.getProperty('glide.sp.socialqa.enabled', false) === 'true';

  if (data.sqandaEnabled)
		getQuestions();

	// add in additional search tables from sp_search_groups
	var portalGR = $sp.getPortalRecord();
	var portalID = portalGR.getDisplayValue('sys_id');
	var sg = GlideRecord('sp_search_group');
	sg.addQuery('sp_portal',portalID);
	sg.addQuery('active',true);
	sg.orderBy('order');
	sg.query();
	while (sg.next())
		addSearchTable(sg);

	// typeahead search generates multiple "Your text query contained only
	// common words..." msgs, we don't want them
	gs.flushMessages();

	function addSearchTable(sg) {
		var table = sg.getValue('name');
		var condition = sg.getValue('condition');
		var gr = GlideRecord(table);
		if (condition)
			gr.addEncodedQuery(condition);

		gr.addQuery(textQuery, data.q);
		gr.query();
		var searchTableCount = 0;
		while (gr.next() && searchTableCount < data.limit) {
			var rec = {};
			rec.type = "rec";
			rec.table = table;
			rec.sys_id = gr.getDisplayValue('sys_id');
			rec.page = sg.getDisplayValue('sp_page');
			if (!rec.page)
				rec.page = "form";
			rec.label = gr.getDisplayValue();
			rec.score = parseInt(gr.ir_query_score.getDisplayValue());
			data.results.push(rec);
			searchTableCount++;
		}
	}

	function getKnowledge() {
		var kb = new GlideRecord('kb_knowledge');
		kb.addQuery('workflow_state', 'published');
		kb.addQuery('valid_to', '>=', (new GlideDate()).getLocalDate().getValue());
		kb.addQuery(textQuery, data.q);
		kb.addQuery('kb_knowledge_base', $sp.getValue('kb_knowledge_base'));
		kb.query();
		var kbCount = 0;
		while (kb.next() && kbCount < data.limit) {
			if (!$sp.canReadRecord(kb))
				continue;

			var article = {};
			article.type = "kb";
			$sp.getRecordDisplayValues(article, kb, 'sys_id,number,short_description,published,text');
			if (!article.text)
				article.text = "";
			article.text = $sp.stripHTML(article.text);
			article.text = article.text.substring(0,200);
			article.score = parseInt(kb.ir_query_score.getDisplayValue());
			article.label = article.short_description;
			data.results.push(article);
			kbCount++;
		}
	}

	function getCatalogItems() {
		var sc = new GlideRecord('sc_cat_item');
		sc.addQuery(textQuery, data.q);
		sc.addQuery('active',true);
		sc.addQuery('no_search', '!=', true);
		sc.addQuery('visible_standalone', true);
		sc.addQuery('sys_class_name', 'NOT IN', 'sc_cat_item_wizard');
		sc.addQuery('sc_catalogs', $sp.getValue('sc_catalog'));
		sc.query();
		var catCount = 0;
		while (sc.next() && catCount < data.limit) {
			if (!$sp.canReadRecord(sc))
				continue;

			var item = {};
			if (sc.getRecordClassName() == "sc_cat_item_guide")
				item.type = "sc_guide";
			else if (sc.getRecordClassName() == "sc_cat_item_content") {
				var gr = new GlideRecord('sc_cat_item_content');
				gr.get(sc.getUniqueValue());
				$sp.getRecordValues(item, gr, 'url,content_type,kb_article');
				item.type = "sc_content";
			}
			else
				item.type = "sc";

			$sp.getRecordDisplayValues(item, sc, 'name,short_description,picture,price,sys_id');
			item.score = parseInt(sc.ir_query_score.getDisplayValue());
			item.label = item.name;
			data.results.push(item);
			catCount++;
		}
	}

	function getQuestions() {
		var questionGR = new GlideRecord("kb_social_qa_question");
		questionGR.addActiveQuery();
		questionGR.addQuery(textQuery, data.q);
		questionGR.query();
		var qCount = 0;
		while (questionGR.next() && qCount < data.limit) {
			if (!$sp.canReadRecord(questionGR))
				continue;

			var question = {};
			question.type = "qa";
			$sp.getRecordDisplayValues(question, questionGR, 'question,question_details,sys_created_on,sys_id');
			question.text = (question.question_details) ? $sp.stripHTML(question.question_details) : "";
			question.text = question.text.substring(0,200);
			question.label = question.question;
			question.score = 0;
			data.results.push(question);
			qCount++;
		}
	}

  // START KALEO ADDITIONS
  function getKaleoResults() {
    // CHANGEME THESE VALUES FOR YOUR KALEO CONFIGURATION
    var KALEO_HOST = 'CHANGEME https://YOUR-TENANT-HERE.kaleosoftware.com';
    var WIDGET_TOKEN = 'CHANGEME YOUR WIDGET TOKEN';
    var SHARED_SECRET = 'CHANGEME YOUR authentication.shared_secret SETTING';
    var MAX_RESULTS = 5;

    var KaleoJWT = function(){
      var global={};
	    !function(r){if("object"==typeof exports&&"undefined"!=typeof module)module.exports=r();else if("function"==typeof define&&define.amd)define([],r);else{var e;e="undefined"!=typeof window?window:"undefined"!=typeof global?global:"undefined"!=typeof self?self:this,e.KaleoJWT=r()}}(function(){return function r(e,t,n){function o(f,i){if(!t[f]){if(!e[f]){var c="function"==typeof require&&require;if(!i&&c)return c(f,!0);if(a)return a(f,!0);var h=new Error("Cannot find module '"+f+"'");throw h.code="MODULE_NOT_FOUND",h}var u=t[f]={exports:{}};e[f][0].call(u.exports,function(r){var t=e[f][1][r];return o(t?t:r)},u,u.exports,r,e,t,n)}return t[f].exports}for(var a="function"==typeof require&&require,f=0;f<n.length;f++)o(n[f]);return o}({1:[function(r,e,t){e.exports={_keyStr:"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=",
      encode:function(r){var e,t,n,o,a,f,i,c="",h=0;for(r=this._utf8_encode(r);h<r.length;)e=r.charCodeAt(h++),t=r.charCodeAt(h++),n=r.charCodeAt(h++),o=e>>2,a=(3&e)<<4|t>>4,f=(15&t)<<2|n>>6,i=63&n,isNaN(t)?f=i=64:isNaN(n)&&(i=64),c=c+this._keyStr.charAt(o)+this._keyStr.charAt(a)+this._keyStr.charAt(f)+this._keyStr.charAt(i);return c},decode:function(r){var e,t,n,o,a,f,i,c="",h=0;for(r=r.replace(/[^A-Za-z0-9+\/=]/g,"");h<r.length;)o=this._keyStr.indexOf(r.charAt(h++)),a=this._keyStr.indexOf(r.charAt(h++)),f=this._keyStr.indexOf(r.charAt(h++)),i=this._keyStr.indexOf(r.charAt(h++)),e=o<<2|a>>4,t=(15&a)<<4|f>>2,n=(3&f)<<6|i,c+=String.fromCharCode(e),64!=f&&(c+=String.fromCharCode(t)),64!=i&&(c+=String.fromCharCode(n));return c=this._utf8_decode(c)},
      _utf8_encode:function(r){r=r.replace(/rn/g,"n");for(var e="",t=0;t<r.length;t++){var n=r.charCodeAt(t);n<128?e+=String.fromCharCode(n):n>127&&n<2048?(e+=String.fromCharCode(n>>6|192),e+=String.fromCharCode(63&n|128)):(e+=String.fromCharCode(n>>12|224),e+=String.fromCharCode(n>>6&63|128),e+=String.fromCharCode(63&n|128))}return e},_utf8_decode:function(r){for(var e="",t=0,n=c1=c2=0;t<r.length;)n=r.charCodeAt(t),n<128?(e+=String.fromCharCode(n),t++):n>191&&n<224?(c2=r.charCodeAt(t+1),e+=String.fromCharCode((31&n)<<6|63&c2),t+=2):(c2=r.charCodeAt(t+1),c3=r.charCodeAt(t+2),e+=String.fromCharCode((15&n)<<12|(63&c2)<<6|63&c3),t+=3);return e}}},{}],2:[function(r,e,t){e.exports={encode:function(r){return r=r.replace(/=+$/,""),r=r.replace(/\+/g,"-"),r=r.replace(/\//g,"_")},decode:function(r){return r=(r+"===").slice(0,r.length+r.length%4),r.replace(/-/g,"+").replace(/_/g,"/"),r}}},{}],3:[function(r,e,t){e.exports=function(){function r(r){var e,t,n,o="",a=-1;if(r&&r.length)for(n=r.length;(a+=1)<n;)e=r.charCodeAt(a),t=a+1<n?r.charCodeAt(a+1):0,55296<=e&&e<=56319&&56320<=t&&t<=57343&&(e=65536+((1023&e)<<10)+(1023&t),a+=1),e<=127?o+=String.fromCharCode(e):e<=2047?o+=String.fromCharCode(192|e>>>6&31,128|63&e):e<=65535?o+=String.fromCharCode(224|e>>>12&15,128|e>>>6&63,128|63&e):e<=2097151&&(o+=String.fromCharCode(240|e>>>18&7,128|e>>>12&63,128|e>>>6&63,128|63&e));return o}
      function e(r,e){var t=(65535&r)+(65535&e),n=(r>>16)+(e>>16)+(t>>16);return n<<16|65535&t}function t(r,e){for(var t,n=e?"0123456789ABCDEF":"0123456789abcdef",o="",a=0,f=r.length;a<f;a+=1)t=r.charCodeAt(a),o+=n.charAt(t>>>4&15)+n.charAt(15&t);return o}function n(r){var e,t=32*r.length,n="";for(e=0;e<t;e+=8)n+=String.fromCharCode(r[e>>5]>>>24-e%32&255);return n}function o(r){var e,t=8*r.length,n=Array(r.length>>2),o=n.length;for(e=0;e<o;e+=1)n[e]=0;for(e=0;e<t;e+=8)n[e>>5]|=(255&r.charCodeAt(e/8))<<24-e%32;return n}function a(r,e){var t,n,o,a,f,i,c,h,u=e.length,d=Array();for(i=Array(Math.ceil(r.length/2)),a=i.length,t=0;t<a;t+=1)i[t]=r.charCodeAt(2*t)<<8|r.charCodeAt(2*t+1);for(;i.length>0;){for(f=Array(),o=0,t=0;t<i.length;t+=1)o=(o<<16)+i[t],n=Math.floor(o/u),o-=n*u,(f.length>0||n>0)&&(f[f.length]=n);d[d.length]=o,i=f}for(c="",t=d.length-1;t>=0;t--)c+=e.charAt(d[t]);for(h=Math.ceil(8*r.length/(Math.log(e.length)/Math.log(2))),t=c.length;t<h;t+=1)c=e[0]+c;return c}
      function f(r,e){var t,n,o,a="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/",f="",i=r.length;for(e=e||"=",t=0;t<i;t+=3)for(o=r.charCodeAt(t)<<16|(t+1<i?r.charCodeAt(t+1)<<8:0)|(t+2<i?r.charCodeAt(t+2):0),n=0;n<4;n+=1)f+=8*t+6*n>8*r.length?e:a.charAt(o>>>6*(3-n)&63);return f}var i;return i={VERSION:"1.0.5",SHA256:function(i){function c(e,t){return e=t?r(e):e,n(y(o(e),8*e.length))}function h(e,t){e=_?r(e):e,t=_?r(t):t;var a,f=0,i=o(e),c=Array(16),h=Array(16);for(i.length>16&&(i=y(i,8*e.length));f<16;f+=1)c[f]=909522486^i[f],h[f]=1549556828^i[f];return a=y(c.concat(o(t)),512+8*t.length),n(y(h.concat(a),768))}function u(r,e){return r>>>e|r<<32-e}function d(r,e){return r>>>e}function l(r,e,t){return r&e^~r&t}function g(r,e,t){return r&e^r&t^e&t}
      function s(r){return u(r,2)^u(r,13)^u(r,22)}function C(r){return u(r,6)^u(r,11)^u(r,25)}function p(r){return u(r,7)^u(r,18)^d(r,3)}function A(r){return u(r,17)^u(r,19)^d(r,10)}function y(r,t){var n,o,a,f,i,c,h,u,d,y,m,v,_=[1779033703,-1150833019,1013904242,-1521486534,1359893119,-1694144372,528734635,1541459225],x=new Array(64);for(r[t>>5]|=128<<24-t%32,r[(t+64>>9<<4)+15]=t,d=0;d<r.length;d+=16){for(n=_[0],o=_[1],a=_[2],f=_[3],i=_[4],c=_[5],h=_[6],u=_[7],y=0;y<64;y+=1)y<16?x[y]=r[y+d]:x[y]=e(e(e(A(x[y-2]),x[y-7]),p(x[y-15])),x[y-16]),m=e(e(e(e(u,C(i)),l(i,c,h)),S[y]),x[y]),v=e(s(n),g(n,o,a)),u=h,h=c,c=i,i=e(f,m),f=a,a=o,o=n,n=e(m,v);_[0]=e(n,_[0]),_[1]=e(o,_[1]),_[2]=e(a,_[2]),_[3]=e(f,_[3]),_[4]=e(i,_[4]),_[5]=e(c,_[5]),_[6]=e(h,_[6]),_[7]=e(u,_[7])}return _}var S,m=!(!i||"boolean"!=typeof i.uppercase)&&i.uppercase,v=i&&"string"==typeof i.pad?i.pda:"=",_=!i||"boolean"!=typeof i.utf8||i.utf8;this.hex=function(r){return t(c(r,_))},this.b64=function(r){return f(c(r,_),v)},this.any=function(r,e){return a(c(r,_),e)},this.raw=function(r){return c(r,_)},
      this.hex_hmac=function(r,e){return t(h(r,e))},this.b64_hmac=function(r,e){return f(h(r,e),v)},this.any_hmac=function(r,e,t){return a(h(r,e),t)},this.vm_test=function(){return"900150983cd24fb0d6963f7d28e17f72"===hex("abc").toLowerCase()},this.setUpperCase=function(r){return"boolean"==typeof r&&(m=r),this},this.setPad=function(r){return v=r||v,this},this.setUTF8=function(r){return"boolean"==typeof r&&(_=r),this},S=[1116352408,1899447441,-1245643825,-373957723,961987163,1508970993,-1841331548,-1424204075,-670586216,310598401,607225278,1426881987,1925078388,-2132889090,-1680079193,-1046744716,-459576895,-272742522,264347078,604807628,770255983,1249150122,1555081692,1996064986,-1740746414,-1473132947,-1341970488,-1084653625,-958395405,-710438585,113926993,338241895,666307205,773529912,1294757372,1396182291,1695183700,1986661051,-2117940946,-1838011259,-1564481375,-1474664885,-1035236496,-949202525,-778901479,-694614492,-200395387,275423344,430227734,506948616,659060556,883997877,958139571,1322822218,1537002063,1747873779,1955562222,2024104815,-2067236844,-1933114872,-1866530822,-1538233109,-1090935817,-965641998]}}}()},{}],
      4:[function(r,e,t){e.exports=function(){function e(r){if(null==r.match(/^([^.]+)\.([^.]+)\.([^.]+)$/))throw"JWT token is not a form of 'Head.Payload.SigValue'.";return{header:RegExp.$1,payload:RegExp.$2,sig:RegExp.$3}}function t(r,e,t){var n=i.encode(f.encode(JSON.stringify(r))),o=i.encode(f.encode(JSON.stringify(e))),c=i.encode(a.b64_hmac(t,n+"."+o));return n+"."+o+"."+c}function n(r,t){var n=e(r),o=i.encode(a.b64_hmac(t,n.header+"."+n.payload));return o===n.sig}var o=r("./hashes-hs256.js"),a=new o.SHA256,f=r("./Base64.js"),i=r("./Base64url"),c={alg:"HS256",typ:"JWT"};return{sign:function(r,e){return r.exp=r.exp||Math.floor(Date.now()/1e3)+3600,t(c,r,e)},decode:function(r){var t=e(r);return f.decode(i.decode(t.payload))},verify:function(r,e){return n(r,e)}}}()},{"./Base64.js":1,"./Base64url":2,"./hashes-hs256.js":3}]},{},[4])(4)});
      return global.KaleoJWT;
	  }();

    var url = KALEO_HOST+"/api/v5/questions";

    var user = gs.getUser();
    var user_params = {
      email: user.getEmail(),
      firstname: user.getFirstName(),
      lastname: user.getLastName()
    };		

    var jwtToken = KaleoJWT.sign(user_params, SHARED_SECRET);

    var restMessage = new sn_ws.RESTMessageV2();
    restMessage.setHttpMethod("get");
    restMessage.setEndpoint(url);
    restMessage.setQueryParameter('widget_token',WIDGET_TOKEN);
    restMessage.setQueryParameter('_fields','id,title');
    restMessage.setQueryParameter('per_page', MAX_RESULTS);
    restMessage.setQueryParameter('term',input.q);
    restMessage.setQueryParameter('ap_jwt',jwtToken);
    restMessage.setQueryParameter('ap_source','servicenow');

    var response = restMessage.execute();
    var result = {collection: [], meta: {}}
    if (response.getStatusCode() == 200 && response.getHeader('Content-Type') == 'application/json') {
      var body = response.getBody();
      result = JSON.parse(body);
    }

    return result.collection.map(function(item) {
      var q = {}
      q.type = 'kaleo';
      q.label = item.title;
      q.text = item.title;
      q.id = item.id;
      q.score = 100;
      q.url = KALEO_HOST+'/v5/questions/'+item.id+"?ap_source=servicenow&ap_jwt="+jwtToken;
      return q;
    })
  }
  // END KALEO ADDITIONS
})();
```

If the user performing the search does NOT have a Kaleo account, one will be auto provisioned for them just-in-time, using their ServiceNow account information (email, firstname, lastname).

### Client Script

For the client script portion of the Typeahead Widget, this snippet contains the default code with Kaleo changes

```javascript
function ($filter, $location, $uibModal, $scope, $sce) {
  var c = this;
  c.options.glyph = c.options.glyph || 'search';
  c.options.title = c.options.title || '${Search}';

  c.onSelect = function($item, $model, $label, $event) {
    if ($item.type == "sc")
      $location.search({id: 'sc_cat_item', sys_id: $item.sys_id});
    if ($item.type == "sc_guide")
      $location.search({id: 'sc_cat_item_guide', sys_id: $item.sys_id});
    if ($item.type == "kb")
      $location.search({id: 'kb_article', sys_id: $item.sys_id});
    if ($item.type == "qa")
      $location.search({id: 'kb_social_qa_question', question_id: $item.sys_id});
    if ($item.type == "rec")
      $location.search({id: $item.page, sys_id: $item.sys_id, table: $item.table});

    //
    // START KALEO CHANGES
    //
    if ($item.type == "kaleo") {
      var kaleoUrl = $item.url;

      $scope.iframeUrl = $sce.trustAsResourceUrl(kaleoUrl);

      // Make the text input still display the search query
      c.selectedState.label = $scope.query;

      // Pop up Kaleo answer in a modal
      $scope.modalInstance = $uibModal.open({
        templateUrl: 'kaleoModal',
        scope: $scope
      });
    }
    // END KALEO CHANGES

    return false;
  };

  $scope.closeModal = function() {
    $scope.modalInstance.close();
  };

  c.getResults = function(query) {
    $scope.query = query;
    return c.server.get({q: query}).then(function(response) {
      return $filter('orderBy')(response.data.results, '-score');
    });
  }
}
```

### HTML Script

For the HTML portion of the Typeahead Widget, this snippet contains the default code with Kaleo changes


```html
<div id="kaleo-homepage-search" class="hidden-xs wrapper-xl">
  <div class="wrapper-xl">
  	<h1 class="text-center text-4x m-b-lg sp-tagline-color">How can we help you?</h1>
  	<!-- <h4 ng-if="options.short_description" class="text-center m-b-lg sp-tagline-color" ng-bind="options.short_description"></h4> -->
    <form method="get" action="?">
      <input type="hidden" name="id" value="search"/>
      <input type="hidden" name="t" value="{{data.searchType}}"/>
      <div class="input-group input-group-{{::c.options.size}}">
        <!-- uses ui.bootstrap.typeahead -->
        <input name="q" type="text" placeholder="{{::c.options.title}}" ng-model="c.selectedState"
           ng-model-options="{debounce: 250}" autocomplete="off"
           uib-typeahead="item as item.label for item in c.getResults($viewValue)"
           typeahead-focus-first="false"
           typeahead-on-select="c.onSelect($item, $model, $label)"
           typeahead-template-url="kp-typeahead.html" class="form-control input-typeahead">
        <span class="input-group-btn">
          <button name="search" type="submit" class="btn btn-{{::c.options.color}}">
        	 <i ng-if="::c.options.glyph" class="fa fa-{{::c.options.glyph}}"></i>
          </button>
        </span>
      </div>
    </form>
    <script type="text/ng-template" id="kaleoModal">
      <style>
      .modal-dialog {
        width: 900px !important;
      }
      iframe {
        width: 100%;
        height: 500px;
        border: 0;
      }
      </style>
    	<div class="kaleo panel panel-default">
    		<div class="panel-heading">
    			<h4 class="panel-title">Kaleo Answer</h4>
    		</div>
    		<div class="panel-body" style="padding: 0">
    			<iframe src="{{iframeUrl}}"></iframe>
    		</div>
	      <div class="panel-footer text-right">
    			<button class="btn btn-primary" ng-click="closeModal()">${Close}</button>
    		</div>
    	</div>
    </script>
  </div>
</div>
```

### Angular Template

Now we need a template that will be used to display search results in the typeahead dropdown. You can go to here `https://YOUR_SN_INSTANCE/sp_config?id=lf&table=sp_ng_template` and create a New Template

Widget: Typeahead Search (Kaleo) [Find the one we created in the previous step]
ID: kp-template.html
Template:
```html
<a class="ta-item" ng-href="{{match.model.content_type == 'external' ? match.model.url : ''}}" target="{{match.model.url ? '_blank' : ''}}">
  <i class="ta-img" ng-if="match.model.type=='sc'" style="background-image:url('{{match.model.picture}}')"></i>
  <i class="ta-img" ng-if="match.model.type=='sc_guide'" style="background-image:url('{{match.model.picture}}')"></i>
  <i class="ta-icon fa fa-file-text-o" ng-if="match.model.type=='sc_content' && match.model.content_type == 'kb'"></i>
  <strong ng-if="match.model.type=='sc_content' && match.model.content_type == 'external'">➚</strong>
  <i class='ta-icon fa fa-file-text-o' ng-if="match.model.type=='kb'"></i>
  <i class='ta-icon fa fa-comments-o' ng-if="match.model.type=='qa'"></i>
  <i class='ta-icon' ng-if="match.model.type=='rec'"></i>
  <span ng-bind-html="match.label | uibTypeaheadHighlight:query"></span>
</a>
```

<a class="ta-item">
  <i class="ta-img" ng-if="match.model.type=='sc'" style="background-image:url('{{match.model.picture}}')"></i>
  <i class='ta-icon fa fa-file-text-o' ng-if="match.model.type=='kb'"></i>
  <img class="kaleo-icon" src="https://kaleo-prod-assets.s3.amazonaws.com/logos/favicon.png" ng-if="match.model.type=='kaleo'" />
  <i class='ta-icon fa fa-comments-o' ng-if="match.model.type=='qa'"></i>
  <i class='ta-icon' ng-if="match.model.type=='rec'"></i>
  <button type="button" class="btn btn-warning btn-xs" ng-if="match.model.type=='createTicket'">{{match.model.label}}</button>
  <span ng-bind-html="match.label | uibTypeaheadHighlight:query" ng-if="match.model.type!='createTicket'"></span>
</a>
