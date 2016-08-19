# Sharepoint Integration Guide

Kaleo content can be exposed in SharePoint in several ways. Not all versions of SharePoint may support these techniques.

## Kaleo Widget WebPart

Sharepoint allows you to use our standard HTML widget as part of a WebPart. Follow the directions in the Kaleo Widget Guide V5.

## Kaleo Search

Kaleo can be connected to the hosted Office365 version of SharePoint, such that when searching Kaleo from the top search bar in V5, matching results from Sharepoint will also be included.



### Azure Configuration

For seamless user authentication, Kaleo should also be configured for SSO via SAML in Azure Active Directory. Once that is complete, then you need to create a Kaleo Search application here [Manage Azure](https://manage.windowsazure.com)

Navigate to **Applications** tab

Click the **Add** icon at the bottom of the screen

Choose **Add an application that my organization id developing**

![](/images/KaleoSharepointSearch-1.png)

Name can be anything, let's say **Kaleo Search**
Type is Web **Application**

Now you configure the properties of the application.

![](/images/KaleoSharepointSearch-2.png)

> Sign-On URL: **https://YOURTENANT.kaleosoftware.com**
>
> App ID URI: **https://YOURTENANT.kaleosoftware.com/v5/aad/callback**

In the **Permissions to other applications** section,

Click the **Add application** button, and choose **Office 365 SharePoint Online**

In the **Delegated Permissions** dropdown, make sure the pictured permissions are selected:

![](/images/KaleoSharepointSearch-5.png)

Note the Client ID, as you will ned it later when we configure the Kaleo settings.

Click Manage Manifest, Download Manifest

![](/images/KaleoSharepointSearch-4.png)

This will save an XML file in your downloads folder. Open this XML file in an editor and make the following change:

![](/images/KaleoSharepointSearch-6.png)

Click Manage Manifest, Upload Manifest, and upload the XML file you just changed.

### Kaleo Configuration

It your Tenant Settings (https://YOURTENANT.kaleosoftware.com/admin/setting) you will need to create the following settings:

| Setting Name          | Value   |
|-----------------------|---------|
| feature.aad.enabled   | true    |
| feature.aad.client_id | 123-345 |
| feature.aad.endpoint  | https://YOU.sharepoint.com |


### Useage

Once you have Azure and Kaleo configured, when you search Kaleo from the top search bar, you will see results from Kaleo as well as results from SharePoint.

![](/images/KaleoSharepointSearch-7.png)

## SharePoint Crawler

SharePoint has the ability to crawl websites, and add the content it finds to its internal search index.  Kaleo can be configured to expose a sitemap of a specific Board. A sitemap is an XML document that lists every piece of content, and a link to that content. Armed with this information, SharePoint can then crawl each page, index the content found on that page, and add it to its internal search index. When a user searches SharePoint, then Kaleo results will also be returned, intermingled with other SharePoint content, and sorted by relevance to the user’s query.
One downside to this approach is that the crawler must be set to crawl Kaleo at specific intervals, and the results will only be as fresh as the last crawl.

To enable this feature, contact your Kaleo Software customer success representative, and they will configure your tenant and issue you a `crawler_token`.  You can then go to

`https://your-tenant-name.kaleosoftware.com/sitemap.xml?crawler_token=123`

and see an XML document listing all questions in the Kaleo system from all *public* boards. **Private boards cannot be crawled**.

You can then go to SharePoint and use that sitemap URL as the root URL for a new crawl.

![](/images/sharepoint-central-admin.png)

![](/images/sharepoint-crawler-edit-content-source.jpg)

## SharePoint OpenSearch

SharePoint has the ability to integrate search results from any OpenSearch compliant search service, and Kaleo exposes a search API that conforms to the OpenSearch standard. You configure this in SharePoint like below, where Source URL is

`https://your-tenant-name.kaleosoftware.com/widgets/search_results.rss?widget_token=your-token&term={searchTerms}`

![](/images/sharepoint-opensearch-setup.png)

When the user types in a search query, SharePoint calls out to the Kaleo API and gathers the results to present to the user. The results are not intermingled with other SharePoint content, and cannot be sorted by relevance with respect to non-Kaleo content. Snippets of content are returned as part of the results that highlight keyword matches within the Kaleo content, making it easier for the user to determine if the content is relevant to them.

![](/images/sharepoint-opensearch-results.png)
