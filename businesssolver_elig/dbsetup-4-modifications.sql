
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [custom].[bss_locations] (
	[LocationCode] varchar(4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
	[OverrideLocationCode] varchar(4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
	[LocationDescription] varchar(255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
	[DoSkip] varchar(1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL DEFAULT ('N'),
	[SkipReason] varchar(255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
	CONSTRAINT [PK__bss_loca__DDB144D4E79E35AD] PRIMARY KEY CLUSTERED ([LocationCode]) 
	WITH (PAD_INDEX = OFF,
		IGNORE_DUP_KEY = OFF,
		ALLOW_ROW_LOCKS = ON,
		ALLOW_PAGE_LOCKS = ON)
	ON [PRIMARY]
)
ON [PRIMARY]
GO

ALTER TABLE [custom].[bss_locations] SET (LOCK_ESCALATION = TABLE)
GO

INSERT INTO custom.bss_locations (LocationCode, LocationDescription, DoSkip)
SELECT prln_code AS LocationCode, prln_long AS LocationDescription, 'N' AS DoSkip
FROM dbo.prlocatn
WHERE prln_code NOT IN (
	SELECT DISTINCT LocationCode
	FROM custom.bss_locations
)
GO

UPDATE custom.bss_locations 
SET DoSkip = 'Y'
WHERE LocationCode IN (
	SELECT CAST(sl.loc AS varchar(4)) AS LocationCode
	FROM custom.bss_skiploc sl
	WHERE sl.loc IS NOT NULL
)
GO

DROP TABLE [custom].[bss_skiploc]
GO
