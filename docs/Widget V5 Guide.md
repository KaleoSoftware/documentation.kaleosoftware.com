# Widget Guide V5

Kaleo is a SaaS application that can be accessed through a web browser. Kaleo can also be embedded into other applications, which allows users to interact with the Kaleo system without leaving the application they are working in.  This document will describe the Kaleo Widget (Version 5) and document where and how it can be used.

## Simple Widget

In this implementation, we simply put an HTML anchor tag on the host page that displays an image, which when clicked will open the Kaleo web application in a popup browser window.
Paste the following code into the host page (replace YOUR TENANT with the name of your tenant, and the image can be replaced with any image):

```html
<a href="https://YOUR TENANT.kaleosoftware.com/v5/widget" onclick="window.open(this.href, 'kaleo_widget', 'left=20,top=20,width=500,height=500,toolbar=0,resizable=0'); return false;" >
  <img src="https://production.kaleosoftware.com/assets/widgets/placeholder-closed.png" />
</a>
```

### Targeting Widgets to Specific Boards

You can configure a Widget in the Kaleo Admin (https://YOUR_TENANT.kaleosoftware.com/admin) and specify a set of Searchable Boards and Postable Boards for a specific Widget Token. You then reference this widget token in the URL, like so:

```html
<a href="https://YOUR TENANT.kaleosoftware.com/v5/widget?widget_token=1234" onclick="window.open(this.href, 'kaleo_widget', 'left=20,top=20,width=500,height=500,toolbar=0,resizable=0'); return false;" >
  <img src="https://production.kaleosoftware.com/assets/widgets/placeholder-closed.png" />
</a>
```

So in the above code, the `widget_token=1234` will cause Kaleo to look up the Widget Token and scope the widget to the specified boards for searching, and when the user clicks the Ask Kaleo button the boards will be restricted to the configured Postable Boards.

## Embedded Widget (IFRAME)

The Kaleo Embedded Widget is built using standard web technologies (HTML/JavaScript/CSS). The basic operation is similar to a Facebook or Twitter embeddable widget – a snippet of code (HTML/JavaScript/CSS) is pasted into the target app, and the Kaleo Widget appears in an IFRAME in the host page.  The Kaleo Widget can be embedded easily in other web applications, provided they allow, and expose a mechanism, for embedding `<script>` tags into their pages.

<div class="well">
  The Embedded Widget REQUIRES the following in order to work successfully:

  <ul>
    <li>Your SSO provider must allow embedding its login page into an IFRAME</li>

    <li>Your host page must not set an IE Document Compatibility Mode</li>
  </ul>

</div>


To implement the Kaleo Embedded Widget, we need to inject it into the host page. This is done by pasting snippets of code into the host app.

### CSS Styles

The following snippet of CSS code defines the look-and-feel of the Kaleo Widget and the Kaleo Popup.

<div class="well">
**NOTE** This CSS code is a sample of what can be done. Most likely you will need to modify it to make things look correct in your host page.

</div>

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

    -moz-border-bottom-left-radius: 12px;
    -moz-border-bottom-right-radius: 12px;
    -webkit-border-bottom-left-radius: 12px;
    -webkit-border-bottom-right-radius: 12px;
    border-bottom-left-radius: 12px;
    border-bottom-right-radius: 12px;

    -moz-box-shadow: 3px 3px 14px #333;
    -webkit-box-shadow: 3px 3px 14px #333;
    box-shadow: 3px 3px 14px #333;
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
<div class="kw-container" data-iframe-src="https://YOUR TENANT/v5/widget" data-show-spinner="true"></div>
```

### JavaScript

The following snippet of JavaScript code activates the Kaleo Widget. This code should be pasted into the host page **after** the HTML code.

```html
<script type="text/javascript" src="https://YOUR TENANT/assets/v5/widgets/injector.js" async defer></script>
```

### Advanced SSO Integration

Assuming you have configured Kaleo to integrate with your corporate identity service (ADFS, Okta, OneLogin, etc), we can leverage that to ensure that the end user is not required to manually log in to Kaleo in order to use the widget.

We accomplish this by using a hidden `<iframe>` tag, which will kick off a SAML login attempt in the background. As long as the user is already logged in to your identity service, the iframe will redirect back to Kaleo and automatically log the user in to Kaleo and provision an account for them. They can then use the Kaleo Widget as normal with no manual login required. If the auto-login attempt fails, the user will be presented with the standard Kaleo sign-in page.

### P3P Headers

<div class="well">
  **Note for IE:** In order for this to work on Microsoft Internet Explorer, your SSO endpoint MUST serve an HTTP header called `P3P` in order for IE to save the cookies necessary for authentication. The contents of the P3P header should be something like `CP="HONK"` or `CP="This is not a privacy policy!"`. It doesn't matter what is in there, just that some string of characters are present.
  <br /><br />
  Also, IE CANNOT be set to use an older Document Mode.
</div>

&nbsp;
