USE CO_HF_MART
GO

/* back original table */
IF EXISTS(SELECT * FROM sysobjects WHERE xtype = 'U' AND uid = 1 AND NAME = 'D_VEHICLE_REGISTRATION_STATUS')
BEGIN
	EXEC sp_rename 'dbo.D_VEHICLE_REGISTRATION_STATUS', 'D_VEHICLE_REGISTRATION_STATUS_BK'; 
	PRINT 'Renamed [DBO].[D_VEHICLE_REGISTRATION_STATUS] to [D_VEHICLE_REGISTRATION_STATUS_BK]'
END

IF EXISTS(SELECT * FROM sysobjects WHERE xtype = 'U' AND uid = 1 AND NAME = 'F_VEHICLE_REGISTRATION')
BEGIN
	EXEC sp_rename 'dbo.F_VEHICLE_REGISTRATION', 'F_VEHICLE_REGISTRATION_BK'; 
	PRINT 'Renamed [DBO].[F_VEHICLE_REGISTRATION] to [F_VEHICLE_REGISTRATION_BK]'
END


/*
 * NOTES: Creates B_VEHICLE_ATTRIBUTES dimension for AspiraOne datamart 
 *
 * DATE        JIRA      USER             DESCRIPTION
 * ----------  --------  ---------------  ---------------------------------------
 * 04/17/2019  DMA-3744  Zongpei Liu	  Initialization.
*/

SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL READ COMMITTED

IF OBJECT_ID('DBO.B_VEHICLE_ATTRIBUTES') IS NULL
BEGIN
	CREATE TABLE DBO.B_VEHICLE_ATTRIBUTES(
		B_VEHICLE_ATTRIBUTES_KEY    int             IDENTITY(1,1),
		D_VEHICLE_KEY               int             NULL,
		ATTRIBUTE_NM                varchar(255)    NULL,
		ATTRIBUTE_VALUE_TXT         varchar(256)    NULL,
		AWO_VEHICLE_ID              int             NULL,
		AWO_ATTRIBUTE_ID            int             NULL,
		MART_CREATED_DTM            datetime        NULL,
		MART_MODIFIED_DTM           datetime        NULL,
		CONSTRAINT PK_B_VEHICLE_ATTRIBUTES PRIMARY KEY CLUSTERED (B_VEHICLE_ATTRIBUTES_KEY)
	) ON CO_HF_MART_DATA

	exec sys.sp_addextendedproperty 'MS_Description', 'Surrogate key used to identify the vehicle and vehicle attribute within the data mart.', 'schema', 'dbo', 'table', 'B_VEHICLE_ATTRIBUTES', 'column', 'B_VEHICLE_ATTRIBUTES_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Surrogate key used to uniquely identify a vehicle dimension record. - NOT FOR EXTERNAL USE -', 'schema', 'dbo', 'table', 'B_VEHICLE_ATTRIBUTES', 'column', 'D_VEHICLE_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Attribute name.', 'schema', 'dbo', 'table', 'B_VEHICLE_ATTRIBUTES', 'column', 'ATTRIBUTE_NM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Attribute value.', 'schema', 'dbo', 'table', 'B_VEHICLE_ATTRIBUTES', 'column', 'ATTRIBUTE_VALUE_TXT'
	exec sys.sp_addextendedproperty 'MS_Description', 'Identifier for an vehicle record in AO.', 'schema', 'dbo', 'table', 'B_VEHICLE_ATTRIBUTES', 'column', 'AWO_VEHICLE_ID'
	exec sys.sp_addextendedproperty 'MS_Description', 'Identifier for an attribute record in AO.', 'schema', 'dbo', 'table', 'B_VEHICLE_ATTRIBUTES', 'column', 'AWO_ATTRIBUTE_ID'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart Created Datetime: system date and time when this record was created in the mart.', 'schema', 'dbo', 'table', 'B_VEHICLE_ATTRIBUTES', 'column', 'MART_CREATED_DTM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart Modified Datetime: system date and time when this record was last modified in the mart.', 'schema', 'dbo', 'table', 'B_VEHICLE_ATTRIBUTES', 'column', 'MART_MODIFIED_DTM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Bridge table to maintian 1 to many relationship between vehicle and vehicle attributes', 'schema', 'dbo', 'table', 'B_VEHICLE_ATTRIBUTES'
	
	PRINT '[INFO] CREATED TABLE [DBO].[B_VEHICLE_ATTRIBUTES]'
END
GO

--INDEX: B_VEHICLE_ATTRIBUTES_VEHICLE_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_VEHICLE_ATTRIBUTES]','U') AND i.name = 'B_VEHICLE_ATTRIBUTES_VEHICLE_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_VEHICLE_ATTRIBUTES_VEHICLE_KEY_IX] ON [dbo].[B_VEHICLE_ATTRIBUTES](D_VEHICLE_KEY) ON CO_HF_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_VEHICLE_ATTRIBUTES].[B_VEHICLE_ATTRIBUTES_VEHICLE_KEY_IX]'
END
GO

--INDEX: B_VEHICLE_ATTRIBUTES_SOURCE_ID_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_VEHICLE_ATTRIBUTES]','U') AND i.name = 'B_VEHICLE_ATTRIBUTES_SOURCE_ID_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_VEHICLE_ATTRIBUTES_SOURCE_ID_IX] ON [dbo].[B_VEHICLE_ATTRIBUTES](AWO_VEHICLE_ID, AWO_ATTRIBUTE_ID) ON CO_HF_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_VEHICLE_ATTRIBUTES].[B_VEHICLE_ATTRIBUTES_SOURCE_ID_IX]'
END
GO

/**
 *	AUTHOR:		Kelvin Wang (kelvin.wang@activenetwork.com)
 *	NOTES:		Hunt quota bridge
 *  DATE       JIRA      AUTHOR       DESCRIPTION
 *  ---------- --------  ----------   --------------------------------
 *  07/04/2018  DMA-2955  Kelvin Wang  Initial
 *	03/04/2018	DMA-2937  Zongpei Liu  Added index: B_VEHICLE_COONWER_VEHICLE_ID_IX
**/

SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL READ COMMITTED

IF OBJECT_ID('[dbo].[B_VEHICLE_COOWNER]') IS NULL
BEGIN
CREATE TABLE [dbo].[B_VEHICLE_COOWNER](
    [B_VEHICLE_COOWNER_KEY]   int            IDENTITY(1,1),
    [D_VEHICLE_KEY]           int            NULL,
    [COOWNER_STATUS_NM]       varchar(50)    NULL,
    [COOWNER_CONJUNCTION_NM]  varchar(50)    NULL,
    [COOWNER_FIRST_NM]        varchar(28)    NULL,
    [COOWNER_MIDDLE_NM]       varchar(28)    NULL,
    [COOWNER_LAST_NM]         varchar(28)    NULL,
    [COOWNER_SUFFIX_TXT]      varchar(10)    NULL,
    [COOWNER_BIRTH_DT]        datetime       NULL,
    [COOWNER_CREATE_DTM]      datetime       NULL,
    [COOWNER_UPDATE_DTM]      datetime       NULL,
    [COOWNER_CREATE_USER_ID]  int            NULL,
    [COOWNER_UPDATE_USER_ID]  int            NULL,
    [AWO_IDENTIFIER_ID]       int            NULL,
    [AWO_VEHICLE_ID]          int            NULL,
    [AWO_ID]                  int            NULL,
    [CUR_REC_IND]             smallint       NULL,
    [DELETED_IND]             smallint       NULL,
    [MART_CREATED_DTM]        datetime       NULL,
    [MART_MODIFIED_DTM]       datetime       NULL
	CONSTRAINT [PK_B_VEHICLE_COOWNER] PRIMARY KEY CLUSTERED ([B_VEHICLE_COOWNER_KEY])
)ON [CO_HF_MART_DATA]
	
exec sys.sp_addextendedproperty 'MS_Description', 'Surrogate key used to identify the vehicle and vehicle co-owner relationship within the data mart.', 'schema', 'dbo', 'table', 'B_VEHICLE_COOWNER', 'column', 'B_VEHICLE_COOWNER_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Surrogate key used to uniquely identify a vehicle dimension record. - NOT FOR EXTERNAL USE -', 'schema', 'dbo', 'table', 'B_VEHICLE_COOWNER', 'column', 'D_VEHICLE_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Vehicle coowner status name.', 'schema', 'dbo', 'table', 'B_VEHICLE_COOWNER', 'column', 'COOWNER_STATUS_NM'
exec sys.sp_addextendedproperty 'MS_Description', 'Vehicle coowner conjunction name.', 'schema', 'dbo', 'table', 'B_VEHICLE_COOWNER', 'column', 'COOWNER_CONJUNCTION_NM'
exec sys.sp_addextendedproperty 'MS_Description', 'Vehicle coowner first name.', 'schema', 'dbo', 'table', 'B_VEHICLE_COOWNER', 'column', 'COOWNER_FIRST_NM'
exec sys.sp_addextendedproperty 'MS_Description', 'Vehicle coowner middle name.', 'schema', 'dbo', 'table', 'B_VEHICLE_COOWNER', 'column', 'COOWNER_MIDDLE_NM'
exec sys.sp_addextendedproperty 'MS_Description', 'Vehicle coowner last name.', 'schema', 'dbo', 'table', 'B_VEHICLE_COOWNER', 'column', 'COOWNER_LAST_NM'
exec sys.sp_addextendedproperty 'MS_Description', 'Vehicle coowner suffix text.', 'schema', 'dbo', 'table', 'B_VEHICLE_COOWNER', 'column', 'COOWNER_SUFFIX_TXT'
exec sys.sp_addextendedproperty 'MS_Description', 'Vehicle coowner birth date.', 'schema', 'dbo', 'table', 'B_VEHICLE_COOWNER', 'column', 'COOWNER_BIRTH_DT'
exec sys.sp_addextendedproperty 'MS_Description', 'Vehicle coowner create datetime.', 'schema', 'dbo', 'table', 'B_VEHICLE_COOWNER', 'column', 'COOWNER_CREATE_DTM'
exec sys.sp_addextendedproperty 'MS_Description', 'Vehicle coowner update datetime.', 'schema', 'dbo', 'table', 'B_VEHICLE_COOWNER', 'column', 'COOWNER_UPDATE_DTM'
exec sys.sp_addextendedproperty 'MS_Description', 'Mart source ID of GLOBAL.D_USER_AUTH.', 'schema', 'dbo', 'table', 'B_VEHICLE_COOWNER', 'column', 'COOWNER_CREATE_USER_ID'
exec sys.sp_addextendedproperty 'MS_Description', 'Mart source ID of GLOBAL.D_USER_AUTH.', 'schema', 'dbo', 'table', 'B_VEHICLE_COOWNER', 'column', 'COOWNER_UPDATE_USER_ID'
exec sys.sp_addextendedproperty 'MS_Description', 'Mart source ID of C_IDENTIFIER.', 'schema', 'dbo', 'table', 'B_VEHICLE_COOWNER', 'column', 'AWO_IDENTIFIER_ID'
exec sys.sp_addextendedproperty 'MS_Description', 'Mart source ID of E_VEHICLE.', 'schema', 'dbo', 'table', 'B_VEHICLE_COOWNER', 'column', 'AWO_VEHICLE_ID'
exec sys.sp_addextendedproperty 'MS_Description', 'Mart source ID of E_VEHICLE_COOWNER.', 'schema', 'dbo', 'table', 'B_VEHICLE_COOWNER', 'column', 'AWO_ID'
exec sys.sp_addextendedproperty 'MS_Description', 'Indicator identifying whether or not the bridge record is current.', 'schema', 'dbo', 'table', 'B_VEHICLE_COOWNER', 'column', 'CUR_REC_IND'
exec sys.sp_addextendedproperty 'MS_Description', 'Indicates whether or not the record has been soft deleted. 1=Deleted, 0=Active', 'schema', 'dbo', 'table', 'B_VEHICLE_COOWNER', 'column', 'DELETED_IND'
exec sys.sp_addextendedproperty 'MS_Description', 'Date the record was created within the datamart.', 'schema', 'dbo', 'table', 'B_VEHICLE_COOWNER', 'column', 'MART_CREATED_DTM'
exec sys.sp_addextendedproperty 'MS_Description', 'Date the record was last updated within the datamart.', 'schema', 'dbo', 'table', 'B_VEHICLE_COOWNER', 'column', 'MART_MODIFIED_DTM'
exec sys.sp_addextendedproperty 'MS_Description', 'Vehicle co-owner bridge table.', 'schema', 'dbo', 'table', 'B_VEHICLE_COOWNER'

IF OBJECT_ID('dbo.B_VEHICLE_COOWNER') IS NOT NULL
    PRINT '<<< CREATED TABLE dbo.B_VEHICLE_COOWNER >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE dbo.B_VEHICLE_COOWNER >>>'
END


/* 
 * INDEX: [B_VEHICLE_COONWER_AWO_ID_IX] 
 */
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id=OBJECT_ID('dbo.B_VEHICLE_COOWNER') AND name='B_VEHICLE_COONWER_AWO_ID_IX')
BEGIN
	CREATE NONCLUSTERED INDEX [B_VEHICLE_COONWER_AWO_ID_IX] ON [dbo].[B_VEHICLE_COOWNER]([AWO_ID], [CUR_REC_IND])
	WITH (PAD_INDEX= OFF,STATISTICS_NORECOMPUTE =OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING= OFF, MAXDOP=0, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS= ON)
	ON CO_HF_MART_IDX
	PRINT '<<< CREATED INDEX dbo.B_VEHICLE_COOWNER.B_VEHICLE_COONWER_AWO_ID_IX >>>'
END

/* 
 * INDEX: [B_VEHICLE_COONWER_VEHICLE_KEY_IX] 
 */
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id=OBJECT_ID('dbo.B_VEHICLE_COOWNER') AND name='B_VEHICLE_COONWER_VEHICLE_KEY_IX')
BEGIN
	CREATE NONCLUSTERED INDEX [B_VEHICLE_COONWER_VEHICLE_KEY_IX] ON [dbo].[B_VEHICLE_COOWNER]([D_VEHICLE_KEY])
	WITH (PAD_INDEX= OFF,STATISTICS_NORECOMPUTE =OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING= OFF, MAXDOP=0, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS= ON)
	ON CO_HF_MART_IDX
	PRINT '<<< CREATED INDEX dbo.B_VEHICLE_COOWNER.B_VEHICLE_COONWER_VEHICLE_KEY_IX >>>'
END

/* 
 * INDEX: [B_VEHICLE_COONWER_IDENTIFIER_ID_IX] 
 */
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id=OBJECT_ID('dbo.B_VEHICLE_COOWNER') AND name='B_VEHICLE_COONWER_IDENTIFIER_ID_IX')
BEGIN
	CREATE NONCLUSTERED INDEX [B_VEHICLE_COONWER_IDENTIFIER_ID_IX] ON [dbo].[B_VEHICLE_COOWNER]([AWO_IDENTIFIER_ID])
	WITH (PAD_INDEX= OFF,STATISTICS_NORECOMPUTE =OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING= OFF, MAXDOP=0, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS= ON)
	ON CO_HF_MART_IDX
	PRINT '<<< CREATED INDEX dbo.B_VEHICLE_COOWNER.B_VEHICLE_COONWER_IDENTIFIER_ID_IX >>>'
END

/* 
 * INDEX: [B_VEHICLE_COONWER_VEHICLE_ID_IX] 
 */
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id=OBJECT_ID('dbo.B_VEHICLE_COOWNER') AND name='B_VEHICLE_COONWER_VEHICLE_ID_IX')
BEGIN
	CREATE NONCLUSTERED INDEX [B_VEHICLE_COONWER_VEHICLE_ID_IX] ON [dbo].[B_VEHICLE_COOWNER]([AWO_VEHICLE_ID])
	WITH (PAD_INDEX= OFF,STATISTICS_NORECOMPUTE =OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING= OFF, MAXDOP=0, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS= ON)
	ON CO_HF_MART_IDX
	PRINT '<<< CREATED INDEX dbo.B_VEHICLE_COOWNER.B_VEHICLE_COONWER_VEHICLE_ID_IX >>>'
END

SET NOCOUNT OFF


/**
 *	AUTHOR:		Kelvin Wang (kelvin.wang@activenetwork.com)
 *	NOTES:		Hunt quota bridge
 *  DATE       JIRA      AUTHOR       DESCRIPTION
 *  ---------- --------  ----------   --------------------------------
 *  02/15/2019  DMA-3267  Kelvin Wang  Initial
 *	03/04/2018	DMA-2937  Zongpei Liu  Added index: B_VEHICLE_OWNERSHIP_CUSTOMER_PROFILE_VEHICLE_ID_IX
**/

SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL READ COMMITTED

IF OBJECT_ID('[dbo].[B_VEHICLE_OWNERSHIP]') IS NULL
BEGIN
CREATE TABLE [dbo].[B_VEHICLE_OWNERSHIP](
    [B_VEHICLE_OWNERSHIP_KEY]   int            IDENTITY(1,1),
    [D_VEHICLE_KEY]             int            NULL,
    [D_CUSTOMER_PROFILE_KEY]    int            NULL,
    [OWNERSHIP_STATUS_NM]       varchar(50)    NULL,
    [OWNERSHIP_CREATE_DTM]      datetime       NULL,
    [OWNERSHIP_UPDATE_DTM]      datetime       NULL,
    [OWNERSHIP_CREATE_USER_ID]  int            NULL,
    [OWNERSHIP_UPDATE_USER_ID]  int            NULL,
    [AWO_VEHICLE_ID]            int            NULL,
    [AWO_CUSTOMER_PROFILE_ID]   int            NULL,
    [AWO_ID]                    int            NULL,
    [CUR_REC_IND]               smallint       NULL,
    [DELETED_IND]               smallint       NULL,
    [MART_CREATED_DTM]          datetime       NULL,
    [MART_MODIFIED_DTM]         datetime       NULL
	CONSTRAINT [PK_B_VEHICLE_OWNERSHIP] PRIMARY KEY CLUSTERED ([B_VEHICLE_OWNERSHIP_KEY])
)ON [CO_HF_MART_DATA]
	
	exec sys.sp_addextendedproperty 'MS_Description', 'Surrogate key used to identify the vehicle and vehicle co-owner relationship within the data mart.', 'schema', 'dbo', 'table', 'B_VEHICLE_OWNERSHIP', 'column', 'B_VEHICLE_OWNERSHIP_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Surrogate key used to uniquely identify a vehicle dimension record. - NOT FOR EXTERNAL USE -', 'schema', 'dbo', 'table', 'B_VEHICLE_OWNERSHIP', 'column', 'D_VEHICLE_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Surrogate key used to uniquely identify a customer hf profile dimension record. - NOT FOR EXTERNAL USE -', 'schema', 'dbo', 'table', 'B_VEHICLE_OWNERSHIP', 'column', 'D_CUSTOMER_PROFILE_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Vehicle ownership status name.', 'schema', 'dbo', 'table', 'B_VEHICLE_OWNERSHIP', 'column', 'OWNERSHIP_STATUS_NM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Vehicle ownership create datetime.', 'schema', 'dbo', 'table', 'B_VEHICLE_OWNERSHIP', 'column', 'OWNERSHIP_CREATE_DTM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Vehicle ownership update datetime.', 'schema', 'dbo', 'table', 'B_VEHICLE_OWNERSHIP', 'column', 'OWNERSHIP_UPDATE_DTM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart source ID of GLOBAL.D_USER_AUTH.', 'schema', 'dbo', 'table', 'B_VEHICLE_OWNERSHIP', 'column', 'OWNERSHIP_CREATE_USER_ID'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart source ID of GLOBAL.D_USER_AUTH.', 'schema', 'dbo', 'table', 'B_VEHICLE_OWNERSHIP', 'column', 'OWNERSHIP_UPDATE_USER_ID'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart source ID of E_VEHICLE.', 'schema', 'dbo', 'table', 'B_VEHICLE_OWNERSHIP', 'column', 'AWO_VEHICLE_ID'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart source ID of C_CUST_HFPROFILE.', 'schema', 'dbo', 'table', 'B_VEHICLE_OWNERSHIP', 'column', 'AWO_CUSTOMER_PROFILE_ID'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart source ID of E_VEHICLE_OWNER.', 'schema', 'dbo', 'table', 'B_VEHICLE_OWNERSHIP', 'column', 'AWO_ID'
	exec sys.sp_addextendedproperty 'MS_Description', 'Indicator identifying whether or not the bridge record is current.', 'schema', 'dbo', 'table', 'B_VEHICLE_OWNERSHIP', 'column', 'CUR_REC_IND'
	exec sys.sp_addextendedproperty 'MS_Description', 'Indicates whether or not the record has been soft deleted. 1=Deleted, 0=Active', 'schema', 'dbo', 'table', 'B_VEHICLE_OWNERSHIP', 'column', 'DELETED_IND'
	exec sys.sp_addextendedproperty 'MS_Description', 'Date the record was created within the datamart.', 'schema', 'dbo', 'table', 'B_VEHICLE_OWNERSHIP', 'column', 'MART_CREATED_DTM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Date the record was last updated within the datamart.', 'schema', 'dbo', 'table', 'B_VEHICLE_OWNERSHIP', 'column', 'MART_MODIFIED_DTM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Bridge table to maintian 1 to many relationship between vehicle and vehicle owner.', 'schema', 'dbo', 'table', 'B_VEHICLE_OWNERSHIP'

IF OBJECT_ID('dbo.B_VEHICLE_OWNERSHIP') IS NOT NULL
    PRINT '<<< CREATED TABLE dbo.B_VEHICLE_OWNERSHIP >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE dbo.B_VEHICLE_OWNERSHIP >>>'
END


/* 
 * INDEX: [B_VEHICLE_OWNERSHIP_AWO_ID_IX] 
 */
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id=OBJECT_ID('dbo.B_VEHICLE_OWNERSHIP') AND name='B_VEHICLE_OWNERSHIP_AWO_ID_IX')
BEGIN
	CREATE NONCLUSTERED INDEX [B_VEHICLE_OWNERSHIP_AWO_ID_IX] ON [dbo].[B_VEHICLE_OWNERSHIP]([AWO_ID], [CUR_REC_IND])
	WITH (PAD_INDEX= OFF,STATISTICS_NORECOMPUTE =OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING= OFF, MAXDOP=0, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS= ON)
	ON CO_HF_MART_IDX
	PRINT '<<< CREATED INDEX dbo.B_VEHICLE_OWNERSHIP.B_VEHICLE_OWNERSHIP_AWO_ID_IX >>>'
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id=OBJECT_ID('dbo.B_VEHICLE_OWNERSHIP') AND name='B_VEHICLE_OWNERSHIP_VEHICLE_KEY_IX')
BEGIN
	CREATE NONCLUSTERED INDEX [B_VEHICLE_OWNERSHIP_VEHICLE_KEY_IX] ON [dbo].[B_VEHICLE_OWNERSHIP]([D_VEHICLE_KEY])
	WITH (PAD_INDEX= OFF,STATISTICS_NORECOMPUTE =OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING= OFF, MAXDOP=0, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS= ON)
	ON CO_HF_MART_IDX
	PRINT '<<< CREATED INDEX dbo.B_VEHICLE_OWNERSHIP.B_VEHICLE_OWNERSHIP_VEHICLE_KEY_IX >>>'
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id=OBJECT_ID('dbo.B_VEHICLE_OWNERSHIP') AND name='B_VEHICLE_OWNERSHIP_CUSTOMER_PROFILE_KEY_IX')
BEGIN
	CREATE NONCLUSTERED INDEX [B_VEHICLE_OWNERSHIP_CUSTOMER_PROFILE_KEY_IX] ON [dbo].[B_VEHICLE_OWNERSHIP]([D_CUSTOMER_PROFILE_KEY])
	WITH (PAD_INDEX= OFF,STATISTICS_NORECOMPUTE =OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING= OFF, MAXDOP=0, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS= ON)
	ON CO_HF_MART_IDX
	PRINT '<<< CREATED INDEX dbo.B_VEHICLE_OWNERSHIP.B_VEHICLE_OWNERSHIP_CUSTOMER_PROFILE_KEY_IX >>>'
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id=OBJECT_ID('dbo.B_VEHICLE_OWNERSHIP') AND name='B_VEHICLE_OWNERSHIP_CUSTOMER_PROFILE_VEHICLE_ID_IX')
BEGIN
	CREATE NONCLUSTERED INDEX [B_VEHICLE_OWNERSHIP_CUSTOMER_PROFILE_VEHICLE_ID_IX] ON [dbo].[B_VEHICLE_OWNERSHIP](AWO_VEHICLE_ID,AWO_CUSTOMER_PROFILE_ID,CUR_REC_IND)
	WITH (PAD_INDEX= OFF,STATISTICS_NORECOMPUTE =OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING= OFF, MAXDOP=0, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS= ON)
	ON CO_HF_MART_IDX
	PRINT '<<< CREATED INDEX dbo.B_VEHICLE_OWNERSHIP.B_VEHICLE_OWNERSHIP_CUSTOMER_PROFILE_VEHICLE_ID_IX >>>'
END

SET NOCOUNT OFF

/*
 * NOTES: Creates B_VEHICLE_DUPLICATE_ORDER dimension for AspiraOne datamart 
 *
 * DATE        JIRA      USER             DESCRIPTION
 * ----------  --------  ---------------  ---------------------------------------
 * 04/17/2019  DMA-3744  Zongpei Liu	  Initialization.
*/

SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL READ COMMITTED

IF OBJECT_ID('DBO.B_VEHICLE_DUPLICATE_ORDER') IS NULL
BEGIN
	CREATE TABLE DBO.B_VEHICLE_DUPLICATE_ORDER(
		B_VEHICLE_DUPLICATE_ORDER_KEY    int               IDENTITY(1,1),
		ORIGINAL_ORDER_ID                int               NULL,
		ORIGINAL_ORDER_NB                varchar(255)      NULL,
		ORIGINAL_ORDER_TYPE_NM           varchar(255)      NULL,
		ORIGINAL_ORDER_STATUS_NM         VARCHAR(255)      NULL,
		DUPLICATE_ORDER_ID               int               NULL,
		DUPLICATE_ORDER_NB               varchar(255)      NULL,
		DUPLICATE_ORDER_TYPE_NM          varchar(255)      NULL,
		DUPLICATE_ORDER_DTM              datetime          NULL,
		DUPLICATE_ORDER_PRICE_AMT        numeric(38, 6)    NULL,
		DUPLICATE_ORDER_BALANCE_AMT      numeric(38, 6)    NULL,
		DUPLICATE_ORDER_ITEM_STATUS_NM   VARCHAR(255)      NULL,
		DUPLICATE_LOCATION_KEY           int               NULL,
		DUPLICATE_USER_KEY               int               NULL,
		DUPLICATE_ORDER_JC_IND           smallint          NULL,
		AWO_DUPLICATE_LOCATION_ID        int               NULL,
		AWO_DUPLICATE_USER_ID            int               NULL,
		MART_CREATED_DTM                 datetime          NULL,
		MART_MODIFIED_DTM                datetime          NULL,
		CONSTRAINT PK_B_VEHICLE_DUPLICATE_ORDER PRIMARY KEY CLUSTERED (B_VEHICLE_DUPLICATE_ORDER_KEY)
	) ON CO_HF_MART_DATA

	exec sys.sp_addextendedproperty 'MS_Description', 'Surrogate key used to identify the vehicle and its duplicate orders within the data mart.', 'schema', 'dbo', 'table', 'B_VEHICLE_DUPLICATE_ORDER', 'column', 'B_VEHICLE_DUPLICATE_ORDER_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Identifier for an original order record in AO.', 'schema', 'dbo', 'table', 'B_VEHICLE_DUPLICATE_ORDER', 'column', 'ORIGINAL_ORDER_ID'
	exec sys.sp_addextendedproperty 'MS_Description', 'Original order number.', 'schema', 'dbo', 'table', 'B_VEHICLE_DUPLICATE_ORDER', 'column', 'ORIGINAL_ORDER_NB'
	exec sys.sp_addextendedproperty 'MS_Description', 'Original order type, like (registration/title)', 'schema', 'dbo', 'table', 'B_VEHICLE_DUPLICATE_ORDER', 'column', 'ORIGINAL_ORDER_TYPE_NM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Original order status name.', 'schema', 'dbo', 'table', 'B_VEHICLE_DUPLICATE_ORDER', 'column', 'ORIGINAL_ORDER_STATUS_NM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Identifier for a duplicate order record in AO.', 'schema', 'dbo', 'table', 'B_VEHICLE_DUPLICATE_ORDER', 'column', 'DUPLICATE_ORDER_ID'
	exec sys.sp_addextendedproperty 'MS_Description', 'Duplicate order number.', 'schema', 'dbo', 'table', 'B_VEHICLE_DUPLICATE_ORDER', 'column', 'DUPLICATE_ORDER_NB'
	exec sys.sp_addextendedproperty 'MS_Description', 'Duplicate order type, like (Duplicate Registration / Duplicate Title)', 'schema', 'dbo', 'table', 'B_VEHICLE_DUPLICATE_ORDER', 'column', 'DUPLICATE_ORDER_TYPE_NM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Duplicate order date.', 'schema', 'dbo', 'table', 'B_VEHICLE_DUPLICATE_ORDER', 'column', 'DUPLICATE_ORDER_DTM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Duplicate order price amount.', 'schema', 'dbo', 'table', 'B_VEHICLE_DUPLICATE_ORDER', 'column', 'DUPLICATE_ORDER_PRICE_AMT'
	exec sys.sp_addextendedproperty 'MS_Description', 'Duplicate order balance.', 'schema', 'dbo', 'table', 'B_VEHICLE_DUPLICATE_ORDER', 'column', 'DUPLICATE_ORDER_BALANCE_AMT'
	exec sys.sp_addextendedproperty 'MS_Description', 'Duplicate order item status name.', 'schema', 'dbo', 'table', 'B_VEHICLE_DUPLICATE_ORDER', 'column', 'DUPLICATE_ORDER_ITEM_STATUS_NM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Surrogate key used to identify the location record within the data mart.', 'schema', 'dbo', 'table', 'B_VEHICLE_DUPLICATE_ORDER', 'column', 'DUPLICATE_LOCATION_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Surrogate key used to uniquely identify a user dimension record.', 'schema', 'dbo', 'table', 'B_VEHICLE_DUPLICATE_ORDER', 'column', 'DUPLICATE_USER_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Duplicate order JC indictor.', 'schema', 'dbo', 'table', 'B_VEHICLE_DUPLICATE_ORDER', 'column', 'DUPLICATE_ORDER_JC_IND'
	exec sys.sp_addextendedproperty 'MS_Description', 'Identifier for a location record in AO.', 'schema', 'dbo', 'table', 'B_VEHICLE_DUPLICATE_ORDER', 'column', 'AWO_DUPLICATE_LOCATION_ID'
	exec sys.sp_addextendedproperty 'MS_Description', 'Identifier for an user record in AO.', 'schema', 'dbo', 'table', 'B_VEHICLE_DUPLICATE_ORDER', 'column', 'AWO_DUPLICATE_USER_ID'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart Created Datetime: system date and time when this record was created in the mart.', 'schema', 'dbo', 'table', 'B_VEHICLE_DUPLICATE_ORDER', 'column', 'MART_CREATED_DTM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart Modified Datetime: system date and time when this record was last modified in the mart.', 'schema', 'dbo', 'table', 'B_VEHICLE_DUPLICATE_ORDER', 'column', 'MART_MODIFIED_DTM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Bridge table to maintian 1 to many relationship between vehicle and its duplicate orders.', 'schema', 'dbo', 'table', 'B_VEHICLE_DUPLICATE_ORDER'

	PRINT '[INFO] CREATED TABLE [DBO].[B_VEHICLE_DUPLICATE_ORDER]'
END
GO
	
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_VEHICLE_DUPLICATE_ORDER]','U') AND i.name = 'B_VEHICLE_ORIGINAL_ORDER_ID_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_VEHICLE_ORIGINAL_ORDER_ID_IX] ON [dbo].[B_VEHICLE_DUPLICATE_ORDER](ORIGINAL_ORDER_ID) ON CO_HF_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_VEHICLE_DUPLICATE_ORDER].[B_VEHICLE_ORIGINAL_ORDER_ID_IX]'
END
GO

IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_VEHICLE_DUPLICATE_ORDER]','U') AND i.name = 'B_VEHICLE_DUPLICATE_ORDER_ID_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_VEHICLE_DUPLICATE_ORDER_ID_IX] ON [dbo].[B_VEHICLE_DUPLICATE_ORDER](DUPLICATE_ORDER_ID) ON CO_HF_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_VEHICLE_DUPLICATE_ORDER].[B_VEHICLE_DUPLICATE_ORDER_ID_IX]'
END
GO

IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_VEHICLE_DUPLICATE_ORDER]','U') AND i.name = 'B_VEHICLE_DUPLICATE_ORDER_DUP_LOCATION_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_VEHICLE_DUPLICATE_ORDER_DUP_LOCATION_KEY_IX] ON [dbo].[B_VEHICLE_DUPLICATE_ORDER](DUPLICATE_LOCATION_KEY) ON CO_HF_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_VEHICLE_DUPLICATE_ORDER].[B_VEHICLE_DUPLICATE_ORDER_DUP_LOCATION_KEY_IX]'
END
GO

IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_VEHICLE_DUPLICATE_ORDER]','U') AND i.name = 'B_VEHICLE_DUPLICATE_ORDER_DUP_USER_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_VEHICLE_DUPLICATE_ORDER_DUP_USER_KEY_IX] ON [dbo].[B_VEHICLE_DUPLICATE_ORDER](DUPLICATE_USER_KEY) ON CO_HF_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_VEHICLE_DUPLICATE_ORDER].[B_VEHICLE_DUPLICATE_ORDER_DUP_USER_KEY_IX]'
END
GO

IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_VEHICLE_DUPLICATE_ORDER]','U') AND i.name = 'B_VEHICLE_DUPLICATE_ORDER_AWO_LOC_ID_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_VEHICLE_DUPLICATE_ORDER_AWO_LOC_ID_IX] ON [dbo].[B_VEHICLE_DUPLICATE_ORDER](AWO_DUPLICATE_LOCATION_ID) ON CO_HF_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_VEHICLE_DUPLICATE_ORDER].[B_VEHICLE_DUPLICATE_ORDER_AWO_LOC_ID_IX]'
END
GO

IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_VEHICLE_DUPLICATE_ORDER]','U') AND i.name = 'B_VEHICLE_DUPLICATE_ORDER_AWO_DUP_USER_ID_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_VEHICLE_DUPLICATE_ORDER_AWO_DUP_USER_ID_IX] ON [dbo].[B_VEHICLE_DUPLICATE_ORDER](AWO_DUPLICATE_USER_ID) ON CO_HF_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_VEHICLE_DUPLICATE_ORDER].[B_VEHICLE_DUPLICATE_ORDER_AWO_DUP_USER_ID_IX]'
END
GO

IF EXISTS(select * from sysobjects a,syscolumns b,systypes c where a.id=b.id and a.name='D_ADDRESS' and a.xtype='U' and b.name = 'ADDRESS_LINE_1' and b.xtype=c.xtype and c.name = 'varchar' and b.length = 512)
BEGIN
	ALTER TABLE D_ADDRESS ALTER COLUMN [ADDRESS_LINE_1] VARCHAR(3000)
	PRINT '[INFO] ALTER TABLE D_ADDRESS ALTER COLUMN [ADDRESS_LINE_1] TO VARCHAR(3000)'
END

IF EXISTS(select * from sysobjects a,syscolumns b,systypes c where a.id=b.id and a.name='D_ADDRESS' and a.xtype='U' and b.name = 'CITY_NAME' and b.xtype=c.xtype and c.name = 'varchar' and b.length = 255)
BEGIN
	ALTER TABLE D_ADDRESS ALTER COLUMN [CITY_NAME] VARCHAR(512)
	PRINT '[INFO] ALTER TABLE D_ADDRESS ALTER COLUMN [CITY_NAME] TO VARCHAR(512)'
END


IF EXISTS(select * from information_schema.columns where table_name = 'D_CUSTOMER_PROFILE' and column_name = 'SOLICITATION_IND' and data_type = 'smallint')
BEGIN
	ALTER TABLE D_CUSTOMER_PROFILE ALTER COLUMN SOLICITATION_IND bit NULL
	PRINT '[INFO] ALTER COLUMN [DBO].[D_CUSTOMER_PROFILE].[SOLICITATION_IND] TO bit'
END


/*--DMA-3032: Add computed column [YR_TXT]*/
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.columns c WHERE c.object_id = object_id('[dbo].[D_DT]','U') AND c.name = 'YR_TXT' )
BEGIN
    ALTER TABLE [dbo].[D_DT] ADD 
		[YR_TXT]            AS CONVERT(VARCHAR(4),YR_NB)
	PRINT '[INFO] ADDED COMPUTED COLUMN [dbo].[D_DT].[YR_TXT]'
END

/*--DMA-3032: Add computed column [FISCAL_YEAR_TXT]*/
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.columns c WHERE c.object_id = object_id('[dbo].[D_DT]','U') AND c.name = 'FISCAL_YEAR_TXT' )
BEGIN
    ALTER TABLE [dbo].[D_DT] ADD 
		[FISCAL_YEAR_TXT]                     AS CONVERT(VARCHAR(4),AWO_FISCAL_YR)
	PRINT '[INFO] ADDED COMPUTED COLUMN [dbo].[D_DT].[FISCAL_YEAR_TXT]'
END


IF NOT EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_LOCATION') AND name='STATION_NM')
BEGIN
	ALTER TABLE D_LOCATION ADD STATION_NM VARCHAR(255) NULL
	exec sys.sp_addextendedproperty 'MS_Description', 'Station name.', 'schema', 'dbo', 'table', 'D_LOCATION', 'column', 'STATION_NM'
	PRINT '[INFO] ADD COLUMN [DBO].[D_LOCATION].[STATION_NM]'
END

IF NOT EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_LOCATION') AND name='AREA_NM')
BEGIN
	ALTER TABLE D_LOCATION ADD AREA_NM VARCHAR(255) NULL
	exec sys.sp_addextendedproperty 'MS_Description', 'Area name', 'schema', 'dbo', 'table', 'D_LOCATION', 'column', 'AREA_NM'
	PRINT '[INFO] ADD COLUMN [DBO].[D_LOCATION].[AREA_NM]'
END

IF NOT EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_LOCATION') AND name='LOCATION_NM')
BEGIN
	ALTER TABLE D_LOCATION ADD LOCATION_NM VARCHAR(255) NULL
	exec sys.sp_addextendedproperty 'MS_Description', 'Location name.', 'schema', 'dbo', 'table', 'D_LOCATION', 'column', 'LOCATION_NM'
	PRINT '[INFO] ADD COLUMN [DBO].[D_LOCATION].[LOCATION_NM]'
END

IF NOT EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_LOCATION') AND name='CATEGORY_NM')
BEGIN
	ALTER TABLE D_LOCATION ADD CATEGORY_NM VARCHAR(255) NULL
	exec sys.sp_addextendedproperty 'MS_Description', 'Category name.', 'schema', 'dbo', 'table', 'D_LOCATION', 'column', 'CATEGORY_NM'
	PRINT '[INFO] ADD COLUMN [DBO].[D_LOCATION].[CATEGORY_NM]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_LOCATION') AND name='LOOP_NM')
BEGIN
	ALTER TABLE D_LOCATION DROP COLUMN LOOP_NM
	PRINT '[INFO] DROPPRED COLUMN [DBO].[D_LOCATION].[LOOP_NM]'
END


/*
 * NOTES: Creates D_PURCHASE_TYPE dimension for AspiraOne datamart 
 *
 * DATE        JIRA      USER             DESCRIPTION
 * ----------  --------  ---------------  ---------------------------------------
 * 05/20/2019  DMA-3996  Zongpei Liu	  Initialization.
*/

SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL READ COMMITTED

IF OBJECT_ID('DBO.D_PURCHASE_TYPE') IS NULL
BEGIN
	CREATE TABLE DBO.D_PURCHASE_TYPE(
		D_PURCHASE_TYPE_KEY    int             IDENTITY(1,1),
		PURCHASE_TYPE_NM       varchar(255)    NULL,
		DELETED_IND            smallint        NULL,
		CUR_REC_IND            smallint        NULL,
		AWO_ID                 int             NULL,
		MART_CREATED_DTM       datetime        NULL,
		MART_MODIFIED_DTM      datetime        NULL,
		CONSTRAINT PK_D_PURCHASE_TYPE PRIMARY KEY CLUSTERED (D_PURCHASE_TYPE_KEY)
	) ON CO_HF_MART_DATA

	exec sys.sp_addextendedproperty 'MS_Description', 'Surrogate key used to identify a purchase type record within the data mart.', 'schema', 'dbo', 'table', 'D_PURCHASE_TYPE', 'column', 'D_PURCHASE_TYPE_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'The description of pruchase type.', 'schema', 'dbo', 'table', 'D_PURCHASE_TYPE', 'column', 'PURCHASE_TYPE_NM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Deleted Indicator: 1 if this record has been deleted in the source system, otherwise 0.', 'schema', 'dbo', 'table', 'D_PURCHASE_TYPE', 'column', 'DELETED_IND'
	exec sys.sp_addextendedproperty 'MS_Description', 'Indicator identifying whether or not the dimension record is current.', 'schema', 'dbo', 'table', 'D_PURCHASE_TYPE', 'column', 'CUR_REC_IND'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart Source Identifier: source system identifier for this record.', 'schema', 'dbo', 'table', 'D_PURCHASE_TYPE', 'column', 'AWO_ID'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart Created Datetime: system date and time when this record was created in the mart.', 'schema', 'dbo', 'table', 'D_PURCHASE_TYPE', 'column', 'MART_CREATED_DTM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart Modified Datetime: system date and time when this record was last modified in the mart.', 'schema', 'dbo', 'table', 'D_PURCHASE_TYPE', 'column', 'MART_MODIFIED_DTM'

	PRINT '[INFO] CREATED TABLE [DBO].[D_PURCHASE_TYPE]'
END
GO

IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[D_PURCHASE_TYPE]','U') AND i.name = 'D_PURCHASE_TYPE_MART_SOURCE_ID_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [D_PURCHASE_TYPE_MART_SOURCE_ID_IX] ON [dbo].[D_PURCHASE_TYPE]([AWO_ID]) ON CO_HF_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[D_PURCHASE_TYPE].[D_PURCHASE_TYPE_MART_SOURCE_ID_IX]'
END
GO

/**
 *	AUTHOR:		Kelvin Wang (kelvin.wang@activenetwork.com)
 *	NOTES:		Hunt quota bridge
 *  DATE       JIRA      AUTHOR       DESCRIPTION
 *  ---------- --------  ----------   --------------------------------
 *  2/22/2019  DMA-3268  Kelvin Wang  Initial
 *  4/30/2019  DMA-3945  Kelvin Wang  DMA-3945 update D_STOLEN_VEHICLE.CUR_REC_IND D_STOLEN_VEHICLE.DELETED_IND to bit type per Skye's request.
**/

SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL READ COMMITTED

IF OBJECT_ID('[dbo].[D_STOLEN_VEHICLE]') IS NULL
BEGIN
CREATE TABLE [dbo].[D_STOLEN_VEHICLE](
    [D_STOLEN_VEHICLE_KEY]              int             IDENTITY(1,1),
    [D_STOLEN_VEHICLE_FILE_KEY]         int             NULL,
    [VEHICLE_NB]                        varchar(56)     NULL,
    [VEHICLE_HULL_ID]                   varchar(128)    NULL,
    [VEHICLE_MAKE_NM]                   varchar(255)    NULL,
    [VEHICLE_MODEL_YEAR_NB]             int             NULL,
    [VEHICLE_MODEL_YEAR_TXT]            varchar(8)      NULL, 
    [VEHICLE_REGISTRATION_STATE_NM]     varchar(50)     NULL,
    [VEHICLE_EXPIRATIN_YEAR_NB]         int             NULL,
    [VEHICLE_EXPIRATIN_YEAR_TXT]        varchar(8)      NULL, 
    [VEHICLE_OWNER_NM]                  varchar(128)    NULL,
    [VEHICLE_THEFT_DT]                  date            NULL,
    [VEHICLE_REPORT_THEFT_AGENCY_NM]    varchar(128)    NULL,
    [VEHICLE_OWNER_APPLIED_NUMBER_TXT]  varchar(256)    NULL,
    [VEHICLE_COAST_GUARD_NUMBER_TXT]    varchar(256)    NULL,
    [VEHICLE_BOAT_TYPE_TXT]             varchar(256)    NULL,
    [VEHICLE_BOAT_LENGTH_TXT]           varchar(256)    NULL,
    [VEHICLE_BOAT_MODEL_TXT]            varchar(256)    NULL,
    [VEHICLE_PROPULSION_TXT]            varchar(256)    NULL,
    [VEHICLE_HULL_TXT]                  varchar(256)    NULL,
    [VEHICLE_HULL_SHAP_TXT]             varchar(256)    NULL,
    [VEHICLE_HOME_PORT_TXT]             varchar(256)    NULL,
    [VEHICLE_BOAT_NAME_TXT]             varchar(256)    NULL,
    [VEHICLE_COLOR_TXT]                 varchar(256)    NULL,
    [AWO_VEHICLE_ID]                    int             NULL,
    [AWO_STOLEN_VEHICLE_FILE_ID]        int             NULL,
    [AWO_ID]                            int             NULL,
    [CUR_REC_IND]                       bit             NULL,
    [DELETED_IND]                       bit             NULL,
    [MART_CREATED_DTM]                  datetime        NULL,
    [MART_MODIFIED_DTM]                 datetime        NULL
	CONSTRAINT [PK_D_STOLEN_VEHICLE] PRIMARY KEY CLUSTERED ([D_STOLEN_VEHICLE_KEY])
)ON [CO_HF_MART_DATA]
	
exec sys.sp_addextendedproperty 'MS_Description', 'Surrogate key used to uniquely identify a stolen vehicle dimension record.', 'schema', 'dbo', 'table', 'D_STOLEN_VEHICLE', 'column', 'D_STOLEN_VEHICLE_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Surrogate key used to uniquely identify a stolen vehicle file dimension record.', 'schema', 'dbo', 'table', 'D_STOLEN_VEHICLE', 'column', 'D_STOLEN_VEHICLE_FILE_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Stolen vehicle number.', 'schema', 'dbo', 'table', 'D_STOLEN_VEHICLE', 'column', 'VEHICLE_NB'
exec sys.sp_addextendedproperty 'MS_Description', 'Stolen vehicle Hull ID.', 'schema', 'dbo', 'table', 'D_STOLEN_VEHICLE', 'column', 'VEHICLE_HULL_ID'
exec sys.sp_addextendedproperty 'MS_Description', 'Stolen vehicle make name.', 'schema', 'dbo', 'table', 'D_STOLEN_VEHICLE', 'column', 'VEHICLE_MAKE_NM'
exec sys.sp_addextendedproperty 'MS_Description', 'Stolen vehicle model year number.', 'schema', 'dbo', 'table', 'D_STOLEN_VEHICLE', 'column', 'VEHICLE_MODEL_YEAR_NB'
exec sys.sp_addextendedproperty 'MS_Description', 'Text value of stolen vehicle model year number.', 'schema', 'dbo', 'table', 'D_STOLEN_VEHICLE', 'column', 'VEHICLE_MODEL_YEAR_TXT'
exec sys.sp_addextendedproperty 'MS_Description', 'Stolen vehicle registration state name.', 'schema', 'dbo', 'table', 'D_STOLEN_VEHICLE', 'column', 'VEHICLE_REGISTRATION_STATE_NM'
exec sys.sp_addextendedproperty 'MS_Description', 'Stolen vehicle epiration year number.', 'schema', 'dbo', 'table', 'D_STOLEN_VEHICLE', 'column', 'VEHICLE_EXPIRATIN_YEAR_NB'
exec sys.sp_addextendedproperty 'MS_Description', 'Text value of stolen vehicle epiration year number.', 'schema', 'dbo', 'table', 'D_STOLEN_VEHICLE', 'column', 'VEHICLE_EXPIRATIN_YEAR_TXT'
exec sys.sp_addextendedproperty 'MS_Description', 'Stolen vehicle owner name.', 'schema', 'dbo', 'table', 'D_STOLEN_VEHICLE', 'column', 'VEHICLE_OWNER_NM'
exec sys.sp_addextendedproperty 'MS_Description', 'Stolen vehicle theft date.', 'schema', 'dbo', 'table', 'D_STOLEN_VEHICLE', 'column', 'VEHICLE_THEFT_DT'
exec sys.sp_addextendedproperty 'MS_Description', 'Stolen vehicle report theft agency name.', 'schema', 'dbo', 'table', 'D_STOLEN_VEHICLE', 'column', 'VEHICLE_REPORT_THEFT_AGENCY_NM'
exec sys.sp_addextendedproperty 'MS_Description', 'Stolen vehicle owner applied number.', 'schema', 'dbo', 'table', 'D_STOLEN_VEHICLE', 'column', 'VEHICLE_OWNER_APPLIED_NUMBER_TXT'
exec sys.sp_addextendedproperty 'MS_Description', 'Stolen vehicle coast guard number.', 'schema', 'dbo', 'table', 'D_STOLEN_VEHICLE', 'column', 'VEHICLE_COAST_GUARD_NUMBER_TXT'
exec sys.sp_addextendedproperty 'MS_Description', 'Stolen vehicle boat type.', 'schema', 'dbo', 'table', 'D_STOLEN_VEHICLE', 'column', 'VEHICLE_BOAT_TYPE_TXT'
exec sys.sp_addextendedproperty 'MS_Description', 'Stolen vehicle boat length.', 'schema', 'dbo', 'table', 'D_STOLEN_VEHICLE', 'column', 'VEHICLE_BOAT_LENGTH_TXT'
exec sys.sp_addextendedproperty 'MS_Description', 'Stolen vehicle boat model.', 'schema', 'dbo', 'table', 'D_STOLEN_VEHICLE', 'column', 'VEHICLE_BOAT_MODEL_TXT'
exec sys.sp_addextendedproperty 'MS_Description', 'Stolen vehicle propulsion.', 'schema', 'dbo', 'table', 'D_STOLEN_VEHICLE', 'column', 'VEHICLE_PROPULSION_TXT'
exec sys.sp_addextendedproperty 'MS_Description', 'Stolen vehicle hull ID.', 'schema', 'dbo', 'table', 'D_STOLEN_VEHICLE', 'column', 'VEHICLE_HULL_TXT'
exec sys.sp_addextendedproperty 'MS_Description', 'Stolen vehicle hull shap.', 'schema', 'dbo', 'table', 'D_STOLEN_VEHICLE', 'column', 'VEHICLE_HULL_SHAP_TXT'
exec sys.sp_addextendedproperty 'MS_Description', 'Stolen vehicle home port.', 'schema', 'dbo', 'table', 'D_STOLEN_VEHICLE', 'column', 'VEHICLE_HOME_PORT_TXT'
exec sys.sp_addextendedproperty 'MS_Description', 'Stolen vehicle boat name.', 'schema', 'dbo', 'table', 'D_STOLEN_VEHICLE', 'column', 'VEHICLE_BOAT_NAME_TXT'
exec sys.sp_addextendedproperty 'MS_Description', 'Stolen vehicle color.', 'schema', 'dbo', 'table', 'D_STOLEN_VEHICLE', 'column', 'VEHICLE_COLOR_TXT'
exec sys.sp_addextendedproperty 'MS_Description', 'Mart source ID of E_VEHICLE.', 'schema', 'dbo', 'table', 'D_STOLEN_VEHICLE', 'column', 'AWO_VEHICLE_ID'
exec sys.sp_addextendedproperty 'MS_Description', 'Mart source ID of X_EXTERNAL_DATA_FILE.', 'schema', 'dbo', 'table', 'D_STOLEN_VEHICLE', 'column', 'AWO_STOLEN_VEHICLE_FILE_ID'
exec sys.sp_addextendedproperty 'MS_Description', 'Mart source ID of E_VEHICLE_OWNER.', 'schema', 'dbo', 'table', 'D_STOLEN_VEHICLE', 'column', 'AWO_ID'
exec sys.sp_addextendedproperty 'MS_Description', 'Indicator identifying whether or not the bridge record is current.', 'schema', 'dbo', 'table', 'D_STOLEN_VEHICLE', 'column', 'CUR_REC_IND'
exec sys.sp_addextendedproperty 'MS_Description', 'Indicates whether or not the record has been soft deleted. 1=Deleted, 0=Active', 'schema', 'dbo', 'table', 'D_STOLEN_VEHICLE', 'column', 'DELETED_IND'
exec sys.sp_addextendedproperty 'MS_Description', 'Date the record was created within the datamart.', 'schema', 'dbo', 'table', 'D_STOLEN_VEHICLE', 'column', 'MART_CREATED_DTM'
exec sys.sp_addextendedproperty 'MS_Description', 'Date the record was last updated within the datamart.', 'schema', 'dbo', 'table', 'D_STOLEN_VEHICLE', 'column', 'MART_MODIFIED_DTM'
exec sys.sp_addextendedproperty 'MS_Description', 'Stolen vehicle dimension.', 'schema', 'dbo', 'table', 'D_STOLEN_VEHICLE'

IF OBJECT_ID('dbo.D_STOLEN_VEHICLE') IS NOT NULL
    PRINT '<<< CREATED TABLE dbo.D_STOLEN_VEHICLE >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE dbo.D_STOLEN_VEHICLE >>>'
END


/* 
 * INDEX: [D_STOLEN_VEHICLE_AWO_ID_IX] 
 */
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id=OBJECT_ID('dbo.D_STOLEN_VEHICLE') AND name='D_STOLEN_VEHICLE_AWO_ID_IX')
BEGIN
	CREATE NONCLUSTERED INDEX [D_STOLEN_VEHICLE_AWO_ID_IX] ON [dbo].[D_STOLEN_VEHICLE]([AWO_ID], [CUR_REC_IND])
	WITH (PAD_INDEX= OFF,STATISTICS_NORECOMPUTE =OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING= OFF, MAXDOP=0, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS= ON)
	ON CO_HF_MART_IDX
	PRINT '<<< CREATED INDEX dbo.D_STOLEN_VEHICLE.D_STOLEN_VEHICLE_AWO_ID_IX >>>'
END

/* 
 * INDEX: [D_STOLEN_VEHICLE_D_STOLEN_VEHICLE_FILE_KEY_IX] 
 */
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id=OBJECT_ID('dbo.D_STOLEN_VEHICLE') AND name='D_STOLEN_VEHICLE_D_STOLEN_VEHICLE_FILE_KEY_IX')
BEGIN
	CREATE NONCLUSTERED INDEX [D_STOLEN_VEHICLE_D_STOLEN_VEHICLE_FILE_KEY_IX] ON [dbo].[D_STOLEN_VEHICLE]([D_STOLEN_VEHICLE_FILE_KEY])
	WITH (PAD_INDEX= OFF,STATISTICS_NORECOMPUTE =OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING= OFF, MAXDOP=0, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS= ON)
	ON CO_HF_MART_IDX
	PRINT '<<< CREATED INDEX dbo.D_STOLEN_VEHICLE.D_STOLEN_VEHICLE_D_STOLEN_VEHICLE_FILE_KEY_IX >>>'
END

/* 
 * INDEX: [D_STOLEN_VEHICLE_AWO_VEHICLE_ID_IX] 
 */
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id=OBJECT_ID('dbo.D_STOLEN_VEHICLE') AND name='D_STOLEN_VEHICLE_AWO_VEHICLE_ID_IX')
BEGIN
	CREATE NONCLUSTERED INDEX [D_STOLEN_VEHICLE_AWO_VEHICLE_ID_IX] ON [dbo].[D_STOLEN_VEHICLE]([AWO_VEHICLE_ID])
	WITH (PAD_INDEX= OFF,STATISTICS_NORECOMPUTE =OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING= OFF, MAXDOP=0, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS= ON)
	ON CO_HF_MART_IDX
	PRINT '<<< CREATED INDEX dbo.D_STOLEN_VEHICLE.D_STOLEN_VEHICLE_AWO_VEHICLE_ID_IX >>>'
END

/* 
 * INDEX: [D_STOLEN_VEHICLE_AWO_STOLEN_VEHICLE_FILE_ID] 
 */
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id=OBJECT_ID('dbo.D_STOLEN_VEHICLE') AND name='D_STOLEN_VEHICLE_AWO_STOLEN_VEHICLE_FILE_ID')
BEGIN
	CREATE NONCLUSTERED INDEX [D_STOLEN_VEHICLE_AWO_STOLEN_VEHICLE_FILE_ID] ON [dbo].[D_STOLEN_VEHICLE]([AWO_STOLEN_VEHICLE_FILE_ID])
	WITH (PAD_INDEX= OFF,STATISTICS_NORECOMPUTE =OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING= OFF, MAXDOP=0, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS= ON)
	ON CO_HF_MART_IDX
	PRINT '<<< CREATED INDEX dbo.D_STOLEN_VEHICLE.D_STOLEN_VEHICLE_AWO_STOLEN_VEHICLE_FILE_ID >>>'
END

SET NOCOUNT OFF


/**
 *	AUTHOR:		Kelvin Wang (kelvin.wang@activenetwork.com)
 *	NOTES:		Hunt quota bridge
 *  DATE       JIRA      AUTHOR       DESCRIPTION
 *  ---------- --------  ----------   --------------------------------
 *  2/22/2019  DMA-3268  Kelvin Wang  Initial
**/

SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL READ COMMITTED

IF OBJECT_ID('[dbo].[D_STOLEN_VEHICLE_FILE]') IS NULL
BEGIN
CREATE TABLE [dbo].[D_STOLEN_VEHICLE_FILE](
    [D_STOLEN_VEHICLE_FILE_KEY]  int              IDENTITY(1,1),
    [FILE_STATUS_NM]             varchar(50)      NULL,
    [FILE_IMPORT_START_DTM]      datetime         NULL,
    [FILE_IMPORT_END_DTM]        datetime         NULL,
    [FILE_NM]                    varchar(1000)    NULL,
    [FILE_CREATED_LOCATION_NM]   varchar(255)     NULL,
    [FILE_CREATED_USER_NM]       varchar(50)      NULL,
    [FILE_RECORDS_CNT]           int              NULL,
    [FILE_MATCHED_RECORDS_CNT]   int              NULL,
    [AWO_ID]                     int              NULL,
    [CUR_REC_IND]                smallint         NULL,
    [DELETED_IND]                smallint         NULL,
    [MART_CREATED_DTM]           datetime         NULL,
    [MART_MODIFIED_DTM]          datetime         NULL
	CONSTRAINT [PK_D_STOLEN_VEHICLE_FILE] PRIMARY KEY CLUSTERED ([D_STOLEN_VEHICLE_FILE_KEY])
)ON [CO_HF_MART_DATA]
	
exec sys.sp_addextendedproperty 'MS_Description', 'Surrogate key used to uniquely identify a stolen vehicle file dimension record.', 'schema', 'dbo', 'table', 'D_STOLEN_VEHICLE_FILE', 'column', 'D_STOLEN_VEHICLE_FILE_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Stolen vehicle file import status name.', 'schema', 'dbo', 'table', 'D_STOLEN_VEHICLE_FILE', 'column', 'FILE_STATUS_NM'
exec sys.sp_addextendedproperty 'MS_Description', 'Stolen vehicle file import start datetime.', 'schema', 'dbo', 'table', 'D_STOLEN_VEHICLE_FILE', 'column', 'FILE_IMPORT_START_DTM'
exec sys.sp_addextendedproperty 'MS_Description', 'Stolen vehicle file import end datetime.', 'schema', 'dbo', 'table', 'D_STOLEN_VEHICLE_FILE', 'column', 'FILE_IMPORT_END_DTM'
exec sys.sp_addextendedproperty 'MS_Description', 'Stolen vehicle file name.', 'schema', 'dbo', 'table', 'D_STOLEN_VEHICLE_FILE', 'column', 'FILE_NM'
exec sys.sp_addextendedproperty 'MS_Description', 'Stolen vehicle file process created location name.', 'schema', 'dbo', 'table', 'D_STOLEN_VEHICLE_FILE', 'column', 'FILE_CREATED_LOCATION_NM'
exec sys.sp_addextendedproperty 'MS_Description', 'Stolen vehicle file process created user name.', 'schema', 'dbo', 'table', 'D_STOLEN_VEHICLE_FILE', 'column', 'FILE_CREATED_USER_NM'
exec sys.sp_addextendedproperty 'MS_Description', 'Records count in stolen vehicle file.', 'schema', 'dbo', 'table', 'D_STOLEN_VEHICLE_FILE', 'column', 'FILE_RECORDS_CNT'
exec sys.sp_addextendedproperty 'MS_Description', 'Matched records count in stolen vehicle file.', 'schema', 'dbo', 'table', 'D_STOLEN_VEHICLE_FILE', 'column', 'FILE_MATCHED_RECORDS_CNT'
exec sys.sp_addextendedproperty 'MS_Description', 'Mart source ID of E_VEHICLE_OWNER.', 'schema', 'dbo', 'table', 'D_STOLEN_VEHICLE_FILE', 'column', 'AWO_ID'
exec sys.sp_addextendedproperty 'MS_Description', 'Indicator identifying whether or not the bridge record is current.', 'schema', 'dbo', 'table', 'D_STOLEN_VEHICLE_FILE', 'column', 'CUR_REC_IND'
exec sys.sp_addextendedproperty 'MS_Description', 'Indicates whether or not the record has been soft deleted. 1=Deleted, 0=Active', 'schema', 'dbo', 'table', 'D_STOLEN_VEHICLE_FILE', 'column', 'DELETED_IND'
exec sys.sp_addextendedproperty 'MS_Description', 'Date the record was created within the datamart.', 'schema', 'dbo', 'table', 'D_STOLEN_VEHICLE_FILE', 'column', 'MART_CREATED_DTM'
exec sys.sp_addextendedproperty 'MS_Description', 'Date the record was last updated within the datamart.', 'schema', 'dbo', 'table', 'D_STOLEN_VEHICLE_FILE', 'column', 'MART_MODIFIED_DTM'
exec sys.sp_addextendedproperty 'MS_Description', 'Stolen vehicle file dimension.', 'schema', 'dbo', 'table', 'D_STOLEN_VEHICLE_FILE'

IF OBJECT_ID('dbo.D_STOLEN_VEHICLE_FILE') IS NOT NULL
    PRINT '<<< CREATED TABLE dbo.D_STOLEN_VEHICLE_FILE >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE dbo.D_STOLEN_VEHICLE_FILE >>>'
END


/* 
 * INDEX: [D_STOLEN_VEHICLE_FILE_AWO_ID_IX] 
 */
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id=OBJECT_ID('dbo.D_STOLEN_VEHICLE_FILE') AND name='D_STOLEN_VEHICLE_FILE_AWO_ID_IX')
BEGIN
	CREATE NONCLUSTERED INDEX [D_STOLEN_VEHICLE_FILE_AWO_ID_IX] ON [dbo].[D_STOLEN_VEHICLE_FILE]([AWO_ID], [CUR_REC_IND])
	WITH (PAD_INDEX= OFF,STATISTICS_NORECOMPUTE =OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING= OFF, MAXDOP=0, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS= ON)
	ON CO_HF_MART_IDX
	PRINT '<<< CREATED INDEX dbo.D_STOLEN_VEHICLE_FILE.D_STOLEN_VEHICLE_FILE_AWO_ID_IX >>>'
END

SET NOCOUNT OFF


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_VEHICLE') AND name='PARENT_VEHICLE_SERIAL_ID')
BEGIN
	ALTER TABLE D_VEHICLE DROP COLUMN PARENT_VEHICLE_SERIAL_ID 
	PRINT '[INFO] DROPPED COLUMN [DBO].[D_VEHICLE].[PARENT_VEHICLE_SERIAL_ID]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_VEHICLE') AND name='PARENT_VEHICLE_PLATE_ID')
BEGIN
	ALTER TABLE D_VEHICLE DROP COLUMN PARENT_VEHICLE_PLATE_ID 
	PRINT '[INFO] DROPPED COLUMN [DBO].[D_VEHICLE].[PARENT_VEHICLE_PLATE_ID]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_VEHICLE') AND name='PARENT_VEHICLE_TYPE_NM')
BEGIN
	ALTER TABLE D_VEHICLE DROP COLUMN PARENT_VEHICLE_TYPE_NM 
	PRINT '[INFO] DROPPED COLUMN [DBO].[D_VEHICLE].[PARENT_VEHICLE_TYPE_NM]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_VEHICLE') AND name='PARENT_VEHICLE_STATUS_DSC')
BEGIN
	ALTER TABLE D_VEHICLE DROP COLUMN PARENT_VEHICLE_STATUS_DSC 
	PRINT '[INFO] DROPPED COLUMN [DBO].[D_VEHICLE].[PARENT_VEHICLE_STATUS_DSC]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_VEHICLE') AND name='PARENT_MANUFACTURER_CD')
BEGIN
	ALTER TABLE D_VEHICLE DROP COLUMN PARENT_MANUFACTURER_CD 
	PRINT '[INFO] DROPPED COLUMN [DBO].[D_VEHICLE].[PARENT_MANUFACTURER_CD]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_VEHICLE') AND name='PARENT_MANUFACTURER_NM')
BEGIN
	ALTER TABLE D_VEHICLE DROP COLUMN PARENT_MANUFACTURER_NM 
	PRINT '[INFO] DROPPED COLUMN [DBO].[D_VEHICLE].[PARENT_MANUFACTURER_NM]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_VEHICLE') AND name='PARENT_MODEL_YR')
BEGIN
	ALTER TABLE D_VEHICLE DROP COLUMN PARENT_MODEL_YR 
	PRINT '[INFO] DROPPED COLUMN [DBO].[D_VEHICLE].[PARENT_MODEL_YR]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_VEHICLE') AND name='PARENT_BUILT_YR')
BEGIN
	ALTER TABLE D_VEHICLE DROP COLUMN PARENT_BUILT_YR 
	PRINT '[INFO] DROPPED COLUMN [DBO].[D_VEHICLE].[PARENT_BUILT_YR]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_VEHICLE') AND name='PARENT_HORSEPOWER_NB')
BEGIN
	ALTER TABLE D_VEHICLE DROP COLUMN PARENT_HORSEPOWER_NB 
	PRINT '[INFO] DROPPED COLUMN [DBO].[D_VEHICLE].[PARENT_HORSEPOWER_NB]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_VEHICLE') AND name='PARENT_HULL_TYPE_DSC')
BEGIN
	ALTER TABLE D_VEHICLE DROP COLUMN PARENT_HULL_TYPE_DSC 
	PRINT '[INFO] DROPPED COLUMN [DBO].[D_VEHICLE].[PARENT_HULL_TYPE_DSC]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_VEHICLE') AND name='PARENT_LENGTH_NB')
BEGIN
	ALTER TABLE D_VEHICLE DROP COLUMN PARENT_LENGTH_NB 
	PRINT '[INFO] DROPPED COLUMN [DBO].[D_VEHICLE].[PARENT_LENGTH_NB]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_VEHICLE') AND name='PARENT_USE_TYPE_DSC')
BEGIN
	ALTER TABLE D_VEHICLE DROP COLUMN PARENT_USE_TYPE_DSC 
	PRINT '[INFO] DROPPED COLUMN [DBO].[D_VEHICLE].[PARENT_USE_TYPE_DSC]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_VEHICLE') AND name='PARENT_BOAT_TYPE_DSC')
BEGIN
	ALTER TABLE D_VEHICLE DROP COLUMN PARENT_BOAT_TYPE_DSC 
	PRINT '[INFO] DROPPED COLUMN [DBO].[D_VEHICLE].[PARENT_BOAT_TYPE_DSC]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_VEHICLE') AND name='PARENT_DRIVETRAIN_DSC')
BEGIN
	ALTER TABLE D_VEHICLE DROP COLUMN PARENT_DRIVETRAIN_DSC 
	PRINT '[INFO] DROPPED COLUMN [DBO].[D_VEHICLE].[PARENT_DRIVETRAIN_DSC]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_VEHICLE') AND name='PARENT_FUEL_DSC')
BEGIN
	ALTER TABLE D_VEHICLE DROP COLUMN PARENT_FUEL_DSC 
	PRINT '[INFO] DROPPED COLUMN [DBO].[D_VEHICLE].[PARENT_FUEL_DSC]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_VEHICLE') AND name='COOWNER_CUSTOMER_NB')
BEGIN
	ALTER TABLE D_VEHICLE DROP COLUMN COOWNER_CUSTOMER_NB 
	PRINT '[INFO] DROPPED COLUMN [DBO].[D_VEHICLE].[COOWNER_CUSTOMER_NB]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_VEHICLE') AND name='COOWNER_NAME_SALUTATION_TXT')
BEGIN
	ALTER TABLE D_VEHICLE DROP COLUMN COOWNER_NAME_SALUTATION_TXT 
	PRINT '[INFO] DROPPED COLUMN [DBO].[D_VEHICLE].[COOWNER_NAME_SALUTATION_TXT]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_VEHICLE') AND name='COOWNER_FIRST_NM')
BEGIN
	ALTER TABLE D_VEHICLE DROP COLUMN COOWNER_FIRST_NM 
	PRINT '[INFO] DROPPED COLUMN [DBO].[D_VEHICLE].[COOWNER_FIRST_NM]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_VEHICLE') AND name='COOWNER_MIDDLE_NM')
BEGIN
	ALTER TABLE D_VEHICLE DROP COLUMN COOWNER_MIDDLE_NM 
	PRINT '[INFO] DROPPED COLUMN [DBO].[D_VEHICLE].[COOWNER_MIDDLE_NM]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_VEHICLE') AND name='COOWNER_LAST_NM')
BEGIN
	ALTER TABLE D_VEHICLE DROP COLUMN COOWNER_LAST_NM 
	PRINT '[INFO] DROPPED COLUMN [DBO].[D_VEHICLE].[COOWNER_LAST_NM]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_VEHICLE') AND name='COOWNER_NAME_SUFFIX_TXT')
BEGIN
	ALTER TABLE D_VEHICLE DROP COLUMN COOWNER_NAME_SUFFIX_TXT 
	PRINT '[INFO] DROPPED COLUMN [DBO].[D_VEHICLE].[COOWNER_NAME_SUFFIX_TXT]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_VEHICLE') AND name='COOWNER_SALES_CATEGORY_NM')
BEGIN
	ALTER TABLE D_VEHICLE DROP COLUMN COOWNER_SALES_CATEGORY_NM 
	PRINT '[INFO] DROPPED COLUMN [DBO].[D_VEHICLE].[COOWNER_SALES_CATEGORY_NM]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_VEHICLE') AND name='COOWNER_CUSTOMER_CLASS_NM')
BEGIN
	ALTER TABLE D_VEHICLE DROP COLUMN COOWNER_CUSTOMER_CLASS_NM 
	PRINT '[INFO] DROPPED COLUMN [DBO].[D_VEHICLE].[COOWNER_CUSTOMER_CLASS_NM]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_VEHICLE') AND name='COOWNER_HOME_PHONE_NB_TXT')
BEGIN
	ALTER TABLE D_VEHICLE DROP COLUMN COOWNER_HOME_PHONE_NB_TXT 
	PRINT '[INFO] DROPPED COLUMN [DBO].[D_VEHICLE].[COOWNER_HOME_PHONE_NB_TXT]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_VEHICLE') AND name='COOWNER_WORK_PHONE_NB_TXT')
BEGIN
	ALTER TABLE D_VEHICLE DROP COLUMN COOWNER_WORK_PHONE_NB_TXT 
	PRINT '[INFO] DROPPED COLUMN [DBO].[D_VEHICLE].[COOWNER_WORK_PHONE_NB_TXT]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_VEHICLE') AND name='COOWNER_MOBILE_PHONE_NB_TXT')
BEGIN
	ALTER TABLE D_VEHICLE DROP COLUMN COOWNER_MOBILE_PHONE_NB_TXT 
	PRINT '[INFO] DROPPED COLUMN [DBO].[D_VEHICLE].[COOWNER_MOBILE_PHONE_NB_TXT]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_VEHICLE') AND name='COOWNER_FAX_NB_TXT')
BEGIN
	ALTER TABLE D_VEHICLE DROP COLUMN COOWNER_FAX_NB_TXT 
	PRINT '[INFO] DROPPED COLUMN [DBO].[D_VEHICLE].[COOWNER_FAX_NB_TXT]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_VEHICLE') AND name='COOWNER_EMAIL_ADR')
BEGIN
	ALTER TABLE D_VEHICLE DROP COLUMN COOWNER_EMAIL_ADR 
	PRINT '[INFO] DROPPED COLUMN [DBO].[D_VEHICLE].[COOWNER_EMAIL_ADR]'
END



IF EXISTS(SELECT * FROM sys.indexes WHERE object_id=OBJECT_ID('DBO.D_VEHICLE') AND name='D_VEHICLE_COWN_PHY_ADDR_KEY_IX')
BEGIN
	DROP INDEX D_VEHICLE_COWN_PHY_ADDR_KEY_IX ON DBO.D_VEHICLE
	PRINT '[INFO] DROPPED INDEX [DBO].[D_VEHICLE].[D_VEHICLE_COWN_PHY_ADDR_KEY_IX]'	
END

IF EXISTS(SELECT * FROM sys.indexes WHERE object_id=OBJECT_ID('DBO.D_VEHICLE') AND name='D_VEHICLE_COWN_MAIL_ADDR_KEY_IX')
BEGIN
	DROP INDEX D_VEHICLE_COWN_MAIL_ADDR_KEY_IX ON DBO.D_VEHICLE
	PRINT '[INFO] DROPPED INDEX [DBO].[D_VEHICLE].[D_VEHICLE_COWN_MAIL_ADDR_KEY_IX]'	
END



IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_VEHICLE') AND name='COOWNER_PHYS_ADDRESS_KEY')
BEGIN
	ALTER TABLE D_VEHICLE DROP COLUMN COOWNER_PHYS_ADDRESS_KEY 
	PRINT '[INFO] DROPPED COLUMN [DBO].[D_VEHICLE].[COOWNER_PHYS_ADDRESS_KEY]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_VEHICLE') AND name='COOWNER_MAIL_ADDRESS_KEY')
BEGIN
	ALTER TABLE D_VEHICLE DROP COLUMN COOWNER_MAIL_ADDRESS_KEY 
	PRINT '[INFO] DROPPED COLUMN [DBO].[D_VEHICLE].[COOWNER_MAIL_ADDRESS_KEY]'
END

/* DMA-2955 drop parent vehicle and coowner columns begin*/


/* DMA-2955 drop Dropped HULL_TYPE_DSC / LENGTH_NB / USE_TYPE_DSC / BOAT_TYPE_DSC / DRIVETRAIN_DSC / FUEL_DSC add MANUFACTURER_PRINT_NM begin*/
IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_VEHICLE') AND name='HULL_TYPE_DSC')
BEGIN
	ALTER TABLE D_VEHICLE DROP COLUMN HULL_TYPE_DSC 
	PRINT '[INFO] DROPPED COLUMN [DBO].[D_VEHICLE].[HULL_TYPE_DSC]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_VEHICLE') AND name='LENGTH_NB')
BEGIN
	ALTER TABLE D_VEHICLE DROP COLUMN LENGTH_NB 
	PRINT '[INFO] DROPPED COLUMN [DBO].[D_VEHICLE].[LENGTH_NB]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_VEHICLE') AND name='USE_TYPE_DSC')
BEGIN
	ALTER TABLE D_VEHICLE DROP COLUMN USE_TYPE_DSC 
	PRINT '[INFO] DROPPED COLUMN [DBO].[D_VEHICLE].[USE_TYPE_DSC]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_VEHICLE') AND name='BOAT_TYPE_DSC')
BEGIN
	ALTER TABLE D_VEHICLE DROP COLUMN BOAT_TYPE_DSC 
	PRINT '[INFO] DROPPED COLUMN [DBO].[D_VEHICLE].[BOAT_TYPE_DSC]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_VEHICLE') AND name='DRIVETRAIN_DSC')
BEGIN
	ALTER TABLE D_VEHICLE DROP COLUMN DRIVETRAIN_DSC 
	PRINT '[INFO] DROPPED COLUMN [DBO].[D_VEHICLE].[DRIVETRAIN_DSC]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_VEHICLE') AND name='FUEL_DSC')
BEGIN
	ALTER TABLE D_VEHICLE DROP COLUMN FUEL_DSC 
	PRINT '[INFO] DROPPED COLUMN [DBO].[D_VEHICLE].[FUEL_DSC]'
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = N'MANUFACTURER_PRINT_NM' AND OBJECT_ID = OBJECT_ID(N'D_VEHICLE'))
BEGIN
	 ALTER TABLE [dbo].[D_VEHICLE] ADD [MANUFACTURER_PRINT_NM] VARCHAR(56) NULL
	 PRINT '[INFO] ADDED COLUMN [dbo].[D_VEHICLE].[MANUFACTURER_PRINT_NM]'
END

/* DMA-2955 drop Dropped HULL_TYPE_DSC / LENGTH_NB / USE_TYPE_DSC / BOAT_TYPE_DSC / DRIVETRAIN_DSC / FUEL_DSC add MANUFACTURER_PRINT_NM end*/

IF EXISTS(select * from sysobjects a,syscolumns b,systypes c where a.id=b.id and a.name='D_VEHICLE' and a.xtype='U' and b.name = 'MODEL_YR' and b.xtype=c.xtype and c.name = 'int')
BEGIN
	EXEC sp_RENAME 'D_VEHICLE.MODEL_YR', 'MODEL_YEAR_TXT', 'COLUMN'
	ALTER TABLE [D_VEHICLE] ALTER COLUMN [MODEL_YEAR_TXT] varchar(4)
	PRINT '[INFO] UPDATED [DBO].[D_VEHICLE].[MODEL_YEAR_TXT] TO VARCHAR(4)'
END

IF EXISTS(select * from sysobjects a,syscolumns b,systypes c where a.id=b.id and a.name='D_VEHICLE' and a.xtype='U' and b.name = 'BUILT_YR' and b.xtype=c.xtype and c.name = 'int')
BEGIN
	EXEC sp_RENAME 'D_VEHICLE.BUILT_YR', 'BUILT_YEAR_TXT', 'COLUMN'
	ALTER TABLE [D_VEHICLE] ALTER COLUMN [BUILT_YEAR_TXT] varchar(4)
	PRINT '[INFO] UPDATED [DBO].[D_VEHICLE].[BUILT_YEAR_TXT] TO VARCHAR(4)'
END


/*
 * NOTES: Creates D_VEHICLE_RTI_STATUS dimension for AspiraOne datamart 
 *
 * DATE        JIRA      USER             DESCRIPTION
 * ----------  --------  ---------------  ---------------------------------------
 * 02/13/2019  DMA-3269  Zongpei Liu	  Initialization.
*/

SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL READ COMMITTED

IF OBJECT_ID('DBO.D_VEHICLE_RTI_STATUS') IS NULL
BEGIN
	CREATE TABLE DBO.D_VEHICLE_RTI_STATUS(
		D_VEHICLE_RTI_STATUS_KEY    int             IDENTITY(1,1),
		VEHICLE_RTI_STATUS_NM       varchar(255)    NULL,
		CUR_REC_IND                 smallint        NULL,
		DELETED_IND                 smallint        NULL,
		AWO_ID                      int             NULL,
		MART_CREATED_DTM            datetime        NULL,
		MART_MODIFIED_DTM           datetime        NULL,
		CONSTRAINT PK_D_VEHICLE_RTI_STATUS PRIMARY KEY CLUSTERED (D_VEHICLE_RTI_STATUS_KEY)
	) ON CO_HF_MART_DATA

	exec sys.sp_addextendedproperty 'MS_Description', 'Surrogate key used to uniquely identify a vehicle RTI dimension record.', 'schema', 'dbo', 'table', 'D_VEHICLE_RTI_STATUS', 'column', 'D_VEHICLE_RTI_STATUS_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Vehicle RTI status description.', 'schema', 'dbo', 'table', 'D_VEHICLE_RTI_STATUS', 'column', 'VEHICLE_RTI_STATUS_NM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Indicator identifying whether or not the dimension record is current.', 'schema', 'dbo', 'table', 'D_VEHICLE_RTI_STATUS', 'column', 'CUR_REC_IND'
	exec sys.sp_addextendedproperty 'MS_Description', 'Deleted Indicator: 1 if this record has been deleted in the source system, otherwise 0.', 'schema', 'dbo', 'table', 'D_VEHICLE_RTI_STATUS', 'column', 'DELETED_IND'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart Source Identifier: source system identifier for this record.', 'schema', 'dbo', 'table', 'D_VEHICLE_RTI_STATUS', 'column', 'AWO_ID'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart Created Datetime: system date and time when this record was created in the mart.', 'schema', 'dbo', 'table', 'D_VEHICLE_RTI_STATUS', 'column', 'MART_CREATED_DTM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart Modified Datetime: system date and time when this record was last modified in the mart.', 'schema', 'dbo', 'table', 'D_VEHICLE_RTI_STATUS', 'column', 'MART_MODIFIED_DTM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Vehicle RTI status dimension. ', 'schema', 'dbo', 'table', 'D_VEHICLE_RTI_STATUS'

	PRINT '[INFO] CREATED TABLE [DBO].[D_VEHICLE_RTI_STATUS]'
END
GO



/*
 * NOTES: Creates F_VEHICLE_RTI fact for AspiraOne datamart 
 *
 * DATE        JIRA      USER             DESCRIPTION
 * ----------  --------  ---------------  ---------------------------------------
 * 02/13/2019  DMA-3269  Zongpei Liu	  Initialization.
 * 05/20/2019  DMA-3996  Zongpei Liu	  Added D_PURCHASE_TYPE_KEY / STATE_FEE_AMT / TRANSACTION_FEE_AMT / WILDLIFE_EDUCATION_FEE_AMT / SEARCH_RESCUE_FEE_AMT / ORDER_BALANCE_AMT / ORDER_PRICE_AMT / ORDER_PAID_AMT.
*/

SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL READ COMMITTED

IF OBJECT_ID('DBO.F_VEHICLE_RTI') IS NULL
BEGIN
	CREATE TABLE DBO.F_VEHICLE_RTI(
		F_VEHICLE_RTI_KEY                   int               IDENTITY(1,1),
		D_VEHICLE_RTI_STATUS_KEY            int               NULL,
		D_PRODUCT_KEY                       int               NULL,
		D_VEHICLE_KEY                       int               NULL,
		PRODUCT_CUSTOMER_PROFILE_KEY        int               NULL,
		REGISTRATION_EFFECTIVE_DATE_KEY     int               NULL,
		REGISTRATION_EXPIRATION_DATE_KEY    int               NULL,
		RTI_CREATION_DATE_KEY               int               NULL,
		REGISTER_USER_KEY                   int               NULL,
		REGISTER_LOCATION_KEY               int               NULL,
		D_STORE_KEY                         int               NULL,
		ACTIVATE_REG_USER_KEY               int               NULL,
		ACTIVATE_REG_LOCATION_KEY           int               NULL,
		ORDER_ID                            int               NULL,
		ORDER_NB                            varchar(255)      NULL,
		ORDER_BALANCE_AMT                   numeric(38, 6)    NULL,
		ORDER_PRICE_AMT                     numeric(38, 6)    NULL,
		ORDER_PAID_AMT                      numeric(38, 6)    NULL,
		ORDER_ITEM_ID                       int               NULL,
		D_PURCHASE_TYPE_KEY                 int               NULL,
		CREATION_PRICE_AMT                  decimal(38, 6)    NULL,
		REGISTRATION_ID                     int               NULL,
		REGISTRATION_NB                     varchar(128)      NULL,
		TITLE_ID                            int               NULL,
		TITLE_NB                            varchar(128)      NULL,
		DUPLICATES_CNT                      smallint          NULL,
		CORRECTION_CNT                      smallint          NULL,
		FISCAL_YEAR_NB                      smallint          NULL,
		FISCAL_YEAR_TXT                     varchar(4)        NULL,
		REGISTRATION_CNT                    smallint          NULL,
		TITLE_CNT                           smallint          NULL,
		VENDOR_FEE_AMT                      numeric(38, 6)    NULL,
		STATE_FEE_AMT                       numeric(38, 6)    NULL,
		TRANSACTION_FEE_AMT                 numeric(38, 6)    NULL,
		WILDLIFE_EDUCATION_FEE_AMT          numeric(38, 6)    NULL,
		SEARCH_RESCUE_FEE_AMT               numeric(38, 6)    NULL,
		AWO_PRODUCT_ID                      int               NULL,
		AWO_VEHICLE_ID                      int               NULL,
		AWO_CUSTOMER_PROFILE_ID             int               NULL,
		AWO_REGISTER_USER_ID                int               NULL,
		AWO_REGISTER_LOCATION_ID            int               NULL,
		AWO_STORE_ID                        int               NULL,
		AWO_ACTIVATE_REG_USER_ID            int               NULL,
		AWO_ACTIVATE_REG_LOCATION_ID        int               NULL,
		AWO_ID                              int               NULL,
		MART_CREATED_DTM                    datetime          NULL,
		MART_MODIFIED_DTM                   datetime          NULL,
		CONSTRAINT PK_F_VEHICLE_RTI PRIMARY KEY CLUSTERED (F_VEHICLE_RTI_KEY)
	) ON CO_HF_MART_DATA

	exec sys.sp_addextendedproperty 'MS_Description', 'Surrogate key used to uniquely identify a vehicle registration record.', 'schema', 'dbo', 'table', 'F_VEHICLE_RTI', 'column', 'F_VEHICLE_RTI_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Foreign key identifying the RTI status.', 'schema', 'dbo', 'table', 'F_VEHICLE_RTI', 'column', 'D_VEHICLE_RTI_STATUS_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Foreign key identifying the product.', 'schema', 'dbo', 'table', 'F_VEHICLE_RTI', 'column', 'D_PRODUCT_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Foreign key identifying the vehicle.', 'schema', 'dbo', 'table', 'F_VEHICLE_RTI', 'column', 'D_VEHICLE_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Foreign key identifying the customer profile.', 'schema', 'dbo', 'table', 'F_VEHICLE_RTI', 'column', 'PRODUCT_CUSTOMER_PROFILE_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Foreign key identifying the effective date of the registration. YYYYMMDD.', 'schema', 'dbo', 'table', 'F_VEHICLE_RTI', 'column', 'REGISTRATION_EFFECTIVE_DATE_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Foreign key identifying the expiration date of the registration. YYYYMMDD.', 'schema', 'dbo', 'table', 'F_VEHICLE_RTI', 'column', 'REGISTRATION_EXPIRATION_DATE_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Surrogate key identifying a date record, formatted as YYYYMMDD.', 'schema', 'dbo', 'table', 'F_VEHICLE_RTI', 'column', 'RTI_CREATION_DATE_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Surrogate key used to uniquely identify a user dimension record.', 'schema', 'dbo', 'table', 'F_VEHICLE_RTI', 'column', 'REGISTER_USER_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Surrogate key used to identify the location record within the data mart.', 'schema', 'dbo', 'table', 'F_VEHICLE_RTI', 'column', 'REGISTER_LOCATION_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Surrogate key used to identify the store record within the data mart.', 'schema', 'dbo', 'table', 'F_VEHICLE_RTI', 'column', 'D_STORE_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Surrogate key used to uniquely identify a user dimension record.', 'schema', 'dbo', 'table', 'F_VEHICLE_RTI', 'column', 'ACTIVATE_REG_USER_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Surrogate key used to identify the location record within the data mart.', 'schema', 'dbo', 'table', 'F_VEHICLE_RTI', 'column', 'ACTIVATE_REG_LOCATION_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Order number of this RTI.', 'schema', 'dbo', 'table', 'F_VEHICLE_RTI', 'column', 'ORDER_NB'
	exec sys.sp_addextendedproperty 'MS_Description', 'Order balance.', 'schema', 'dbo', 'table', 'F_VEHICLE_RTI', 'column', 'ORDER_BALANCE_AMT'
	exec sys.sp_addextendedproperty 'MS_Description', 'Order price.', 'schema', 'dbo', 'table', 'F_VEHICLE_RTI', 'column', 'ORDER_PRICE_AMT'
	exec sys.sp_addextendedproperty 'MS_Description', 'Order paid amount.', 'schema', 'dbo', 'table', 'F_VEHICLE_RTI', 'column', 'ORDER_PAID_AMT'
	exec sys.sp_addextendedproperty 'MS_Description', 'Creation order item id.', 'schema', 'dbo', 'table', 'F_VEHICLE_RTI', 'column', 'ORDER_ITEM_ID'
	exec sys.sp_addextendedproperty 'MS_Description', 'Surrogate key used to identify a purchase type record within the data mart.', 'schema', 'dbo', 'table', 'F_VEHICLE_RTI', 'column', 'D_PURCHASE_TYPE_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Creation price.', 'schema', 'dbo', 'table', 'F_VEHICLE_RTI', 'column', 'CREATION_PRICE_AMT'
	exec sys.sp_addextendedproperty 'MS_Description', 'Registration ID.', 'schema', 'dbo', 'table', 'F_VEHICLE_RTI', 'column', 'REGISTRATION_ID'
	exec sys.sp_addextendedproperty 'MS_Description', 'Registration number.', 'schema', 'dbo', 'table', 'F_VEHICLE_RTI', 'column', 'REGISTRATION_NB'
	exec sys.sp_addextendedproperty 'MS_Description', 'Title ID.', 'schema', 'dbo', 'table', 'F_VEHICLE_RTI', 'column', 'TITLE_ID'
	exec sys.sp_addextendedproperty 'MS_Description', 'Title number.', 'schema', 'dbo', 'table', 'F_VEHICLE_RTI', 'column', 'TITLE_NB'
	exec sys.sp_addextendedproperty 'MS_Description', 'Count of duplicates.', 'schema', 'dbo', 'table', 'F_VEHICLE_RTI', 'column', 'DUPLICATES_CNT'
	exec sys.sp_addextendedproperty 'MS_Description', 'Count of correction.', 'schema', 'dbo', 'table', 'F_VEHICLE_RTI', 'column', 'CORRECTION_CNT'
	exec sys.sp_addextendedproperty 'MS_Description', 'Fiscal year.', 'schema', 'dbo', 'table', 'F_VEHICLE_RTI', 'column', 'FISCAL_YEAR_NB'
	exec sys.sp_addextendedproperty 'MS_Description', 'Text value of fiscal year(Jaspersoft using).', 'schema', 'dbo', 'table', 'F_VEHICLE_RTI', 'column', 'FISCAL_YEAR_TXT'
	exec sys.sp_addextendedproperty 'MS_Description', '1 for registration record, else 0.', 'schema', 'dbo', 'table', 'F_VEHICLE_RTI', 'column', 'REGISTRATION_CNT'
	exec sys.sp_addextendedproperty 'MS_Description', '1 for title record, else 0.', 'schema', 'dbo', 'table', 'F_VEHICLE_RTI', 'column', 'TITLE_CNT'
	exec sys.sp_addextendedproperty 'MS_Description', 'Vendor fee.', 'schema', 'dbo', 'table', 'F_VEHICLE_RTI', 'column', 'VENDOR_FEE_AMT'
	exec sys.sp_addextendedproperty 'MS_Description', 'State fee.', 'schema', 'dbo', 'table', 'F_VEHICLE_RTI', 'column', 'STATE_FEE_AMT'
	exec sys.sp_addextendedproperty 'MS_Description', 'Transaction fee.', 'schema', 'dbo', 'table', 'F_VEHICLE_RTI', 'column', 'TRANSACTION_FEE_AMT'
	exec sys.sp_addextendedproperty 'MS_Description', 'Wildlife Education Fee (WES).', 'schema', 'dbo', 'table', 'F_VEHICLE_RTI', 'column', 'WILDLIFE_EDUCATION_FEE_AMT'
	exec sys.sp_addextendedproperty 'MS_Description', 'Search and Rescue Fee (S&R).', 'schema', 'dbo', 'table', 'F_VEHICLE_RTI', 'column', 'SEARCH_RESCUE_FEE_AMT'
	exec sys.sp_addextendedproperty 'MS_Description', 'PK used to identify the product within AWO (p_prd.prd_id).', 'schema', 'dbo', 'table', 'F_VEHICLE_RTI', 'column', 'AWO_PRODUCT_ID'
	exec sys.sp_addextendedproperty 'MS_Description', 'PK used to identify the vehicle within AWO (e_vehicle.id).', 'schema', 'dbo', 'table', 'F_VEHICLE_RTI', 'column', 'AWO_VEHICLE_ID'
	exec sys.sp_addextendedproperty 'MS_Description', 'PK used to identify the customer hf profile within AWO (c_cust_hfprofile.id).', 'schema', 'dbo', 'table', 'F_VEHICLE_RTI', 'column', 'AWO_CUSTOMER_PROFILE_ID'
	exec sys.sp_addextendedproperty 'MS_Description', 'ID of the user who completed the register transaction.', 'schema', 'dbo', 'table', 'F_VEHICLE_RTI', 'column', 'AWO_REGISTER_USER_ID'
	exec sys.sp_addextendedproperty 'MS_Description', 'ID of the location where completed the register transaction.', 'schema', 'dbo', 'table', 'F_VEHICLE_RTI', 'column', 'AWO_REGISTER_LOCATION_ID'
	exec sys.sp_addextendedproperty 'MS_Description', 'ID of the store where completed the register transaction.', 'schema', 'dbo', 'table', 'F_VEHICLE_RTI', 'column', 'AWO_STORE_ID'
	exec sys.sp_addextendedproperty 'MS_Description', 'ID of the user who activate the register transaction.', 'schema', 'dbo', 'table', 'F_VEHICLE_RTI', 'column', 'AWO_ACTIVATE_REG_USER_ID'
	exec sys.sp_addextendedproperty 'MS_Description', 'ID of the location where activate the register transaction.', 'schema', 'dbo', 'table', 'F_VEHICLE_RTI', 'column', 'AWO_ACTIVATE_REG_LOCATION_ID'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart Source Identifier: source system identifier for this record.', 'schema', 'dbo', 'table', 'F_VEHICLE_RTI', 'column', 'AWO_ID'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart Created Datetime: system date and time when this record was created in the mart.', 'schema', 'dbo', 'table', 'F_VEHICLE_RTI', 'column', 'MART_CREATED_DTM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart Modified Datetime: system date and time when this record was last modified in the mart.', 'schema', 'dbo', 'table', 'F_VEHICLE_RTI', 'column', 'MART_MODIFIED_DTM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Fact table containing vehicle RTI information. ', 'schema', 'dbo', 'table', 'F_VEHICLE_RTI'

	PRINT '[INFO] CREATED TABLE [DBO].[F_VEHICLE_RTI]'
END
GO

--Index: F_VEHICLE_RTI_VEHICLE_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_VEHICLE_RTI]','U') AND i.name = 'F_VEHICLE_RTI_VEHICLE_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_VEHICLE_RTI_VEHICLE_KEY_IX] ON [dbo].[F_VEHICLE_RTI]([D_VEHICLE_KEY]) ON CO_HF_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_VEHICLE_RTI].[F_VEHICLE_RTI_VEHICLE_KEY_IX]'
END
GO

--Index: F_VEHICLE_RTI_REGISTRATION_EXPIRATION_DATE_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_VEHICLE_RTI]','U') AND i.name = 'F_VEHICLE_RTI_REGISTRATION_EXPIRATION_DATE_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_VEHICLE_RTI_REGISTRATION_EXPIRATION_DATE_KEY_IX] ON [dbo].[F_VEHICLE_RTI]([REGISTRATION_EXPIRATION_DATE_KEY]) ON CO_HF_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_VEHICLE_RTI].[F_VEHICLE_RTI_REGISTRATION_EXPIRATION_DATE_KEY_IX]'
END
GO

--Index: F_VEHICLE_RTI_REGISTRATION_EFFECTIVE_DATE_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_VEHICLE_RTI]','U') AND i.name = 'F_VEHICLE_RTI_REGISTRATION_EFFECTIVE_DATE_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_VEHICLE_RTI_REGISTRATION_EFFECTIVE_DATE_KEY_IX] ON [dbo].[F_VEHICLE_RTI]([REGISTRATION_EFFECTIVE_DATE_KEY]) ON CO_HF_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_VEHICLE_RTI].[F_VEHICLE_RTI_REGISTRATION_EFFECTIVE_DATE_KEY_IX]'
END
GO

--Index: F_VEHICLE_RTI_CREATION_DATE_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_VEHICLE_RTI]','U') AND i.name = 'F_VEHICLE_RTI_CREATION_DATE_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_VEHICLE_RTI_CREATION_DATE_KEY_IX] ON [dbo].[F_VEHICLE_RTI]([RTI_CREATION_DATE_KEY]) ON CO_HF_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_VEHICLE_RTI].[F_VEHICLE_RTI_CREATION_DATE_KEY_IX]'
END
GO

--Index: F_VEHICLE_RTI_PRODUCT_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_VEHICLE_RTI]','U') AND i.name = 'F_VEHICLE_RTI_PRODUCT_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_VEHICLE_RTI_PRODUCT_KEY_IX] ON [dbo].[F_VEHICLE_RTI]([D_PRODUCT_KEY]) ON CO_HF_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_VEHICLE_RTI].[F_VEHICLE_RTI_PRODUCT_KEY_IX]'
END
GO

--Index: F_VEHICLE_RTI_CUSTOMER_PROFILE_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_VEHICLE_RTI]','U') AND i.name = 'F_VEHICLE_RTI_CUSTOMER_PROFILE_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_VEHICLE_RTI_CUSTOMER_PROFILE_KEY_IX] ON [dbo].[F_VEHICLE_RTI]([PRODUCT_CUSTOMER_PROFILE_KEY]) ON CO_HF_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_VEHICLE_RTI].[F_VEHICLE_RTI_CUSTOMER_PROFILE_KEY_IX]'
END
GO

--Index: F_VEHICLE_RTI_FISCAL_YEAR_NB_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_VEHICLE_RTI]','U') AND i.name = 'F_VEHICLE_RTI_FISCAL_YEAR_NB_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_VEHICLE_RTI_FISCAL_YEAR_NB_IX] ON [dbo].[F_VEHICLE_RTI]([FISCAL_YEAR_NB]) ON CO_HF_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_VEHICLE_RTI].[F_VEHICLE_RTI_FISCAL_YEAR_NB_IX]'
END
GO

--Index: F_VEHICLE_RTI_FISCAL_YEAR_TXT_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_VEHICLE_RTI]','U') AND i.name = 'F_VEHICLE_RTI_FISCAL_YEAR_TXT_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_VEHICLE_RTI_FISCAL_YEAR_TXT_IX] ON [dbo].[F_VEHICLE_RTI]([FISCAL_YEAR_TXT]) ON CO_HF_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_VEHICLE_RTI].[F_VEHICLE_RTI_FISCAL_YEAR_TXT_IX]'
END
GO

IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_VEHICLE_RTI]','U') AND i.name = 'F_VEHICLE_RTI_AWO_PRODUCT_ID_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_VEHICLE_RTI_AWO_PRODUCT_ID_IX] ON [dbo].[F_VEHICLE_RTI]([AWO_PRODUCT_ID]) ON CO_HF_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_VEHICLE_RTI].[F_VEHICLE_RTI_AWO_PRODUCT_ID_IX]'
END
GO

IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_VEHICLE_RTI]','U') AND i.name = 'F_VEHICLE_RTI_AWO_VEHICLE_ID_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_VEHICLE_RTI_AWO_VEHICLE_ID_IX] ON [dbo].[F_VEHICLE_RTI]([AWO_VEHICLE_ID]) ON CO_HF_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_VEHICLE_RTI].[F_VEHICLE_RTI_AWO_VEHICLE_ID_IX]'
END
GO

IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_VEHICLE_RTI]','U') AND i.name = 'F_VEHICLE_RTI_AWO_CUSTOMER_PROFILE_ID_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_VEHICLE_RTI_AWO_CUSTOMER_PROFILE_ID_IX] ON [dbo].[F_VEHICLE_RTI]([AWO_CUSTOMER_PROFILE_ID]) ON CO_HF_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_VEHICLE_RTI].[F_VEHICLE_RTI_AWO_CUSTOMER_PROFILE_ID_IX]'
END
GO

IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_VEHICLE_RTI]','U') AND i.name = 'F_VEHICLE_RTI_AWO_ID_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_VEHICLE_RTI_AWO_ID_IX] ON [dbo].[F_VEHICLE_RTI]([AWO_ID]) ON CO_HF_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_VEHICLE_RTI].[F_VEHICLE_RTI_AWO_ID_IX]'
END
GO

IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_VEHICLE_RTI]','U') AND i.name = 'F_VEHICLE_RTI_REGISTER_USER_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_VEHICLE_RTI_REGISTER_USER_KEY_IX] ON [dbo].[F_VEHICLE_RTI]([REGISTER_USER_KEY]) ON CO_HF_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_VEHICLE_RTI].[F_VEHICLE_RTI_REGISTER_USER_KEY_IX]'
END
GO

IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_VEHICLE_RTI]','U') AND i.name = 'F_VEHICLE_RTI_REGISTER_LOCATION_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_VEHICLE_RTI_REGISTER_LOCATION_KEY_IX] ON [dbo].[F_VEHICLE_RTI]([REGISTER_LOCATION_KEY]) ON CO_HF_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_VEHICLE_RTI].[F_VEHICLE_RTI_REGISTER_LOCATION_KEY_IX]'
END
GO

IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_VEHICLE_RTI]','U') AND i.name = 'F_VEHICLE_RTI_D_STORE_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_VEHICLE_RTI_D_STORE_KEY_IX] ON [dbo].[F_VEHICLE_RTI]([D_STORE_KEY]) ON CO_HF_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_VEHICLE_RTI].[F_VEHICLE_RTI_D_STORE_KEY_IX]'
END
GO

IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_VEHICLE_RTI]','U') AND i.name = 'F_VEHICLE_RTI_ACTIVATE_REG_USER_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_VEHICLE_RTI_ACTIVATE_REG_USER_KEY_IX] ON [dbo].[F_VEHICLE_RTI]([ACTIVATE_REG_USER_KEY]) ON CO_HF_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_VEHICLE_RTI].[F_VEHICLE_RTI_ACTIVATE_REG_USER_KEY_IX]'
END
GO

IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_VEHICLE_RTI]','U') AND i.name = 'F_VEHICLE_RTI_ACTIVATE_REG_USER_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_VEHICLE_RTI_ACTIVATE_REG_USER_KEY_IX] ON [dbo].[F_VEHICLE_RTI]([ACTIVATE_REG_USER_KEY]) ON CO_HF_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_VEHICLE_RTI].[F_VEHICLE_RTI_ACTIVATE_REG_USER_KEY_IX]'
END
GO

IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_VEHICLE_RTI]','U') AND i.name = 'F_VEHICLE_RTI_AWO_REG_USER_ID_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_VEHICLE_RTI_AWO_REG_USER_ID_IX] ON [dbo].[F_VEHICLE_RTI]([AWO_REGISTER_USER_ID]) ON CO_HF_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_VEHICLE_RTI].[F_VEHICLE_RTI_AWO_REG_USER_ID_IX]'
END
GO

IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_VEHICLE_RTI]','U') AND i.name = 'F_VEHICLE_RTI_AWO_REG_LOC_ID_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_VEHICLE_RTI_AWO_REG_LOC_ID_IX] ON [dbo].[F_VEHICLE_RTI]([AWO_REGISTER_LOCATION_ID]) ON CO_HF_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_VEHICLE_RTI].[F_VEHICLE_RTI_AWO_REG_LOC_ID_IX]'
END
GO

IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_VEHICLE_RTI]','U') AND i.name = 'F_VEHICLE_RTI_AWO_STORE_ID_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_VEHICLE_RTI_AWO_STORE_ID_IX] ON [dbo].[F_VEHICLE_RTI]([AWO_STORE_ID]) ON CO_HF_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_VEHICLE_RTI].[F_VEHICLE_RTI_AWO_STORE_ID_IX]'
END
GO

IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_VEHICLE_RTI]','U') AND i.name = 'F_VEHICLE_RTI_AWO_ACTIVATE_REG_USER_ID_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_VEHICLE_RTI_AWO_ACTIVATE_REG_USER_ID_IX] ON [dbo].[F_VEHICLE_RTI]([AWO_ACTIVATE_REG_USER_ID]) ON CO_HF_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_VEHICLE_RTI].[F_VEHICLE_RTI_AWO_ACTIVATE_REG_USER_ID_IX]'
END
GO


IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_VEHICLE_RTI]','U') AND i.name = 'F_VEHICLE_RTI_ORDER_ID_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_VEHICLE_RTI_ORDER_ID_IX] ON [dbo].[F_VEHICLE_RTI]([ORDER_ID]) ON CO_HF_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_VEHICLE_RTI].[F_VEHICLE_RTI_ORDER_ID_IX]'
END
GO

IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_VEHICLE_RTI]','U') AND i.name = 'F_VEHICLE_RTI_ACTIVATE_REG_LOCATION_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_VEHICLE_RTI_ACTIVATE_REG_LOCATION_KEY_IX] ON [dbo].[F_VEHICLE_RTI]([ACTIVATE_REG_LOCATION_KEY]) ON CO_HF_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_VEHICLE_RTI].[F_VEHICLE_RTI_ACTIVATE_REG_LOCATION_KEY_IX]'
END
GO

IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_VEHICLE_RTI]','U') AND i.name = 'F_VEHICLE_RTI_PURCHASE_TYPE_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_VEHICLE_RTI_PURCHASE_TYPE_KEY_IX] ON [dbo].[F_VEHICLE_RTI]([D_PURCHASE_TYPE_KEY]) ON CO_HF_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_VEHICLE_RTI].[F_VEHICLE_RTI_PURCHASE_TYPE_KEY_IX]'
END
GO


