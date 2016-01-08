SELECT t01.* 
FROM (
	SELECT
	  prec_emp AS NUMBER
	, 
	 CASE WHEN (
	(prec_job IS NULL OR prec_job LIKE '')
	AND
	prec_type = '1'
	)
	THEN '9999999001'
	ELSE
		 CASE WHEN (
		(prec_job IS NULL OR prec_job LIKE '')
		AND
		prec_type = '2'
		)
		THEN '9999999002'
		ELSE
			 CASE WHEN (
			(prec_job IS NULL OR prec_job LIKE '')
			AND
			prec_type = '3'
			)
			THEN '9999999003'
			ELSE
				 CASE WHEN (
				(prec_job IS NULL OR prec_job LIKE '')
				AND
				prec_type = '4'
				)
				THEN '9999999004'
				ELSE
					 CASE WHEN (
					(prec_job IS NULL OR prec_job LIKE '')
					AND
					prec_type = '5'
					)
					THEN '9999999005'
					ELSE
						 CASE WHEN (
						(prec_job IS NULL OR prec_job LIKE '')
						AND
						prec_type = '6'
						)
						THEN '9999999006'
						ELSE
							 CASE WHEN (
							(prec_job IS NULL OR prec_job LIKE '')
							AND
							prec_type = '7'
							)
							THEN '9999999007'
							ELSE
								 CASE WHEN (
								(prec_job IS NULL OR prec_job LIKE '')
								AND
								prec_type = '8'
								)
								THEN '9999999008'
								ELSE
									 CASE WHEN (
									(prec_job IS NULL OR prec_job LIKE '')
									AND
									prec_type = '9'
									)
									THEN '9999999009'
									ELSE
										 CASE WHEN (
										(prec_job IS NULL OR prec_job LIKE '')
										AND
										prec_type = 'B'
										)
										THEN '9999999009'
										ELSE
										''
	END END END END END END END END END END AS JOBCODE
	, CASE WHEN (  (prec_job IS NULL OR prec_job LIKE '') AND prec_type IN ('5','6') )
					THEN 0.0000 ELSE  
						CASE WHEN (prec_avail < 0.0000) THEN 0.0000 ELSE prec_avail END
					END AS HRSACCRUED
	, 0 AS HRSTAKEN
	, 0 AS HRSOVER
	, CONVERT(nvarchar(10), GETDATE(), 23) AS POSTDATE
	, 'Y' AS CLEARACCRUAL
	FROM [MUNIS_SERVER_FQDN].mu_live.dbo.prempacc prempacc
	INNER JOIN [MUNIS_SERVER_FQDN].mu_live.dbo.prempmst prempmst ON prempacc.prec_emp = prempmst.prem_emp AND prempacc.prec_proj = prempmst.prem_proj
	WHERE prec_proj = 0
	AND (prec_job IS NULL OR rtrim(prec_job) LIKE '')
	AND prem_loc IN (SELECT deptcode FROM [MUNIS_SERVER_FQDN].mu_live.custom.timeclockplus_depts)
) t01
INNER JOIN (
	SELECT DISTINCT EmployeeId, CONVERT(decimal,JobCode) AS JobCode FROM TIMECLOCKPLUS_DATABASE.dbo.EmployeeJobCodes WHERE JobCode IS NOT NULL AND EmployeeId IS NOT NULL
) t09 ON t01.NUMBER = t09.EmployeeId AND CONVERT(decimal,t01.JOBCODE) = t09.JobCode
WHERE t01.NUMBER IS NOT NULL
AND t01.NUMBER IN (
	SELECT DISTINCT EmployeeId FROM TIMECLOCKPLUS_DATABASE.dbo.EmployeeList WHERE EmployeeId IS NOT NULL
)
