# SSO SAML Guide

Kaleo supports Single Sign On (SSO), by integrating with corporate Identity Providers (IdP) (i.e. Microsoft Active Directory, Salesforce.com, Okta.com, OneLogin.com) via the SAML protocol, in which the user’s web browser mediates communications between Kaleo and the IdP. In this way, Kaleo does not need any access or permissions to resources inside a private corporate network. 

## User Provisioning

Kaleo does not need to integrate directly with the IdP. Instead, a Kaleo user account can be provisioned just-in-time when a login request is made. Kaleo uses the cryptographically verified user information from the IdP (including first name, last name, email, job title, department, location) to immediately create an account in the Kaleo system, and then logs the user in, for a seamless experience.  Kaleo can be configured to allow logins **only** from your IdP, so if a user is removed from your IdP then they no longer will have the ability to log in to the Kaleo system. 

![](http://documentation.kaleosoftware.com.s3.amazonaws.com/images/Kaleo-SAML-SSO-Architecture-Diagram.png)

### Kaleo SAML Configuration

Your tenant must be configured for SSO. The following settings in Tenant Admin -> Settings should be created:

```
authentication.saml.enabled: true
authentication.saml.idp_sso_target_url: https://YOUR_IDP_URL_HERE
# The fingerprint of your X509 certificate
authentication.saml.idp_cert_fingerprint: 12:34:56:67:89

# For IE Windows-based authentication
authentication.saml.authentication_context: urn:federation:authentication:windows

# For Web-based Forms authentication
authentication.saml.authentication_context: urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport

# The default assertion claims for user info are these. Customize the values to suit your IdP
authentication.saml.claims.firstname:  http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname
authentication.saml.claims.lastname:  http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname
authentication.saml.claims.job_title:  http://schemas.microsoft.com/ws/2008/06/identity/claims/role
authentication.saml.claims.department:  http://schemas.xmlsoap.org/claims/Group
authentication.saml.claims.location:  location
authentication.saml.claims.mobile_phone: mobile_phone

```

### SAML Metadata

Your SAML metadata can be found here:

https://<YOUR TENANT NAME HERE>.kaleosoftware.com/sso/saml_metadata

This metadata XML can be imported into most IdP systems. Otherwise, by viewing the information in the XML document, you can manually configure your IdP according to its documentation.

## ADFS IdP Configuration

For instructions on how to configure Microsoft ADFS to work with Kaleo, read this [guide](/KaleoSSOADFSIntegration/KaleoSSOADFSIntegration.html).

## Salesforce IdP Configuration

Salesforce.com can be used as an IdP, and Kaleo can authenticate users against it.  First you need to set up an Authentication Provider, and then you need to set up Remote Access for Kaleo.

![](http://documentation.kaleosoftware.com.s3.amazonaws.com/images/Salesforce-Auth-Provider-1.jpg)

![](http://documentation.kaleosoftware.com.s3.amazonaws.com/images/Salesforce-Auth-Provider-2.jpg)

![](http://documentation.kaleosoftware.com.s3.amazonaws.com/images/Salesforce-Remote-Access-1.jpg)

![](http://documentation.kaleosoftware.com.s3.amazonaws.com/images/Salesforce-Remote-Access-2.jpg)

### Kaleo Salesforce Settings

In Tenant Admin -> Settings, the following settings need to be created:

```
authentication.salesforce.enabled: true
authentication.salesforce.client_id: YOUR CLIENT ID
authentication.salesforce.client_secret: YOUR SECRET
authentication.salesforce.site:  https://login.salesforce.com
authentication.salesforce.authorize_url:  /services/oauth2/authorize
```


## SAML Token Signing

Kaleo can be configured to sign SAML requests for an added level of security. Normally, a SAML request will look something like this:

```
https://adfs.company.com/adfs/ls/?SAMLRequest=...Base64 Encoded XML Request...&RelayState=http%3A%2F%2Ftenant.kaleosoftware.com%2Fusers%2Fauth%2Fsaml
```

With Request Signing configured to be active, Kaleo would instead send a request that looks like this:

```
https://adfs.company.com/adfs/ls/?SAMLRequest=...Base64 Encoded XML Request...&RelayState=http%3A%2F%2Ftenant.kaleosoftware.com%2Fusers%2Fauth%2Fsaml&SigAlg=http%3A%2F%2Fwww.w3.org%2F2000%2F09%2Fxmldsig%23rsa-sha1&Signature=...Base64 Encoded Signature...
```

To configure your Kaleo instance for Request Signing, go to the Tenant Admin -> Settings, and create a new setting:

`authentication.saml.sign_requests` and set it's value to `false`.

Kaleo will sign requests with a CA-signed certificate. The Kaleo key and the certificate trust chain are below.

## Kaleo Public Key

```
-----BEGIN CERTIFICATE-----
MIIFWDCCBECgAwIBAgIRAKp8N1BvxD9W61Rklmp2ARUwDQYJKoZIhvcNAQELBQAw
gZAxCzAJBgNVBAYTAkdCMRswGQYDVQQIExJHcmVhdGVyIE1hbmNoZXN0ZXIxEDAO
BgNVBAcTB1NhbGZvcmQxGjAYBgNVBAoTEUNPTU9ETyBDQSBMaW1pdGVkMTYwNAYD
VQQDEy1DT01PRE8gUlNBIERvbWFpbiBWYWxpZGF0aW9uIFNlY3VyZSBTZXJ2ZXIg
Q0EwHhcNMTQxMTEwMDAwMDAwWhcNMTkxMTA5MjM1OTU5WjBVMSEwHwYDVQQLExhE
b21haW4gQ29udHJvbCBWYWxpZGF0ZWQxFDASBgNVBAsTC1Bvc2l0aXZlU1NMMRow
GAYDVQQDExFrYWxlb3NvZnR3YXJlLmNvbTCCASIwDQYJKoZIhvcNAQEBBQADggEP
ADCCAQoCggEBALsCzDjfd8eigFA1EwKieiTMOvwbDsvDSNeQj7FdEuClHJiZWLLd
4ZrRvgKutk3FpNBh1DYxSqXiyzwMzl+KQAngW6u+Db/I0RC7qd9Ado4ZEaOEyYzb
V4KNVvs/bSqYPuzLqQZY/TwqarEFDSB3s9Z/wRZpve9EWlPBFJpatnrl5fcSYPmX
63w3eY1JtWuZKtDc0evnbsVZYnN5VZxlesTw7L0ghoxrjt87fweWCZRUd7afN2Ah
GDw9KOeHF+a/jTe4FE6km2ak5gPLDOPAM0aBQX6tLjyG8+llh2WgoGmwlklSxAIP
40VJa3fdt4a4vaIzl7pY4/4k8k35amQ2FPcCAwEAAaOCAeUwggHhMB8GA1UdIwQY
MBaAFJCvajqUWgvYkOoSVnPfQ7Q6KNrnMB0GA1UdDgQWBBSN3I5umnzmhRDPxWmN
U2UVjMTpozAOBgNVHQ8BAf8EBAMCBaAwDAYDVR0TAQH/BAIwADAdBgNVHSUEFjAU
BggrBgEFBQcDAQYIKwYBBQUHAwIwTwYDVR0gBEgwRjA6BgsrBgEEAbIxAQICBzAr
MCkGCCsGAQUFBwIBFh1odHRwczovL3NlY3VyZS5jb21vZG8uY29tL0NQUzAIBgZn
gQwBAgEwVAYDVR0fBE0wSzBJoEegRYZDaHR0cDovL2NybC5jb21vZG9jYS5jb20v
Q09NT0RPUlNBRG9tYWluVmFsaWRhdGlvblNlY3VyZVNlcnZlckNBLmNybDCBhQYI
KwYBBQUHAQEEeTB3ME8GCCsGAQUFBzAChkNodHRwOi8vY3J0LmNvbW9kb2NhLmNv
bS9DT01PRE9SU0FEb21haW5WYWxpZGF0aW9uU2VjdXJlU2VydmVyQ0EuY3J0MCQG
CCsGAQUFBzABhhhodHRwOi8vb2NzcC5jb21vZG9jYS5jb20wMwYDVR0RBCwwKoIR
a2FsZW9zb2Z0d2FyZS5jb22CFXd3dy5rYWxlb3NvZnR3YXJlLmNvbTANBgkqhkiG
9w0BAQsFAAOCAQEANlnbcEAP0zefoGmOzSui8DRUp/Q4K71IlYb6ImLz3PZjOr6N
PVEEysFNHOFbZhgRQJUJ7vbacmUP6h+zk4JcdCj26g9fL08Ef6oBl5TY+7zx+3V6
OYWyuhZya5DMBUOPAzjOv6aCWNzxrBJY3kgF3TS27p5Dj1peLU/GDEzcdOuUyOeu
GfSntkCQtEMLsRPDH6uO0tafqMXIwxWJhogOT3NYvqO36gEw4nV3LJA0gAA3zgf0
aDjwnEs9NLL8F4PAYjwCaMTV225BQFIm/ZFr63wvWyyqplFiqzmsAUZDiMKez4VU
P6E5Xpk1kF0dURaHoR3bdZRa4yiJvPCGuKNyGQ==
-----END CERTIFICATE-----
```

## Trust Chain Public Keys

### AddTrust External CA Root

```
-----BEGIN CERTIFICATE-----
MIIENjCCAx6gAwIBAgIBATANBgkqhkiG9w0BAQUFADBvMQswCQYDVQQGEwJTRTEU
MBIGA1UEChMLQWRkVHJ1c3QgQUIxJjAkBgNVBAsTHUFkZFRydXN0IEV4dGVybmFs
IFRUUCBOZXR3b3JrMSIwIAYDVQQDExlBZGRUcnVzdCBFeHRlcm5hbCBDQSBSb290
MB4XDTAwMDUzMDEwNDgzOFoXDTIwMDUzMDEwNDgzOFowbzELMAkGA1UEBhMCU0Ux
FDASBgNVBAoTC0FkZFRydXN0IEFCMSYwJAYDVQQLEx1BZGRUcnVzdCBFeHRlcm5h
bCBUVFAgTmV0d29yazEiMCAGA1UEAxMZQWRkVHJ1c3QgRXh0ZXJuYWwgQ0EgUm9v
dDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALf3GjPm8gAELTngTlvt
H7xsD821+iO2zt6bETOXpClMfZOfvUq8k+0DGuOPz+VtUFrWlymUWoCwSXrbLpX9
uMq/NzgtHj6RQa1wVsfwTz/oMp50ysiQVOnGXw94nZpAPA6sYapeFI+eh6FqUNzX
mk6vBbOmcZSccbNQYArHE504B4YCqOmoaSYYkKtMsE8jqzpPhNjfzp/haW+710LX
a0Tkx63ubUFfclpxCDezeWWkWaCUN/cALw3CknLa0Dhy2xSoRcRdKn23tNbE7qzN
E0S3ySvdQwAl+mG5aWpYIxG3pzOPVnVZ9c0p10a3CitlttNCbxWyuHv77+ldU9U0
WicCAwEAAaOB3DCB2TAdBgNVHQ4EFgQUrb2YejS0Jvf6xCZU7wO94CTLVBowCwYD
VR0PBAQDAgEGMA8GA1UdEwEB/wQFMAMBAf8wgZkGA1UdIwSBkTCBjoAUrb2YejS0
Jvf6xCZU7wO94CTLVBqhc6RxMG8xCzAJBgNVBAYTAlNFMRQwEgYDVQQKEwtBZGRU
cnVzdCBBQjEmMCQGA1UECxMdQWRkVHJ1c3QgRXh0ZXJuYWwgVFRQIE5ldHdvcmsx
IjAgBgNVBAMTGUFkZFRydXN0IEV4dGVybmFsIENBIFJvb3SCAQEwDQYJKoZIhvcN
AQEFBQADggEBALCb4IUlwtYj4g+WBpKdQZic2YR5gdkeWxQHIzZlj7DYd7usQWxH
YINRsPkyPef89iYTx4AWpb9a/IfPeHmJIZriTAcKhjW88t5RxNKWt9x+Tu5w/Rw5
6wwCURQtjr0W4MHfRnXnJK3s9EK0hZNwEGe6nQY1ShjTK3rMUUKhemPR5ruhxSvC
Nr4TDea9Y355e6cJDUCrat2PisP29owaQgVR1EX1n6diIWgVIEM8med8vSTYqZEX
c4g/VhsxOBi0cQ+azcgOno4uG+GMmIPLHzHxREzGBHNJdmAPx/i9F4BrLunMTA5a
mnkPIAou1Z5jJh5VkpTYghdae9C8x49OhgQ=
-----END CERTIFICATE-----
```

### COMODO RSA Add Trust CA

```
-----BEGIN CERTIFICATE-----
MIIFdDCCBFygAwIBAgIQJ2buVutJ846r13Ci/ITeIjANBgkqhkiG9w0BAQwFADBv
MQswCQYDVQQGEwJTRTEUMBIGA1UEChMLQWRkVHJ1c3QgQUIxJjAkBgNVBAsTHUFk
ZFRydXN0IEV4dGVybmFsIFRUUCBOZXR3b3JrMSIwIAYDVQQDExlBZGRUcnVzdCBF
eHRlcm5hbCBDQSBSb290MB4XDTAwMDUzMDEwNDgzOFoXDTIwMDUzMDEwNDgzOFow
gYUxCzAJBgNVBAYTAkdCMRswGQYDVQQIExJHcmVhdGVyIE1hbmNoZXN0ZXIxEDAO
BgNVBAcTB1NhbGZvcmQxGjAYBgNVBAoTEUNPTU9ETyBDQSBMaW1pdGVkMSswKQYD
VQQDEyJDT01PRE8gUlNBIENlcnRpZmljYXRpb24gQXV0aG9yaXR5MIICIjANBgkq
hkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAkehUktIKVrGsDSTdxc9EZ3SZKzejfSNw
AHG8U9/E+ioSj0t/EFa9n3Byt2F/yUsPF6c947AEYe7/EZfH9IY+Cvo+XPmT5jR6
2RRr55yzhaCCenavcZDX7P0N+pxs+t+wgvQUfvm+xKYvT3+Zf7X8Z0NyvQwA1onr
ayzT7Y+YHBSrfuXjbvzYqOSSJNpDa2K4Vf3qwbxstovzDo2a5JtsaZn4eEgwRdWt
4Q08RWD8MpZRJ7xnw8outmvqRsfHIKCxH2XeSAi6pE6p8oNGN4Tr6MyBSENnTnIq
m1y9TBsoilwie7SrmNnu4FGDwwlGTm0+mfqVF9p8M1dBPI1R7Qu2XK8sYxrfV8g/
vOldxJuvRZnio1oktLqpVj3Pb6r/SVi+8Kj/9Lit6Tf7urj0Czr56ENCHonYhMsT
8dm74YlguIwoVqwUHZwK53Hrzw7dPamWoUi9PPevtQ0iTMARgexWO/bTouJbt7IE
IlKVgJNp6I5MZfGRAy1wdALqi2cVKWlSArvX31BqVUa/oKMoYX9w0MOiqiwhqkfO
KJwGRXa/ghgntNWutMtQ5mv0TIZxMOmm3xaG4Nj/QN370EKIf6MzOi5cHkERgWPO
GHFrK+ymircxXDpqR+DDeVnWIBqv8mqYqnK8V0rSS527EPywTEHl7R09XiidnMy/
s1Hap0flhFMCAwEAAaOB9DCB8TAfBgNVHSMEGDAWgBStvZh6NLQm9/rEJlTvA73g
JMtUGjAdBgNVHQ4EFgQUu69+Aj36pvE8hI6t7jiY7NkyMtQwDgYDVR0PAQH/BAQD
AgGGMA8GA1UdEwEB/wQFMAMBAf8wEQYDVR0gBAowCDAGBgRVHSAAMEQGA1UdHwQ9
MDswOaA3oDWGM2h0dHA6Ly9jcmwudXNlcnRydXN0LmNvbS9BZGRUcnVzdEV4dGVy
bmFsQ0FSb290LmNybDA1BggrBgEFBQcBAQQpMCcwJQYIKwYBBQUHMAGGGWh0dHA6
Ly9vY3NwLnVzZXJ0cnVzdC5jb20wDQYJKoZIhvcNAQEMBQADggEBAGS/g/FfmoXQ
zbihKVcN6Fr30ek+8nYEbvFScLsePP9NDXRqzIGCJdPDoCpdTPW6i6FtxFQJdcfj
Jw5dhHk3QBN39bSsHNA7qxcS1u80GH4r6XnTq1dFDK8o+tDb5VCViLvfhVdpfZLY
Uspzgb8c8+a4bmYRBbMelC1/kZWSWfFMzqORcUx8Rww7Cxn2obFshj5cqsQugsv5
B5a6SE2Q8pTIqXOi6wZ7I53eovNNVZ96YUWYGGjHXkBrI/V5eu+MtWuLt29G9Hvx
PUsE2JOAWVrgQSQdso8VYFhH2+9uRv0V9dlfmrPb2LjkQLPNlzmuhbsdjrzch5vR
pu/xO28QOG8=
-----END CERTIFICATE-----
```

### COMODO RSA Domain Validation Secure Server CA

```
-----BEGIN CERTIFICATE-----
MIIGCDCCA/CgAwIBAgIQKy5u6tl1NmwUim7bo3yMBzANBgkqhkiG9w0BAQwFADCB
hTELMAkGA1UEBhMCR0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4G
A1UEBxMHU2FsZm9yZDEaMBgGA1UEChMRQ09NT0RPIENBIExpbWl0ZWQxKzApBgNV
BAMTIkNPTU9ETyBSU0EgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkwHhcNMTQwMjEy
MDAwMDAwWhcNMjkwMjExMjM1OTU5WjCBkDELMAkGA1UEBhMCR0IxGzAZBgNVBAgT
EkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBxMHU2FsZm9yZDEaMBgGA1UEChMR
Q09NT0RPIENBIExpbWl0ZWQxNjA0BgNVBAMTLUNPTU9ETyBSU0EgRG9tYWluIFZh
bGlkYXRpb24gU2VjdXJlIFNlcnZlciBDQTCCASIwDQYJKoZIhvcNAQEBBQADggEP
ADCCAQoCggEBAI7CAhnhoFmk6zg1jSz9AdDTScBkxwtiBUUWOqigwAwCfx3M28Sh
bXcDow+G+eMGnD4LgYqbSRutA776S9uMIO3Vzl5ljj4Nr0zCsLdFXlIvNN5IJGS0
Qa4Al/e+Z96e0HqnU4A7fK31llVvl0cKfIWLIpeNs4TgllfQcBhglo/uLQeTnaG6
ytHNe+nEKpooIZFNb5JPJaXyejXdJtxGpdCsWTWM/06RQ1A/WZMebFEh7lgUq/51
UHg+TLAchhP6a5i84DuUHoVS3AOTJBhuyydRReZw3iVDpA3hSqXttn7IzW3uLh0n
c13cRTCAquOyQQuvvUSH2rnlG51/ruWFgqUCAwEAAaOCAWUwggFhMB8GA1UdIwQY
MBaAFLuvfgI9+qbxPISOre44mOzZMjLUMB0GA1UdDgQWBBSQr2o6lFoL2JDqElZz
30O0Oija5zAOBgNVHQ8BAf8EBAMCAYYwEgYDVR0TAQH/BAgwBgEB/wIBADAdBgNV
HSUEFjAUBggrBgEFBQcDAQYIKwYBBQUHAwIwGwYDVR0gBBQwEjAGBgRVHSAAMAgG
BmeBDAECATBMBgNVHR8ERTBDMEGgP6A9hjtodHRwOi8vY3JsLmNvbW9kb2NhLmNv
bS9DT01PRE9SU0FDZXJ0aWZpY2F0aW9uQXV0aG9yaXR5LmNybDBxBggrBgEFBQcB
AQRlMGMwOwYIKwYBBQUHMAKGL2h0dHA6Ly9jcnQuY29tb2RvY2EuY29tL0NPTU9E
T1JTQUFkZFRydXN0Q0EuY3J0MCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5jb21v
ZG9jYS5jb20wDQYJKoZIhvcNAQEMBQADggIBAE4rdk+SHGI2ibp3wScF9BzWRJ2p
mj6q1WZmAT7qSeaiNbz69t2Vjpk1mA42GHWx3d1Qcnyu3HeIzg/3kCDKo2cuH1Z/
e+FE6kKVxF0NAVBGFfKBiVlsit2M8RKhjTpCipj4SzR7JzsItG8kO3KdY3RYPBps
P0/HEZrIqPW1N+8QRcZs2eBelSaz662jue5/DJpmNXMyYE7l3YphLG5SEXdoltMY
dVEVABt0iN3hxzgEQyjpFv3ZBdRdRydg1vs4O2xyopT4Qhrf7W8GjEXCBgCq5Ojc
2bXhc3js9iPc0d1sjhqPpepUfJa3w/5Vjo1JXvxku88+vZbrac2/4EjxYoIQ5QxG
V/Iz2tDIY+3GH5QFlkoakdH368+PUq4NCNk+qKBR6cGHdNXJ93SrLlP7u3r7l+L4
HyaPs9Kg4DdbKDsx5Q5XLVq4rXmsXiBmGqW5prU5wfWYQ//u+aen/e7KJD2AFsQX
j4rBYKEMrltDR5FL1ZoXX/nUh8HCjLfn4g8wGTeGrODcQgPmlKidrv0PJFGUzpII
0fxQ8ANAe4hZ7Q7drNJ3gjTcBpUC2JD5Leo31Rpg0Gcg19hCC0Wvgmje3WYkN5Ap
lBlGGSW4gNfL1IYoakRwJiNiqZ+Gb7+6kHDSVneFeO/qJakXzlByjAA6quPbYzSf
+AZxAeKCINT+b72x
-----END CERTIFICATE-----
```
