SELECT DISTINCT
  rtrim(rtrim(CAST(prjb_reference AS varchar)) + ltrim(CAST(prpt_code AS varchar))) AS JOBNUMBER
, substring((rtrim(prjb_code) + '-' + rtrim(prjb_short)),0,20) AS JCGROUP
, prjobcls.prjb_code + '-' + CAST(prpaytyp.prpt_code AS varchar) + ' ' + prpaytyp.prpt_long AS DESCRIPTION
, 'Y' AS ACTIVE
, 'N' AS LEAVECODE
, CASE WHEN (prpaytyp.prpt_code = prjobcls.prjb_basepay) THEN 'Y' ELSE 'N' END AS CLOCKED
, 'N' AS ASKCOST
, '' AS MJCUST3213
, '' AS MJCUST3200
, '' AS MJCUST3206
, '' AS MJCUST3203
, '' AS MJCUST3204
, '' AS MJCUST3205
, '' AS MJCUST3214
FROM  [MUNIS_SERVER_FQDN].mu_live.dbo.premppay premppay 
INNER JOIN  [MUNIS_SERVER_FQDN].mu_live.dbo.prjobcls prjobcls ON premppay.prep_job = prjobcls.prjb_code AND premppay.prep_proj = prjobcls.prjb_proj
INNER JOIN  [MUNIS_SERVER_FQDN].mu_live.dbo.prpaytyp prpaytyp ON premppay.prep_pay = prpaytyp.prpt_code AND premppay.prep_proj = prpaytyp.prpt_proj
LEFT OUTER JOIN (
	SELECT CAST(CAST(JobCode AS decimal) AS varchar) AS JobCode
	FROM TIMECLOCKPLUS_DATABASE.dbo.MasterJobCodeList
) existingjobcodes ON (rtrim(rtrim(CAST(prjb_reference AS varchar)) + ltrim(CAST(prpt_code AS varchar)))) = existingjobcodes.JobCode
WHERE prep_proj = 0
AND prep_inactive = 'A'
AND prjb_reference IS NOT NULL
AND rtrim(prjb_reference) NOT LIKE ''
AND existingjobcodes.JobCode IS NULL
