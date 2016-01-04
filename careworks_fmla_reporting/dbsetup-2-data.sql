
INSERT INTO custom.careworks_location_exclusions (location_code)
SELECT '8800'
UNION ALL
SELECT '7300'
;

INSERT INTO [custom].[careworks_config] ([setting],[value]) SELECT 'Pay_Period_Start_Day','Saturday' ;
INSERT INTO [custom].[careworks_config] ([setting],[value]) SELECT 'Company_Name','Fairfield County' ;
INSERT INTO [custom].[careworks_config] ([setting],[value]) SELECT 'Key_Person_Percentage','10' ;
INSERT INTO [custom].[careworks_config] ([setting],[value]) SELECT 'HoursWorked_PayType_Lower','100' ;
INSERT INTO [custom].[careworks_config] ([setting],[value]) SELECT 'HoursWorked_PayType_Upper','199' ;

INSERT INTO [custom].[careworks_empstatus_xr] (status_code, export_value)
SELECT 'PT','Part time'
UNION ALL
SELECT 'S','Part time'
UNION ALL
SELECT 'FT','Full time'
;

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

UPDATE custom.careworks_bgnu_xr SET export_value = 'Sheriff - Dispatchers' WHERE bgnu_code = 'DISP' ;
UPDATE custom.careworks_bgnu_xr SET export_value = 'Sheriff - Sgt/Lt' WHERE bgnu_code = 'SGLT' ;
UPDATE custom.careworks_bgnu_xr SET export_value = 'Sheriff - Deputy' WHERE bgnu_code = 'DEPT' ;
UPDATE custom.careworks_bgnu_xr SET export_value = 'Forest Rose Education Assoc' WHERE bgnu_code = 'FREA' ;
UPDATE custom.careworks_bgnu_xr SET export_value = 'Engineer Road Worker' WHERE bgnu_code = 'ENG' ;

INSERT INTO custom.careworks_marital_xr (marital_code, export_value)
SELECT DISTINCT prempmst.prem_marital AS marital_code, 'U' AS export_value
FROM dbo.prempmst
WHERE prempmst.prem_marital NOT IN (
	SELECT DISTINCT marital_code FROM custom.careworks_marital_xr
)
;

UPDATE custom.careworks_marital_xr
SET export_value = marital_code
WHERE marital_code IN ('S','M','W')
;
