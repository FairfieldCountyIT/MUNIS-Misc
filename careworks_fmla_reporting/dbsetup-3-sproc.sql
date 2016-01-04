SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [custom].[careworks_fmla_generate]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	IF OBJECT_ID('tempdb.dbo.#careworks_fmla_work', 'U') IS NOT NULL
  DROP TABLE #careworks_fmla_work; 

IF OBJECT_ID('tempdb.dbo.#t1_iskey', 'U') IS NOT NULL
  DROP TABLE #t1_iskey; 

DECLARE @maxpayenddate DATE

DECLARE @myactiverowcount INTEGER

DECLARE @hrswrkd_pay_low INTEGER

DECLARE @hrswrkd_pay_high INTEGER

DECLARE @companyname VARCHAR(255)

DECLARE @period_start_day VARCHAR(255)

DECLARE @key_person_mult NUMERIC

SELECT @maxpayenddate = max(prct_end_date) FROM prctlfil WHERE prct_finished = 'Y'

SELECT @companyname = max([value]) FROM [custom].[careworks_config] WHERE setting = 'Company_Name'

SELECT @period_start_day = max([value]) FROM [custom].[careworks_config] WHERE setting = 'Pay_Period_Start_Day'

SELECT @key_person_mult = max(CAST([value] AS numeric)) FROM [custom].[careworks_config] WHERE setting = 'Key_Person_Percentage'

SELECT @hrswrkd_pay_low = max(CAST([value] as integer)) FROM [custom].[careworks_config] WHERE setting = 'HoursWorked_PayType_Lower'

SELECT @hrswrkd_pay_high = max(CAST([value] as integer)) FROM [custom].[careworks_config] WHERE setting = 'HoursWorked_PayType_Upper'

INSERT INTO [custom].[careworks_empstatus_xr] (status_code, export_value)
SELECT DISTINCT prempmst.prem_status AS status_code, 'Unknown' AS export_value
FROM dbo.prempmst
WHERE prempmst.prem_status IS NOT NULL
AND prempmst.prem_status NOT IN (
	SELECT DISTINCT status_code FROM [custom].[careworks_empstatus_xr]
)
;

INSERT INTO custom.careworks_bgnu_xr (bgnu_code, export_value)
SELECT DISTINCT prempmst.prem_p_bargain AS bgnu_code, '' AS export_value
FROM dbo.prempmst
WHERE prempmst.prem_p_bargain NOT IN (
	SELECT DISTINCT bgnu_code FROM custom.careworks_bgnu_xr
)
;

INSERT INTO custom.careworks_marital_xr (marital_code, export_value)
SELECT DISTINCT prempmst.prem_marital AS marital_code, 'U' AS export_value
FROM dbo.prempmst
WHERE prempmst.prem_marital NOT IN (
	SELECT DISTINCT marital_code FROM custom.careworks_marital_xr
)
;

SELECT
  '' as [SSN] -- employee ssn
, prempmst.prem_emp as [Employee ID]
, RTRIM(LEFT(prempmst.prem_lname,30)) as [Last Name]
, RTRIM(LEFT(prempmst.prem_fname,30)) as [First name]
, prempmst.prem_minit as [Middle Initial]
, RTRIM(LEFT(COALESCE(prempmst.prem_suffix,''),4)) as [Suffix]
, RTRIM(LEFT(praddrss.prad_addr1,60)) AS [Street Address 1]
, RTRIM(LEFT(praddrss.prad_addr2,60)) AS [Street Address 2]
, substring(praddrss.prad_zip,1,5) AS [Zip Code]
, RTRIM(LEFT(praddrss.prad_city,30)) AS [City]
, RTRIM(LEFT(praddrss.prad_state,30)) AS [State/Province]
, RTRIM(LEFT(COALESCE(county.prms_long,''),30)) AS [County]
, CASE WHEN (RTRIM(LEFT(praddrss.prad_country,30)) = 'USA') THEN 'U.S.' ELSE '' END AS [Country]
, CASE WHEN (len(praddrss.prad_zip)=10) THEN substring(praddrss.prad_zip,7,4) ELSE '' END AS [Zip4]
, '' AS [Company ID]
, @companyname AS [Company Name]
, LEFT(prempmst.prem_loc,30) AS [Department]
, '' AS [Area]
, RTRIM(LEFT(premppay.prep_job + '-' + CONVERT(varchar(10),COALESCE(premppay.prep_pos,0)) + ':' + COALESCE(pmposctl.pmpc_desc,prjobcls.prjb_long,''),30)) AS [Occupation]
, LEFT(prempmst.prem_wkloc,20) AS [EE Location ID]
, LEFT(prwrkloc.prwl_name,60) AS [Location Name]
, '' AS [Work Shift]
, CONVERT(VARCHAR(10), COALESCE(prempmst.prem_orig,prempmst.prem_hire), 101) AS [Date Hired]
, '' AS [Position Start Date]
, CASE WHEN (super1_prempmst.prem_emp IS NOT NULL) THEN LEFT(rtrim(rtrim(rtrim(super1_prempmst.prem_fname) + ' ' + super1_prempmst.prem_minit) + ' ' + super1_prempmst.prem_lname),60) ELSE '' END AS [Supervisor]
, '' AS [Supervisor Phone]
, '' AS [Supervisor Ext]
, '' AS [Is Management]
, empstatus_xr.export_value AS [Work Status]
, COALESCE(bgnu_xr.export_value,'') AS [Union Affiliate]
, '' AS [Employee Work Phone] -- employee work phone
, '' AS [Employee Work Phone Ext] -- employee work phone extension
, RIGHT(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(prempmst.prem_home_ph,'(','') ,')','') ,' ','') ,'.','') ,'*','') ,'-',''),'+',''),10) AS [Employee Personal Phone]
, COALESCE(marital_xr.export_value,'U') AS [Marital Status]
, CONVERT(VARCHAR(10), prempmst.prem_dob, 101) AS [Date of Birth]
, CASE WHEN (prempmst.prem_gender NOT IN ('M','F')) THEN 'U' ELSE prempmst.prem_gender END AS [Sex]
, '' AS [Number of Dependents]
, '' AS [Citizenship]
, '' AS [Work Permit Filed]
, '' AS [Language]
, '' as [Blank Field 1]
, '' as [Blank Field 2]
, prwrkloc.prwl_state AS [Employee Work State]
, '' as [Blank Field 3]
, CASE WHEN (prempmst.prem_inact_date IS NULL) THEN 'Active' ELSE 'Inactive' END AS [Employment Status]
, CASE WHEN (prempmst.prem_inact_date IS NULL) THEN '' ELSE CONVERT(VARCHAR(10), prempmst.prem_inact_date, 101) END AS [Inactive Status Date]
, '' as [NCCI]
, '' as [SOC]
, COALESCE(premppay.prep_perhrs,0) AS [Standard Hours Worked]
, CASE WHEN (premppay.prep_freq = 'B') THEN 'B' ELSE '' END AS [Standard Hours Worked Frequency]
, CONVERT(VARCHAR(10), premppay.prep_start, 101) AS [Hours Worked Date]
, '' AS [Percent Full Time]
, '' AS [Participates in Group Health]
, CASE WHEN (spouse_prempmst.prem_emp IS NOT NULL) THEN rtrim(rtrim(rtrim(spouse_prempmst.prem_fname) + ' ' + spouse_prempmst.prem_minit) + ' ' + spouse_prempmst.prem_lname) ELSE '' END AS [Spouse Name with Same Employer]
, '' as [Spouse SSN]
, CASE WHEN (spouse_prempmst.prem_emp IS NOT NULL) THEN CONVERT(varchar(10),spouse_prempmst.prem_emp) ELSE '' END AS [Spouse Employee ID]
, 'N' AS [Key Employee]
, CONVERT(VARCHAR(10), GETDATE(), 101) AS [Effective Date of File]
, '' AS [Work Schedule Name]
, premppay.prep_per_sal AS [Wage]
, CASE WHEN (premppay.prep_freq = 'B') THEN '2' ELSE '' END AS [Wage Frequency]
, '' AS [Wage Effective Date]
, '' AS [Average Weekly Wage]
, '' AS [Payroll Class]
, '' as [Blank Field 4]
, '' AS [Sick Time Accrued Off]
, '' AS [Personal Time off Accrued]
, '' AS [Vacation Time off Accrued]
, '' AS [Other Time Off Accrued]
, '' AS [Total Time Off Accrued]
, '' AS [Time Off Accrued Date]
, CASE WHEN (super1_prempmst.prem_email IS NOT NULL) THEN LEFT(rtrim(super1_prempmst.prem_email),256) ELSE '' END AS [Supervisor 1 E-mail]
, '' as [Supervisor SSN]
, CASE WHEN (super1_prempmst.prem_emp IS NOT NULL) THEN CONVERT(varchar(99),super1_prempmst.prem_emp) ELSE '' END AS [Supervisor 1 ID]
, COALESCE(hours_worked.hours_worked,0) AS [Hrs Wrkd last 12 Months]
, CONVERT(VARCHAR(10), @maxpayenddate, 101) AS [Hrs Wrkd last 12 Months Date]
, '' AS [Hrs Paid in the Last 12 Months]
, '' AS [Hrs Pd in the Last 12 Months Date]
, REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(COALESCE(prempphn.prph_phone,''),'(','') ,')','') ,' ','') ,'.','') ,'*','') ,'-',''),'+','') AS [Employee Cell Phone]
, LEFT(rtrim(prempmst.prem_email),256) AS [Employee E-mail]
, CASE WHEN (super2_prempmst.prem_fname IS NOT NULL) THEN LEFT(rtrim(rtrim(rtrim(super2_prempmst.prem_fname) + ' ' + super2_prempmst.prem_minit) + ' ' + super2_prempmst.prem_lname),60) ELSE '' END AS [Supervisor 2]
, '' AS [Supervisor 2 Phone]
, '' AS [Supervisor 2 Ext]
, LEFT(rtrim(COALESCE(super2_prempmst.prem_email,'')),256) as [Supervisor 2 E-mail]
, '' AS [Supervisor 2 SSN]
, CASE WHEN (super2_prempmst.prem_emp IS NOT NULL) THEN CONVERT(varchar(99),super2_prempmst.prem_emp) ELSE '' END AS [Supervisor 2 ID]
, '' AS [Rehire] -- rehire
, @period_start_day AS [Pay Period Start Day]
, '' AS [Voluntary STD Indicator]
INTO #careworks_fmla_work
FROM prempmst prempmst
LEFT OUTER JOIN prempmst spouse_prempmst ON prempmst.prem_spouse = spouse_prempmst.prem_emp AND prempmst.prem_proj = spouse_prempmst.prem_proj
LEFT OUTER JOIN prempmst super1_prempmst ON prempmst.prem_supervisor = super1_prempmst.prem_emp AND prempmst.prem_proj = super1_prempmst.prem_proj AND (prempmst.prem_emp <> super1_prempmst.prem_emp)
LEFT OUTER JOIN prempmst super2_prempmst ON super1_prempmst.prem_supervisor = super2_prempmst.prem_emp AND super1_prempmst.prem_proj = super2_prempmst.prem_proj AND (super1_prempmst.prem_emp <> super2_prempmst.prem_emp)
LEFT OUTER JOIN praddrss praddrss ON prempmst.prem_emp = praddrss.prad_emp AND prempmst.prem_proj = praddrss.prad_proj AND praddrss.prad_addnum=1
LEFT OUTER JOIN prmisccd county ON praddrss.prad_county = county.prms_code
LEFT OUTER JOIN prwrkloc prwrkloc ON prempmst.prem_wkloc = prwrkloc.prwl_location
LEFT OUTER JOIN premppay premppay ON prempmst.prem_emp = premppay.prep_emp AND prempmst.prem_proj = premppay.prep_proj AND premppay.prep_base_pay = 'Y' AND prempmst.prem_p_jclass = premppay.prep_job AND premppay.prep_inactive = 'A'
LEFT OUTER JOIN prjobcls prjobcls ON prempmst.prem_p_jclass = prjobcls.prjb_code AND prempmst.prem_proj = prjobcls.prjb_proj
LEFT OUTER JOIN pmposctl pmposctl ON pmposctl.pmpc_proj = 0 AND premppay.prep_job = pmposctl.pmpc_job_class AND premppay.prep_pos = pmposctl.pmpc_position
LEFT OUTER JOIN [custom].[careworks_empstatus_xr] empstatus_xr ON prempmst.prem_status = empstatus_xr.status_code
LEFT OUTER JOIN custom.careworks_bgnu_xr bgnu_xr ON prempmst.prem_p_bargain = bgnu_xr.bgnu_code
LEFT OUTER JOIN custom.careworks_marital_xr marital_xr ON prempmst.prem_marital = marital_xr.marital_code
LEFT OUTER JOIN (
    SELECT prph_emp, prph_type, MAX(prph_phone) AS prph_phone
    FROM prempphn 
    WHERE prph_proj =0
    GROUP BY prph_emp, prph_type
    ) prempphn ON prempmst.prem_emp = prempphn.prph_emp AND prempphn.prph_type = 'CELL'
LEFT OUTER JOIN (
    SELECT preh_emp, SUM(preh_hours) AS hours_worked
    FROM prearnhi
    WHERE prearnhi.preh_end_date > DATEADD(year,-1,@maxpayenddate)
    AND preh_pay BETWEEN @hrswrkd_pay_low AND @hrswrkd_pay_high
    --AND preh_pay_type IN ('1','2')
    GROUP BY preh_emp
) hours_worked ON prempmst.prem_emp = hours_worked.preh_emp
WHERE prempmst.prem_proj = 0
AND (prempmst.prem_inact_date IS NULL OR prempmst.prem_inact_date > DATEADD(month,-1,@maxpayenddate))
AND prempmst.prem_loc NOT IN (SELECT DISTINCT location_code FROM custom.careworks_location_exclusions)

SELECT @myactiverowcount = COUNT(*) 
FROM #careworks_fmla_work
WHERE [Employment Status] = 'Active'

SELECT [Employee ID], RANK() OVER (ORDER BY [Wage] DESC) AS salary_rank
INTO #t1_iskey
FROM #careworks_fmla_work
WHERE [Employment Status] = 'Active'

UPDATE #careworks_fmla_work
SET [Key Employee] = 'Y'
WHERE [Employee ID] IN (
    SELECT [Employee ID]
    FROM #t1_iskey
    WHERE salary_rank <= (@myactiverowcount * @key_person_mult / 100)
)

SELECT *
FROM #careworks_fmla_work

DROP TABLE #t1_iskey

    
END

GO

