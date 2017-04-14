# Security

## Kaleo Security Posture

Kaleo has been built using industry-standard best practices to ensure the utmost safety and security of our customer's data at all times.

Kaleo's physical infrastructure is built using Amazon AWS EC2, hosted in secure facilities by [Amazon](https://aws.amazon.com/compliance/), the world's leading provider of hosted services. Amazon data centers hold SSAE16/PCI/ISO2700x certifications and implement carrier-class physical security and redundancies to protect Kaleo's servers.

Kaleo follows the [Twelve Factor App](http://12factor.net/) methodology for system design and architecture, which is a set of best practices for building modern scalable, maintainable, and secure SaaS applications. All administrator access to Kaleo servers is secured via Two-Factor Authentication, and strictly limited to key personnel.

Kaleo follows immutable infrastructure practices, where all Kaleo infrastructure is declaratively defined in code, that is used to build up servers from a known-good, hardened base image. When new OS software or patches need to be deployed, a new image is built and attached to the Amazon Elastic Load Balancer, and the old images are destroyed. Immutable infrastructure benefits include lower IT complexity and failures, improved security and easier troubleshooting than on mutable infrastructure. It eliminates server patching and configuration changes, because each update to the service or application workload initiates a new, tested and up-to-date instance. If the new instance does not meet expectations, it is simple to roll back to the prior known-good instance.

Kaleo logs all OS and Web App events into a centralized logging/analysis/monitoring system, which alerts Kaleo system administrators to any abnormal behavior, potential attacks, or performance/availability issues.

As an extra layer of protection, Kaleo deploys [CloudFlare](http://www.cloudflare.com) in front of our application servers. CloudFlare acts as a Content Delivery Network (CDN) to ensure fast, low-latency access to the Kaleo application no matter where is the world your are.  (NOTE: The CDN is used for static assets like images and Kaleo web site HTML/CSS/Javascript -- customer data is NEVER available outside of the secure Kaleo system itself.)  CloudFlare also provides advanced security features including Intrusion Prevention Systems (IPS) and Denial of Service (DoS) attack mitigation.

All textual data entered into Kaleo by users is stored in the Kaleo PostgreSQL datastore, isolated from other Kaleo customers, and hosted at a secure Amazon facility. All data is encrypted at all times, in-motion via SSL, and also at-rest via disk encryption technology (AES-256).

All binary data uploaded by users to Kaleo, including Screencasts, Images, and Documents, is stored in Amazon's S3 cloud service, and is encrypted in motion via SSL, and at-rest using Amazons' server-side encryption technology.  All S3 URLs are also secure, signed URLs with an expiration date, to prevent unauthenticated access.

## Penetration Tests and Security Audits

Kaleo currently utilizes several 3rd-party security vendors to perform daily automated scans on the site from the outside and test for any known vulnerabilities. A manual penetration test is performed annually.

## Software Development Lifecycle

Kaleo's SLDC is an Agile process based on industry best-practices (OWASP, CMM). Development is done on Github with Pull Requests for code reviews. Linters (es-lint, etc) are used to enforce code style. Security reviews are an integral part of the Code Review process, and automated unit/functional/integration tests are written for every feature, and static analysis is done as part of a Continuous Integration / Continuous Delivery process.


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
- Usage of System Features (posting of Questions, Answers, Comments, screencasts, etc.)

## Data Locality, Retention, and Destruction Policies

For Kaleo customers under a valid service agreement, all data submitted by the customer and their users to the Kaleo system is stored in several places:

### Permanent Storage

- Amazon RDS Postgres Database [US-East, USA] (Text data entered into the Kaleo system)
- Amazon S3 [Multi-region USA] (Document, Images, Videos, Screencasts uploaded to the Kaleo system)
- Elastic Search [US-East, USA] (Text data is indexed for search features)

### Temporary Storage

- Amazon CloudWatch [USA] (System logs, scrubbed of passwords/API tokens/etc, stored for 1 year)
- Amazon CloudTrail [USA] (System audit logs of all administrative actions, stored for 5 years)
- Amazon Database Backups [USA] (Rolling backups are stored for up to 1 year)
- Analytics [USA] (Application usage analytics, stored for up to 5 years)

### Ephemeral Storage

- Amazon ElastiCache [US-East, USA] (Cache of frequently accessed content for performance, 30 days max)

### Retention

Kaleo will retain customer data for as long as a customer has a valid services agreement. Metadata (logs, analytics) are stored for up to 5 years.

### Destruction

Upon customer request, Kaleo will destroy all customer data. Kaleo will:

- Delete customer's Postgres Schema and all backups
- Delete customer's S3 Objects, Versions, and finally Bucket
- Delete customer's Elastic Search Index

Note that Kaleo will issue the necessary DELETE commands to Amazon, but we rely on Amazon to actually delete the data from their physical systems. Also note that all customer data is stored encrypted-at-rest using Amazon's KMS encryption technology.

Other metadata pertaining to the customer may still be retained, such as audit logs, web access logs, and analytics. However, to the extent that any of this data contains Personally Identifiable Information, it is an internal Kaleo user_id, and once the customer database has been destroyed, the mapping of that user_id to a specific identifiable person is lost.
