# SOC Home Lab — Detection Engineering Report

*Author : Paule Judith Tougouma  
*Date : May 2026  
*Technique : MITRE ATT&CK T1059.004 - Unix Shell Execution  
*Environment : VMware Workstation Pro · Ubuntu · Kali Linux · Splunk Enterprise  

# Lab Environment

| Machine | Role | OS | Tool |
| SOC-MONITORING | SIEM server | Ubuntu Desktop | Splunk Enterprise |
| SOC-FORWARDER | Monitored endpoint | Ubuntu Server | Splunk Universal Forwarder |
| SOC-ROGUE | Attack machine | Kali Linux | Atomic Red Team |

*Hypervisor : VMware Workstation Pro on Windows 11 
*Network : VMware NAT - all 3 VMs on 192.168.1.0/24  
*Log sources : /var/log/auth.log and /var/log/syslog  
*Splunk receiving port : 9997  


# Attack Simulation

*Framework : Atomic Red Team v2.3.0 by Red Canary  
*Technique : T1059.004 - Command and Scripting Interpreter: Unix Shell  
*Tactic : Execution (TA0002)  
*Machine : SOC-ROGUE (Kali Linux)  

Command executed :
powershell
Invoke-AtomicTest T1059.004 -TestNumbers 1 -InputArgs @{"remote_host"="X.X.X.X"} (x.x.x.x has been replaced by the real IP address)


*What the attack did :
- Atomic Red Team compiled and executed a bash script via PowerShell
- Ran a ping to 8.8.8.8 to simulate internet connectivity check
- PowerShell ScriptBlock logging captured the full execution in /var/log/syslog
- Exit code: 0 - execution completed successfully

# Where AI Helped

- Rule drafting : Claude generated a first Sigma draft assuming /tmp + bash.  Used as starting point only - not deployed without validation.
- SPL conversion : Claude guided sigma-cli to convert Sigma YAML in SPL automatically using `sigma convert -t splunk --without-pipeline`
- Concepts : MITRE ATT&CK mapping, Sigma pipelines, sigma-cli setup, Linux syslog vs Windows event logs.


## Gap Analysis

| AI Assumed | Reality |   
| Attack uses /tmp directory | No /tmp artifact found in Splunk |
| Keywords : bash, /bin/sh | Keywords : ScriptBlock_Compile_Detail, Invoke-AtomicRedTeam |
| Simple shell script execution | Full PowerShell framework execution captured in syslog |

* Found manually : org.bluez appeared frequently - identified as Kali Bluetooth service noise, not attack signal.
  Real keywords discovered by inspecting raw Splunk events.

* Key lesson : AI reduced rule drafting time significantly. But the AI rule would have detected nothing against real logs. Manual log inspection found the actual signal.

# Validated Detection Rule
View (sigma rule file)

# False Positives

| Source | Why it fires | Mitigation |

| Authorized red team | Same tools and keywords | Whitelist known red team IPs and time windows |
| Security researcher | Running Atomic Red Team for testing | Whitelist lab accounts |
| CI/CD PowerShell pipeline | Automated deployment scripts | Whitelist pipeline service accounts |

# Severity : HIGH

PowerShell execution on Linux is uncommon in enterprise environments and should be treated as suspicious by default. Invoke-AtomicRedTeam in production logs means a known attack framework is actively running. Escalates to CRITICAL if combined with a successful SSH login, privilege escalation, or outbound connections to unknown IPs.



# Investigation Steps

When this alert fires, investigate :

| Question | SPL Query |
|---|---|
| Who ran it? | `index=* host=kali "ScriptBlock" \| rex field=_raw "user=(?<user>\S+)" \| table _time user _raw` |
| Recent SSH logins? | `index=* "Accepted password" host=socforwarder earliest=-1h` |
| Outbound connections? | `index=* host=kali ("ping" OR "curl" OR "wget") earliest=-30m` |


# What I Would Do Differently

1. Fix the log pipeline before anything else
I spent more time troubleshooting log forwarding than writing detection rules. A broken pipeline means your SIEM sees nothing - you are completely blind. Always verify endpoints are sending data before starting detection work.

2. Deploy auditd from day one**
Syslog misses bash-level command execution entirely. auditd with execve syscall rules would have captured every command run on the machine - including the exact script Atomic Red Team executed.

3. Establish a 24h log baseline before simulating attacks**
Knowing what normal looks like makes it immediately obvious what is noise versus signal. This would have saved significant investigation time. We don't have to wait for the attack before trying to guest what is normal or not .

# Skills Demonstrated

- Built a complete 3-VM SOC lab from scratch on VMware Workstation Pro
- Configured Splunk Enterprise with Universal Forwarder across separate VMs
- Simulated MITRE ATT&CK T1059.004 using Atomic Red Team on Kali Linux
- Identified real detection keywords through manual Splunk log analysis
- Generated and validated a Sigma detection rule based on real log evidence
- Converted Sigma rule to SPL using sigma-cli with Splunk backend
- Documented the gap between AI assumptions and real log data
- Distinguished false signals from real attack indicators
- Used Claude AI as a force multiplier - not a replacement for analysis



*This report documents a hands-on SOC analyst training exercise completed independently.
Claude AI was used for initial rule drafting, SPL conversion, and concept explanation.
All detection logic was validated manually against real attack logs captured in Splunk.*

I am able to explain my project by myself . It's important today to move fast with AI , but understanding what you are doing matters.
##TOUGOUMA PAULE JUDITH 
