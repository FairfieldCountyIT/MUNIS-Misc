BEGIN TRANSACTION;

DELETE FROM LocationIdentifiers
WHERE LocationId IN (
	SELECT LocationIdentifiers.LocationId
	FROM LocationIdentifiers
	INNER JOIN EmployeeList ON LocationIdentifiers.ComputerId = CAST(EmployeeList.EmployeeId AS varchar)
	WHERE ApplicationId = 16
	AND (
		LocationIdentifiers.Configuration <> EmployeeList.Class
		OR 
		LocationIdentifiers.Configuration IS NULL
		)
	AND LocationId is not null
)
AND ApplicationId = 16
;

INSERT INTO LocationIdentifiers (Company, ComputerId, ApplicationId, Port, Description, Configuration)
SELECT EmployeeList.Company, CAST(EmployeeId AS varchar) AS ComputerId, 16 AS ApplicationId, 0 AS Port, '' AS Description, t0.RecordId AS Configuration
FROM EmployeeList
INNER JOIN (
	SELECT Company, RecordId
	FROM ModuleData
	WHERE ModuleNumber = 1000005
) t0 ON EmployeeList.Class = t0.RecordId
LEFT OUTER JOIN LocationIdentifiers ON LocationIdentifiers.ApplicationId = 16 AND LocationIdentifiers.ComputerId = CAST(EmployeeList.EmployeeId AS varchar)
WHERE LocationIdentifiers.LocationId IS NULL
;

COMMIT TRANSACTION;
