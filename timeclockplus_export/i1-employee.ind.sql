SELECT 
prem_emp AS NUMBER
, prem_loc AS TEMPLATEID
, rtrim(prem_fname) AS FIRSTNAME
, rtrim(prem_lname) AS LASTNAME
, prem_emp AS ECODE
, prem_ssn AS SSN
, prem_loc AS DEPARTMENT
, substring(prem_ssn,8,4) AS PIN
, CASE WHEN (supervisor_user.rums_idcode IS NOT NULL) THEN rtrim(supervisor_user.rums_idcode) ELSE '' END AS [MANAGERID]
, REPLACE(REPLACE(REPLACE(REPLACE(prem_home_ph,' ',''),'-',''),')',''),'(','') AS PHONE
, prem_gender AS GENDER
, lower(rtrim(prem_email)) AS EMAIL
, 'N' AS JOBCOST
, prem_loc AS EMCUST3217
, CASE WHEN (prem_hire IS NOT NULL) THEN CONVERT(nvarchar(10), prem_hire, 23) ELSE '' END AS DATEHIRE
, CASE WHEN (prem_term_date IS NOT NULL) THEN CONVERT(nvarchar(10), prem_term_date, 23) ELSE '' END AS DATELEFT
, CASE WHEN (prem_dob IS NOT NULL) THEN CONVERT(nvarchar(10), prem_dob, 23) ELSE '' END  AS DOB
, rtrim(prjobcls.prjb_reference) + CAST(prjobcls.prjb_basepay AS varchar) AS DEFJCODE
, 0.00 AS DEFRATE
, CASE WHEN (prem_status = 'FT') THEN 'Full Time' ELSE 'Part Time' END AS STATUS
, RTRIM(COALESCE(praddrss.prad_addr1,'')) AS ADDRESS1
, RTRIM(COALESCE(praddrss.prad_addr2,'')) AS ADDRESS2
, RTRIM(COALESCE(praddrss.prad_city,'')) AS [CITY]
, RTRIM(COALESCE(praddrss.prad_state,'')) AS [STATE]
, RTRIM(COALESCE(praddrss.prad_zip,'')) AS [ZIP]
FROM [MUNIS_SERVER_FQDN].[mu_live].[dbo].prempmst prempmst
INNER JOIN [MUNIS_SERVER_FQDN].[mu_live].[dbo].prjobcls prjobcls ON prempmst.prem_p_jclass = prjobcls.prjb_code AND prempmst.prem_proj = prjobcls.prjb_proj
LEFT OUTER JOIN [MUNIS_SERVER_FQDN].[mu_live].[dbo].praddrss praddrss ON prempmst.prem_emp = praddrss.prad_emp AND prempmst.prem_proj = praddrss.prad_proj  AND praddrss.prad_addnum=1
LEFT OUTER JOIN (
	SELECT rums_pr_emp_no, rtrim(min(rums_idcode)) AS rums_idcode
	FROM [MUNIS_SERVER_FQDN].[mu_live].[dbo].rousrmst rousrmst
	WHERE rums_pr_emp_no IS NOT NULL
	AND rums_pr_emp_no NOT LIKE '' 
	AND rums_pr_emp_no <> 0
	AND rums_acct_status = 1
	GROUP BY rums_pr_emp_no
) supervisor_user ON prempmst.prem_supervisor = supervisor_user.rums_pr_emp_no
WHERE prem_proj = 0
AND prem_loc IN (SELECT deptcode FROM [MUNIS_SERVER_FQDN].[mu_live].[custom].timeclockplus_depts)
AND prjb_reference IS NOT NULL
AND prjb_reference NOT LIKE ''
AND (
	prem_term_date IS NULL
	OR
	prem_term_date BETWEEN DATEADD(month,-2, GETDATE()) AND GETDATE()
)
AND prem_emp NOT IN (
	SELECT DISTINCT EmployeeId FROM TIMECLOCKPLUS_DATABASE.dbo.EmployeeList
)
