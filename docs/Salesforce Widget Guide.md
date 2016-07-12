# Kaleo Widget Salesforce Integration Instructions

## Embedding the Kaleo Widget on Detail Pages

![](images/SF-Embed-Widget-1.png)

This integration will allow the embedding of the Kaleo widget within an
object’s detail page as a Visualforce page layout element that can be
placed and positioned using the standard page layout customization
functionality.

### 1. Create the Visualforce page element for the widget

Go to Setup&rarr;Develop&rarr;Visualforce Pages and click on the ‘New’
button.

Name the VisualForce Page “Kaleo VF” or any other name that makes sense
to you.

Replace the existing default Visualforce page code with the following
code snippet.

```
<apex:page sidebar="false" showHeader="false" standardController="[Object Name]">      
  <a href="https://[Your Client ID].kaleosoftware.com/v5/widget" 
    onclick="window.open(this.href, 'kaleo_widget', 'left=20,top=20,width=500,height=500,toolbar=0,resizable=0'); return false;">
    <img src="https://production.kaleosoftware.com/assets/widgets/placeholder-closed.png" />
  </a>
</apex:page>
```

Replace the \[Object Name\] with the API name of the object that you
want to embed the widget on. If you want to put it on the Accounts
detail page, replace it with “Account.” If you want to embed on a custom
object’s page layout, use the custom object’s API name that’s in the
format of “Object\_Name\_\_c.”

Replace the \[Your Client ID\] part with your specific Kaleo ID provided
to you.

Save the new VisualForce page.

###  2. Add the widget to the page layout

Edit the Page Layout of your standard or custom object that you wish to
have the Kaleo widget appear on. For this example, we use the Account
layout.

On the Page Layout editor, scroll down to Visualforce Pages on the left
and select by clicking on it. You will then see the newly created
Visualforce page element available to drag and drop onto your page
layout.

![](images/SF-Embed-Widget-2.png)

To adjust the size of the embedded widget, click on the wrench tool on
the upper right hand side of your embedded Visualforce page. This will
bring up the Visualforce Page Properties settings menu. The standard
height is 200px, and we recommend a height of 80px for this widget.

![](images/SF-Embed-Widget-3.png)

The widget is now embedded on your object’s detail page! This process
can be repeated any number of times for your other object’s detail
pages.

## Creating a Custom Kaleo Lightning Navigation Menu Item

![](images/SF-Embed-Widget-4.png)

This process will allow you to have a custom Kaleo navigation item on
your Salesforce instance’s Lightning Experience navigation menu.

### 1. Create the Visualforce page element for the Lightning navigation item

Go to Setup&rarr;Develop&rarr;Visualforce Pages and click on the ‘New’
button.

Name the VisualForce Page “Kaleo Lightning” or any other name that makes
sense to you.

Replace the existing default Visualforce page code with the following
code snippet.

```
<apex:page sidebar="false" showHeader="false">         
  <script>             
    window.open('https:// [Your Client ID].kaleosoftware.com/v5/widget', 'kaleo_widget', 'left=20, top=20,width=500,height=500,toolbar=0,resizable=0');             
    window.history.back();         
  </script>  
</apex:page>
```

Replace the \[Your Client ID\] part with your specific Kaleo ID provided
to you.

Save the new VisualForce page.

### 2. Create a Visualforce tab using the VisualForce page

Go to Setup&rarr;Create&rarr;Tabs and select ‘New’ under VisualForce Tabs.

On the next page, select the previously created VisualForce page and
fill in the remaining fields for the Label and Name as you want it to
appear.

![](images/SF-Embed-Widget-5.png)

Click on the Lookup icon on the Tab Style to customize the tab style.

![](images/SF-Embed-Widget-6.png)

Select a standard icon. If you wish to use a custom icon, click on the
“Create your own style” button and select a background color and an
image from your Salesforce Documents. You may need to first upload your
custom icon into Salesforce documents for it to be available for use.
Icons should be 100 x 100 px and less than 20kb in size.

![](images/SF-Embed-Widget-7.png)

### 3. Create a custom Lightning Navigation menu and add the custom Kaleo tab

Switch to Lightning Experience and click on the gear icon on the top
right and go to Setup Home-&gt;Navigation Menus and click on ‘New’ to
create a new custom menu. If you already have a custom menu you would
like to add the tab to, you can skip this step and move onto adding the
tab to your existing menu.

Fill out the information for the new menu and click ‘Next.’

![](images/SF-Embed-Widget-8.png)

Select the available tabs that you would like to have on your custom
menu. You will see that the Kaleo tab that you created previously will
be available to select.

![](images/SF-Embed-Widget-9.png)

Finish selecting and ordering your custom menu tabs for Lightning
navigation and hit ‘Next.’

Finally, specify which Profiles should be assigned this navigation menu.
Only those profiles you assign here will see your custom navigation menu
when they are on Lightning Experience.

![](images/SF-Embed-Widget-10.png)

Hit ‘Save & Finish’

The custom navigation menu will now to available to all profiles that
you have assigned it to.
