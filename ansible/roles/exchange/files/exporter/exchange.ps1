# Set global variables for UP and DOWN
$Up = 1
$Down = 2

# Set collector.textfile.directory
$Collector_textfile_directory = 'C:\Program Files (x86)\windows_exporter\textfile_inputs'

try
{
	# Get MailboxDatabase Status
	$Maildb= @(Get-MailboxDatabase -IncludePreExchange -Status | Sort Name | Select-Object Name, Server, Mounted)
	
	# Get MailboxDatabase Copy Status
	$Maildbcopy= @(Get-MailboxDatabaseCopyStatus -Identity * | Sort Name | Select-Object DatabaseName,MailboxServer,ContentIndexState,CopyQueueLength)
	
	# Generate a valid .prom file
	Set-Content -Path $Collector_textfile_directory\exchange.prom -Encoding Ascii -NoNewline -Value ""
	
	# Adding Metric windows_exchange_dbmount_status
	Add-Content -Path $Collector_textfile_directory\exchange.prom -Encoding Ascii -NoNewline -Value "# HELP windows_exchange_dbmount_status MailboxDatabase mount status.`n"
	Add-Content -Path $Collector_textfile_directory\exchange.prom -Encoding Ascii -NoNewline -Value "# TYPE windows_exchange_dbmount_status gauge`n"
	$Counter= 0
	foreach ($j in $Maildb.Name){
		$k= $Maildb.Server[$Counter]
		if($Maildb.Mounted[$Counter] -like "True") {
			Add-Content -Path $Collector_textfile_directory\exchange.prom -Encoding Ascii -NoNewline -Value "windows_exchange_dbmount_status{DB=""${j}"",Server=""${k}""} ${Up}`n"
		}
		else {
			Add-Content -Path $Collector_textfile_directory\exchange.prom -Encoding Ascii -NoNewline -Value "windows_exchange_dbmount_status{DB=""${j}"",Server=""${k}""} ${Down}`n"
		}
		$Counter= $Counter + 1
	}
	
	# Adding Metric windows_exchange_dbcopy_status
	Add-Content -Path $Collector_textfile_directory\exchange.prom -Encoding Ascii -NoNewline -Value "# HELP windows_exchange_dbcopy_status MailboxDatabase replication ContentIndexState health metric.`n"
	Add-Content -Path $Collector_textfile_directory\exchange.prom -Encoding Ascii -NoNewline -Value "# TYPE windows_exchange_dbcopy_status gauge`n"
	$Counter= 0
	foreach ($j in $Maildbcopy.DatabaseName){
		$k= $Maildbcopy.MailboxServer[$Counter]
		if($Maildbcopy.ContentIndexState[$Counter] -like "Healthy") {
			Add-Content -Path $Collector_textfile_directory\exchange.prom -Encoding Ascii -NoNewline -Value "windows_exchange_dbcopy_status{DB=""${j}"",Server=""${k}""} ${Up}`n"
		}
		else {
			Add-Content -Path $Collector_textfile_directory\exchange.prom -Encoding Ascii -NoNewline -Value "windows_exchange_dbcopy_status{DB=""${j}"",Server=""${k}""} ${Down}`n"
		}
		$Counter= $Counter + 1
	}
	
	# Adding Metric windows_exchange_dbcopy_queuelength
	$Counter= 0
	Add-Content -Path $Collector_textfile_directory\exchange.prom -Encoding Ascii -NoNewline -Value "# HELP windows_exchange_dbcopy_queuelength MailboxDatabase CopyQueueLength metric.`n"
	Add-Content -Path $Collector_textfile_directory\exchange.prom -Encoding Ascii -NoNewline -Value "# TYPE windows_exchange_dbcopy_queuelength gauge`n"
	foreach ($j in $Maildbcopy.DatabaseName){
		$k= $Maildbcopy.MailboxServer[$Counter]
		$l= $Maildbcopy.CopyQueueLength[$Counter]
		Add-Content -Path $Collector_textfile_directory\exchange.prom -Encoding Ascii -NoNewline -Value "windows_exchange_dbcopy_queuelength{DB=""${j}"",Server=""${k}""} ${l}`n"
		$Counter= $Counter + 1
	}
}
catch
{
	Add-Content -Path C:\scripts\exchange.log -Encoding Ascii -NoNewline -Value "$(Get-Date) Error de ejecucion porque ha excedido el numero maximo de conexiones permitidas`n"
	Exit
}
