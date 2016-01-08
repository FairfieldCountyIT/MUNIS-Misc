SELECT DISTINCT
  rtrim(rtrim(CAST(prjb_reference AS varchar)) + ltrim(CAST(prpt_code AS varchar))) AS JOBNUMBER
, substring((rtrim(prjb_code) + '-' + rtrim(prjb_short)),0,20) AS JCGROUP
, 'Y' AS ACTIVE
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
WHERE prep_proj = 0
AND prep_inactive = 'A'
AND prjb_reference IS NOT NULL
AND rtrim(prjb_reference) NOT LIKE ''
