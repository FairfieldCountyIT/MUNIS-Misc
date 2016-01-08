BEGIN TRANSACTION;

UPDATE EmployeeJobCodes
SET RequiresCostCode=0
WHERE JobCode IN (
	SELECT JobCode
	FROM MasterJobCodeList
	WHERE CostGroupId =0
	OR CostGroupId IS NULL
)
AND ( 
	RequiresCostCode <> 0
	OR
	RequiresCostCode IS NULL
)
;

UPDATE EmployeeJobCodes
SET RequiresCostCode=1
WHERE JobCode IN (
	SELECT JobCode
	FROM MasterJobCodeList
	WHERE NOT CostGroupId = 0
)
AND RequiresCostCode <> 1
;

UPDATE EmployeeList
SET JobCosting = 0
WHERE EmployeeId NOT IN (
	SELECT DISTINCT EmployeeId
	FROM EmployeeJobCodes
	WHERE RequiresCostCode = 1
)
AND JobCosting <> 0
;

UPDATE EmployeeList
SET JobCosting = 1
WHERE EmployeeId IN (
	SELECT DISTINCT EmployeeId
	FROM EmployeeJobCodes
	WHERE RequiresCostCode = 1
)
AND JobCosting <> 1
;

COMMIT TRANSACTION;
