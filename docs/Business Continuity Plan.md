# Business Continuity Plan

```
Kaleo Software, Inc  CONFIDENTIAL
```

## Emergency Notification Contacts


| Name | Email | Mobile | Home |
| ---- | ----- | ------ | ---- |
|      |       |        |      |
|      |       |        |      |



## Purpose

The purpose of this business continuity plan is to prepare Kaleo Software in the event of extended service outages caused by factors beyond our control (e.g., natural disasters, Amazon outages, DNS disruptions, man-made events), and to restore services to the widest extent possible in a minimum time frame. All Kaleo sites are expected to implement preventive measures whenever possible to minimize operational disruptions and to recover as rapidly as possible when an incident occurs.

## Scope

The scope of this plan is limited to situations where the Kaleo service is for whatever reason not available to a majority of it's customers. See the Security Incident Response Plan document for information on how to respond to a security incident.

## Team Member Responsibilities

- All of the members should keep an updated calling list of their work team members’ work, home, and cell phone numbers both at home and at work.
- All team members should keep this plan for reference at home in case the disaster happens after normal work hours. All team members should familiarize themselves with the contents of this plan.

## Disaster Declaration

A **Disaster** should be declared when

- Automated monitoring systems indicate that the Kaleo service has been DOWN in multiple geographical locations for more than 30 minutes.
- Customer Success personnel receive reports from 3 or more customers of the service being unavailable.

## Customer Notifications

Customer Success will notify each Kaleo customer, via their designated contact, of the emergency, and provide ongoing status updates.

## Triage Outage

First, identify the extent and the root cause of the outage.

- Amazon [https://status.aws.amazon.com/](https://status.aws.amazon.com/)
- CloudFlare [https://www.cloudflarestatus.com/](https://www.cloudflarestatus.com/)
- Pingdom [http://stats.pingdom.com/f3k1hdiaoet5/459063](http://stats.pingdom.com/f3k1hdiaoet5/459063)
- DNS
- Amazon internal network
- General Internet / Backbone Issue
- Kaleo services (Amazon RDS/EC2/S3/ElastiCache/ElasticSearch)

### Kaleo Code

If it is determined that the outage was caused by a bug in the Kaleo codebase, an emergency fix will be pushed up to production.

### Database Outage

Rotating snapshots of the Kaleo databases are available in Amazon RDS and can be immediately spun up into a new database server.

### Amazon Outage

If it is determined that Amazon is substantially down, and it has been at least 24 hours, Kaleo IT will begin to rebuild the Kaleo service on the Google Cloud. The Kaleo Provisioning repo has the Ansible scripts, and step-by-step instructions, required to re-build the Kaleo infrastructure using Google Cloud VMs.
