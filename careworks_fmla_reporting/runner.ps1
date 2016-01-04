function Get-MUData{
   param([string]$query=$(throw 'query is required.'))
   $conn = New-Object System.Data.Odbc.OdbcConnection
   $conn.ConnectionString = "Driver={SQL Server};Server=SERVERNAME;Database=mu_live;Integrated Security=SSPI"
   $conn.open()
   $cmd = New-object System.Data.Odbc.OdbcCommand($query,$conn)
   $ds = New-Object system.Data.DataSet
   (New-Object system.Data.odbc.odbcDataAdapter($cmd)).fill($ds) | out-null
   $conn.close()
   $ds.Tables[0]
}

$output_dir = "OUTPUT_DIR"
$output_result = Get-MUData "exec custom.careworks_fmla_generate"
$output_result | select "SSN","Employee ID","Last Name","First name","Middle Initial","Suffix","Street Address 1","Street Address 2","Zip Code","City", "State/Province","County","Country","Zip4","Company ID","Company Name","Department","Area","Occupation","EE Location ID","Location Name","Work Shift","Date Hired","Position Start Date","Supervisor","Supervisor Phone","Supervisor Ext","Is Management","Work Status","Union Affiliate","Employee Work Phone","Employee Work Phone Ext","Employee Personal Phone","Marital Status","Date of Birth","Sex","Number of Dependents","Citizenship","Work Permit Files","Language","Blank Field 1","Blank Field 2","Employee Work State","Blank Field 3","Employment Status","Inactive Status Date","NCCI","SOC","Standard Hours Worked","Standard Hours Worked Frequency","Hours Worked Date","Percent Full Time","Participates in Group Health","Spouse Name with Same Employer","Spouse SSN","Spouse Employee ID","Key Employee","Effective Date of File","Work Schedule Name","Wage","Wage Frequency","Average Weekly Wage","Wage Effective Date","Payroll Class","Blank Field 4","Sick Time Accrued Off","Personal Time off Accrued","Vacation Time off Accrued","Other Time Off Accrued","Total Time Off Accrued","Time Off Accrued Date","Supervisor 1 E-mail","Supervisor SSN", "Supervisor 1 ID","Hrs Wrkd last 12 Months","Hrs Wrkd last 12 Months Date","Hrs Paid in the Last 12 Months","Hrs Pd in the Last 12 Months Date","Employee Cell Phone","Employee E-mail","Supervisor 2","Supervisor 2 Phone","Supervisor 2 Ext","Supervisor 2 E-mail","Supervisor 2 SSN","Supervisor 2 ID","Rehire","Pay Period Start Day","Voluntary STD Indicator" | export-csv ($output_dir + "\output.csv") -notypeinformation -force
