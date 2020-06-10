# Import Windows Task Scheduler Tasks from an export .xml file:'
# See http://jon.netdork.net/2011/03/10/powershell-and-importing-xml-scheduled-tasks/
function Get-Computer-Hostname()
{
    return $env:computername    
}
$computer_hostname = Get-Computer-Hostname

#$task_path = "c:\Temp\tasks\*.xml"
$task_path = "C:\Common\repo\pho-BB-client-computer-deploy\DeployToClient\Tasks\UploadEventData.xml"
$task_user = "$computer_hostname\watsonlab"
$task_pass = "cajal1852"

$sch = New-Object -ComObject("Schedule.Service")
$sch.connect("localhost")
$folder = $sch.GetFolder("\")

Get-Item $task_path | %{
	$task_name = $_.Name.Replace('.xml', '')
	$task_xml = Get-Content $_.FullName
	$task = $sch.NewTask($null)
	$task.XmlText = ($task_xml | out-string)
	$folder.RegisterTaskDefinition($task_name, $task, 6, $task_user, $task_pass, 1, $null)
    #Register-ScheduledTask -Xml (get-content '\\chi-fp01\it\Weekly System Info Report.xml' | out-string) -TaskName "Weekly System Info Report" -User globomantics\administrator -Password P@ssw0rd –Force
}