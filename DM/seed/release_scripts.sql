USE TX_CAMPING_MART
GO

IF NOT EXISTS(SELECT * FROM sysobjects WHERE xtype = 'U' AND uid = 1 AND NAME = 'D_ORDER_BK20190729')
BEGIN
	SELECT * INTO D_ORDER_BK20190729 FROM D_ORDER WITH(NOLOCK)
	PRINT 'Backuped D_ORDER'
END

IF NOT EXISTS(SELECT * FROM sysobjects WHERE xtype = 'U' AND uid = 1 AND NAME = 'F_ORDER_ITEM_BK20190729')
BEGIN
	SELECT * INTO F_ORDER_ITEM_BK20190729 FROM F_ORDER_ITEM WITH(NOLOCK)
	PRINT 'Backuped F_ORDER_ITEM'
END

-- Transaction message

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_ORDER') AND name='COMMENT_TXT')
BEGIN
	ALTER TABLE D_ORDER DROP COLUMN COMMENT_TXT
	PRINT '[INFO] DROPPED COLUMN [DBO].[D_ORDER].[COMMENT_TXT]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.F_ORDER_ITEM') AND name='COMMENT_TXT')
BEGIN
	ALTER TABLE F_ORDER_ITEM DROP COLUMN COMMENT_TXT
	PRINT '[INFO] DROPPED COLUMN [DBO].[F_ORDER_ITEM].[COMMENT_TXT]'
END

IF NOT EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.F_ORDER_ITEM') AND name='ORDER_PROCESS_STATUS_KEY')
BEGIN
	ALTER TABLE F_ORDER_ITEM ADD ORDER_PROCESS_STATUS_KEY bigint NULL
	exec sys.sp_addextendedproperty 'MS_Description', 'Order Process Status Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'F_ORDER_ITEM', 'column', 'ORDER_PROCESS_STATUS_KEY'
	PRINT '[INFO] ADD COLUMN [DBO].[F_ORDER_ITEM].[ORDER_PROCESS_STATUS_KEY]'
END

--INDEX: F_ORDER_ITEM_ORDER_PROCESS_STATUS_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_ORDER_ITEM]','U') AND i.name = 'F_ORDER_ITEM_ORDER_PROCESS_STATUS_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_ORDER_ITEM_ORDER_PROCESS_STATUS_KEY_IX] ON [dbo].[F_ORDER_ITEM](ORDER_PROCESS_STATUS_KEY) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_ORDER_ITEM].[F_ORDER_ITEM_ORDER_PROCESS_STATUS_KEY_IX]'
END
GO


IF EXISTS(SELECT * FROM sysobjects WHERE xtype = 'U' AND uid = 1 AND NAME = 'D_SITE_ATTRIBUTES')
BEGIN
	EXEC sp_rename 'dbo.D_SITE_ATTRIBUTES', 'D_SITE_ATTRIBUTES20190729'; 
	PRINT 'Backuped D_SITE_ATTRIBUTES'
END

/*

 * NOTES: Creates B_ORDER_TRANS_MESSAGE bridge for AspiraOne datamart 
 *
 * DATE        JIRA      USER             DESCRIPTION
 * ----------  --------  ---------------  ---------------------------------------
 * 04/17/2019  DMA-3521  Zongpei Liu	  Initialization.

*/

SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL READ COMMITTED

IF OBJECT_ID('DBO.B_ORDER_TRANS_MESSAGE') IS NULL
BEGIN
	CREATE TABLE DBO.B_ORDER_TRANS_MESSAGE(
		ORDER_TRANS_MESSAGE_KEY              bigint           IDENTITY(1,1),
		ORDER_KEY                            bigint           NULL,
		MESSAGE_CREATED_DTM                  datetime         NULL,
		MESSAGE_TXT                          varchar(255)     NULL,
		CREATED_USER_KEY                     bigint           NULL,
		CREATED_LOCATION_KEY                 bigint           NULL,
		MART_SOURCE_ID                       bigint           NULL,
		MART_CREATED_DTM                     datetime         NULL,
		MART_MODIFIED_DTM                    datetime         NULL,
		CONSTRAINT PK_B_ORDER_TRANS_MESSAGE PRIMARY KEY CLUSTERED (ORDER_TRANS_MESSAGE_KEY)
	) ON TX_CAMPING_MART_DATA

	exec sys.sp_addextendedproperty 'MS_Description', 'Order Transaction Message Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'B_ORDER_TRANS_MESSAGE', 'column', 'ORDER_TRANS_MESSAGE_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Order Key: surrogate key uniquely identifying this record in the mart.', 'schema', 'dbo', 'table', 'B_ORDER_TRANS_MESSAGE', 'column', 'ORDER_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Message Created Date Time: message created time in source.', 'schema', 'dbo', 'table', 'B_ORDER_TRANS_MESSAGE', 'column', 'MESSAGE_CREATED_DTM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Message Text; message content.', 'schema', 'dbo', 'table', 'B_ORDER_TRANS_MESSAGE', 'column', 'MESSAGE_TXT'
	exec sys.sp_addextendedproperty 'MS_Description', 'User Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'B_ORDER_TRANS_MESSAGE', 'column', 'CREATED_USER_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Location Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'B_ORDER_TRANS_MESSAGE', 'column', 'CREATED_LOCATION_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart Source Identifier: source system identifier for this record.', 'schema', 'dbo', 'table', 'B_ORDER_TRANS_MESSAGE', 'column', 'MART_SOURCE_ID'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart Created Datetime: system date and time when this record was created in the mart.', 'schema', 'dbo', 'table', 'B_ORDER_TRANS_MESSAGE', 'column', 'MART_CREATED_DTM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart Modified Datetime: system date and time when this record was last modified in the mart.', 'schema', 'dbo', 'table', 'B_ORDER_TRANS_MESSAGE', 'column', 'MART_MODIFIED_DTM'
	exec sys.sp_addextendedproperty 'MS_Description', 'B_Order_Transaction_Message: order transaction message.', 'schema', 'dbo', 'table', 'B_ORDER_TRANS_MESSAGE'

	PRINT '[INFO] CREATED TABLE [DBO].[B_ORDER_TRANS_MESSAGE]'
END

--INDEX: B_ORDER_TRANS_MESSAGE_MART_SOURCE_ID_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_ORDER_TRANS_MESSAGE]','U') AND i.name = 'B_ORDER_TRANS_MESSAGE_MART_SOURCE_ID_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_ORDER_TRANS_MESSAGE_MART_SOURCE_ID_IX] ON [dbo].[B_ORDER_TRANS_MESSAGE]([MART_SOURCE_ID]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_ORDER_TRANS_MESSAGE].[B_ORDER_TRANS_MESSAGE_MART_SOURCE_ID_IX]'
END
GO

--INDEX: B_ORDER_TRANS_MESSAGE_ORDER_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_ORDER_TRANS_MESSAGE]','U') AND i.name = 'B_ORDER_TRANS_MESSAGE_ORDER_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_ORDER_TRANS_MESSAGE_ORDER_KEY_IX] ON [dbo].[B_ORDER_TRANS_MESSAGE]([ORDER_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_ORDER_TRANS_MESSAGE].[B_ORDER_TRANS_MESSAGE_ORDER_KEY_IX]'
END
GO

--INDEX: B_ORDER_TRANS_MESSAGE_CREATED_USER_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_ORDER_TRANS_MESSAGE]','U') AND i.name = 'B_ORDER_TRANS_MESSAGE_CREATED_USER_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_ORDER_TRANS_MESSAGE_CREATED_USER_KEY_IX] ON [dbo].[B_ORDER_TRANS_MESSAGE]([CREATED_USER_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_ORDER_TRANS_MESSAGE].[B_ORDER_TRANS_MESSAGE_CREATED_USER_KEY_IX]'
END
GO

--INDEX: B_ORDER_TRANS_MESSAGE_CREATED_LOCATION_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_ORDER_TRANS_MESSAGE]','U') AND i.name = 'B_ORDER_TRANS_MESSAGE_CREATED_LOCATION_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_ORDER_TRANS_MESSAGE_CREATED_LOCATION_KEY_IX] ON [dbo].[B_ORDER_TRANS_MESSAGE]([CREATED_LOCATION_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_ORDER_TRANS_MESSAGE].[B_ORDER_TRANS_MESSAGE_CREATED_LOCATION_KEY_IX]'
END
GO


/*

DO NOT deploy until TPWD CODE FREEZE finish

 * NOTES: Creates R_ORDER_PROCESS_STATUS dimension for AspiraOne datamart 
 *
 * DATE        JIRA      USER             DESCRIPTION
 * ----------  --------  ---------------  ---------------------------------------
 * 01/07/2019  DMA-2862  Zongpei Liu	  Initialization.
*/


SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL READ COMMITTED

IF OBJECT_ID('DBO.R_ORDER_PROCESS_STATUS') IS NULL
BEGIN
	CREATE TABLE DBO.R_ORDER_PROCESS_STATUS(
		ORDER_PROCESS_STATUS_KEY     bigint          IDENTITY(1,1),
		ORDER_PROCESS_STATUS_NM      varchar(512)    NULL,
		MART_SOURCE_ID               bigint          NULL,
		MART_CREATED_DTM             datetime        NULL,
		MART_MODIFIED_DTM            datetime        NULL,
		CONSTRAINT PK_R_ORDER_PROCESS_STATUS PRIMARY KEY CLUSTERED (ORDER_PROCESS_STATUS_KEY)
	) ON TX_CAMPING_MART_DATA

	exec sys.sp_addextendedproperty 'MS_Description', 'Order Process Status Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'R_ORDER_PROCESS_STATUS', 'column', 'ORDER_PROCESS_STATUS_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Order Process Status Name: valid statuses for orders (Pre Arrival, Checked In, Checked Out, Awarded, etc).', 'schema', 'dbo', 'table', 'R_ORDER_PROCESS_STATUS', 'column', 'ORDER_PROCESS_STATUS_NM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart Source Identifier: source system identifier for this record.', 'schema', 'dbo', 'table', 'R_ORDER_PROCESS_STATUS', 'column', 'MART_SOURCE_ID'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart Created Datetime: system date and time when this record was created in the mart.', 'schema', 'dbo', 'table', 'R_ORDER_PROCESS_STATUS', 'column', 'MART_CREATED_DTM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart Modified Datetime: system date and time when this record was last modified in the mart.', 'schema', 'dbo', 'table', 'R_ORDER_PROCESS_STATUS', 'column', 'MART_MODIFIED_DTM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Order Process Status: the list of process statuses for orders (Pre Arrival, Checked In, Checked Out, Awarded, etc).', 'schema', 'dbo', 'table', 'R_ORDER_PROCESS_STATUS'

	PRINT '[INFO] CREATED TABLE [DBO].[R_ORDER_PROCESS_STATUS]'
END
GO

--INDEX: R_ORDER_PROCESS_STATUS_MART_SOURCE_ID_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[R_ORDER_PROCESS_STATUS]','U') AND i.name = 'R_ORDER_PROCESS_STATUS_MART_SOURCE_ID_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [R_ORDER_PROCESS_STATUS_MART_SOURCE_ID_IX] ON [dbo].[R_ORDER_PROCESS_STATUS]([MART_SOURCE_ID]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[R_ORDER_PROCESS_STATUS].[R_ORDER_PROCESS_STATUS_MART_SOURCE_ID_IX]'
END
GO

/*

 * NOTES: Creates B_ORDER_ITEM_TRANS_MESSAGE bridge for AspiraOne datamart 
 *
 * DATE        JIRA      USER             DESCRIPTION
 * ----------  --------  ---------------  ---------------------------------------
 * 04/17/2019  DMA-3521  Zongpei Liu	  Initialization.

*/

SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL READ COMMITTED

IF OBJECT_ID('DBO.B_ORDER_ITEM_TRANS_MESSAGE') IS NULL
BEGIN
	CREATE TABLE DBO.B_ORDER_ITEM_TRANS_MESSAGE(
		ORDER_ITEM_TRANS_MESSAGE_KEY         bigint           IDENTITY(1,1),
		ITEM_KEY                             bigint           NULL,
		MESSAGE_CREATED_DTM                  datetime         NULL,
		MESSAGE_TXT                          varchar(255)     NULL,
		CREATED_USER_KEY                     bigint           NULL,
		CREATED_LOCATION_KEY                 bigint           NULL,
		MART_SOURCE_ID                       bigint           NULL,
		MART_CREATED_DTM                     datetime         NULL,
		MART_MODIFIED_DTM                    datetime         NULL,
		CONSTRAINT PK_B_ORDER_ITEM_TRANS_MESSAGE PRIMARY KEY CLUSTERED (ORDER_ITEM_TRANS_MESSAGE_KEY)
	) ON TX_CAMPING_MART_DATA

	exec sys.sp_addextendedproperty 'MS_Description', 'Order Item Transaction Message Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'B_ORDER_ITEM_TRANS_MESSAGE', 'column', 'ORDER_ITEM_TRANS_MESSAGE_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Order Key: surrogate key uniquely identifying this record in the mart.', 'schema', 'dbo', 'table', 'B_ORDER_ITEM_TRANS_MESSAGE', 'column', 'ITEM_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Message Created Date Time: message created time in source.', 'schema', 'dbo', 'table', 'B_ORDER_ITEM_TRANS_MESSAGE', 'column', 'MESSAGE_CREATED_DTM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Message Text; message content.', 'schema', 'dbo', 'table', 'B_ORDER_ITEM_TRANS_MESSAGE', 'column', 'MESSAGE_TXT'
	exec sys.sp_addextendedproperty 'MS_Description', 'User Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'B_ORDER_ITEM_TRANS_MESSAGE', 'column', 'CREATED_USER_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Location Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'B_ORDER_ITEM_TRANS_MESSAGE', 'column', 'CREATED_LOCATION_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart Source Identifier: source system identifier for this record.', 'schema', 'dbo', 'table', 'B_ORDER_ITEM_TRANS_MESSAGE', 'column', 'MART_SOURCE_ID'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart Created Datetime: system date and time when this record was created in the mart.', 'schema', 'dbo', 'table', 'B_ORDER_ITEM_TRANS_MESSAGE', 'column', 'MART_CREATED_DTM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart Modified Datetime: system date and time when this record was last modified in the mart.', 'schema', 'dbo', 'table', 'B_ORDER_ITEM_TRANS_MESSAGE', 'column', 'MART_MODIFIED_DTM'
	exec sys.sp_addextendedproperty 'MS_Description', 'B_Order_Item_Transaction_Message: order item transaction message.', 'schema', 'dbo', 'table', 'B_ORDER_ITEM_TRANS_MESSAGE'

	PRINT '[INFO] CREATED TABLE [DBO].[B_ORDER_ITEM_TRANS_MESSAGE]'
END

--INDEX: B_ORDER_ITEM_TRANS_MESSAGE_MART_SOURCE_ID_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_ORDER_ITEM_TRANS_MESSAGE]','U') AND i.name = 'B_ORDER_ITEM_TRANS_MESSAGE_MART_SOURCE_ID_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_ORDER_ITEM_TRANS_MESSAGE_MART_SOURCE_ID_IX] ON [dbo].[B_ORDER_ITEM_TRANS_MESSAGE]([MART_SOURCE_ID]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_ORDER_ITEM_TRANS_MESSAGE].[B_ORDER_ITEM_TRANS_MESSAGE_MART_SOURCE_ID_IX]'
END
GO

--INDEX: B_ORDER_ITEM_TRANS_MESSAGE_ITEM_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_ORDER_ITEM_TRANS_MESSAGE]','U') AND i.name = 'B_ORDER_ITEM_TRANS_MESSAGE_ITEM_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_ORDER_ITEM_TRANS_MESSAGE_ITEM_KEY_IX] ON [dbo].[B_ORDER_ITEM_TRANS_MESSAGE]([ITEM_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_ORDER_ITEM_TRANS_MESSAGE].[B_ORDER_ITEM_TRANS_MESSAGE_ITEM_KEY_IX]'
END
GO

--INDEX: B_ORDER_ITEM_TRANS_MESSAGE_CREATED_USER_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_ORDER_ITEM_TRANS_MESSAGE]','U') AND i.name = 'B_ORDER_ITEM_TRANS_MESSAGE_CREATED_USER_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_ORDER_ITEM_TRANS_MESSAGE_CREATED_USER_KEY_IX] ON [dbo].[B_ORDER_ITEM_TRANS_MESSAGE]([CREATED_USER_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_ORDER_ITEM_TRANS_MESSAGE].[B_ORDER_ITEM_TRANS_MESSAGE_CREATED_USER_KEY_IX]'
END
GO

--INDEX: B_ORDER_ITEM_TRANS_MESSAGE_CREATED_LOCATION_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_ORDER_ITEM_TRANS_MESSAGE]','U') AND i.name = 'B_ORDER_ITEM_TRANS_MESSAGE_CREATED_LOCATION_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_ORDER_ITEM_TRANS_MESSAGE_CREATED_LOCATION_KEY_IX] ON [dbo].[B_ORDER_ITEM_TRANS_MESSAGE]([CREATED_LOCATION_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_ORDER_ITEM_TRANS_MESSAGE].[B_ORDER_ITEM_TRANS_MESSAGE_CREATED_LOCATION_KEY_IX]'
END
GO


-- Occupant type
/* back original table */
IF NOT EXISTS(SELECT * FROM sysobjects WHERE xtype = 'U' AND uid = 1 AND NAME = 'D_DAILY_ENTRANCE_BK20190729')
BEGIN
	SELECT * INTO D_DAILY_ENTRANCE_BK20190729 FROM D_DAILY_ENTRANCE WITH(NOLOCK)
	PRINT 'Backuped D_DAILY_ENTRANCE'
END

IF NOT EXISTS(SELECT * FROM sysobjects WHERE xtype = 'U' AND uid = 1 AND NAME = 'D_RESERVATION_BK20190729')
BEGIN
	SELECT * INTO D_RESERVATION_BK20190729 FROM D_RESERVATION WITH(NOLOCK)
	PRINT 'Backuped D_RESERVATION'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_RESERVATION') AND name='CHECKIN_IND')
BEGIN
        ALTER TABLE D_RESERVATION DROP COLUMN CHECKIN_IND
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_RESERVATION].[CHECKIN_IND]'
END

IF NOT EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_RESERVATION') AND name='PRIMARY_OCCUPANT_TYPE_NM')
BEGIN
	ALTER TABLE D_RESERVATION ADD PRIMARY_OCCUPANT_TYPE_NM varchar(255) NULL
	exec sys.sp_addextendedproperty 'MS_Description', 'Primary Occupant type: Primary occupant''s type.', 'schema', 'dbo', 'table', 'D_RESERVATION', 'column', 'PRIMARY_OCCUPANT_TYPE_NM'
	PRINT '[INFO] ADD COLUMN [DBO].[D_RESERVATION].[PRIMARY_OCCUPANT_TYPE_NM]'
END

IF NOT EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_RESERVATION') AND name='RESERVATION_STATUS_NM')
BEGIN
	ALTER TABLE D_RESERVATION ADD RESERVATION_STATUS_NM varchar(100) NULL
	exec sys.sp_addextendedproperty 'MS_Description', 'reservation status.', 'schema', 'dbo', 'table', 'D_RESERVATION', 'column', 'RESERVATION_STATUS_NM'
	PRINT '[INFO] ADD COLUMN [DBO].[D_RESERVATION].[RESERVATION_STATUS_NM]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_DAILY_ENTRANCE') AND name='CHECKIN_IND')
BEGIN
        ALTER TABLE D_DAILY_ENTRANCE DROP COLUMN CHECKIN_IND
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_DAILY_ENTRANCE].[CHECKIN_IND]'
END

IF NOT EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_DAILY_ENTRANCE') AND name='PRIMARY_OCCUPANT_TYPE_NM')
BEGIN
	ALTER TABLE D_DAILY_ENTRANCE ADD PRIMARY_OCCUPANT_TYPE_NM varchar(255) NULL
	exec sys.sp_addextendedproperty 'MS_Description', 'Primary Occupant type: Primary occupant''s type.', 'schema', 'dbo', 'table', 'D_DAILY_ENTRANCE', 'column', 'PRIMARY_OCCUPANT_TYPE_NM'
	PRINT '[INFO] ADD COLUMN [DBO].[D_DAILY_ENTRANCE].[PRIMARY_OCCUPANT_TYPE_NM]'
END

IF NOT EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_DAILY_ENTRANCE') AND name='RESERVATION_STATUS_NM')
BEGIN
	ALTER TABLE D_DAILY_ENTRANCE ADD RESERVATION_STATUS_NM varchar(100) NULL
	exec sys.sp_addextendedproperty 'MS_Description', 'reservation status.', 'schema', 'dbo', 'table', 'D_DAILY_ENTRANCE', 'column', 'RESERVATION_STATUS_NM'
	PRINT '[INFO] ADD COLUMN [DBO].[D_DAILY_ENTRANCE].[RESERVATION_STATUS_NM]'
END

/*

DO NOT deploy to UAT until TPWD CODE FREEZE finish

 * NOTES: Creates B_RESERVATION_OCCUPANT bridge for AspiraOne datamart 
 *
 * DATE        JIRA      USER             DESCRIPTION
 * ----------  --------  ---------------  ---------------------------------------
 * 04/19/2019  DMA-3756  Kelvin Wang	  Initialization.
*/

SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL READ COMMITTED

IF OBJECT_ID('DBO.B_RESERVATION_OCCUPANT') IS NULL
BEGIN
		CREATE TABLE [dbo].[B_RESERVATION_OCCUPANT](
			[RESERVATION_OCCUPANT_KEY]  bigint          IDENTITY(1,1),
			[ITEM_KEY]                  bigint          NULL,
			[OCCUPANT_TYPE_NM]          varchar(255)    NULL,
			[OCCUPANT_TYPE_CNT]         int             NULL,
			[OCCUPANT_TYPE_ID]          bigint          NULL,
			[DELETED_IND]               smallint        NULL,
			[MART_CREATED_DTM]          datetime        NULL,
			[MART_MODIFIED_DTM]         datetime        NULL
		CONSTRAINT PK_B_RESERVATION_OCCUPANT PRIMARY KEY CLUSTERED ([RESERVATION_OCCUPANT_KEY])
	) ON TX_CAMPING_MART_DATA

	exec sys.sp_addextendedproperty 'MS_Description', 'Reservation Occupant Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'B_RESERVATION_OCCUPANT', 'column', 'RESERVATION_OCCUPANT_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Item Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'B_RESERVATION_OCCUPANT', 'column', 'ITEM_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Occupant Type Name: Name of occupant type.', 'schema', 'dbo', 'table', 'B_RESERVATION_OCCUPANT', 'column', 'OCCUPANT_TYPE_NM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Occupant Type Count: Count of certain occupant type.', 'schema', 'dbo', 'table', 'B_RESERVATION_OCCUPANT', 'column', 'OCCUPANT_TYPE_CNT'
	exec sys.sp_addextendedproperty 'MS_Description', 'Occupant Type Identifier:  source system identifier for order profile occupant type.', 'schema', 'dbo', 'table', 'B_RESERVATION_OCCUPANT', 'column', 'OCCUPANT_TYPE_ID'
	exec sys.sp_addextendedproperty 'MS_Description', 'Deleted Indicator: 1 if this record has been deleted in the source system, otherwise 0.', 'schema', 'dbo', 'table', 'B_RESERVATION_OCCUPANT', 'column', 'DELETED_IND'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart Created Datetime: system date and time when this record was created in the mart.', 'schema', 'dbo', 'table', 'B_RESERVATION_OCCUPANT', 'column', 'MART_CREATED_DTM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart Modified Datetime: system date and time when this record was last modified in the mart.', 'schema', 'dbo', 'table', 'B_RESERVATION_OCCUPANT', 'column', 'MART_MODIFIED_DTM'
	exec sys.sp_addextendedproperty 'MS_Description', 'B Reservation Occupant: Reservation occupant bridge table.', 'schema', 'dbo', 'table', 'B_RESERVATION_OCCUPANT'

	PRINT '[INFO] CREATED TABLE [DBO].[B_RESERVATION_OCCUPANT]'
END
GO

--INDEX: B_RESERVATION_OCCUPANT_ITEM_KEY_OCCUPANT_TYPE_ID_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_RESERVATION_OCCUPANT]','U') AND i.name = 'B_RESERVATION_OCCUPANT_ITEM_KEY_OCCUPANT_TYPE_ID_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_RESERVATION_OCCUPANT_ITEM_KEY_OCCUPANT_TYPE_ID_IX] ON [dbo].[B_RESERVATION_OCCUPANT]([ITEM_KEY], [OCCUPANT_TYPE_ID]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_RESERVATION_OCCUPANT].[B_RESERVATION_OCCUPANT_ITEM_KEY_OCCUPANT_TYPE_ID_IX]'
END
GO

--INDEX: B_RESERVATION_OCCUPANT_ITEM_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_RESERVATION_OCCUPANT]','U') AND i.name = 'B_RESERVATION_OCCUPANT_ITEM_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_RESERVATION_OCCUPANT_ITEM_KEY_IX] ON [dbo].[B_RESERVATION_OCCUPANT]([ITEM_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_RESERVATION_OCCUPANT].[B_RESERVATION_OCCUPANT_ITEM_KEY_IX]'
END
GO

/*

DO NOT deploy to UAT until TPWD CODE FREEZE finish

 * NOTES: Creates B_RESERVATION_VEHICLE bridge for AspiraOne datamart 
 *
 * DATE        JIRA      USER             DESCRIPTION
 * ----------  --------  ---------------  ---------------------------------------
 * 04/19/2019  DMA-3756  Kelvin Wang	  Initialization.
*/

SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL READ COMMITTED

IF OBJECT_ID('DBO.B_RESERVATION_VEHICLE') IS NULL
BEGIN
		CREATE TABLE [dbo].[B_RESERVATION_VEHICLE](
			[RESERVATION_VEHICLE_KEY]  bigint          IDENTITY(1,1),
			[ITEM_KEY]                 bigint          NULL,
			[VEHICLE_TYPE_NM]          varchar(255)    NULL,
			[VEHICLE_PLATE_NB]         varchar(255)    NULL,
			[VEHICLE_STATE_NM]         varchar(255)    NULL,
			[VEHICLE_MAKER_NM]         varchar(255)    NULL,
			[VEHICLE_MODEL_NM]         varchar(255)    NULL,
			[VEHICLE_COLOR_NM]         varchar(255)    NULL,
			[MART_SOURCE_ID]           bigint          NULL,
			[DELETED_IND]              smallint        NULL,
			[MART_CREATED_DTM]         datetime        NULL,
			[MART_MODIFIED_DTM]        datetime        NULL
		CONSTRAINT PK_B_RESERVATION_VEHICLE PRIMARY KEY CLUSTERED ([RESERVATION_VEHICLE_KEY])
	) ON TX_CAMPING_MART_DATA

	exec sys.sp_addextendedproperty 'MS_Description', 'Reservation Vehicle Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'B_RESERVATION_VEHICLE', 'column', 'RESERVATION_VEHICLE_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Item Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'B_RESERVATION_VEHICLE', 'column', 'ITEM_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Vehicle Type Name: Name of vehicle type.', 'schema', 'dbo', 'table', 'B_RESERVATION_VEHICLE', 'column', 'VEHICLE_TYPE_NM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Vehicle Plate Number: Number of vehicle plate.', 'schema', 'dbo', 'table', 'B_RESERVATION_VEHICLE', 'column', 'VEHICLE_PLATE_NB'
	exec sys.sp_addextendedproperty 'MS_Description', 'Vehicle State Name: State name of vehicle.', 'schema', 'dbo', 'table', 'B_RESERVATION_VEHICLE', 'column', 'VEHICLE_STATE_NM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Vehicle Maker Name: Name of vehicle maker.', 'schema', 'dbo', 'table', 'B_RESERVATION_VEHICLE', 'column', 'VEHICLE_MAKER_NM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Vehicle Model Name: Name of vehicle model.', 'schema', 'dbo', 'table', 'B_RESERVATION_VEHICLE', 'column', 'VEHICLE_MODEL_NM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Vehicle Color Name: Name of vehicle color.', 'schema', 'dbo', 'table', 'B_RESERVATION_VEHICLE', 'column', 'VEHICLE_COLOR_NM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart Source Identifier: source system identifier for this record.', 'schema', 'dbo', 'table', 'B_RESERVATION_VEHICLE', 'column', 'MART_SOURCE_ID'
	exec sys.sp_addextendedproperty 'MS_Description', 'Deleted Indicator: 1 if this record has been deleted in the source system, otherwise 0.', 'schema', 'dbo', 'table', 'B_RESERVATION_VEHICLE', 'column', 'DELETED_IND'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart Created Datetime: system date and time when this record was created in the mart.', 'schema', 'dbo', 'table', 'B_RESERVATION_VEHICLE', 'column', 'MART_CREATED_DTM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart Modified Datetime: system date and time when this record was last modified in the mart.', 'schema', 'dbo', 'table', 'B_RESERVATION_VEHICLE', 'column', 'MART_MODIFIED_DTM'
	exec sys.sp_addextendedproperty 'MS_Description', 'B Reservation Vehicle: Reservation vehicle bridge table.', 'schema', 'dbo', 'table', 'B_RESERVATION_VEHICLE'

	PRINT '[INFO] CREATED TABLE [DBO].[B_RESERVATION_VEHICLE]'
END
GO

--INDEX: B_RESERVATION_VEHICLE_MART_SOURCE_ID_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_RESERVATION_VEHICLE]','U') AND i.name = 'B_RESERVATION_VEHICLE_MART_SOURCE_ID_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_RESERVATION_VEHICLE_MART_SOURCE_ID_IX] ON [dbo].[B_RESERVATION_VEHICLE]([MART_SOURCE_ID]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_RESERVATION_VEHICLE].[B_RESERVATION_VEHICLE_MART_SOURCE_ID_IX]'
END
GO

--INDEX: B_RESERVATION_VEHICLE_ITEM_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_RESERVATION_VEHICLE]','U') AND i.name = 'B_RESERVATION_VEHICLE_ITEM_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_RESERVATION_VEHICLE_ITEM_KEY_IX] ON [dbo].[B_RESERVATION_VEHICLE]([ITEM_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_RESERVATION_VEHICLE].[B_RESERVATION_VEHICLE_ITEM_KEY_IX]'
END
GO

/*

DO NOT deploy to UAT until TPWD CODE FREEZE finish

 * NOTES: Creates B_RESERVATION_VEHICLE_OCCUPANT bridge for AspiraOne datamart 
 *
 * DATE        JIRA      USER             DESCRIPTION
 * ----------  --------  ---------------  ---------------------------------------
 * 04/19/2019  DMA-3756  Kelvin Wang	  Initialization.
*/

SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL READ COMMITTED

IF OBJECT_ID('DBO.B_RESERVATION_VEHICLE_OCCUPANT') IS NULL
BEGIN
		CREATE TABLE [dbo].[B_RESERVATION_VEHICLE_OCCUPANT](
			[RESERVATION_VEHICLE_OCCUPANT_KEY]  bigint          IDENTITY(1,1),
			[ITEM_KEY]                          bigint          NULL,
			[RESERVATION_VEHICLE_KEY]           bigint          NULL,
			[OCCUPANT_TYPE_NM]                  varchar(255)    NULL,
			[OCCUPANT_TYPE_CNT]                 int             NULL,
			[PROFILE_VEHICLE_ID]                bigint          NULL,
			[OCCUPANT_TYPE_ID]                  bigint          NULL,
			[DELETED_IND]                       smallint        NULL,
			[MART_CREATED_DTM]                  datetime        NULL,
			[MART_MODIFIED_DTM]                 datetime        NULL
		CONSTRAINT PK_B_RESERVATION_VEHICLE_OCCUPANT PRIMARY KEY CLUSTERED ([RESERVATION_VEHICLE_OCCUPANT_KEY])
	) ON TX_CAMPING_MART_DATA

	exec sys.sp_addextendedproperty 'MS_Description', 'Reservation Vehicle Occupant Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'B_RESERVATION_VEHICLE_OCCUPANT', 'column', 'RESERVATION_VEHICLE_OCCUPANT_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Item Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'B_RESERVATION_VEHICLE_OCCUPANT', 'column', 'ITEM_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Reservation Vehicle Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'B_RESERVATION_VEHICLE_OCCUPANT', 'column', 'RESERVATION_VEHICLE_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Occupant Type Name: Name of occupant type.', 'schema', 'dbo', 'table', 'B_RESERVATION_VEHICLE_OCCUPANT', 'column', 'OCCUPANT_TYPE_NM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Occupant Type Count: Count of certain occupant type.', 'schema', 'dbo', 'table', 'B_RESERVATION_VEHICLE_OCCUPANT', 'column', 'OCCUPANT_TYPE_CNT'
	exec sys.sp_addextendedproperty 'MS_Description', 'Profile Vehicle Identifier: source system identifier for order profile vehicle.', 'schema', 'dbo', 'table', 'B_RESERVATION_VEHICLE_OCCUPANT', 'column', 'PROFILE_VEHICLE_ID'
	exec sys.sp_addextendedproperty 'MS_Description', 'Occupant Type Identifier:  source system identifier for order profile occupant type.', 'schema', 'dbo', 'table', 'B_RESERVATION_VEHICLE_OCCUPANT', 'column', 'OCCUPANT_TYPE_ID'
	exec sys.sp_addextendedproperty 'MS_Description', 'Deleted Indicator: 1 if this record has been deleted in the source system, otherwise 0.', 'schema', 'dbo', 'table', 'B_RESERVATION_VEHICLE_OCCUPANT', 'column', 'DELETED_IND'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart Created Datetime: system date and time when this record was created in the mart.', 'schema', 'dbo', 'table', 'B_RESERVATION_VEHICLE_OCCUPANT', 'column', 'MART_CREATED_DTM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart Modified Datetime: system date and time when this record was last modified in the mart.', 'schema', 'dbo', 'table', 'B_RESERVATION_VEHICLE_OCCUPANT', 'column', 'MART_MODIFIED_DTM'
	exec sys.sp_addextendedproperty 'MS_Description', 'B Reservation Vehicle Occupant: Reservation vehicle occupant bridge table.', 'schema', 'dbo', 'table', 'B_RESERVATION_VEHICLE_OCCUPANT'

	PRINT '[INFO] CREATED TABLE [DBO].[B_RESERVATION_VEHICLE_OCCUPANT]'
END
GO

--INDEX: B_RESERVATION_VEHICLE_OCCUPANT_RESERVATION_VEHICLE_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_RESERVATION_VEHICLE_OCCUPANT]','U') AND i.name = 'B_RESERVATION_VEHICLE_OCCUPANT_RESERVATION_VEHICLE_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_RESERVATION_VEHICLE_OCCUPANT_RESERVATION_VEHICLE_KEY_IX] ON [dbo].[B_RESERVATION_VEHICLE_OCCUPANT]([RESERVATION_VEHICLE_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_RESERVATION_VEHICLE_OCCUPANT].[B_RESERVATION_VEHICLE_OCCUPANT_RESERVATION_VEHICLE_KEY_IX]'
END
GO

--INDEX: B_RESERVATION_VEHICLE_OCCUPANT_ITEM_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_RESERVATION_VEHICLE_OCCUPANT]','U') AND i.name = 'B_RESERVATION_VEHICLE_OCCUPANT_ITEM_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_RESERVATION_VEHICLE_OCCUPANT_ITEM_KEY_IX] ON [dbo].[B_RESERVATION_VEHICLE_OCCUPANT]([ITEM_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_RESERVATION_VEHICLE_OCCUPANT].[B_RESERVATION_VEHICLE_OCCUPANT_ITEM_KEY_IX]'
END
GO

--INDEX: B_RESERVATION_VEHICLE_OCCUPANT_PROFILE_VEHICLE_ID_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_RESERVATION_VEHICLE_OCCUPANT]','U') AND i.name = 'B_RESERVATION_VEHICLE_OCCUPANT_PROFILE_VEHICLE_ID_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_RESERVATION_VEHICLE_OCCUPANT_PROFILE_VEHICLE_ID_IX] ON [dbo].[B_RESERVATION_VEHICLE_OCCUPANT]([OCCUPANT_TYPE_ID]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_RESERVATION_VEHICLE_OCCUPANT].[B_RESERVATION_VEHICLE_OCCUPANT_PROFILE_VEHICLE_ID_IX]'
END
GO


/*

DO NOT deploy to UAT until TPWD CODE FREEZE finish

 * NOTES: Creates B_DAILY_ENTRANCE_OCCUPANT bridge for AspiraOne datamart 
 *
 * DATE        JIRA      USER             DESCRIPTION
 * ----------  --------  ---------------  ---------------------------------------
 * 04/19/2019  DMA-3756  Kelvin Wang	  Initialization.
*/

SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL READ COMMITTED

IF OBJECT_ID('DBO.B_DAILY_ENTRANCE_OCCUPANT') IS NULL
BEGIN
		CREATE TABLE [dbo].[B_DAILY_ENTRANCE_OCCUPANT](
			[DAILY_ENTRANCE_OCCUPANT_KEY]  bigint          IDENTITY(1,1),
			[ITEM_KEY]                  bigint          NULL,
			[OCCUPANT_TYPE_NM]          varchar(255)    NULL,
			[OCCUPANT_TYPE_CNT]         int             NULL,
			[OCCUPANT_TYPE_ID]          bigint          NULL,
			[DELETED_IND]               smallint        NULL,
			[MART_CREATED_DTM]          datetime        NULL,
			[MART_MODIFIED_DTM]         datetime        NULL
		CONSTRAINT PK_B_DAILY_ENTRANCE_OCCUPANT PRIMARY KEY CLUSTERED ([DAILY_ENTRANCE_OCCUPANT_KEY])
	) ON TX_CAMPING_MART_DATA

	exec sys.sp_addextendedproperty 'MS_Description', 'Daily Entrance Occupant Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'B_DAILY_ENTRANCE_OCCUPANT', 'column', 'DAILY_ENTRANCE_OCCUPANT_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Item Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'B_DAILY_ENTRANCE_OCCUPANT', 'column', 'ITEM_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Occupant Type Name: Name of occupant type.', 'schema', 'dbo', 'table', 'B_DAILY_ENTRANCE_OCCUPANT', 'column', 'OCCUPANT_TYPE_NM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Occupant Type Count: Count of certain occupant type.', 'schema', 'dbo', 'table', 'B_DAILY_ENTRANCE_OCCUPANT', 'column', 'OCCUPANT_TYPE_CNT'
	exec sys.sp_addextendedproperty 'MS_Description', 'Occupant Type Identifier:  source system identifier for order profile occupant type.', 'schema', 'dbo', 'table', 'B_DAILY_ENTRANCE_OCCUPANT', 'column', 'OCCUPANT_TYPE_ID'
	exec sys.sp_addextendedproperty 'MS_Description', 'Deleted Indicator: 1 if this record has been deleted in the source system, otherwise 0.', 'schema', 'dbo', 'table', 'B_DAILY_ENTRANCE_OCCUPANT', 'column', 'DELETED_IND'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart Created Datetime: system date and time when this record was created in the mart.', 'schema', 'dbo', 'table', 'B_DAILY_ENTRANCE_OCCUPANT', 'column', 'MART_CREATED_DTM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart Modified Datetime: system date and time when this record was last modified in the mart.', 'schema', 'dbo', 'table', 'B_DAILY_ENTRANCE_OCCUPANT', 'column', 'MART_MODIFIED_DTM'
	exec sys.sp_addextendedproperty 'MS_Description', 'B Daily Entrance Occupant: Daily Entrance occupant bridge table.', 'schema', 'dbo', 'table', 'B_DAILY_ENTRANCE_OCCUPANT'

	PRINT '[INFO] CREATED TABLE [DBO].[B_DAILY_ENTRANCE_OCCUPANT]'
END
GO

--INDEX: B_DAILY_ENTRANCE_OCCUPANT_ITEM_KEY_OCCUPANT_TYPE_ID_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_DAILY_ENTRANCE_OCCUPANT]','U') AND i.name = 'B_DAILY_ENTRANCE_OCCUPANT_ITEM_KEY_OCCUPANT_TYPE_ID_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_DAILY_ENTRANCE_OCCUPANT_ITEM_KEY_OCCUPANT_TYPE_ID_IX] ON [dbo].[B_DAILY_ENTRANCE_OCCUPANT]([ITEM_KEY], [OCCUPANT_TYPE_ID]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_DAILY_ENTRANCE_OCCUPANT].[B_DAILY_ENTRANCE_OCCUPANT_ITEM_KEY_OCCUPANT_TYPE_ID_IX]'
END
GO

--INDEX: B_DAILY_ENTRANCE_OCCUPANT_ITEM_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_DAILY_ENTRANCE_OCCUPANT]','U') AND i.name = 'B_DAILY_ENTRANCE_OCCUPANT_ITEM_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_DAILY_ENTRANCE_OCCUPANT_ITEM_KEY_IX] ON [dbo].[B_DAILY_ENTRANCE_OCCUPANT]([ITEM_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_DAILY_ENTRANCE_OCCUPANT].[B_DAILY_ENTRANCE_OCCUPANT_ITEM_KEY_IX]'
END
GO

/*

DO NOT deploy to UAT until TPWD CODE FREEZE finish

 * NOTES: Creates B_DAILY_ENTRANCE_VEHICLE bridge for AspiraOne datamart 
 *
 * DATE        JIRA      USER             DESCRIPTION
 * ----------  --------  ---------------  ---------------------------------------
 * 04/19/2019  DMA-3756  Kelvin Wang	  Initialization.
*/

SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL READ COMMITTED

IF OBJECT_ID('DBO.B_DAILY_ENTRANCE_VEHICLE') IS NULL
BEGIN
		CREATE TABLE [dbo].[B_DAILY_ENTRANCE_VEHICLE](
			[DAILY_ENTRANCE_VEHICLE_KEY]  bigint          IDENTITY(1,1),
			[ITEM_KEY]                 bigint          NULL,
			[VEHICLE_TYPE_NM]          varchar(255)    NULL,
			[VEHICLE_PLATE_NB]         varchar(255)    NULL,
			[VEHICLE_STATE_NM]         varchar(255)    NULL,
			[VEHICLE_MAKER_NM]         varchar(255)    NULL,
			[VEHICLE_MODEL_NM]         varchar(255)    NULL,
			[VEHICLE_COLOR_NM]         varchar(255)    NULL,
			[MART_SOURCE_ID]           bigint          NULL,
			[DELETED_IND]              smallint        NULL,
			[MART_CREATED_DTM]         datetime        NULL,
			[MART_MODIFIED_DTM]        datetime        NULL
		CONSTRAINT PK_B_DAILY_ENTRANCE_VEHICLE PRIMARY KEY CLUSTERED ([DAILY_ENTRANCE_VEHICLE_KEY])
	) ON TX_CAMPING_MART_DATA

	exec sys.sp_addextendedproperty 'MS_Description', 'Daily Entrance Vehicle Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'B_DAILY_ENTRANCE_VEHICLE', 'column', 'DAILY_ENTRANCE_VEHICLE_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Item Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'B_DAILY_ENTRANCE_VEHICLE', 'column', 'ITEM_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Vehicle Type Name: Name of vehicle type.', 'schema', 'dbo', 'table', 'B_DAILY_ENTRANCE_VEHICLE', 'column', 'VEHICLE_TYPE_NM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Vehicle Plate Number: Number of vehicle plate.', 'schema', 'dbo', 'table', 'B_DAILY_ENTRANCE_VEHICLE', 'column', 'VEHICLE_PLATE_NB'
	exec sys.sp_addextendedproperty 'MS_Description', 'Vehicle State Name: State name of vehicle.', 'schema', 'dbo', 'table', 'B_DAILY_ENTRANCE_VEHICLE', 'column', 'VEHICLE_STATE_NM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Vehicle Maker Name: Name of vehicle maker.', 'schema', 'dbo', 'table', 'B_DAILY_ENTRANCE_VEHICLE', 'column', 'VEHICLE_MAKER_NM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Vehicle Model Name: Name of vehicle model.', 'schema', 'dbo', 'table', 'B_DAILY_ENTRANCE_VEHICLE', 'column', 'VEHICLE_MODEL_NM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Vehicle Color Name: Name of vehicle color.', 'schema', 'dbo', 'table', 'B_DAILY_ENTRANCE_VEHICLE', 'column', 'VEHICLE_COLOR_NM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart Source Identifier: source system identifier for this record.', 'schema', 'dbo', 'table', 'B_DAILY_ENTRANCE_VEHICLE', 'column', 'MART_SOURCE_ID'
	exec sys.sp_addextendedproperty 'MS_Description', 'Deleted Indicator: 1 if this record has been deleted in the source system, otherwise 0.', 'schema', 'dbo', 'table', 'B_DAILY_ENTRANCE_VEHICLE', 'column', 'DELETED_IND'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart Created Datetime: system date and time when this record was created in the mart.', 'schema', 'dbo', 'table', 'B_DAILY_ENTRANCE_VEHICLE', 'column', 'MART_CREATED_DTM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart Modified Datetime: system date and time when this record was last modified in the mart.', 'schema', 'dbo', 'table', 'B_DAILY_ENTRANCE_VEHICLE', 'column', 'MART_MODIFIED_DTM'
	exec sys.sp_addextendedproperty 'MS_Description', 'B Daily Entrance Vehicle: Daily Entrance vehicle bridge table.', 'schema', 'dbo', 'table', 'B_DAILY_ENTRANCE_VEHICLE'

	PRINT '[INFO] CREATED TABLE [DBO].[B_DAILY_ENTRANCE_VEHICLE]'
END
GO

--INDEX: B_DAILY_ENTRANCE_VEHICLE_MART_SOURCE_ID_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_DAILY_ENTRANCE_VEHICLE]','U') AND i.name = 'B_DAILY_ENTRANCE_VEHICLE_MART_SOURCE_ID_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_DAILY_ENTRANCE_VEHICLE_MART_SOURCE_ID_IX] ON [dbo].[B_DAILY_ENTRANCE_VEHICLE]([MART_SOURCE_ID]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_DAILY_ENTRANCE_VEHICLE].[B_DAILY_ENTRANCE_VEHICLE_MART_SOURCE_ID_IX]'
END
GO

--INDEX: B_DAILY_ENTRANCE_VEHICLE_ITEM_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_DAILY_ENTRANCE_VEHICLE]','U') AND i.name = 'B_DAILY_ENTRANCE_VEHICLE_ITEM_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_DAILY_ENTRANCE_VEHICLE_ITEM_KEY_IX] ON [dbo].[B_DAILY_ENTRANCE_VEHICLE]([ITEM_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_DAILY_ENTRANCE_VEHICLE].[B_DAILY_ENTRANCE_VEHICLE_ITEM_KEY_IX]'
END
GO

/*

DO NOT deploy to UAT until TPWD CODE FREEZE finish

 * NOTES: Creates B_DAILY_ENTRANCE_VEHICLE_OCCUPANT bridge for AspiraOne datamart 
 *
 * DATE        JIRA      USER             DESCRIPTION
 * ----------  --------  ---------------  ---------------------------------------
 * 04/19/2019  DMA-3756  Kelvin Wang	  Initialization.
*/

SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL READ COMMITTED

IF OBJECT_ID('DBO.B_DAILY_ENTRANCE_VEHICLE_OCCUPANT') IS NULL
BEGIN
		CREATE TABLE [dbo].[B_DAILY_ENTRANCE_VEHICLE_OCCUPANT](
			[DAILY_ENTRANCE_VEHICLE_OCCUPANT_KEY]  bigint          IDENTITY(1,1),
			[ITEM_KEY]                          bigint          NULL,
			[DAILY_ENTRANCE_VEHICLE_KEY]           bigint          NULL,
			[OCCUPANT_TYPE_NM]                  varchar(255)    NULL,
			[OCCUPANT_TYPE_CNT]                 int             NULL,
			[PROFILE_VEHICLE_ID]                bigint          NULL,
			[OCCUPANT_TYPE_ID]                  bigint          NULL,
			[DELETED_IND]                       smallint        NULL,
			[MART_CREATED_DTM]                  datetime        NULL,
			[MART_MODIFIED_DTM]                 datetime        NULL
		CONSTRAINT PK_B_DAILY_ENTRANCE_VEHICLE_OCCUPANT PRIMARY KEY CLUSTERED ([DAILY_ENTRANCE_VEHICLE_OCCUPANT_KEY])
	) ON TX_CAMPING_MART_DATA

	exec sys.sp_addextendedproperty 'MS_Description', 'Daily Entrance Vehicle Occupant Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'B_DAILY_ENTRANCE_VEHICLE_OCCUPANT', 'column', 'DAILY_ENTRANCE_VEHICLE_OCCUPANT_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Item Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'B_DAILY_ENTRANCE_VEHICLE_OCCUPANT', 'column', 'ITEM_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Daily Entrance Vehicle Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'B_DAILY_ENTRANCE_VEHICLE_OCCUPANT', 'column', 'DAILY_ENTRANCE_VEHICLE_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Occupant Type Name: Name of occupant type.', 'schema', 'dbo', 'table', 'B_DAILY_ENTRANCE_VEHICLE_OCCUPANT', 'column', 'OCCUPANT_TYPE_NM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Occupant Type Count: Count of certain occupant type.', 'schema', 'dbo', 'table', 'B_DAILY_ENTRANCE_VEHICLE_OCCUPANT', 'column', 'OCCUPANT_TYPE_CNT'
	exec sys.sp_addextendedproperty 'MS_Description', 'Profile Vehicle Identifier: source system identifier for order profile vehicle.', 'schema', 'dbo', 'table', 'B_DAILY_ENTRANCE_VEHICLE_OCCUPANT', 'column', 'PROFILE_VEHICLE_ID'
	exec sys.sp_addextendedproperty 'MS_Description', 'Occupant Type Identifier:  source system identifier for order profile occupant type.', 'schema', 'dbo', 'table', 'B_DAILY_ENTRANCE_VEHICLE_OCCUPANT', 'column', 'OCCUPANT_TYPE_ID'
	exec sys.sp_addextendedproperty 'MS_Description', 'Deleted Indicator: 1 if this record has been deleted in the source system, otherwise 0.', 'schema', 'dbo', 'table', 'B_DAILY_ENTRANCE_VEHICLE_OCCUPANT', 'column', 'DELETED_IND'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart Created Datetime: system date and time when this record was created in the mart.', 'schema', 'dbo', 'table', 'B_DAILY_ENTRANCE_VEHICLE_OCCUPANT', 'column', 'MART_CREATED_DTM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart Modified Datetime: system date and time when this record was last modified in the mart.', 'schema', 'dbo', 'table', 'B_DAILY_ENTRANCE_VEHICLE_OCCUPANT', 'column', 'MART_MODIFIED_DTM'
	exec sys.sp_addextendedproperty 'MS_Description', 'B Daily Entrance Vehicle Occupant: Daily Entrance vehicle occupant bridge table.', 'schema', 'dbo', 'table', 'B_DAILY_ENTRANCE_VEHICLE_OCCUPANT'

	PRINT '[INFO] CREATED TABLE [DBO].[B_DAILY_ENTRANCE_VEHICLE_OCCUPANT]'
END
GO

--INDEX: B_DAILY_ENTRANCE_VEHICLE_OCCUPANT_DAILY_ENTRANCE_VEHICLE_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_DAILY_ENTRANCE_VEHICLE_OCCUPANT]','U') AND i.name = 'B_DAILY_ENTRANCE_VEHICLE_OCCUPANT_DAILY_ENTRANCE_VEHICLE_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_DAILY_ENTRANCE_VEHICLE_OCCUPANT_DAILY_ENTRANCE_VEHICLE_KEY_IX] ON [dbo].[B_DAILY_ENTRANCE_VEHICLE_OCCUPANT]([DAILY_ENTRANCE_VEHICLE_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_DAILY_ENTRANCE_VEHICLE_OCCUPANT].[B_DAILY_ENTRANCE_VEHICLE_OCCUPANT_DAILY_ENTRANCE_VEHICLE_KEY_IX]'
END
GO

--INDEX: B_DAILY_ENTRANCE_VEHICLE_OCCUPANT_ITEM_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_DAILY_ENTRANCE_VEHICLE_OCCUPANT]','U') AND i.name = 'B_DAILY_ENTRANCE_VEHICLE_OCCUPANT_ITEM_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_DAILY_ENTRANCE_VEHICLE_OCCUPANT_ITEM_KEY_IX] ON [dbo].[B_DAILY_ENTRANCE_VEHICLE_OCCUPANT]([ITEM_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_DAILY_ENTRANCE_VEHICLE_OCCUPANT].[B_DAILY_ENTRANCE_VEHICLE_OCCUPANT_ITEM_KEY_IX]'
END
GO

--INDEX: B_DAILY_ENTRANCE_VEHICLE_OCCUPANT_PROFILE_VEHICLE_ID_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_DAILY_ENTRANCE_VEHICLE_OCCUPANT]','U') AND i.name = 'B_DAILY_ENTRANCE_VEHICLE_OCCUPANT_PROFILE_VEHICLE_ID_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_DAILY_ENTRANCE_VEHICLE_OCCUPANT_PROFILE_VEHICLE_ID_IX] ON [dbo].[B_DAILY_ENTRANCE_VEHICLE_OCCUPANT]([OCCUPANT_TYPE_ID]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_DAILY_ENTRANCE_VEHICLE_OCCUPANT].[B_DAILY_ENTRANCE_VEHICLE_OCCUPANT_PROFILE_VEHICLE_ID_IX]'
END
GO


IF NOT EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_ORDER') AND name='CONFIRMATION_STATUS_NM')
BEGIN
	ALTER TABLE dbo.D_ORDER ADD CONFIRMATION_STATUS_NM varchar(100) NULL
	exec sys.sp_addextendedproperty 'MS_Description', 'Confirmation status name.', 'schema', 'dbo', 'table', 'D_ORDER', 'column', 'CONFIRMATION_STATUS_NM'
	PRINT '[INFO] ADD COLUMN [DBO].[D_ORDER].[CONFIRMATION_STATUS_NM]'
END

IF NOT EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_ORDER') AND name='TOTAL_DISCOUNT_AMT')
BEGIN
	ALTER TABLE dbo.D_ORDER ADD TOTAL_DISCOUNT_AMT decimal(38, 6) NULL
	exec sys.sp_addextendedproperty 'MS_Description', 'Total Discount Amount: the total of discounts applied to this order.', 'schema', 'dbo', 'table', 'D_ORDER', 'column', 'TOTAL_DISCOUNT_AMT'
	PRINT '[INFO] ADD COLUMN [DBO].[D_ORDER].[TOTAL_DISCOUNT_AMT]'
END



/*
 * NOTES: Creates B_TICKET_TOUR dimension for AspiraOne datamart 
 *
 * DATE        JIRA      USER             DESCRIPTION
 * ----------  --------  ---------------  ---------------------------------------
 * 06/26/2019  DMA-3739  Zongpei Liu	  Initialization.
*/

SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL READ COMMITTED

IF OBJECT_ID('DBO.B_TICKET_TOUR') IS NULL
BEGIN
	CREATE TABLE DBO.B_TICKET_TOUR(
		B_TICKET_TOUR_KEY           bigint          IDENTITY(1,1),
		ITEM_KEY                    bigint          NULL,
		TOUR_NM                     varchar(255)    NULL,
		TOUR_START_DT               date            NULL,
		TOUR_END_DT                 date            NULL,
		MULTIPLE_DAYS_IND           smallint        NULL,
		TOUR_START_TIME_TXT         varchar(10)     NULL,
		TOUR_END_TIME_TXT           varchar(10)     NULL,
		DELIVERY_METHOD_NM          varchar(255)    NULL,
		TICKET_STATUS_NM            varchar(255)    NULL,
		TOUR_STATUS_NM              varchar(255)    NULL,
		TICKET_TYPE_NM              varchar(255)    NULL,
		TICKET_QTY                  int             NULL,
		PRINTED_CNT                 int             NULL,
		TOUR_INSTANCE_ID            int             NULL,
		ADMISSION_TYPE_ID           int             NULL,
		TOUR_INVENTORY_ID           int             NULL,
		MART_CREATED_DTM            datetime        NULL,
		MART_MODIFIED_DTM           datetime        NULL,
		CONSTRAINT PK_B_TICKET_TOUR PRIMARY KEY CLUSTERED (B_TICKET_TOUR_KEY)
	) ON TX_CAMPING_MART_DATA

	exec sys.sp_addextendedproperty 'MS_Description', 'Ticket Tour Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'DBO', 'table', 'B_TICKET_TOUR', 'column', 'B_TICKET_TOUR_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Item Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'DBO', 'table', 'B_TICKET_TOUR', 'column', 'ITEM_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Tour Start date:Tour Start date', 'schema', 'DBO', 'table', 'B_TICKET_TOUR', 'column', 'TOUR_START_DT'
	exec sys.sp_addextendedproperty 'MS_Description', 'Tour End Date:Tour End Date', 'schema', 'DBO', 'table', 'B_TICKET_TOUR', 'column', 'TOUR_END_DT'
	exec sys.sp_addextendedproperty 'MS_Description', 'Multiple Days Indictor:Multiple Days Indictor', 'schema', 'DBO', 'table', 'B_TICKET_TOUR', 'column', 'MULTIPLE_DAYS_IND'
	exec sys.sp_addextendedproperty 'MS_Description', 'Tour Start time text:Tour Start time text', 'schema', 'DBO', 'table', 'B_TICKET_TOUR', 'column', 'TOUR_START_TIME_TXT'
	exec sys.sp_addextendedproperty 'MS_Description', 'Tour End Time Text:Tour End Time Text', 'schema', 'DBO', 'table', 'B_TICKET_TOUR', 'column', 'TOUR_END_TIME_TXT'
	exec sys.sp_addextendedproperty 'MS_Description', 'Delivery Method Name: Delivery Method Name', 'schema', 'DBO', 'table', 'B_TICKET_TOUR', 'column', 'DELIVERY_METHOD_NM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Ticket Status Name:Ticket Status Name', 'schema', 'DBO', 'table', 'B_TICKET_TOUR', 'column', 'TICKET_STATUS_NM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Tour Status Name:Tour Status Name', 'schema', 'DBO', 'table', 'B_TICKET_TOUR', 'column', 'TOUR_STATUS_NM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Ticket Type Name: ticket type name.', 'schema', 'DBO', 'table', 'B_TICKET_TOUR', 'column', 'TICKET_TYPE_NM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Ticket quantity: ticket quantity.', 'schema', 'DBO', 'table', 'B_TICKET_TOUR', 'column', 'TICKET_QTY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Print count:Print count', 'schema', 'DBO', 'table', 'B_TICKET_TOUR', 'column', 'PRINTED_CNT'
	exec sys.sp_addextendedproperty 'MS_Description', 'Tour Instance ID:Tour Instance ID', 'schema', 'DBO', 'table', 'B_TICKET_TOUR', 'column', 'TOUR_INSTANCE_ID'
	exec sys.sp_addextendedproperty 'MS_Description', 'Admission Type ID:Admission Type ID', 'schema', 'DBO', 'table', 'B_TICKET_TOUR', 'column', 'ADMISSION_TYPE_ID'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart Created Datetime: system date and time when this record was created in the mart.', 'schema', 'DBO', 'table', 'B_TICKET_TOUR', 'column', 'MART_CREATED_DTM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart Modified Datetime: system date and time when this record was last modified in the mart.', 'schema', 'DBO', 'table', 'B_TICKET_TOUR', 'column', 'MART_MODIFIED_DTM'
	exec sys.sp_addextendedproperty 'MS_Description', 'B_Ticket_Tour: tour detail info.', 'schema', 'DBO', 'table', 'B_TICKET_TOUR'

	PRINT '[INFO] CREATED TABLE [DBO].[B_TICKET_TOUR]'
END
GO

IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_TICKET_TOUR]','U') AND i.name = 'B_TICKET_TOUR_ITEM_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_TICKET_TOUR_ITEM_KEY_IX] ON [dbo].[B_TICKET_TOUR]([ITEM_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_TICKET_TOUR].[B_TICKET_TOUR_ITEM_KEY_IX]'
END
GO

IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_TICKET_TOUR]','U') AND i.name = 'B_TICKET_TOUR_MART_SOURCE_ID_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_TICKET_TOUR_MART_SOURCE_ID_IX] ON [dbo].[B_TICKET_TOUR](TOUR_INSTANCE_ID, ADMISSION_TYPE_ID) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_TICKET_TOUR].[B_TICKET_TOUR_MART_SOURCE_ID_IX]'
END
GO

IF NOT EXISTS(SELECT * FROM sysobjects WHERE xtype = 'U' AND uid = 1 AND NAME = 'D_TICKET_BK20190729')
BEGIN
	SELECT * INTO D_TICKET_BK20190729 FROM D_TICKET WITH(NOLOCK)
	PRINT 'Backuped D_TICKET'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='ADULT_13_OVER_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN ADULT_13_OVER_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[ADULT_13_OVER_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='YOUTH_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN YOUTH_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[YOUTH_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='SIX_UP_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN SIX_UP_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[SIX_UP_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='FIVE_UNDER_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN FIVE_UNDER_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[FIVE_UNDER_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='TWO_UNDER_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN TWO_UNDER_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[TWO_UNDER_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='GA_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN GA_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[GA_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='GAC_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN GAC_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[GAC_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='TOUR_GUIDE_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN TOUR_GUIDE_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[TOUR_GUIDE_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='SELF_GUIDED_AUDIO_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN SELF_GUIDED_AUDIO_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[SELF_GUIDED_AUDIO_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='SELF_GUIDED_NON_AUDIO_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN SELF_GUIDED_NON_AUDIO_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[SELF_GUIDED_NON_AUDIO_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='MOTORCOACH_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN MOTORCOACH_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[MOTORCOACH_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='ALL_TYPES_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN ALL_TYPES_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[ALL_TYPES_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='SENIOR_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN SENIOR_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[SENIOR_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='DVET_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN DVET_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[DVET_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='COMP_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN COMP_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[COMP_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='GENERAL_ADMISSION_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN GENERAL_ADMISSION_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[GENERAL_ADMISSION_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='ADULT_PRE_PAID_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN ADULT_PRE_PAID_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[ADULT_PRE_PAID_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='CHILD_12_UNDER_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN CHILD_12_UNDER_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[CHILD_12_UNDER_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='STUDENT_1_SITE_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN STUDENT_1_SITE_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[STUDENT_1_SITE_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='STUDENT_2_SITE_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN STUDENT_2_SITE_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[STUDENT_2_SITE_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='STUDENT_3_SITE_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN STUDENT_3_SITE_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[STUDENT_3_SITE_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='ADULT_W10_STUDENTS_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN ADULT_W10_STUDENTS_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[ADULT_W10_STUDENTS_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='BUS_DRIVER_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN BUS_DRIVER_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[BUS_DRIVER_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='CHILDREN_0_5_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN CHILDREN_0_5_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[CHILDREN_0_5_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='CHILDREN_6_15_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN CHILDREN_6_15_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[CHILDREN_6_15_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='STUDENT_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN STUDENT_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[STUDENT_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='FAMILY_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN FAMILY_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[FAMILY_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='CHILD_0_4_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN CHILD_0_4_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[CHILD_0_4_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='CHILD_5_12_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN CHILD_5_12_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[CHILD_5_12_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='SCHOOL_GROUP_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN SCHOOL_GROUP_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[SCHOOL_GROUP_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='YOUTH_GROUP_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN YOUTH_GROUP_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[YOUTH_GROUP_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='ACTIVE_RETIRED_MILITARY_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN ACTIVE_RETIRED_MILITARY_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[ACTIVE_RETIRED_MILITARY_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='GROUP_ENTRY_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN GROUP_ENTRY_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[GROUP_ENTRY_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='CHILD_6_12_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN CHILD_6_12_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[CHILD_6_12_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='ADULT_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN ADULT_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[ADULT_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='CHILD_4_11_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN CHILD_4_11_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[CHILD_4_11_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='CHILD_0_3_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN CHILD_0_3_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[CHILD_0_3_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='SENIOR_65_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN SENIOR_65_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[SENIOR_65_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='ADULT_1_SITE_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN ADULT_1_SITE_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[ADULT_1_SITE_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='ADULT_2_SITE_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN ADULT_2_SITE_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[ADULT_2_SITE_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='ADULT_3_SITE_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN ADULT_3_SITE_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[ADULT_3_SITE_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='CHILD_UNDER_13_ROUND_TRIP_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN CHILD_UNDER_13_ROUND_TRIP_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[CHILD_UNDER_13_ROUND_TRIP_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='CHILD_UNDER_13_ONE_WAY_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN CHILD_UNDER_13_ONE_WAY_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[CHILD_UNDER_13_ONE_WAY_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='ADULT_13_OVER_ONE_WAY_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN ADULT_13_OVER_ONE_WAY_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[ADULT_13_OVER_ONE_WAY_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='ADULT_13_OVER_ROUND_TRIP_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN ADULT_13_OVER_ROUND_TRIP_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[ADULT_13_OVER_ROUND_TRIP_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='TPWD_EMPLOYEE_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN TPWD_EMPLOYEE_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[TPWD_EMPLOYEE_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='CHILD_0_5_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN CHILD_0_5_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[CHILD_0_5_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='CHILD_0_12_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN CHILD_0_12_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[CHILD_0_12_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='CHILD_0_18_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN CHILD_0_18_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[CHILD_0_18_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='FAMILY_TICKET_NON_REFUNDABLE_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN FAMILY_TICKET_NON_REFUNDABLE_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[FAMILY_TICKET_NON_REFUNDABLE_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='ADULT_GROUP_BF_IH_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN ADULT_GROUP_BF_IH_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[ADULT_GROUP_BF_IH_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='ADULT_GROUP_BF_M_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN ADULT_GROUP_BF_M_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[ADULT_GROUP_BF_M_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='ADULT_GROUP_IH_BF_M_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN ADULT_GROUP_IH_BF_M_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[ADULT_GROUP_IH_BF_M_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='ADULT_GROUP_IH_M_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN ADULT_GROUP_IH_M_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[ADULT_GROUP_IH_M_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='GROUP_BUS_DRIVER_TEACHER_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN GROUP_BUS_DRIVER_TEACHER_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[GROUP_BUS_DRIVER_TEACHER_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='STUDENT_GROUP_BF_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN STUDENT_GROUP_BF_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[STUDENT_GROUP_BF_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='STUDENT_GROUP_BF_IH_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN STUDENT_GROUP_BF_IH_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[STUDENT_GROUP_BF_IH_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='STUDENT_GROUP_BF_IH_M_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN STUDENT_GROUP_BF_IH_M_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[STUDENT_GROUP_BF_IH_M_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='STUDENT_GROUP_BF_M_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN STUDENT_GROUP_BF_M_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[STUDENT_GROUP_BF_M_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='STUDENT_GROUP_IH_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN STUDENT_GROUP_IH_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[STUDENT_GROUP_IH_QTY]'
END


IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='STUDENT_GROUP_IH_M_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN STUDENT_GROUP_IH_M_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[STUDENT_GROUP_IH_M_QTY]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='TOUR_START_DT')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN TOUR_START_DT
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[TOUR_START_DT]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='TOUR_END_DT')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN TOUR_END_DT
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[TOUR_END_DT]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='MULTIPLE_DAYS_IND')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN MULTIPLE_DAYS_IND
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[MULTIPLE_DAYS_IND]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='TOUR_START_TIME_TXT')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN TOUR_START_TIME_TXT
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[TOUR_START_TIME_TXT]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='TOUR_END_TIME_TXT')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN TOUR_END_TIME_TXT
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[TOUR_END_TIME_TXT]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='TOTAL_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN TOTAL_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[TOTAL_QTY]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='PRINTED_QTY')
BEGIN
        ALTER TABLE D_TICKET DROP COLUMN PRINTED_QTY
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_TICKET].[PRINTED_QTY]'
END


IF NOT EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='TOUR_NM')
BEGIN
	ALTER TABLE D_TICKET ADD TOUR_NM varchar(255) NULL
	exec sys.sp_addextendedproperty 'MS_Description', 'Tour Name.', 'schema', 'dbo', 'table', 'D_TICKET', 'column', 'TOUR_NM'
	PRINT '[INFO] ADD COLUMN [DBO].[D_TICKET].[TOUR_NM]'
END

IF NOT EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='TICKET_CONFIRMATION_STATUS_NM')
BEGIN
	ALTER TABLE D_TICKET ADD TICKET_CONFIRMATION_STATUS_NM varchar(100) NULL
	exec sys.sp_addextendedproperty 'MS_Description', 'Ticket confirmation status name.', 'schema', 'dbo', 'table', 'D_TICKET', 'column', 'TICKET_CONFIRMATION_STATUS_NM'
	PRINT '[INFO] ADD COLUMN [DBO].[D_TICKET].[TICKET_CONFIRMATION_STATUS_NM]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_TICKET') AND name='CONFIRMATION_STATUS_NM')
BEGIN
	EXEC sp_RENAME 'D_TICKET.CONFIRMATION_STATUS_NM' , 'TOUR_CONFIRMATION_STATUS_NM', 'COLUMN'
	PRINT '[INFO] Renamed COLUMN [DBO].[D_TICKET.CONFIRMATION_STATUS_NM] to TOUR_CONFIRMATION_STATUS_NM'
END
GO

/*
 * NOTES: Creates B_SITE_ATTRIBUTES dimension for AspiraOne datamart 
 *
 * DATE        JIRA      USER             DESCRIPTION
 * ----------  --------  ---------------  ---------------------------------------
 * 4/08/2019   DMA-3755   Kelvin Wang      Initialization.
 * 6/3/2019    DMA-4252   Kelvin Wang      added ATTRIBUTE_GROUP_NM.
*/

SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL READ COMMITTED

IF OBJECT_ID('DBO.B_SITE_ATTRIBUTES') IS NULL
BEGIN
	CREATE TABLE DBO.B_SITE_ATTRIBUTES(
			[SITE_ATTRIBUTES_KEY]                bigint            IDENTITY(1,1),
			[PRODUCT_KEY]                        bigint            NULL,
			[ATTRIBUTE_NM]                       varchar(255)      NULL,
			[ATTRIBUTE_VALUE_TXT]                varchar(4000)     NULL,
			[PRODUCT_ID]                         bigint            NULL,
			[PRODUCT_ATTRIBUTE_ID]               bigint            NULL,
			[MART_CREATED_DTM]                   datetime          NULL,
			[MART_MODIFIED_DTM]                  datetime          NULL
        CONSTRAINT PK_B_SITE_ATTRIBUTES PRIMARY KEY CLUSTERED (SITE_ATTRIBUTES_KEY)
	) ON TX_CAMPING_MART_DATA

	exec sys.sp_addextendedproperty 'MS_Description', 'Site Attributes Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'B_SITE_ATTRIBUTES', 'column', 'SITE_ATTRIBUTES_KEY'	
    exec sys.sp_addextendedproperty 'MS_Description', 'Product Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'B_SITE_ATTRIBUTES', 'column', 'PRODUCT_KEY'	
	exec sys.sp_addextendedproperty 'MS_Description', 'Site attribute name.', 'schema', 'dbo', 'table', 'B_SITE_ATTRIBUTES', 'column', 'ATTRIBUTE_NM'	
	exec sys.sp_addextendedproperty 'MS_Description', 'Site attribute value.', 'schema', 'dbo', 'table', 'B_SITE_ATTRIBUTES', 'column', 'ATTRIBUTE_VALUE_TXT'
	exec sys.sp_addextendedproperty 'MS_Description', 'Product ID in the source.', 'schema', 'dbo', 'table', 'B_SITE_ATTRIBUTES', 'column', 'PRODUCT_ID'
	exec sys.sp_addextendedproperty 'MS_Description', 'Product Attribute ID in the source.', 'schema', 'dbo', 'table', 'B_SITE_ATTRIBUTES', 'column', 'PRODUCT_ATTRIBUTE_ID'
    exec sys.sp_addextendedproperty 'MS_Description', 'Mart Modified Datetime: system date and time when this record was last modified in the mart.', 'schema', 'dbo', 'table', 'B_SITE_ATTRIBUTES', 'column', 'MART_MODIFIED_DTM'
    exec sys.sp_addextendedproperty 'MS_Description', 'Site Attributes: bridge table to maintain 1 to many relationship site and attributes.', 'schema', 'dbo', 'table', 'B_SITE_ATTRIBUTES'
	
	PRINT '[INFO] CREATED TABLE [DBO].[B_SITE_ATTRIBUTES]'
END
GO

--INDEX: B_SITE_ATTRIBUTES_MART_SOURCE_ID_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_SITE_ATTRIBUTES]','U') AND i.name = 'B_SITE_ATTRIBUTES_MART_SOURCE_ID_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_SITE_ATTRIBUTES_MART_SOURCE_ID_IX] ON [dbo].[B_SITE_ATTRIBUTES]([PRODUCT_ID],[PRODUCT_ATTRIBUTE_ID]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_SITE_ATTRIBUTES].[B_SITE_ATTRIBUTES_MART_SOURCE_ID_IX]'
END
GO

--INDEX: B_SITE_ATTRIBUTES_PRODUCT_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_SITE_ATTRIBUTES]','U') AND i.name = 'B_SITE_ATTRIBUTES_PRODUCT_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_SITE_ATTRIBUTES_PRODUCT_KEY_IX] ON [dbo].[B_SITE_ATTRIBUTES]([PRODUCT_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_SITE_ATTRIBUTES].[B_SITE_ATTRIBUTES_PRODUCT_KEY_IX]'
END
GO

--DMA-4252 added ATTRIBUTE_GROUP_NM.
IF NOT EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.B_SITE_ATTRIBUTES') AND name='ATTRIBUTE_GROUP_NM')
BEGIN
	ALTER TABLE B_SITE_ATTRIBUTES ADD ATTRIBUTE_GROUP_NM varchar(255) NULL
	exec sys.sp_addextendedproperty 'MS_Description', 'payment allocation datetime', 'schema', 'dbo', 'table', 'B_SITE_ATTRIBUTES', 'column', 'ATTRIBUTE_GROUP_NM'
	PRINT '[INFO] ADD COLUMN [DBO].[B_SITE_ATTRIBUTES].[ATTRIBUTE_GROUP_NM]'
END


/*

 * NOTES: Creates B_ORDER_TRANS_MESSAGE bridge for AspiraOne datamart 
 *
 * DATE        JIRA      USER             DESCRIPTION
 * ----------  --------  ---------------  ---------------------------------------
 * 04/17/2019  DMA-3521  Zongpei Liu	  Initialization.

*/

SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL READ COMMITTED

IF OBJECT_ID('DBO.B_ORDER_TRANS_MESSAGE') IS NULL
BEGIN
	CREATE TABLE DBO.B_ORDER_TRANS_MESSAGE(
		ORDER_TRANS_MESSAGE_KEY              bigint           IDENTITY(1,1),
		ORDER_KEY                            bigint           NULL,
		MESSAGE_CREATED_DTM                  datetime         NULL,
		MESSAGE_TXT                          varchar(255)     NULL,
		CREATED_USER_KEY                     bigint           NULL,
		CREATED_LOCATION_KEY                 bigint           NULL,
		MART_SOURCE_ID                       bigint           NULL,
		MART_CREATED_DTM                     datetime         NULL,
		MART_MODIFIED_DTM                    datetime         NULL,
		CONSTRAINT PK_B_ORDER_TRANS_MESSAGE PRIMARY KEY CLUSTERED (ORDER_TRANS_MESSAGE_KEY)
	) ON TX_CAMPING_MART_DATA

	exec sys.sp_addextendedproperty 'MS_Description', 'Order Transaction Message Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'B_ORDER_TRANS_MESSAGE', 'column', 'ORDER_TRANS_MESSAGE_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Order Key: surrogate key uniquely identifying this record in the mart.', 'schema', 'dbo', 'table', 'B_ORDER_TRANS_MESSAGE', 'column', 'ORDER_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Message Created Date Time: message created time in source.', 'schema', 'dbo', 'table', 'B_ORDER_TRANS_MESSAGE', 'column', 'MESSAGE_CREATED_DTM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Message Text; message content.', 'schema', 'dbo', 'table', 'B_ORDER_TRANS_MESSAGE', 'column', 'MESSAGE_TXT'
	exec sys.sp_addextendedproperty 'MS_Description', 'User Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'B_ORDER_TRANS_MESSAGE', 'column', 'CREATED_USER_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Location Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'B_ORDER_TRANS_MESSAGE', 'column', 'CREATED_LOCATION_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart Source Identifier: source system identifier for this record.', 'schema', 'dbo', 'table', 'B_ORDER_TRANS_MESSAGE', 'column', 'MART_SOURCE_ID'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart Created Datetime: system date and time when this record was created in the mart.', 'schema', 'dbo', 'table', 'B_ORDER_TRANS_MESSAGE', 'column', 'MART_CREATED_DTM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart Modified Datetime: system date and time when this record was last modified in the mart.', 'schema', 'dbo', 'table', 'B_ORDER_TRANS_MESSAGE', 'column', 'MART_MODIFIED_DTM'
	exec sys.sp_addextendedproperty 'MS_Description', 'B_Order_Transaction_Message: order transaction message.', 'schema', 'dbo', 'table', 'B_ORDER_TRANS_MESSAGE'

	PRINT '[INFO] CREATED TABLE [DBO].[B_ORDER_TRANS_MESSAGE]'
END

--INDEX: B_ORDER_TRANS_MESSAGE_MART_SOURCE_ID_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_ORDER_TRANS_MESSAGE]','U') AND i.name = 'B_ORDER_TRANS_MESSAGE_MART_SOURCE_ID_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_ORDER_TRANS_MESSAGE_MART_SOURCE_ID_IX] ON [dbo].[B_ORDER_TRANS_MESSAGE]([MART_SOURCE_ID]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_ORDER_TRANS_MESSAGE].[B_ORDER_TRANS_MESSAGE_MART_SOURCE_ID_IX]'
END
GO

--INDEX: B_ORDER_TRANS_MESSAGE_ORDER_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_ORDER_TRANS_MESSAGE]','U') AND i.name = 'B_ORDER_TRANS_MESSAGE_ORDER_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_ORDER_TRANS_MESSAGE_ORDER_KEY_IX] ON [dbo].[B_ORDER_TRANS_MESSAGE]([ORDER_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_ORDER_TRANS_MESSAGE].[B_ORDER_TRANS_MESSAGE_ORDER_KEY_IX]'
END
GO

--INDEX: B_ORDER_TRANS_MESSAGE_CREATED_USER_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_ORDER_TRANS_MESSAGE]','U') AND i.name = 'B_ORDER_TRANS_MESSAGE_CREATED_USER_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_ORDER_TRANS_MESSAGE_CREATED_USER_KEY_IX] ON [dbo].[B_ORDER_TRANS_MESSAGE]([CREATED_USER_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_ORDER_TRANS_MESSAGE].[B_ORDER_TRANS_MESSAGE_CREATED_USER_KEY_IX]'
END
GO

--INDEX: B_ORDER_TRANS_MESSAGE_CREATED_LOCATION_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_ORDER_TRANS_MESSAGE]','U') AND i.name = 'B_ORDER_TRANS_MESSAGE_CREATED_LOCATION_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_ORDER_TRANS_MESSAGE_CREATED_LOCATION_KEY_IX] ON [dbo].[B_ORDER_TRANS_MESSAGE]([CREATED_LOCATION_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_ORDER_TRANS_MESSAGE].[B_ORDER_TRANS_MESSAGE_CREATED_LOCATION_KEY_IX]'
END
GO




/*

 * NOTES: Creates B_ORDER_ITEM_TRANS_MESSAGE bridge for AspiraOne datamart 
 *
 * DATE        JIRA      USER             DESCRIPTION
 * ----------  --------  ---------------  ---------------------------------------
 * 04/17/2019  DMA-3521  Zongpei Liu	  Initialization.

*/

SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL READ COMMITTED

IF OBJECT_ID('DBO.B_ORDER_ITEM_TRANS_MESSAGE') IS NULL
BEGIN
	CREATE TABLE DBO.B_ORDER_ITEM_TRANS_MESSAGE(
		ORDER_ITEM_TRANS_MESSAGE_KEY         bigint           IDENTITY(1,1),
		ITEM_KEY                             bigint           NULL,
		MESSAGE_CREATED_DTM                  datetime         NULL,
		MESSAGE_TXT                          varchar(255)     NULL,
		CREATED_USER_KEY                     bigint           NULL,
		CREATED_LOCATION_KEY                 bigint           NULL,
		MART_SOURCE_ID                       bigint           NULL,
		MART_CREATED_DTM                     datetime         NULL,
		MART_MODIFIED_DTM                    datetime         NULL,
		CONSTRAINT PK_B_ORDER_ITEM_TRANS_MESSAGE PRIMARY KEY CLUSTERED (ORDER_ITEM_TRANS_MESSAGE_KEY)
	) ON TX_CAMPING_MART_DATA

	exec sys.sp_addextendedproperty 'MS_Description', 'Order Item Transaction Message Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'B_ORDER_ITEM_TRANS_MESSAGE', 'column', 'ORDER_ITEM_TRANS_MESSAGE_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Order Key: surrogate key uniquely identifying this record in the mart.', 'schema', 'dbo', 'table', 'B_ORDER_ITEM_TRANS_MESSAGE', 'column', 'ITEM_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Message Created Date Time: message created time in source.', 'schema', 'dbo', 'table', 'B_ORDER_ITEM_TRANS_MESSAGE', 'column', 'MESSAGE_CREATED_DTM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Message Text; message content.', 'schema', 'dbo', 'table', 'B_ORDER_ITEM_TRANS_MESSAGE', 'column', 'MESSAGE_TXT'
	exec sys.sp_addextendedproperty 'MS_Description', 'User Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'B_ORDER_ITEM_TRANS_MESSAGE', 'column', 'CREATED_USER_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Location Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'B_ORDER_ITEM_TRANS_MESSAGE', 'column', 'CREATED_LOCATION_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart Source Identifier: source system identifier for this record.', 'schema', 'dbo', 'table', 'B_ORDER_ITEM_TRANS_MESSAGE', 'column', 'MART_SOURCE_ID'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart Created Datetime: system date and time when this record was created in the mart.', 'schema', 'dbo', 'table', 'B_ORDER_ITEM_TRANS_MESSAGE', 'column', 'MART_CREATED_DTM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart Modified Datetime: system date and time when this record was last modified in the mart.', 'schema', 'dbo', 'table', 'B_ORDER_ITEM_TRANS_MESSAGE', 'column', 'MART_MODIFIED_DTM'
	exec sys.sp_addextendedproperty 'MS_Description', 'B_Order_Item_Transaction_Message: order item transaction message.', 'schema', 'dbo', 'table', 'B_ORDER_ITEM_TRANS_MESSAGE'

	PRINT '[INFO] CREATED TABLE [DBO].[B_ORDER_ITEM_TRANS_MESSAGE]'
END

--INDEX: B_ORDER_ITEM_TRANS_MESSAGE_MART_SOURCE_ID_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_ORDER_ITEM_TRANS_MESSAGE]','U') AND i.name = 'B_ORDER_ITEM_TRANS_MESSAGE_MART_SOURCE_ID_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_ORDER_ITEM_TRANS_MESSAGE_MART_SOURCE_ID_IX] ON [dbo].[B_ORDER_ITEM_TRANS_MESSAGE]([MART_SOURCE_ID]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_ORDER_ITEM_TRANS_MESSAGE].[B_ORDER_ITEM_TRANS_MESSAGE_MART_SOURCE_ID_IX]'
END
GO

--INDEX: B_ORDER_ITEM_TRANS_MESSAGE_ITEM_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_ORDER_ITEM_TRANS_MESSAGE]','U') AND i.name = 'B_ORDER_ITEM_TRANS_MESSAGE_ITEM_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_ORDER_ITEM_TRANS_MESSAGE_ITEM_KEY_IX] ON [dbo].[B_ORDER_ITEM_TRANS_MESSAGE]([ITEM_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_ORDER_ITEM_TRANS_MESSAGE].[B_ORDER_ITEM_TRANS_MESSAGE_ITEM_KEY_IX]'
END
GO

--INDEX: B_ORDER_ITEM_TRANS_MESSAGE_CREATED_USER_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_ORDER_ITEM_TRANS_MESSAGE]','U') AND i.name = 'B_ORDER_ITEM_TRANS_MESSAGE_CREATED_USER_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_ORDER_ITEM_TRANS_MESSAGE_CREATED_USER_KEY_IX] ON [dbo].[B_ORDER_ITEM_TRANS_MESSAGE]([CREATED_USER_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_ORDER_ITEM_TRANS_MESSAGE].[B_ORDER_ITEM_TRANS_MESSAGE_CREATED_USER_KEY_IX]'
END
GO

--INDEX: B_ORDER_ITEM_TRANS_MESSAGE_CREATED_LOCATION_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_ORDER_ITEM_TRANS_MESSAGE]','U') AND i.name = 'B_ORDER_ITEM_TRANS_MESSAGE_CREATED_LOCATION_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_ORDER_ITEM_TRANS_MESSAGE_CREATED_LOCATION_KEY_IX] ON [dbo].[B_ORDER_ITEM_TRANS_MESSAGE]([CREATED_LOCATION_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_ORDER_ITEM_TRANS_MESSAGE].[B_ORDER_ITEM_TRANS_MESSAGE_CREATED_LOCATION_KEY_IX]'
END
GO



/*

DO NOT deploy until TPWD CODE FREEZE finish


 * NOTES: Creates B_LOCATION_MESSAGE bridge for AspiraOne datamart 
 *
 * DATE        JIRA      USER             DESCRIPTION
 * ----------  --------  ---------------  ---------------------------------------
 * 01/24/2019  DMA-2916  Zongpei Liu	  Initialization.
*/

SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL READ COMMITTED

IF OBJECT_ID('DBO.B_LOCATION_MESSAGE') IS NULL
BEGIN
	CREATE TABLE DBO.B_LOCATION_MESSAGE(
		MESSAGE_KEY                          bigint           IDENTITY(1,1),
		LOCATION_KEY                         bigint           NULL,
		MESSAGE_TYPE_NM                      varchar(50)      NULL,
		MESSAGE_CREATED_DTM                  datetime         NULL,
		MESSAGE_START_DT                     date             NULL,
		MESSAGE_END_DT                       date             NULL,
		MESSAGE_TXT                          varchar(4000)    NULL,
		INCLUDE_IN_CONFIMATION_LETTER_IND    smallint         NULL,
		INCLUDE_IN_RECEIPT_IND               smallint         NULL,
		INCLUDE_IN_PRINTED_PERMIT_IND        smallint         NULL,
		APPLY_TO_TXT                         varchar(50)      NULL,
		CREATED_USER_KEY                     bigint           NULL,
		CREATED_LOCATION_KEY                 bigint           NULL,
		ACTIVE_IND                           smallint         NULL,
		DELETED_IND                          smallint         NULL,
		MART_SOURCE_ID                       bigint           NULL,
		MART_CREATED_DTM                     datetime         NULL,
		MART_MODIFIED_DTM                    datetime         NULL,
		CONSTRAINT PK_B_LOCATION_MESSAGE PRIMARY KEY CLUSTERED (MESSAGE_KEY)
	) ON TX_CAMPING_MART_DATA

	exec sys.sp_addextendedproperty 'MS_Description', 'Message Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'B_LOCATION_MESSAGE', 'column', 'MESSAGE_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Location Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'B_LOCATION_MESSAGE', 'column', 'LOCATION_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Message Type Name: message type like note/alter.', 'schema', 'dbo', 'table', 'B_LOCATION_MESSAGE', 'column', 'MESSAGE_TYPE_NM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Message Created Date Time: message created time in source.', 'schema', 'dbo', 'table', 'B_LOCATION_MESSAGE', 'column', 'MESSAGE_CREATED_DTM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Message Start Date: message start date.', 'schema', 'dbo', 'table', 'B_LOCATION_MESSAGE', 'column', 'MESSAGE_START_DT'
	exec sys.sp_addextendedproperty 'MS_Description', 'Message End Date: message end date.', 'schema', 'dbo', 'table', 'B_LOCATION_MESSAGE', 'column', 'MESSAGE_END_DT'
	exec sys.sp_addextendedproperty 'MS_Description', 'Message Text; message content.', 'schema', 'dbo', 'table', 'B_LOCATION_MESSAGE', 'column', 'MESSAGE_TXT'
	exec sys.sp_addextendedproperty 'MS_Description', 'Include In Confirmation Letter Identifier: if include in confirmation letter.', 'schema', 'dbo', 'table', 'B_LOCATION_MESSAGE', 'column', 'INCLUDE_IN_CONFIMATION_LETTER_IND'
	exec sys.sp_addextendedproperty 'MS_Description', 'Include In Receipt Identifier: if iclude in receipt.', 'schema', 'dbo', 'table', 'B_LOCATION_MESSAGE', 'column', 'INCLUDE_IN_RECEIPT_IND'
	exec sys.sp_addextendedproperty 'MS_Description', 'Include In Printed Permit Identifier: if include in print permit.', 'schema', 'dbo', 'table', 'B_LOCATION_MESSAGE', 'column', 'INCLUDE_IN_PRINTED_PERMIT_IND'
	exec sys.sp_addextendedproperty 'MS_Description', 'Apply To Text: Apply to which location.', 'schema', 'dbo', 'table', 'B_LOCATION_MESSAGE', 'column', 'APPLY_TO_TXT'
	exec sys.sp_addextendedproperty 'MS_Description', 'User Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'B_LOCATION_MESSAGE', 'column', 'CREATED_USER_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Location Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'B_LOCATION_MESSAGE', 'column', 'CREATED_LOCATION_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Active Indicator: 1 if this record is active in the source system, otherwise 0.', 'schema', 'dbo', 'table', 'B_LOCATION_MESSAGE', 'column', 'ACTIVE_IND'
	exec sys.sp_addextendedproperty 'MS_Description', 'Deleted Indicator: 1 if this record has been deleted in the source system, otherwise 0.', 'schema', 'dbo', 'table', 'B_LOCATION_MESSAGE', 'column', 'DELETED_IND'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart Source Identifier: source system identifier for this record.', 'schema', 'dbo', 'table', 'B_LOCATION_MESSAGE', 'column', 'MART_SOURCE_ID'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart Created Datetime: system date and time when this record was created in the mart.', 'schema', 'dbo', 'table', 'B_LOCATION_MESSAGE', 'column', 'MART_CREATED_DTM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart Modified Datetime: system date and time when this record was last modified in the mart.', 'schema', 'dbo', 'table', 'B_LOCATION_MESSAGE', 'column', 'MART_MODIFIED_DTM'

	PRINT '[INFO] CREATED TABLE [DBO].[B_LOCATION_MESSAGE]'
END
GO


--INDEX: B_LOCATION_MESSAGE_MART_SOURCE_ID_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_LOCATION_MESSAGE]','U') AND i.name = 'B_LOCATION_MESSAGE_MART_SOURCE_ID_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_LOCATION_MESSAGE_MART_SOURCE_ID_IX] ON [dbo].[B_LOCATION_MESSAGE]([MART_SOURCE_ID]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_LOCATION_MESSAGE].[B_LOCATION_MESSAGE_MART_SOURCE_ID_IX]'
END
GO

--INDEX: B_LOCATION_MESSAGE_LOCATION_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_LOCATION_MESSAGE]','U') AND i.name = 'B_LOCATION_MESSAGE_CUSTOMER_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_LOCATION_MESSAGE_CUSTOMER_KEY_IX] ON [dbo].[B_LOCATION_MESSAGE]([LOCATION_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_LOCATION_MESSAGE].[B_LOCATION_MESSAGE_CUSTOMER_KEY_IX]'
END
GO

--INDEX: B_LOCATION_MESSAGE_CREATED_USER_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_LOCATION_MESSAGE]','U') AND i.name = 'B_LOCATION_MESSAGE_CREATED_USER_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_LOCATION_MESSAGE_CREATED_USER_KEY_IX] ON [dbo].[B_LOCATION_MESSAGE]([CREATED_USER_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_LOCATION_MESSAGE].[B_LOCATION_MESSAGE_CREATED_USER_KEY_IX]'
END
GO

--INDEX: B_LOCATION_MESSAGE_CREATED_LOCATION_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_LOCATION_MESSAGE]','U') AND i.name = 'B_LOCATION_MESSAGE_CREATED_LOCATION_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_LOCATION_MESSAGE_CREATED_LOCATION_KEY_IX] ON [dbo].[B_LOCATION_MESSAGE]([CREATED_LOCATION_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_LOCATION_MESSAGE].[B_LOCATION_MESSAGE_CREATED_LOCATION_KEY_IX]'
END
GO


/*

DO NOT deploy until TPWD CODE FREEZE finish


 * NOTES: Creates B_ORDER_MESSAGE bridge for AspiraOne datamart 
 *
 * DATE        JIRA      USER             DESCRIPTION
 * ----------  --------  ---------------  ---------------------------------------
 * 01/23/2019  DMA-3091  Zongpei Liu	  Initialization.

*/

SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL READ COMMITTED

IF OBJECT_ID('DBO.B_ORDER_MESSAGE') IS NULL
BEGIN
	CREATE TABLE DBO.B_ORDER_MESSAGE(
		MESSAGE_KEY                          bigint           IDENTITY(1,1),
		ORDER_KEY                            bigint           NULL,
		MESSAGE_TYPE_NM                      varchar(50)      NULL,
		MESSAGE_CREATED_DTM                  datetime         NULL,
		MESSAGE_TXT                          varchar(4000)    NULL,
		INCLUDE_IN_CONFIMATION_LETTER_IND    smallint         NULL,
		INCLUDE_IN_RECEIPT_IND               smallint         NULL,
		CREATED_USER_KEY                     bigint           NULL,
		CREATED_LOCATION_KEY                 bigint           NULL,
		ACTIVE_IND                           smallint         NULL,
		DELETED_IND                          smallint         NULL,
		MART_SOURCE_ID                       bigint           NULL,
		MART_CREATED_DTM                     datetime         NULL,
		MART_MODIFIED_DTM                    datetime         NULL,
		CONSTRAINT PK_B_ORDER_MESSAGE PRIMARY KEY CLUSTERED (MESSAGE_KEY)
	) ON TX_CAMPING_MART_DATA

	exec sys.sp_addextendedproperty 'MS_Description', 'Message Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'B_ORDER_MESSAGE', 'column', 'MESSAGE_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Order Key: surrogate key uniquely identifying this record in the mart.', 'schema', 'dbo', 'table', 'B_ORDER_MESSAGE', 'column', 'ORDER_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Message Type Name: message type like note/alter.', 'schema', 'dbo', 'table', 'B_ORDER_MESSAGE', 'column', 'MESSAGE_TYPE_NM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Message Created Date Time: message created time in source.', 'schema', 'dbo', 'table', 'B_ORDER_MESSAGE', 'column', 'MESSAGE_CREATED_DTM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Message Text; message content.', 'schema', 'dbo', 'table', 'B_ORDER_MESSAGE', 'column', 'MESSAGE_TXT'
	exec sys.sp_addextendedproperty 'MS_Description', 'Include In Confirmation Letter Identifier: if include in confirmation letter.', 'schema', 'dbo', 'table', 'B_ORDER_MESSAGE', 'column', 'INCLUDE_IN_CONFIMATION_LETTER_IND'
	exec sys.sp_addextendedproperty 'MS_Description', 'Include In Receipt Identifier: if iclude in receipt.', 'schema', 'dbo', 'table', 'B_ORDER_MESSAGE', 'column', 'INCLUDE_IN_RECEIPT_IND'
	exec sys.sp_addextendedproperty 'MS_Description', 'User Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'B_ORDER_MESSAGE', 'column', 'CREATED_USER_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Location Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'B_ORDER_MESSAGE', 'column', 'CREATED_LOCATION_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Active Indicator: 1 if this record is active in the source system, otherwise 0.', 'schema', 'dbo', 'table', 'B_ORDER_MESSAGE', 'column', 'ACTIVE_IND'
	exec sys.sp_addextendedproperty 'MS_Description', 'Deleted Indicator: 1 if this record has been deleted in the source system, otherwise 0.', 'schema', 'dbo', 'table', 'B_ORDER_MESSAGE', 'column', 'DELETED_IND'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart Source Identifier: source system identifier for this record.', 'schema', 'dbo', 'table', 'B_ORDER_MESSAGE', 'column', 'MART_SOURCE_ID'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart Created Datetime: system date and time when this record was created in the mart.', 'schema', 'dbo', 'table', 'B_ORDER_MESSAGE', 'column', 'MART_CREATED_DTM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart Modified Datetime: system date and time when this record was last modified in the mart.', 'schema', 'dbo', 'table', 'B_ORDER_MESSAGE', 'column', 'MART_MODIFIED_DTM'
	exec sys.sp_addextendedproperty 'MS_Description', 'B_Order_Message: order message.', 'schema', 'dbo', 'table', 'B_ORDER_MESSAGE'

	PRINT '[INFO] CREATED TABLE [DBO].[B_ORDER_MESSAGE]'
END

--INDEX: B_ORDER_MESSAGE_MART_SOURCE_ID_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_ORDER_MESSAGE]','U') AND i.name = 'B_ORDER_MESSAGE_MART_SOURCE_ID_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_ORDER_MESSAGE_MART_SOURCE_ID_IX] ON [dbo].[B_ORDER_MESSAGE]([MART_SOURCE_ID]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_ORDER_MESSAGE].[B_ORDER_MESSAGE_MART_SOURCE_ID_IX]'
END
GO

--INDEX: B_ORDER_MESSAGE_ORDER_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_ORDER_MESSAGE]','U') AND i.name = 'B_ORDER_MESSAGE_ORDER_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_ORDER_MESSAGE_ORDER_KEY_IX] ON [dbo].[B_ORDER_MESSAGE]([ORDER_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_ORDER_MESSAGE].[B_ORDER_MESSAGE_ORDER_KEY_IX]'
END
GO

--INDEX: B_ORDER_MESSAGE_CREATED_USER_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_ORDER_MESSAGE]','U') AND i.name = 'B_ORDER_MESSAGE_CREATED_USER_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_ORDER_MESSAGE_CREATED_USER_KEY_IX] ON [dbo].[B_ORDER_MESSAGE]([CREATED_USER_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_ORDER_MESSAGE].[B_ORDER_MESSAGE_CREATED_USER_KEY_IX]'
END
GO

--INDEX: B_ORDER_MESSAGE_CREATED_LOCATION_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_ORDER_MESSAGE]','U') AND i.name = 'B_ORDER_MESSAGE_CREATED_LOCATION_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_ORDER_MESSAGE_CREATED_LOCATION_KEY_IX] ON [dbo].[B_ORDER_MESSAGE]([CREATED_LOCATION_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_ORDER_MESSAGE].[B_ORDER_MESSAGE_CREATED_LOCATION_KEY_IX]'
END
GO

/*

DO NOT deploy until TPWD CODE FREEZE finish


 * NOTES: Creates B_SITE_MESSAGE bridge for AspiraOne datamart 
 *
 * DATE        JIRA      USER             DESCRIPTION
 * ----------  --------  ---------------  ---------------------------------------
 * 01/24/2019  DMA-2916  Zongpei Liu	  Initialization.
*/

SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL READ COMMITTED

IF OBJECT_ID('DBO.B_SITE_MESSAGE') IS NULL
BEGIN
	CREATE TABLE DBO.B_SITE_MESSAGE(
		MESSAGE_KEY                          bigint           IDENTITY(1,1),
		PRODUCT_KEY                          bigint           NULL,
		MESSAGE_TYPE_NM                      varchar(50)      NULL,
		MESSAGE_CREATED_DTM                  datetime         NULL,
		MESSAGE_START_DT                     date             NULL,
		MESSAGE_END_DT                       date             NULL,
		MESSAGE_TXT                          varchar(4000)    NULL,
		INCLUDE_IN_CONFIMATION_LETTER_IND    smallint         NULL,
		INCLUDE_IN_RECEIPT_IND               smallint         NULL,
		INCLUDE_IN_PRINTED_PERMIT_IND        smallint         NULL,
		APPLY_TO_TXT                         varchar(50)      NULL,
		CREATED_USER_KEY                     bigint           NULL,
		CREATED_LOCATION_KEY                 bigint           NULL,
		ACTIVE_IND                           smallint         NULL,
		DELETED_IND                          smallint         NULL,
		MART_SOURCE_ID                       bigint           NULL,
		MART_CREATED_DTM                     datetime         NULL,
		MART_MODIFIED_DTM                    datetime         NULL,
		CONSTRAINT PK_B_SITE_MESSAGE PRIMARY KEY CLUSTERED (MESSAGE_KEY)
	) ON TX_CAMPING_MART_DATA

	exec sys.sp_addextendedproperty 'MS_Description', 'Message Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'B_SITE_MESSAGE', 'column', 'MESSAGE_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Product Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'B_SITE_MESSAGE', 'column', 'PRODUCT_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Message Type Name: message type like note/alter.', 'schema', 'dbo', 'table', 'B_SITE_MESSAGE', 'column', 'MESSAGE_TYPE_NM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Message Created Date Time: message created time in source.', 'schema', 'dbo', 'table', 'B_SITE_MESSAGE', 'column', 'MESSAGE_CREATED_DTM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Message Start Date: message start date.', 'schema', 'dbo', 'table', 'B_SITE_MESSAGE', 'column', 'MESSAGE_START_DT'
	exec sys.sp_addextendedproperty 'MS_Description', 'Message End Date: message end date.', 'schema', 'dbo', 'table', 'B_SITE_MESSAGE', 'column', 'MESSAGE_END_DT'
	exec sys.sp_addextendedproperty 'MS_Description', 'Message Text; message content.', 'schema', 'dbo', 'table', 'B_SITE_MESSAGE', 'column', 'MESSAGE_TXT'
	exec sys.sp_addextendedproperty 'MS_Description', 'Include In Confirmation Letter Identifier: if include in confirmation letter.', 'schema', 'dbo', 'table', 'B_SITE_MESSAGE', 'column', 'INCLUDE_IN_CONFIMATION_LETTER_IND'
	exec sys.sp_addextendedproperty 'MS_Description', 'Include In Receipt Identifier: if iclude in receipt.', 'schema', 'dbo', 'table', 'B_SITE_MESSAGE', 'column', 'INCLUDE_IN_RECEIPT_IND'
	exec sys.sp_addextendedproperty 'MS_Description', 'Include In Printed Permit Identifier: if include in print permit.', 'schema', 'dbo', 'table', 'B_SITE_MESSAGE', 'column', 'INCLUDE_IN_PRINTED_PERMIT_IND'
	exec sys.sp_addextendedproperty 'MS_Description', 'Apply To Text: Apply to which location.', 'schema', 'dbo', 'table', 'B_SITE_MESSAGE', 'column', 'APPLY_TO_TXT'
	exec sys.sp_addextendedproperty 'MS_Description', 'User Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'B_SITE_MESSAGE', 'column', 'CREATED_USER_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Location Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'B_SITE_MESSAGE', 'column', 'CREATED_LOCATION_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Active Indicator: 1 if this record is active in the source system, otherwise 0.', 'schema', 'dbo', 'table', 'B_SITE_MESSAGE', 'column', 'ACTIVE_IND'
	exec sys.sp_addextendedproperty 'MS_Description', 'Deleted Indicator: 1 if this record has been deleted in the source system, otherwise 0.', 'schema', 'dbo', 'table', 'B_SITE_MESSAGE', 'column', 'DELETED_IND'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart Source Identifier: source system identifier for this record.', 'schema', 'dbo', 'table', 'B_SITE_MESSAGE', 'column', 'MART_SOURCE_ID'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart Created Datetime: system date and time when this record was created in the mart.', 'schema', 'dbo', 'table', 'B_SITE_MESSAGE', 'column', 'MART_CREATED_DTM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart Modified Datetime: system date and time when this record was last modified in the mart.', 'schema', 'dbo', 'table', 'B_SITE_MESSAGE', 'column', 'MART_MODIFIED_DTM'
	exec sys.sp_addextendedproperty 'MS_Description', 'B_Site_Message: site message', 'schema', 'dbo', 'table', 'B_SITE_MESSAGE'

PRINT '[INFO] CREATED TABLE [DBO].[B_SITE_MESSAGE]'
END
GO


--INDEX: B_SITE_MESSAGE_MART_SOURCE_ID_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_SITE_MESSAGE]','U') AND i.name = 'B_SITE_MESSAGE_MART_SOURCE_ID_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_SITE_MESSAGE_MART_SOURCE_ID_IX] ON [dbo].[B_SITE_MESSAGE]([MART_SOURCE_ID]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_SITE_MESSAGE].[B_SITE_MESSAGE_MART_SOURCE_ID_IX]'
END
GO

--INDEX: B_SITE_MESSAGE_PRODUCT_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_SITE_MESSAGE]','U') AND i.name = 'B_SITE_MESSAGE_CUSTOMER_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_SITE_MESSAGE_CUSTOMER_KEY_IX] ON [dbo].[B_SITE_MESSAGE]([PRODUCT_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_SITE_MESSAGE].[B_SITE_MESSAGE_CUSTOMER_KEY_IX]'
END
GO

--INDEX: B_SITE_MESSAGE_CREATED_USER_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_SITE_MESSAGE]','U') AND i.name = 'B_SITE_MESSAGE_CREATED_USER_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_SITE_MESSAGE_CREATED_USER_KEY_IX] ON [dbo].[B_SITE_MESSAGE]([CREATED_USER_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_SITE_MESSAGE].[B_SITE_MESSAGE_CREATED_USER_KEY_IX]'
END
GO

--INDEX: B_SITE_MESSAGE_CREATED_LOCATION_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_SITE_MESSAGE]','U') AND i.name = 'B_SITE_MESSAGE_CREATED_LOCATION_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_SITE_MESSAGE_CREATED_LOCATION_KEY_IX] ON [dbo].[B_SITE_MESSAGE]([CREATED_LOCATION_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_SITE_MESSAGE].[B_SITE_MESSAGE_CREATED_LOCATION_KEY_IX]'
END
GO



/*

DO NOT deploy until TPWD CODE FREEZE finish


 * NOTES: Creates B_CUSTOMER_MESSAGE bridge for AspiraOne datamart 
 *
 * DATE        JIRA      USER             DESCRIPTION
 * ----------  --------  ---------------  ---------------------------------------
 * 01/23/2019  DMA-3091  Zongpei Liu	  Initialization.
 */

SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL READ COMMITTED

IF OBJECT_ID('DBO.B_CUSTOMER_MESSAGE') IS NULL
BEGIN
	CREATE TABLE DBO.B_CUSTOMER_MESSAGE(
		MESSAGE_KEY             bigint           IDENTITY(1,1),
		CUSTOMER_KEY            bigint           NULL,
		MESSAGE_TYPE_NM         varchar(50)      NULL,
		MESSAGE_CREATED_DTM     datetime         NULL,
		MESSAGE_TXT             varchar(4000)    NULL,
		CREATED_USER_KEY        bigint           NULL,
		CREATED_LOCATION_KEY    bigint           NULL,
		ACTIVE_IND              smallint         NULL,
		DELETED_IND             smallint         NULL,
		MART_SOURCE_ID          bigint           NULL,
		MART_CREATED_DTM        datetime         NULL,
		MART_MODIFIED_DTM       datetime         NULL,
		CONSTRAINT PK_B_CUSTOMER_MESSAGE PRIMARY KEY CLUSTERED (MESSAGE_KEY)
	) ON TX_CAMPING_MART_DATA

	exec sys.sp_addextendedproperty 'MS_Description', 'Message Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'B_CUSTOMER_MESSAGE', 'column', 'MESSAGE_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Customer Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'B_CUSTOMER_MESSAGE', 'column', 'CUSTOMER_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Message Type Name: message type like note/alter.', 'schema', 'dbo', 'table', 'B_CUSTOMER_MESSAGE', 'column', 'MESSAGE_TYPE_NM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Message Created Date Time: message created time in source.', 'schema', 'dbo', 'table', 'B_CUSTOMER_MESSAGE', 'column', 'MESSAGE_CREATED_DTM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Message Text; message content.', 'schema', 'dbo', 'table', 'B_CUSTOMER_MESSAGE', 'column', 'MESSAGE_TXT'
	exec sys.sp_addextendedproperty 'MS_Description', 'User Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'B_CUSTOMER_MESSAGE', 'column', 'CREATED_USER_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Location Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'B_CUSTOMER_MESSAGE', 'column', 'CREATED_LOCATION_KEY'
	exec sys.sp_addextendedproperty 'MS_Description', 'Active Indicator: 1 if this record is active in the source system, otherwise 0.', 'schema', 'dbo', 'table', 'B_CUSTOMER_MESSAGE', 'column', 'ACTIVE_IND'
	exec sys.sp_addextendedproperty 'MS_Description', 'Deleted Indicator: 1 if this record has been deleted in the source system, otherwise 0.', 'schema', 'dbo', 'table', 'B_CUSTOMER_MESSAGE', 'column', 'DELETED_IND'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart Source Identifier: source system identifier for this record.', 'schema', 'dbo', 'table', 'B_CUSTOMER_MESSAGE', 'column', 'MART_SOURCE_ID'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart Created Datetime: system date and time when this record was created in the mart.', 'schema', 'dbo', 'table', 'B_CUSTOMER_MESSAGE', 'column', 'MART_CREATED_DTM'
	exec sys.sp_addextendedproperty 'MS_Description', 'Mart Modified Datetime: system date and time when this record was last modified in the mart.', 'schema', 'dbo', 'table', 'B_CUSTOMER_MESSAGE', 'column', 'MART_MODIFIED_DTM'
	exec sys.sp_addextendedproperty 'MS_Description', 'B_Customer_Message: customer message.', 'schema', 'dbo', 'table', 'B_CUSTOMER_MESSAGE'

	PRINT '[INFO] CREATED TABLE [DBO].[B_CUSTOMER_MESSAGE]'
END
GO


--INDEX: B_CUSTOMER_MESSAGE_MART_SOURCE_ID_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_CUSTOMER_MESSAGE]','U') AND i.name = 'B_CUSTOMER_MESSAGE_MART_SOURCE_ID_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_CUSTOMER_MESSAGE_MART_SOURCE_ID_IX] ON [dbo].[B_CUSTOMER_MESSAGE]([MART_SOURCE_ID]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_CUSTOMER_MESSAGE].[B_CUSTOMER_MESSAGE_MART_SOURCE_ID_IX]'
END
GO

--INDEX: B_CUSTOMER_MESSAGE_CUSTOMER_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_CUSTOMER_MESSAGE]','U') AND i.name = 'B_CUSTOMER_MESSAGE_CUSTOMER_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_CUSTOMER_MESSAGE_CUSTOMER_KEY_IX] ON [dbo].[B_CUSTOMER_MESSAGE]([CUSTOMER_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_CUSTOMER_MESSAGE].[B_CUSTOMER_MESSAGE_CUSTOMER_KEY_IX]'
END
GO

--INDEX: B_CUSTOMER_MESSAGE_CREATED_USER_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_CUSTOMER_MESSAGE]','U') AND i.name = 'B_CUSTOMER_MESSAGE_CREATED_USER_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_CUSTOMER_MESSAGE_CREATED_USER_KEY_IX] ON [dbo].[B_CUSTOMER_MESSAGE]([CREATED_USER_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_CUSTOMER_MESSAGE].[B_CUSTOMER_MESSAGE_CREATED_USER_KEY_IX]'
END
GO

--INDEX: B_CUSTOMER_MESSAGE_CREATED_LOCATION_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_CUSTOMER_MESSAGE]','U') AND i.name = 'B_CUSTOMER_MESSAGE_CREATED_LOCATION_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_CUSTOMER_MESSAGE_CREATED_LOCATION_KEY_IX] ON [dbo].[B_CUSTOMER_MESSAGE]([CREATED_LOCATION_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_CUSTOMER_MESSAGE].[B_CUSTOMER_MESSAGE_CREATED_LOCATION_KEY_IX]'
END
GO




IF NOT EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.B_SITE_ATTRIBUTES') AND name='ATTRIBUTE_GROUP_NM')
BEGIN
	ALTER TABLE B_SITE_ATTRIBUTES ADD ATTRIBUTE_GROUP_NM varchar(255) NULL
	exec sys.sp_addextendedproperty 'MS_Description', 'payment allocation datetime', 'schema', 'dbo', 'table', 'B_SITE_ATTRIBUTES', 'column', 'ATTRIBUTE_GROUP_NM'
	PRINT '[INFO] ADD COLUMN [DBO].[B_SITE_ATTRIBUTES].[ATTRIBUTE_GROUP_NM]'
END


IF NOT EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_SITE') AND name='LOCATION_KEY')
BEGIN
	ALTER TABLE D_SITE ADD LOCATION_KEY bigint NULL
	exec sys.sp_addextendedproperty 'MS_Description', 'Location Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'D_SITE', 'column', 'LOCATION_KEY'
	PRINT '[INFO] ADD COLUMN [DBO].[D_SITE].[LOCATION_KEY]'
END

--INDEX: D_SITE_LOCATION_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[D_SITE]','U') AND i.name = 'D_SITE_LOCATION_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [D_SITE_LOCATION_KEY_IX] ON [dbo].[D_SITE](LOCATION_KEY) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[D_SITE].[D_SITE_LOCATION_KEY_IX]'
END
GO