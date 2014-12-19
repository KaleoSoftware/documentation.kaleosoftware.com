# Security

## Kaleo Security Posture

Kaleo has been built using industry-standard best practices to ensure the utmost safety and security of our customer's data at all times.

Kaleo's physical infrastructure is built using private, co-located servers, under our full control, hosted in secure facilities by [Rackspace](http://www.rackspace.com/), the world's leading provider of hosted services. Rackspace data centers hold SSAE16/PCI/ISO2700x certifications and implement carrier-class physical security and redundancies to protect Kaleo's servers. 

Kaleo follows the [Twelve Factor App](http://12factor.net/) methodology for system design and architecture, which is a set of best practices for building modern scalable, maintainable, and secure SaaS applications. All administrator access to Kaleo servers is secured via Two-Factor Authentication, and strictly limited to key personnel. 

Kaleo logs all OS and Web App events into a centralized logging/analysis/monitoring system, which alerts Kaleo system administrators to any abnormal behavior, potential attacks, or performance/availability issues.

Kaleo currently utilizes several 3rd-party security vendors to perform routine scans on the site from the outside and test for any known vulnerabilities. 

As an extra layer of protection, Kaleo deploys [CloudFlare](http://www.cloudflare.com) in front of our application servers. CloudFlare acts as a Content Delivery Network (CDN) to ensure fast, low-latency access to the Kaleo application no matter where is the world your are.  (NOTE: The CDN is used for static assets like images and Kaleo web site HTML/CSS/Javascript -- customer data is NEVER available outside of the secure Kaleo system itself.)  CloudFlare also provide advanced security features including Intrusion Prevention Systems (IPS) and Denial of Service (DoS) attack mitigation.



All textual data entered into Kaleo by users is stored in the Kaleo datastore, which is isolated from all other Kaleo tenants, and is hosted at a secure Rackspace facility on private servers, not part of any public cloud. All data is encrypted at all times, in-motion via SSL, and also at-rest via disk encryption technology (PBKDF2-RIPEMD160).

All binary data uploaded by users to Kaleo, including Screencasts, Images, and Documents, is stored in Amazon's S3 cloud service, and is encrypted in motion via SSL, and at-rest using Amazons' server-side encryption technology.  All S3 URLs are also secure, signed URLs with an expiration date, to prevent unauthenticated access.

## Personally Identifiable Information (PII) Collection

Kaleo collects PII from all users of the Kaleo system.  This is either entered by the  user directly, or collected in an automated way via integrations to corporate identity providers, such as Microsoft Active Directory or LDAP systems.  The information collected could include:

- Email
- Hashed Password (for Kaleo application login only and only stored in Kaleo if using Kaleo security for app login; not stored if using SSO as SSO passwords are never stored in Kaleo).
- Name
- Job Title
- Location
- Department
- Phone Number
 
Kaleo also collects activity information derived from the user’s activity within the software. Some of this information is stored in server logs that are routinely deleted after a period of time. Other information is stored as a permanent record of activity within the Kaleo system. The exact activity data collected will change over time as product features are added, changed, or removed, but could include:

- IP address
- Web Browser User Agent
- Kaleo Web Page URLs accessed
- Question/Answer Views
- Question/Answer Votes
- Searches Within System
- Usage of System Features (posting of Questions, Answers, Comments, screencasts,etc.)
