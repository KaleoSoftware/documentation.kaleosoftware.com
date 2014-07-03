# Widget Guide

Kaleo is a SaaS application that can be accessed through a web browser. Kaleo also exposes an API, which allows other applications to interact with the Kaleo system.  Using this API, Kaleo provides a Widget that can be embedded into other applications, and provides users seamless access to Kaleo from wherever they are, instead of having to go to the main Kaleo website. This document will describe the Kaleo Widget and document where and how it can be used.

## Widget Technology

The Kaleo Widget is built using standard web technologies (HTML/JavaScript/CSS). The basic operation is similar to a Facebook or Twitter embeddable widget – a snippet of code (HTML/JavaScript/CSS) is pasted into the target app, and the Kaleo Widget appears on the target page.  The Kaleo Widget can be embedded easily in other web applications, provided they allow, and expose a mechanism, for embedding `<script>` tags into their pages.

## ActiveDirectory

The Kaleo Widget assumes that the user already has an authenticated, secure session established with the kaleosoftware.com website in order to function.  Typically, this is done by first ensuring that Kaleo is linked via SAML to your corporate directory (Microsoft ActiveDirectory, Okta, OneLogin, etc).  Details of this integration can be found in the “Kaleo SSO ADFS Integration” document.

## Implementation

The Kaleo Widget is made up of 2 main parts.  The first is the actual widget code that is specified in the Kaleo Admin page.  On this page, you can create a new Widget, specify which Kaleo Board it is tied to, and define the HTML/JavaScript/CSS code that will be injected into the target app. You can access this page via the My Account -> Admin Panel menu. (Your Kaleo Customer Success representitive will have most likely configured this for you already.)

The second part is a small snippet of JavaScript code called the *Kaleo Widget Injector*, that connects to kaleosoftware.com and grabs the specified Widget using the Widget Token, and injects the HTML/JavaScript/CSS into the target page.

 
## Kaleo Search Widget

The standard Kaleo Search Widget looks like this, and to create this widget, we will first go to the My Account -> Admin Panel page, and select Widgets from the left menu, and then click New.

### Kaleo Widget Fields

**Name:**  Descriptive name, like "Widget for JDE (Production)"

**Board:**  Which Kaleo Board this Widget should be linked to. Search willl only show results from the linked Board.

**Authentication Token:** Leave this field blank and Kaleo will auto-generate a strong authentication token, or you can enter your own.

**Show Post Types:** Must be `question`.

**Auto Create User:**

  * **None** Kaleo will not auto-create any users through this widget.
  * **Email** (Should not be used)
  * **CRMOD SSO Token** For integrations with Oracle's CRM On Demand. (See your Kaleo representative for more details).
  * **SAML** A SAML SSO link with Kaleo should be configured, and then any SAML authenticated users will be automatically created in Kaleo when necessary.

**Embedded HTML:**  This is the raw HTML code that will be injected into the target page. A basic widget looks like this

```html
<div class="kaleoWidget">
  <input class="kaleoSearch" type="text" />
  <span class="kaleoLogo">
    <img src="https://production.kaleosoftware.com/assets/widgets/search/fish-logo.png">
  </span>
</div>
```

**Embedded CSS:** This is the raw CSS code that will be injected into the target page. (This is actually SCSS, so any advanced features of SCSS can be used.)

```scss
@import "kaleo/widgets/search_ui.css.scss";
```

**Embedded JavaScript:**  This is the code that will be run by the Kaleo Injector, and this code should handle inserting the Embedded HTML, which is available in a JavaScript global variable called `KALEO_EMBEDDED_HTML`.

```javascript
// This code will run in the context of the target page. Grab a reference to a DOM element where you want to position the widget html, and insert it into the page.
// You should change the selector from 'body' to point at the location on the page the widget should go.
$("body").after(KALEO_EMBEDDED_HTML);

// We have a timeout here which may or may not be necessary, again depending on the situation
setTimeout(function() {
  var opts = {};
  // Note that this is referencing the global variable that the Kaleo Injector will add to the page.
  opts.host = KALEO_WIDGET_HOST;
  opts.widgetToken = KALEO_WIDGET_TOKEN;
  opts.selector = ".kaleoWidget";
  opts.debug = false;
  opts.useEasyXDM = true;
  opts.errorCallback = function(e){console.log(JSON.stringify(e));}
  var kaleoSearchWidget = new window.Kaleo.SearchWidget(opts);
}, 1000);
```

### Kaleo Widget Injector

Now that we have a Widget defined inside of Kaleo, we need to inject it into the target page. This is done using this small bit of code:

```javascript
<script type="text/javascript">
  // The widget will only run on URLs that match this regex. Here we match anything so it will always run.
  KALEO_WIDGET_URL_REGEX = /./;
  KALEO_WIDGET_HOST = "https://yourtenant.kaleosoftware.com";
  // This is the token specified in the Kaleo Admin -> Widgets page.
  KALEO_WIDGET_TOKEN = "ABC123-GHJEG-JKHKJKH";
</script>
<script type="text/javascript" src="https://yourtenant.kaleosoftware.com/assets/widgets/injector-v2.js"></script>
```

### Advanced SSO Integration
Assuming you have configured Kaleo to integrate with your corporate identity service (ADFS, Okta, OneLogin, etc), we can leverage that to ensure that the end user is not required to manually log in to Kaleo in order to use the widget.

We accomplish this by using a hidden `<iframe>` tag, which will kick off a SAML login attempt in the background. As long as the user is already logged in to your identity service, the iframe will redirect back to Kaleo and automatically log the user in to Kaleo. They can then use the Kaleo Widget as normal with no manual login required.

The injector code snippet with a hidden iframe would look like this

```javascript
<script type="text/javascript">
  // The widget will only run on URLs that match this regex. Here we match anything so it will always run.
  KALEO_WIDGET_URL_REGEX = /./;
  KALEO_WIDGET_HOST = "https://yourtenant.kaleosoftware.com";
  // This is the token specified in the Kaleo Admin -> Widgets page.
  KALEO_WIDGET_TOKEN = "ABC123-GHJEG-JKHKJKH";
</script>
<script type="text/javascript" src="https://yourtenant.kaleosoftware.com/assets/widgets/injector-v2.js"></script>
<iframe src="https://yourtenant.kaleosoftware.com/users/auth/saml?redirect_to=https%3A%2F%2F yourtenant.kaleosoftware.com%2Fwidgets%2Fsaml_status" height="0" width="0"></iframe>
```


<div class="well">
  **Note for IE:** In order for this to work on Microsoft Internet Explorer, your SSO endpoint MUST serve an HTTP header called `P3P` in order for IE to save the cookies necessary for authentication. The contents of the P3P header should be something like `CP="HONK"` or `CP="This is not a privacy policy!"`. It doesn't matter what is in there, just that some string of characters are there.
</div>

