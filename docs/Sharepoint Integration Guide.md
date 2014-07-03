# Sharepoint Integration GuideKaleo content can be exposed in SharePoint in several ways. This guide will outline each method along with the strengths and weaknesses of each one.  This document focuses on the 2013 version of SharePoint, earlier versions of SharePoint may not support these techniques.## Kaleo Widget WebPartKaleo has a JavaScript API as well as a pre-built widget built on top of that API, utilizing standard web technologies (HTML/CSS/JavaScript).SharePoint has the ability to create a WebPart, which can host the Kaleo widget. First, you will need to configure a Kaleo Widget definition in your Kaleo tenant (see the Kaleo Widget Embedding Guide). Each Widget is tied to a specific Kaleo Board, and will search only the content within that Board. Once you have a Kaleo Widget defined in Kaleo, you can paste the following code into your SharePoint WebPart:```html<script type="text/javascript">
     KALEO_WIDGET_HOST = "https://your-tenant-name.kaleosoftware.com";
     KALEO_WIDGET_TOKEN = "your-token-here"; 
</script>
<script type="text/javascript" src="https://your-tenant-name.kaleosoftware.com/assets/widgets/injector-v2.js"></script>
```This will display the following widget, which is a search field that will search a specific Kaleo Board and return matching results:
![](http://kaleo-web.s3.amazonaws.com/documentation_images/typeahead-widget.jpg)### Look-and-feel

The Kaleo Widget can be styled either from scratch or by tweaking the existing CSS. This is done via the Kaleo Admin Panel -> Widget Settings -> Embedded CSS code.### Authentication

The Kaleo Widget can be set to allow for unauthenticated read-only access, which will allow anyone with access to the page the widget lives on, to search Kaleo and view the results. If the user tries to post a question, they will be asked to sign in before proceeding.

If you have SSO enabled for Kaleo, and are integrated with a SAML provider (i.e. Microsoft ADFS, Okta, OneLogin), then we can leverage that to make accessing the Kaleo widget more seamless to the user.

To do this, we insert a hidden IFRAME into the page, which will initiate a SAML login and seamlessly authenticate the user, provided they already have a SAML session established. If they do *not* have an active session, then they will not be logged in and everything will behave as if the user is unauthenticated.

```html
<iframe 
  width='1' height='1' 
  style='visibility:hidden'  
  src='https://your-tenant-name.kaleosoftware.com/users/auth/saml?redirect_to=/widgets/saml_status'>
</iframe>
```## SharePoint CrawlerSharePoint has the ability to crawl websites, and add the content it finds to its internal search index.  Kaleo can be configured to expose a sitemap of a specific Board. A sitemap is an XML document that lists every piece of content, and a link to that content. Armed with this information, SharePoint can then crawl each page, index the content found on that page, and add it to its internal search index. When a user searches SharePoint, then Kaleo results will also be returned, intermingled with other SharePoint content, and sorted by relevance to the user’s query.
One downside to this approach is that the crawler must be set to crawl Kaleo at specific intervals, and the results will only be as fresh as the last crawl.To enable this feature, contact your Kaleo Software customer success representative, and they will configure your tenant and issue you a `crawler_token`.  You can then go to 

`https://your-tenant-name.kaleosoftware.com/sitemap.xml?crawler_token=123` 

and see an XML document listing all questions in the Kaleo system from all *public* boards. **Private boards cannot be crawled**. 

You can then go to SharePoint and use that sitemap URL as the root URL for a new crawl. 

![](http://kaleo-web.s3.amazonaws.com/documentation_images/sharepoint-central-admin.png)

![](http://kaleo-web.s3.amazonaws.com/documentation_images/sharepoint-crawler-edit-content-source.jpg)
## SharePoint OpenSearchSharePoint has the ability to integrate search results from any OpenSearch compliant search service, and Kaleo exposes a search API that conforms to the OpenSearch standard. You configure this in SharePoint like so:

![](http://kaleo-web.s3.amazonaws.com/documentation_images/sharepoint-opensearch-setup.png)When the user types in a search query, SharePoint calls out to the Kaleo API and gathers the results to present to the user. The results are not intermingled with other SharePoint content, and cannot be sorted by relevance with respect to non-Kaleo content. Snippets of content are returned as part of the results that highlight keyword matches within the Kaleo content, making it easier for the user to determine if the content is relevant to them.

![](http://kaleo-web.s3.amazonaws.com/documentation_images/sharepoint-opensearch-results.png)