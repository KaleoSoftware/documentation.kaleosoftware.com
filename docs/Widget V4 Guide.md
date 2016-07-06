# Widget Guide V4 - DEPRECATED prefer using V5 widget

Kaleo is a SaaS application that can be accessed through a web browser. Kaleo can also be embedded into other applications, which allows users to interact with the Kaleo system without leaving the application they are working in.  This document will describe the Kaleo Widget (Version 4) and document where and how it can be used.

## Widget Technology

The Kaleo Widget is built using standard web technologies (HTML/JavaScript/CSS). The basic operation is similar to a Facebook or Twitter embeddable widget – a snippet of code (HTML/JavaScript/CSS) is pasted into the target app, and the Kaleo Widget appears on the target page.  The Kaleo Widget can be embedded easily in other web applications, provided they allow, and expose a mechanism, for embedding `<script>` tags into their pages.

### Widget Embedding

To implement the Kaleo widget, we need to inject it into the target page. This is done by pasting snippets of code into the target app.

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
<div class="kw-container" data-iframe-src="https://YOUR TENANT/v4/boards"></div>
```

### JavaScript

The following snippet of JavaScript code activates the Kaleo Widget. This code should be pasted into the host page **after** the HTML code.

```html
<script type="text/javascript" src="https://YOUR TENANT/assets/v4/widgets/injector.js" async defer></script>
```

### Choosing a Sitemap

You can start the Widget off at a particular point in a Sitemap by specifying a sitemap path in the `data-sitemap` attribute, so for example if you wanted a widget which used a sitemap called `/finance`, you would do this:

```html
<div class="kw-container" data-iframe-src="https://YOUR TENANT/v4/boards" data-sitemap="/finance"></div>
```

### Advanced Customization

By default, Kaleo will inject some HTML code into the widget `div` which comprises the UI of the widget. If you have the need to customize it, you may do so as long as you have elements with all of the `kw-` class names as specified below:

```html
<div class="kw-container" data-iframe-src="https://YOUR TENANT/v4/boards" data-auto-create="false">
  <div class="kw-button"></div>
  <div class="kw-popover">
    <div class="kw-popover-content">
      <div class="kw-iframe-container"></div>
    </div>
  </div>
</div>
```


### Advanced SSO Integration

Assuming you have configured Kaleo to integrate with your corporate identity service (ADFS, Okta, OneLogin, etc), we can leverage that to ensure that the end user is not required to manually log in to Kaleo in order to use the widget.

We accomplish this by using a hidden `<iframe>` tag, which will kick off a SAML login attempt in the background. As long as the user is already logged in to your identity service, the iframe will redirect back to Kaleo and automatically log the user in to Kaleo and provision an account for them. They can then use the Kaleo Widget as normal with no manual login required. If the auto-login attempt fails, the user will be presented with the standard Kaleo sign-in page.

### P3P Headers

<div class="well">
  **Note for IE:** In order for this to work on Microsoft Internet Explorer, your SSO endpoint MUST serve an HTTP header called `P3P` in order for IE to save the cookies necessary for authentication. The contents of the P3P header should be something like `CP="HONK"` or `CP="This is not a privacy policy!"`. It doesn't matter what is in there, just that some string of characters are present.
</div>

&nbsp;
