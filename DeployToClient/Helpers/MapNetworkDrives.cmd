@echo off
REM net use S: \\RDE20007.umhs.med.umich.edu\BehavioralBoxServerShare c474115B357 /user:RDE20007\watsonlabBB /persistent:yes
REM net use I: \\10.17.152.29\ServerInternal-00 cajal1852 /user:10.17.152.29\watsonlab /persistent:yes
REM net use O: \\10.17.152.29\ServerInternal-01 cajal1852 /user:10.17.152.29\watsonlab /persistent:yes
net use I: \\WATSON-BB-OVERSEER\ServerInternal-00 cajal1852 /user:WATSON-BB-OVERSEER\watsonlab /persistent:yes
net use O: \\WATSON-BB-OVERSEER\ServerInternal-01 cajal1852 /user:WATSON-BB-OVERSEER\watsonlab /persistent:yes

REM WATSON-BB-OVERSEER.umhs.med.umich.edu

REM Server Helpers
REM net use B: \\10.17.158.49\ClientDeployables cajal1852 /user:10.17.158.49\watsonlab /persistent:yes


REM @pause