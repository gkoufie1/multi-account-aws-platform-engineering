# Architecture

```text
AWS Management Account
        |
        |-- Security OU
        |      |-- Security Account
        |      |-- Central logging, GuardDuty, Security Hub, AWS Config
        |
        |-- Shared Services OU
        |      |-- Shared Services Account
        |      |-- DNS, networking, CI/CD runners, observability
        |
        |-- Workloads OU
        |      |-- Development Account
        |      |-- Production Account
        |
        |-- Sandbox OU
               |-- Temporary experimentation accounts
```
