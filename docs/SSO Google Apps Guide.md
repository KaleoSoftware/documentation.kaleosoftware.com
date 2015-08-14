# SSO Google Apps Guide

Kaleo supports Single Sign On (SSO), by integrating with Google Apps as an Identity Provider (IdP) via the OAuth2 protocol, in which the user’s web browser mediates communications between Kaleo and the IdP.

### User Provisioning

A Kaleo user account can be provisioned just-in-time when a login request is made. Kaleo uses the cryptographically verified user information from Google (including first name, last name, email) to immediately create an account in the Kaleo system, and then logs the user in, for a seamless experience.  Kaleo can be configured to allow logins **only** from Google, so if a user is removed from Google then they no longer will have the ability to log in to the Kaleo system.

### Google Configuration

Your Google Apps administrator will need to go to the [Google Developer Console](https://console.developers.google.com/project)

Create a new API project.

Under APIs & Auth -> APIs enable the Contacts API and the Google+ API:

![](/images/G-Enabled-APIs-API-Project.jpg)

Under APIs & Auth -> Credentials create a Client ID for a Web Application:

![](/images/G-Credentials-API-Project.jpg)

You will use the Client ID and Client Secret in the next step to configure Kaleo.


### Kaleo Configuration

Your tenant must be configured for Google SSO. The following settings in Tenant Admin -> Settings should be created:

```
authentication.google.enabled: true
authentication.google.client_id: YOUR GOOGLE CLIENT ID
authentication.google.client_secret: YOUR GOOGLE CLIENT SECRET
authentication.google.hd: yourcompany.com  # this should be your google apps domain name
```

You should now see a Login with Google button on your Kaleo login page.

![](/images/G-Kaleo-Login.jpg)
