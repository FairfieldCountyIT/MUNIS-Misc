
DROP VIEW [custom].[bss_elig_warnings]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [custom].[bss_elig_warnings] AS
SELECT DISTINCT 'Fatal' AS severity, 'Term code' + prem_term + ' not present in bss_xr_termcode lookup table.' AS message
FROM mu_live.dbo.prempmst
WHERE prem_proj = 0
AND prem_term IS NOT NULL
AND prem_term NOT LIKE ''
AND prem_term NOT IN (SELECT code FROM mu_live.custom.bss_xr_termcode)
UNION ALL
SELECT DISTINCT 'Fatal' AS severity, 'Marital code' + prem_marital + ' not present in bss_marital lookup table.' AS message
FROM mu_live.dbo.prempmst
WHERE prem_proj = 0
AND prem_marital IS NOT NULL
AND prem_marital NOT LIKE ''
AND prem_marital NOT IN (SELECT prem_marital FROM mu_live.custom.bss_marital)
UNION ALL
SELECT 'WARN' AS severity, 'Emp ' + convert(varchar, emp.prem_emp) + ' is not marked as eligible but theoretically should be.' AS message
FROM mu_live.dbo.prempmst emp
WHERE prem_proj = 0 -- only live data
AND prem_act_stat = 'A' -- only active employees are relevant
AND prem_status = 'FT' -- only full time employees are relevant
AND prem_loc NOT IN ( SELECT loc FROM mu_live.custom.bss_skiploc ) -- certain departments do not participate
AND prem_emp NOT IN ( SELECT emp FROM mu_live.custom.bss_skipemp ) -- municipal court elected officials are not eligible
AND prem_emp NOT IN (
    SELECT pred_emp
    FROM prempded
    WHERE prempded.pred_active = 'Y'
    AND prempded.pred_ded IN (SELECT dedcode FROM mu_live.custom.bss_dedcodes WHERE codeuse='E')
    AND prempded.pred_proj = 0
)
GO

DROP VIEW [custom].[bss_elig_output]
GO

CREATE VIEW [custom].[bss_elig_output] AS SELECT 
      replace(prem_ssn, '-', '') AS SSN
    , prempmst.prem_emp AS IDNumber
    , rtrim(prem_lname) AS LastName
    , rtrim(prem_fname) AS Firstname
    , rtrim(prem_minit) AS MI
    , COALESCE (replace(prem_suffix, '.', ''), '') AS Suffix
    , CONVERT (VARCHAR, prem_dob, 101) AS DOB
    , prem_gender AS Gender
    , bss_xr_ethnic.bss_output AS EthnicCode
    , bss_marital.bss_marital_code AS MaritalStatus
    , rtrim(replace(praddrss.prad_addr1, ',', '')) AS HomeAddress
    , rtrim(prad_addr2) AS HomeAddress2
    , rtrim(prad_city) AS City
    , rtrim(prad_state) AS State
    , LEFT(prad_zip, 5) AS Zip
    , rtrim(replace(prem_email, ',', '.')) AS Email
    , rtrim(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(prem_home_ph, '-', ''), 'c', ''), 'cell', ''), 'C', ''), 'U', ''), '(', ''), ')', ''), '/', ''), '.', ''), 'unlis', '')) AS HomePhone
    , CASE
        WHEN ((SELECT config_value FROM mu_live.custom.bss_config WHERE config_name = 'SALARY_FROM')='PAY') THEN 
            (SELECT sum(premppay.prep_ann_sal1) FROM premppay WHERE premppay.prep_emp = prempmst.prem_emp)
        WHEN ((SELECT config_value FROM mu_live.custom.bss_config WHERE config_name = 'SALARY_FROM')='LIFE') THEN 
            ( SELECT SUM(lifeded.pred_ann_sal) 
            FROM mu_live.dbo.prempded lifeded
            WHERE lifeded.pred_proj = 0
            AND lifeded.pred_emp = prempmst.prem_emp
            AND lifeded.pred_active = 'Y'
            AND lifeded.pred_ded IN (
                SELECT dedcode
                FROM mu_live.custom.bss_dedcodes
                WHERE codeuse = 'L' 
            )
            GROUP BY lifeded.pred_emp
            ) 
        ELSE
            0.00
        END AS AnnualSalary
	, CASE
		WHEN ( ( SELECT TOP 1 config_value FROM mu_live.custom.bss_config WHERE config_name = 'EMP_STATUS_FROM' ) = 'MASTER' ) THEN prem_act_stat
		WHEN ( ( ( SELECT TOP 1 config_value FROM mu_live.custom.bss_config WHERE config_name = 'EMP_STATUS_FROM' ) = 'ELIGDED' )
			AND ( ( SELECT TOP 1 config_value FROM mu_live.custom.bss_config WHERE config_name = 'CONSIDER_ELIGDED_START' ) = 'Y' ) )
			THEN (
				CASE WHEN ( prempded.pred_end >= GETDATE() AND prempded.pred_start <= GETDATE() ) THEN 'A' ELSE 'I' END 
			)
		WHEN ( ( ( SELECT TOP 1 config_value FROM mu_live.custom.bss_config WHERE config_name = 'EMP_STATUS_FROM' ) = 'ELIGDED' )
			AND ( ( SELECT TOP 1 config_value FROM mu_live.custom.bss_config WHERE config_name = 'CONSIDER_ELIGDED_START' ) = 'N' ) )
			THEN (
				CASE WHEN ( prempded.pred_end >= GETDATE() ) THEN 'A' ELSE 'I' END 
			)
		ELSE 'I'
		END AS [Active]
    , 'F' AS EmploymentStatus
    , CASE
        WHEN ( ( SELECT TOP 1 config_value FROM mu_live.custom.bss_config WHERE config_name = 'EMP_STATUS_FROM' ) = 'ELIGDED' ) THEN CONVERT (VARCHAR, prempded.pred_start, 101)
        WHEN ( ( SELECT TOP 1 config_value FROM mu_live.custom.bss_config WHERE config_name = 'EMP_STATUS_FROM' ) = 'MASTER' ) THEN CONVERT (VARCHAR, prempmst.prem_hire, 101)
        ELSE ''
        END AS HireDate
    , rtrim(prjobcls.prjb_long) AS JobTitle
    , CASE
        WHEN ( ( SELECT TOP 1 config_value FROM mu_live.custom.bss_config WHERE config_name = 'EMP_STATUS_FROM' ) = 'ELIGDED' ) THEN (
				CASE
					WHEN ( prempded.pred_end <= DATEADD(day, 90, GETDATE() ) ) THEN CONVERT (VARCHAR, prempded.pred_end, 101)
					ELSE ''
				END
			)
        WHEN ( ( SELECT TOP 1 config_value FROM mu_live.custom.bss_config WHERE config_name = 'EMP_STATUS_FROM' ) = 'MASTER' ) THEN COALESCE (CONVERT (VARCHAR, prem_term_date, 101), '')
        ELSE ''
        END AS TerminationDate
	, CASE
        WHEN ( ( SELECT TOP 1 config_value FROM mu_live.custom.bss_config WHERE config_name = 'EMP_STATUS_FROM' ) = 'MASTER' ) THEN rtrim(COALESCE (prem_term, ''))
		WHEN ( ( SELECT TOP 1 config_value FROM mu_live.custom.bss_config WHERE config_name = 'EMP_STATUS_FROM' ) = 'ELIGDED' ) THEN (
				CASE
					WHEN ( prempded.pred_end <= DATEADD(day, 90, GETDATE() ) ) THEN rtrim(COALESCE (prempded.pred_reference, ''))
					ELSE ''
				END
			)
        ELSE ''
        END AS TermReason --termination codes categorized as Voluntary, Involuntary or Transfer
	, CASE
        WHEN ( ( SELECT TOP 1 config_value FROM mu_live.custom.bss_config WHERE config_name = 'EMP_STATUS_FROM' ) = 'MASTER' ) THEN COALESCE(bss_xr_termcode_m.voluntary,'')
		WHEN ( ( SELECT TOP 1 config_value FROM mu_live.custom.bss_config WHERE config_name = 'EMP_STATUS_FROM' ) = 'ELIGDED' ) THEN (
				CASE
					WHEN ( prempded.pred_end <= DATEADD(day, 90, GETDATE() ) ) THEN COALESCE(bss_xr_termcode_d.voluntary,'')
					ELSE ''
				END
			)
        ELSE ''
        END AS [Voluntary/Involuntary/Transfer]
    , rtrim(prempmst.prem_loc) AS DeptNo --code from Master page rather than Job/Salary to conform with Secova script
    , rtrim(prlocatn.prln_long) AS Dept
    , rtrim(prempmst.prem_p_bargain) AS BargainUnit --bargainunit code from Master page rather than Job/Salary to conform with Secova script
    , prempmst.prem_p_org AS Org
    , ( SELECT TOP 1 config_value FROM mu_live.custom.bss_config WHERE config_name = 'COUNTY' ) AS County
    , premppay.prep_pay AS PayType
    , prempded.pred_ded AS DedCode
    , 'M' AS PayFrequency
FROM mu_live.dbo.prempmst prempmst
INNER JOIN mu_live.dbo.praddrss praddrss ON prempmst.prem_emp = praddrss.prad_emp AND prempmst.prem_proj = praddrss.prad_proj AND praddrss.prad_addnum = 1
INNER JOIN mu_live.dbo.premppay premppay ON premppay.prep_emp = prempmst.prem_emp AND premppay.prep_job = prempmst.prem_p_jclass AND premppay.prep_base_pay = 'Y' AND prempmst.prem_proj = premppay.prep_proj
INNER JOIN mu_live.dbo.prjobcls prjobcls ON prjobcls.prjb_code = prempmst.prem_p_jclass AND prempmst.prem_proj = prjobcls.prjb_proj
INNER JOIN mu_live.dbo.prempded prempded ON prempded.pred_emp = prempmst.prem_emp AND prempmst.prem_proj = prempded.pred_proj AND prempded.pred_ded IN (SELECT dedcode FROM mu_live.custom.bss_dedcodes WHERE codeuse='E') AND prempded.pred_active = 'Y'
LEFT OUTER JOIN mu_live.dbo.prlocatn prlocatn ON prempmst.prem_loc = prlocatn.prln_code
LEFT OUTER JOIN mu_live.custom.bss_marital bss_marital ON prempmst.prem_marital = bss_marital.prem_marital
LEFT OUTER JOIN mu_live.custom.bss_xr_termcode bss_xr_termcode_m ON prempmst.prem_term = bss_xr_termcode_m.code AND prempmst.prem_term NOT LIKE '' AND prempmst.prem_term IS NOT NULL
LEFT OUTER JOIN mu_live.custom.bss_xr_termcode bss_xr_termcode_d ON prempded.pred_reference = bss_xr_termcode_d.code AND prempded.pred_reference NOT LIKE '' AND prempded.pred_reference IS NOT NULL
LEFT OUTER JOIN mu_live.custom.bss_xr_ethnic bss_xr_ethnic ON bss_xr_ethnic.computed =
    (
        0
        + 
        CASE WHEN prem_white = 'Y' THEN 1 ELSE 0 END
        +
        CASE WHEN prem_hawaiian = 'Y' THEN 2 ELSE 0 END
        +
        CASE WHEN prem_black = 'Y' THEN 4 ELSE 0 END
        +
        CASE WHEN prem_asian = 'Y' THEN 8 ELSE 0 END
        +
        CASE WHEN prem_amerind = 'Y' THEN 16 ELSE 0 END
        +
        CASE WHEN prem_hispanic = 'Y' THEN 32 ELSE 0 END
    )
WHERE prempmst.prem_proj = 0
AND (
    prem_term_date IS NULL
    OR 
    ( prem_term_date IS NOT NULL AND getdate() < DATEADD(day, 90, prem_term_date))
)
AND prempmst.prem_loc NOT IN ( SELECT loc FROM mu_live.custom.bss_skiploc )
AND prempmst.prem_emp NOT IN ( SELECT emp FROM mu_live.custom.bss_skipemp )

GO
