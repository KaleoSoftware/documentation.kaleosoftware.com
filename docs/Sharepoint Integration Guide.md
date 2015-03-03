# Sharepoint Integration Guide

Kaleo content can be exposed in SharePoint in several ways. This document focuses on the 2013 version of SharePoint, earlier versions of SharePoint may not support these techniques.

## Kaleo Widget WebPart

Sharepoint allows you to use our standard HTML widget as part of a WebPart. Follow the directions in the Kaleo Widget Guide V4.

## SharePoint Crawler

SharePoint has the ability to crawl websites, and add the content it finds to its internal search index.  Kaleo can be configured to expose a sitemap of a specific Board. A sitemap is an XML document that lists every piece of content, and a link to that content. Armed with this information, SharePoint can then crawl each page, index the content found on that page, and add it to its internal search index. When a user searches SharePoint, then Kaleo results will also be returned, intermingled with other SharePoint content, and sorted by relevance to the user’s query.
One downside to this approach is that the crawler must be set to crawl Kaleo at specific intervals, and the results will only be as fresh as the last crawl.

To enable this feature, contact your Kaleo Software customer success representative, and they will configure your tenant and issue you a `crawler_token`.  You can then go to

`https://your-tenant-name.kaleosoftware.com/sitemap.xml?crawler_token=123`

and see an XML document listing all questions in the Kaleo system from all *public* boards. **Private boards cannot be crawled**.

You can then go to SharePoint and use that sitemap URL as the root URL for a new crawl.

![](http://kaleo-web.s3.amazonaws.com/documentation_images/sharepoint-central-admin.png)

![](http://kaleo-web.s3.amazonaws.com/documentation_images/sharepoint-crawler-edit-content-source.jpg)

## SharePoint OpenSearch

SharePoint has the ability to integrate search results from any OpenSearch compliant search service, and Kaleo exposes a search API that conforms to the OpenSearch standard. You configure this in SharePoint like below, where Source URL is

`https://your-tenant-name.kaleosoftware.com/widgets/search_results.rss?widget_token=your-token&term={searchTerms}`

![](/images/sharepoint-opensearch-setup.png)

When the user types in a search query, SharePoint calls out to the Kaleo API and gathers the results to present to the user. The results are not intermingled with other SharePoint content, and cannot be sorted by relevance with respect to non-Kaleo content. Snippets of content are returned as part of the results that highlight keyword matches within the Kaleo content, making it easier for the user to determine if the content is relevant to them.

![](http://kaleo-web.s3.amazonaws.com/documentation_images/sharepoint-opensearch-results.png)
