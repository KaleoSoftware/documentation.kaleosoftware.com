# System Security

Kaleo has been built using industry-standard best practices to ensure the utmost safety and security of our customer's data at all times.

Kaleo's physical infrastructure is built using private servers, under our full control, hosted in secure facilities by [Rackspace](http://www.rackspace.com/), the world's leading provider of hosted services.

Kaleo follows the [Twelve Factor App](http://12factor.net/) methodology for system design and architecture, which is a set of best practices for building modern scalable, maintainable, and secure SaaS applications.

All textual data entered into Kaleo by users is stored in the Kaleo datastore, which is isolated from all other Kaleo tenants, and is hosted at a secure Rackspace facility on private servers, not part of any public cloud. All data is encrypted at all times, in-motion via SSL, and also at-rest via disk encryption technology.

All binary data uploaded by users to Kaleo, including Screencasts, Images, and Documents, is stored in Amazon's S3 cloud service, and is encrypted in motion via SSL, and at-rest using Amazons' server-side encryption technology.  All S3 URLs are also secure, signed URLs with an expiration date, to prevent unauthenticated access.

