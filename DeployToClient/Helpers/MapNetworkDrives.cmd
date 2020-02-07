@echo off
net use S: \\RDE20007.umhs.med.umich.edu\BehavioralBoxServerShare c474115B357 /user:RDE20007\watsonlabBB /persistent:yes
net use I: \\10.17.158.49\ServerInternal-00 cajal1852 /user:10.17.158.49\watsonlab /persistent:yes
net use O: \\10.17.158.49\ServerInternal-01 cajal1852 /user:10.17.158.49\watsonlab /persistent:yes
REM Server Helpers
REM net use B: \\10.17.158.49\ClientDeployables cajal1852 /user:10.17.158.49\watsonlab /persistent:yes


@pause