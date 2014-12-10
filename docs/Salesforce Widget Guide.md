# Salesforce Integration

This is how to embed the Kaleo widget into the Salesforce home page. Things are complicated a bit by the fact that Salesforce does not allow components to (easily) adjust their height. So we have to use PostMessage in order to accomplish this. Here is what the widget looks like in its open and closed state. 

![](/images/SF-KaleoWidgetClosed.jpg)

![](/images/SF-KaleoWidgetOpen.jpg)


## Salesforce Widget

First we need to make the Kaleo widget. In Build -> Develop -> Pages create a new VisualForce Page. Make sure you use YOUR tenant name and widget token in the javascript code below. Feel free to customize the CSS code below to suit your specific needs.

``` html
<apex:page>
  <script type="text/javascript">
    KaleoWidget = {};
    KaleoWidget.config = [
      //[DOM ID, Host URL, Widget Token]
      ["kw-widget", "https://YOUR_TENANT_NAME.kaleosoftware.com", "YOUR_WIDGET_TOKEN"]
    ];

    (function(w,d,u){
    a=d.createElement('script'),m=d.getElementsByTagName('script')[0];a.async=0;a.src=u;m.parentNode.insertBefore(a,m)
    })(window,document,'https://YOUR_TENANT_NAME.kaleosoftware.com/assets/widget2/injector.js');
  </script>


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
      height: 540px;
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

  <div id="kw-widget" class="kw-container">
    <div class="kw-button"></div>
    <div class="kw-popover">
      <div class="kw-popover-content">
        <div class="kw-iframe-container"><!-- iframe will be injected here when icon is clicked --></div>
      </div>
    </div>
  </div>
</apex:page>
```

Now, go to Build -> Customize -> Home -> Home Page Components and create a new one to house the widget.

![](/images/SF-HomePageComponent.jpg)

In the Build -> Customize -> Home -> Home Page Layouts section, make sure the Kaleo component is checked.

![](/images/SF-HomeLayout.jpg)

At this point the Kaleo widget should show on your home page, but when you click the Kaleo Widget the height will not adjust and most of the widget will be hidden behind other Salesforce components. So we need to create another component on the page that acts as a proxy to listen for messages from the Kaleo Widget, and resize the iframe appropriately. 


## Resizing Proxy

First we need to create a Static Resource that houses the raw Javascript code we will need later.  Save this code snippet to a file, and then in Salesforce create a new static resource (Build -> Develop -> Static Resources), and upload the file. Name the resource `KaleoProxy`. When complete, click View File and note the URL for the static resource, you will need it in the next step.

```html
  if (window.console == null) {
    window.console = {};
    window.console.log = function() {};
  }
  var receiveKaleoMessage = (function() {
    function debugMsg(event) {
      var msg;
      msg = (typeof event.data == "string") ? event.data : JSON.stringify(event.data);
      console.log(msg);
    };

    function receiveMessage(event) {
      debugMsg(event);
      var data = (typeof event.data == "string") ? JSON.parse(event.data) : event.data;
      if (data.kaleo && data.height && data.windowName) {
        document.getElementById(data.windowName).style.height = data.height + "px";
      }
    };
    return receiveMessage;
  })();
  window.addEventListener("message", receiveKaleoMessage, false);
```

![](/images/SF-StaticResourceCode.jpg)

Now we need to inject this static resource into the home page. To do this, we create a new custom link (Build -> Customize -> Home -> Custom Links)

![](/images/SF-CustomLinkScript.jpg)

* Label: KaleoProxy
* Name: KaleoProxy
* Behavior: Execute Javascript
* Content Source: OnClick Javascript
* Text field: {!REQUIRESCRIPT("/resource/1418160669000/KaleoProxy")}

(Use the URL for your static resource, which may be different. You dont need the host name, just the path "/resource/...etc" )

Now, go to Build -> Customize -> Home -> Home Page Components and create a new Links component, call it `KaleoProxyLink`

![](/images/SF-NewCustomLink.jpg)

On the next page, move the KaleoProxy custom links to the right.

![](/images/SF-NewCustomLink2.jpg)

Now, we can (finally!) add the custom links to the home page layout. Go to Build -> Customize -> Home -> Home Page Layouts and in the Select Narrow Components to show make sure KaleoProxy is checked. You can move it to the bottom so its out of the way.

![](/images/SF-Sidebar.jpg)

You will now have a sidebar KaleoProxy component that does nothing but listen for resize events from the Kaleo widget and resizes the iframe. Unfortunately you can't hide the sidebar component, so your users will just have to ignore it. Maybe change the label to IgnoreMe or something.  Intrepid web developers might even find a way to hide it via Javascript, but we will leave that exercise to the reader.






