function Get-TCPData{
   param([string]$query=$(throw 'query is required.'))
   $conn = New-Object System.Data.Odbc.OdbcConnection
   $conn.ConnectionString = "Driver={SQL Server};Server=TIMECLOCKPLUS_DATABASE_FQDN\INSTANCE;Database=TIMECLOCKPLUS_DATABASE;Integrated Security=SSPI"
   $conn.open()
   $cmd = New-object System.Data.Odbc.OdbcCommand($query,$conn)
   $ds = New-Object system.Data.DataSet
   (New-Object system.Data.odbc.odbcDataAdapter($cmd)).fill($ds) | out-null
   $conn.close()
   $ds.Tables[0]
}

function Set-TCPData{
  param([string]$query=$(throw 'query is required.'))
  $conn = New-Object System.Data.Odbc.OdbcConnection
  $conn.ConnectionString = "Driver={SQL Server};Server=TIMECLOCKPLUS_DATABASE_FQDN\INSTANCE;Database=TIMECLOCKPLUS_DATABASE;Integrated Security=SSPI"
  $cmd = new-object System.Data.Odbc.OdbcCommand($query,$conn)
  $conn.open()
  $cmd.ExecuteNonQuery()
  $conn.close()
}

$query_dir = "C:\data\sql"
$i1_output_dir = "c:\data\tcpimport"
$i2_output_dir = "c:\data\tcpimport"
$i1_final_dir = "\\TIMECLOCKPLUS_SERVER1_FQDN\c$\data\tcp_import\instance1\"
$i2_final_dir = "\\TIMECLOCKPLUS_SERVER2_FQDN\c$\data\tcp_import\instance2\"

$i1_users_query = get-content ($query_dir + "\i1-users.nonexist.sql")
$i1_users_result = Get-TCPData $i1_users_query
$i1_users_result | select * | export-csv ($i1_output_dir + "\i1_users.nonexist") -notypeinformation -force

$i2_users_query = get-content ($query_dir + "\i2-users.nonexist.sql")
$i2_users_result = get-tcpdata $i2_users_query
$i2_users_result | select * | export-csv ($i2_output_dir + "\i2-users.nonexist") -notypeinformation -force

$i1_jobcodes_query = get-content ($query_dir + "\i1-jobcodes.mjc.sql")
$i1_jobcodes_result = get-tcpdata $i1_jobcodes_query
$i1_jobcodes_result | select JOBNUMBER, JCGROUP, DESCRIPTION, ACTIVE, LEAVECODE, CLOCKED, ASKCOST, MJCUST3213, MJCUST3200, MJCUST3206, MJCUST3203, MJCUST3204, MJCUST3205, MJCUST3214 | export-csv ($i1_output_dir + "\i1-jobcodes.mjc") -notypeinformation -force

$i2_jobcodes_query = get-content ($query_dir + "\i2-jobcodes.mjc.sql")
$i2_jobcodes_result = get-tcpdata $i2_jobcodes_query
$i2_jobcodes_result | select JOBNUMBER,JCGROUP,ACTIVE,MJCUST3213,MJCUST3200,MJCUST3206,MJCUST3203,MJCUST3204,MJCUST3205,MJCUST3214 | export-csv ($i2_output_dir + "\i2-jobcodes.mjc") -notypeinformation -force

$i1_employee_query = get-content ($query_dir + "\i1-employee.ind.sql")
$i1_employee_result = get-tcpdata $i1_employee_query
$i1_employee_result | select NUMBER,TEMPLATEID,FIRSTNAME,LASTNAME,ECODE,SSN,DEPARTMENT,PIN,MANAGERID,PHONE,GENDER,EMAIL,JOBCOST,EMCUST3217,DATEHIRE,DATELEFT,DOB,DEFJCODE,DEFRATE,STATUS,ADDRESS1,ADDRESS2,CITY,STATE,ZIP | export-csv ($i1_output_dir + "\i1-employee.ind") -notypeinformation -force

$i2_employee_query = get-content ($query_dir + "\i2-employee.ind.sql")
$i2_employee_result = get-tcpdata $i2_employee_query
$i2_employee_result | select NUMBER,FIRSTNAME,LASTNAME,ECODE,SSN,DEPARTMENT,MANAGERID,PHONE,GENDER,EMAIL,EMCUST3217,DATEHIRE,DATELEFT,DOB,STATUS,ADDRESS1,ADDRESS2,CITY,STATE,ZIP | export-csv ($i2_output_dir + "\i2-employee.ind") -notypeinformation -force

$i1_employee_accrualjob_query = get-content ($query_dir + "\i1-employee-accrualjob.ijc.sql")
$i1_employee_accrualjob_result = get-tcpdata $i1_employee_accrualjob_query
$i1_employee_accrualjob_result | select NUMBER,JOBCODE,RATE,CLOCKABLE,EARNSOVT,COUNTOVT,USEDEFRATE,ACTIVE,REQUIRESCOST,EJCUST3213,EJCUST3200,EJCUST3206,EJCUST3203,EJCUST3214 | export-csv ($i1_output_dir + "\i1-employee-accrualjob.ijc") -notypeinformation -force

$i1_employee_job_query = get-content ($query_dir + "\i1-employee-job.ijc.sql")
$i1_employee_job_result = get-tcpdata $i1_employee_job_query
$i1_employee_job_result | select JOBCODE,NUMBER,RATE,CLOCKABLE,EARNSOVT,COUNTOVT,USEDEFRATE,ACTIVE,REQUIRESCOST,EJCUST3213,EJCUST3200,EJCUST3201,EJCUST3202,EJCUST3206,EJCUST3203,EJCUST3204,EJCUST3205,EJCUST3214 | export-csv ($i1_output_dir + "\i1-employee-job.ijc") -notypeinformation -force

$i1_employee_accruals_query = get-content ($query_dir + "\i1-employee-accruals.acc.sql")
$i1_employee_accruals_result = get-tcpdata $i1_employee_accruals_query
$i1_employee_accruals_result | select NUMBER,JOBCODE,HRSACCRUED,HRSTAKEN,HRSOVER,POSTDATE,CLEARACCRUAL | export-csv ($i1_output_dir + "\i1-employee-accruals.acc") -notypeinformation -force

$update_webclock_query = get-content ($query_dir + "\WebClockClassUpdate.sql")
Set-TCPData $update_webclock_query

$update_costing_query = get-content ($query_dir + "\FixupCostingRequirements.sql")
Set-TCPData $update_costing_query

cd $i1_output_dir
ls | where {$_.Length -eq 0} | % { Remove-Item $_.Fullname -force; }

cd $i2_output_dir
ls | where {$_.Length -eq 0} | % { Remove-Item $_.Fullname -force; }

Move-Item "$i1_output_dir\i1*" $i1_final_dir -force
Move-Item "$i2_output_dir\i2*" $i2_final_dir -force
