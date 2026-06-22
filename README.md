# AI-Powered SOC Home Lab

A hands-on detection engineering lab built from scratch using
Splunk, Atomic Red Team, and Claude AI across 3 virtual machines.

# What I Built

| Machine | Role | Tool |

| SOC-MONITOR | SIEM | Splunk Enterprise |
| SOC-FORWARDER | Log collection | Splunk Universal Forwarder |
| SOC-ROGUE | Attack simulation | Atomic Red Team - kali Linux |

# What I Did

- Simulated MITRE ATT&CK T1059.004 - Unix Shell Execution
- Captured attack logs in Splunk via Universal Forwarder
- Used Claude AI to draft a Sigma detection rule
- Validated the rule against real logs - found the AI was wrong
- Converted Sigma rule to SPL using sigma-cli
- Documented the gap between AI assumptions and real log data

# Key Lesson

AI reduced rule drafting from 45 minutes to 15 minutes.
Manual log validation took 20 more minutes.
Without those 20 minutes, the rule would have detected nothing.

# Repository Structure
## Repository Structure

*Phase 1* - Detection engineering : Sigma rule , SPL queries ,Lab report , Screenshots

*Phase 2* - Automation scripts : Bash , Python 
