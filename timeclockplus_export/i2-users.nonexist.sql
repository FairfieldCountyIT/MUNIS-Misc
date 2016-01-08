SELECT 
  t1.rums_idcode AS [USERID]
, t1.rums_idcode AS [NETWORKID]
, t1.rums_idcode AS [EXTERNALID]
, rtrim(prem_email) AS [EMAIL]
, prem_loc AS [DEPARTMENT]
, rtrim(prem_fname) + rtrim(' ' + prem_minit) + ' ' + rtrim(prem_lname) AS [USERNAME]
, prem_emp AS [EMPLOYEEID]
, 1 AS [ACTIVE]
FROM  [MUNIS_SERVER_FQDN].mu_live.dbo.prempmst prempmst
INNER JOIN (
	SELECT rums_pr_emp_no, rtrim(min(rums_idcode)) AS rums_idcode
	FROM  [MUNIS_SERVER_FQDN].mu_live.dbo.rousrmst rousrmst
	WHERE rums_pr_emp_no IS NOT NULL
	AND rums_pr_emp_no NOT LIKE '' 
	AND rums_pr_emp_no <> 0
	AND rums_acct_status = 1
	GROUP BY rums_pr_emp_no
) t1 ON prempmst.prem_emp = t1.rums_pr_emp_no
INNER JOIN TIMECLOCKPLUS_DATABASE.dbo.UserList tcp_user ON UPPER(t1.rums_idcode) COLLATE SQL_Latin1_General_CP1_CI_AS = UPPER(tcp_user.UserId)
WHERE prempmst.prem_proj = 0
AND prempmst.prem_act_stat = 'A'
AND prempmst.prem_emp IN (
	SELECT prem_supervisor
	FROM [MUNIS_SERVER_FQDN].mu_live.dbo.prempmst prempmst
	WHERE prem_proj = 0
	AND prem_act_stat = 'A'
	AND prem_supervisor IS NOT NULL
	AND prem_supervisor <> 0
	AND prem_loc IN (
		SELECT deptcode FROM [MUNIS_SERVER_FQDN].mu_live.custom.timeclockplus_depts
	)
)
AND (
	lower(t1.rums_idcode) COLLATE SQL_Latin1_General_CP1_CI_AS  <> tcp_user.NetworkId
	OR
	lower(t1.rums_idcode) COLLATE SQL_Latin1_General_CP1_CI_AS  <> tcp_user.ExternalUserId
	OR 
	lower(rtrim(prem_email)) COLLATE SQL_Latin1_General_CP1_CI_AS  <> tcp_user.EMail
	OR
	rtrim(prem_loc) COLLATE SQL_Latin1_General_CP1_CI_AS  <> tcp_user.Department
	OR
	prem_emp <> tcp_user.EmployeeId
	OR
	(rtrim(prem_fname) + rtrim(' ' + prem_minit) + ' ' + rtrim(prem_lname)) COLLATE SQL_Latin1_General_CP1_CI_AS  <> tcp_user.UserName
)
