# SSO Azure AD Guide

Kaleo supports Single Sign On (SSO), by integrating with Microsoft Azure as an Identity Provider (IdP) via the SAML protocol, in which the user’s web browser mediates communications between Kaleo and the IdP.

### User Provisioning

A Kaleo user account can be provisioned just-in-time when a login request is made. Kaleo uses the cryptographically verified user information from Azure (including first name, last name, email) to immediately create an account in the Kaleo system, and then logs the user in, for a seamless experience.  Kaleo can be configured to allow logins **only** from Azure, so if a user is removed from Azure then they no longer will have the ability to log in to the Kaleo system.

### Azure AD Configuration

Your Azure administrator will need to go to [Manage Azure](https://manage.windowsazure.com)

Click on you Azure AD Instance

Click on Applications

![](/images/SSOAzure1.png)

Click "Add" at the bottom of the screen.

![](/images/SSOAzure2.png)

Click “Add an application my organization is developing”

![](/images/SSOAzure3.png)

Enter Kaleo for the Application name and click the arrow in the bottom right

![](/images/SSOAzure4.png)

Sign-On URL: https://YOURTENANT.kaleosoftware.com/users/auth/saml/callback

App ID URL: https://YOURTENANT.kaleosoftware.com

Click the checkmark button at the bottom right

After successfully adding the Kaleo Software App to Azure, you may want to set permissions in Azure to control which users have access to the Kaleo application.

![](/images/SSOAzure5.png)

Now, you must go the the Federation Metadata Document URL and download the XML document.

![](/images/SSOAzure7.png)

Also, note your Azure AD tenant ID for later:

![](/images/SSOAzure6.png)


### Kaleo Configuration

Your Kaleo tenant must be configured for Azure SSO. As a Kaleo Admin, go to https://YOURTENANT.kaleosoftware.com/tools/sso_setup

We now need to calculate the fingerprint for the Azure AD X509 certificate. Open the XML document you saved earlier, and look for the certificate


![](/images/SSOAzure8.png)

Copy that string to your clipboard. Then go to https://www.samltool.com/fingerprint.php and paste your cert into the box, and press the Calculate button. Copy the fingerprint for the next step.

Going back to the https://YOURTENANT.kaleosoftware.com/tools/sso_setup page:

Under Basic SAML Settings:

* Enabled: true
* Issuer: https://YOURTENANT.kaleosoftware.com
* Target URL: https://login.windows.net/YOUR-AZURE-TENANT-ID-FROM-EARLIER/saml2
* Idp Cert Fingerprint: FINGERPRINT_YOU_CALCULATED_EARLIER
* Auth Context: urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport

Click Save.


### Finish

You should now be able to test by logging out of Kaleo, and then trying to log in to Kaleo again using the "Use My Company Single Sign On" button, which will take you to Azure to complete the sign in and redirect you back to Kaleo.
