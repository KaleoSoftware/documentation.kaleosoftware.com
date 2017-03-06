# Security Incident Response Plan

```
Kaleo Software, Inc  CONFIDENTIAL
```

This document discusses the steps that should be taken during a security incident.

## Incident Discovered

Call the Kaleo security office 24/7 number **310-404-5654**

The security office will refer to the IT emergency contact list and call the designated numbers in order on the list. The security office will log:

- The name of the caller.
- Time of the call.
- Contact information about the caller.
- The nature of the incident.
- What equipment or persons were involved.
- Location of equipment or persons involved.
- How the incident was detected.
- When the event was first noticed that supported the idea that the incident occurred.

The security office will refer to their contact list for both management personnel and the Incident Response Lead to be contacted. The Lead will investigate further and log the following additional information:

- Is the equipment / system affected business critical?
- What is the severity of the potential impact?
- Which Kaleo customers are affected?
- Name of system being targeted, along with operating system, IP address, and location.
- IP address and any information about the origin of the attack.

## Incident Triage

Contacted members of the response team will meet to discuss the situation and determine a response strategy.

- Is the incident real or perceived?
- Is the incident still in progress?
- What type of incident is this? Example: virus, worm, intrusion, abuse, damage.
- What data or property is threatened and how critical is it?
- What is the impact on the business should the attack succeed? Minimal, serious, or critical?
- What system or systems are targeted, where are they located physically and on the network?
- Is the incident inside the trusted network?
- Is the response urgent?
- Can the incident be quickly contained?
- Will the response alert the attacker and do we care?

## Incident Response

An incident ticket will be created. The incident will be categorized into the highest applicable level of one of the following categories:

- Category one - A threat to sensitive data  
- Category two - A threat to computer systems
- Category three - A disruption of services

Team members will establish and follow one of the following procedures basing their response on the incident assessment:

- System failure procedure
- Active intrusion response procedure - Is critical data at risk?
- Inactive Intrusion response procedure
- System abuse procedure
- Website denial of service response procedure
- Database or file denial of service response procedure

The team may create additional procedures which are not foreseen in this document. If there is no applicable procedure in place, the team must document what was done and later establish a procedure for the incident.

Team members will use forensic techniques, including reviewing system logs, looking for gaps in logs, reviewing CloudWatch / CloudTrail logs, and interviewing witnesses and the incident victim to determine how the incident was caused. Only authorized personnel should be performing interviews or examining evidence.

Team members will recommend changes to prevent the occurrence from happening again or infecting other systems.

Upon management approval, the changes will be implemented.

Team members will restore the affected system(s) to the uninfected / operational state. They may do any or more of the following:

- Remove all VMs for affected services from the production Load Balancer.
- Stop all VMs, but do not destroy them in order to preserve evidence.
- Utilize Ansible scripts to rebuild VMs from scratch using known-good base image
- Boot new VMs and attach to production Load Balancer
- Be sure the system is logging the correct events and to the proper level.
- Make users change passwords if passwords may have been sniffed.

## Create Incident Report

- How the incident was discovered.
- The category of the incident.
- How the incident occurred, whether through email, firewall, etc.
- Where the attack came from, such as IP addresses and other related information about the attacker.
- What the response plan was.
- What was done in response?
- Whether the response was effective.


## Notify Customers

The Customer Success manager will identify which customers were affected by the incident, and identify, to the best of their knowledge, exactly what data could have potentially been disclosed in the incident. An Incident Report will be created for each affected customer and delivered to the customer’s designated security contact within 14 days.

## Notify External Agencies

If appropriate, notify the police and other relevant agencies if prosecution of the intruder is possible. Preserve evidence. Make copies of logs, email, and other communication. Keep lists of witnesses. Keep evidence as long as necessary to complete prosecution and beyond in case of an appeal.

## Post-Incident Review

Assess damage and cost—assess the damage to the organization and estimate both the damage cost and the cost of the containment efforts.

Review response and update policies — plan and take preventative steps so the intrusion can't happen again.

- Consider whether an additional policy could have prevented the intrusion.
- Consider whether a procedure or policy was not followed which allowed the intrusion, and then consider what could be changed to ensure that the procedure or policy is followed in the future.
- Was the incident response appropriate? How could it be improved?
- Was every appropriate party informed in a timely manner?
- Were the incident-response procedures detailed and did they cover the entire situation? How can they be improved?
- Have changes been made to prevent are-infection? Have all systems been patched, systems locked down, passwords changed, anti-virus updated, email policies set, etc.?
- Have changes been made to prevent a new and similar infection?
- Should any security policies be updated?
- What lessons have been learned from this experience?
