# Widget Guide V2

Kaleo is a SaaS application that can be accessed through a web browser. Kaleo also exposes an API, which allows other applications to interact with the Kaleo system.  Using this API, Kaleo provides a Widget that can be embedded into other applications, and provides users seamless access to Kaleo from wherever they are, instead of having to go to the main Kaleo website. This document will describe the Kaleo Widget (Version 2) and document where and how it can be used.

## Widget Technology

The Kaleo Widget is built using standard web technologies (HTML/JavaScript/CSS). The basic operation is similar to a Facebook or Twitter embeddable widget – a snippet of code (HTML/JavaScript/CSS) is pasted into the target app, and the Kaleo Widget appears on the target page.  The Kaleo Widget can be embedded easily in other web applications, provided they allow, and expose a mechanism, for embedding `<script>` tags into their pages.

## ActiveDirectory

The Kaleo Widget assumes that the user already has an authenticated, secure session established with the kaleosoftware.com website in order to function.  Typically, this is done by first ensuring that Kaleo is linked via SAML to your corporate directory (Microsoft ActiveDirectory, Okta, OneLogin, etc).  Details of this integration can be found in the “Kaleo SSO ADFS Integration” document.

## Uncredentialed Access

If you want to provide access to the Kaleo knowledgebase *without* requiring that users be logged in, you can configure a Kaleo widget for Anonymous Access, and anyone who can see the widget can use it to access the knowledgebase in read-only mode.

## Implementation

First, you must create a widget in the Kaleo Admin page.  On this page, you can create a new Widget, and specify which Kaleo Board(s) it is tied to. You can access this page via the My Account -> Admin Panel menu. (Your Kaleo Customer Success representitive will have most likely configured this for you already.) Once you have created a Widget, you will be given a Widget Token, which is a long string that uniquely identifies the Widget, and will be needed in the next phase of implementation.

### Kaleo Widget Configuration

The create a widget, we will first go to the My Account -> Admin Panel page, and select Widgets from the left menu, and then click New.

### Kaleo Widget Fields

**Name:**  Descriptive name, like "Widget for JDE (Production)"

**Board:**  Which Kaleo Board this Widget should be linked to. Search will only show results from the linked Board.

**Authentication Token:** Leave this field blank and Kaleo will auto-generate a strong authentication token, or you can enter your own.

**Show Post Types:** Must be `question`.

**Auto Create User:**

  * **None** Kaleo will not auto-create any users through this widget.
  * **Email** (Should not be used)
  * **CRMOD SSO Token** For integrations with Oracle's CRM On Demand. (See your Kaleo representative for more details).
  * **SAML** A SAML SSO link with Kaleo should be configured, and then any SAML authenticated users will be automatically created in Kaleo when necessary.

**Embedded HTML:**  Not Used

**Embedded CSS:** Not Used

**Embedded JavaScript:**  Not Used

### Target App

Now that we have a Widget defined inside of Kaleo, we need to inject it into the target page. This is done by pasting snippets of code into the target app.

### CSS Styles

The following snippet of CSS code defines the look-and-feel of the Kaleo Widget and the Kaleo Popup.

```css
<style>
  /* BASE STYLES */
  .kw-popover {
    position: absolute;
    height: 560px;
    width: 560px;
  }

  .kw-iframe-container {
    background: white;
    position: absolute;
    height: 560px;
    width: 560px;
  }

  .kw-iframe-container iframe {
    border: none;
    width: 100%;
    height: 100%;

    -moz-border-radius: 12px;
    -webkit-border-radius: 12px;
    border-radius: 12px;

    -moz-box-shadow: 4px 4px 14px #000;
    -webkit-box-shadow: 4px 4px 14px #000;
    box-shadow: 4px 4px 14px #000;
  }

  .kw-container .kw-popover {display: none;}
  .kw-container.kw-open .kw-popover {display: block;}

  /* Replace the button that activates the Kaleo widget by using your own custom image here */
  .kw-container .kw-button {
    height: 50px;
    background-repeat: no-repeat;
    background-image: url("https://production.kaleosoftware.com/assets/widgets/placeholder-closed.png");
  }

  .kw-container.kw-open .kw-button {
    background-image: url("https://production.kaleosoftware.com/assets/widgets/placeholder-open-2.png");
  }
</style>
```

### HTML Code

The following snippet of HTML code defines the widget.

```html
<!-- This snippet of HTML should be placed where you would like the widget to display on your page -->
<div id="kw-widget" class="kw-container">
  <div class="kw-button"></div>
  <div class="kw-popover">
    <div class="kw-popover-content">
      <div class="kw-iframe-container"><!-- iframe will be injected here when icon is clicked --></div>
    </div>
  </div>
</div>
```

### JavaScript

The following snippet of JavaScript code activates the Kaleo Widget.

```javascript
<!-- This snippet of JavaScript should be included somewhere on web page -->
<script type="text/javascript">
  KaleoWidget = {};
  KaleoWidget.config = [
    //[DOM ID, Host URL, Widget Token]
    ["kw-widget", "https://your-tenant-name.kaleosoftware.com", "your-widget-token"]
  ];

  (function(w,d,u){
  a=d.createElement('script'),m=d.getElementsByTagName('script')[0];a.async=0;a.src=u;m.parentNode.insertBefore(a,m)
  })(window,document,'https://production.kaleosoftware.com/assets/widget2/injector.js');
</script>
```


### Advanced SSO Integration

Assuming you have configured Kaleo to integrate with your corporate identity service (ADFS, Okta, OneLogin, etc), we can leverage that to ensure that the end user is not required to manually log in to Kaleo in order to use the widget.

We accomplish this by using a hidden `<iframe>` tag, which will kick off a SAML login attempt in the background. As long as the user is already logged in to your identity service, the iframe will redirect back to Kaleo and automatically log the user in to Kaleo. They can then use the Kaleo Widget as normal with no manual login required. If the auto-login attempt fails, the user will be presented with the standard Kaleo sign-in page.


<div class="well">
  **Note for IE:** In order for this to work on Microsoft Internet Explorer, your SSO endpoint MUST serve an HTTP header called `P3P` in order for IE to save the cookies necessary for authentication. The contents of the P3P header should be something like `CP="HONK"` or `CP="This is not a privacy policy!"`. It doesn't matter what is in there, just that some string of characters are there.
</div>

