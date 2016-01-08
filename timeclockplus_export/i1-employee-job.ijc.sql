SELECT DISTINCT
  rtrim(rtrim(CAST(prjb_reference AS varchar)) + ltrim(CAST(prpt_code AS varchar))) AS JOBCODE
, premppay.prep_emp AS NUMBER
, 0.0000 AS RATE
, CASE WHEN (prjobcls.prjb_basepay = prpaytyp.prpt_code) THEN 'Y' ELSE 'N' END AS CLOCKABLE
, CASE WHEN (prjobcls.prjb_basepay = prpaytyp.prpt_code) THEN 'Y' ELSE 'N' END AS EARNSOVT
, CASE WHEN (prjobcls.prjb_basepay = prpaytyp.prpt_code) THEN 'Y' ELSE 'N' END AS COUNTOVT
, 'Y' AS USEDEFRATE
, CASE WHEN (premppay.prep_inactive = 'A') THEN 'Y' ELSE 'N' END AS ACTIVE
, 'N' AS REQUIRESCOST
, premppay.prep_job AS EJCUST3213
, premppay.prep_pay AS EJCUST3200
, premppay.prep_pay AS EJCUST3201
, premppay.prep_pay AS EJCUST3202
, premppay.prep_org AS EJCUST3206
, premppay.prep_obj AS EJCUST3203
, premppay.prep_obj AS EJCUST3204
, premppay.prep_obj AS EJCUST3205
, premppay.prep_d_proj AS EJCUST3214
FROM [MUNIS_SERVER_FQDN].mu_live.dbo.premppay premppay 
INNER JOIN [MUNIS_SERVER_FQDN].mu_live.dbo.prjobcls prjobcls ON premppay.prep_job = prjobcls.prjb_code AND premppay.prep_proj = prjobcls.prjb_proj
INNER JOIN [MUNIS_SERVER_FQDN].mu_live.dbo.prpaytyp prpaytyp ON premppay.prep_pay = prpaytyp.prpt_code AND premppay.prep_proj = prpaytyp.prpt_proj
LEFT OUTER JOIN (
	SELECT DISTINCT EmployeeId, JobCode FROM TIMECLOCKPLUS_DATABASE.dbo.EmployeeJobCodes
) t9 ON premppay.prep_emp = t9.EmployeeId AND CONVERT(float,rtrim(rtrim(CAST(prjb_reference AS varchar)) + ltrim(CAST(prpt_code AS varchar)))) = t9.JobCode
WHERE prep_proj = 0
AND prep_inactive = 'A'
AND prjb_reference IS NOT NULL
AND rtrim(prjb_reference) NOT LIKE ''
AND t9.JobCode IS NULL