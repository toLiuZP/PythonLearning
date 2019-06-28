USE DMA_MART_TEST
GO

IF NOT EXISTS(SELECT * FROM sysobjects WHERE xtype = 'U' AND uid = 1 AND NAME = 'D_ORDER_BK20190625')
BEGIN
	SELECT * INTO D_ORDER_BK20190625 FROM D_ORDER WITH(NOLOCK)
	PRINT 'Backuped D_ORDER'
END

IF NOT EXISTS(SELECT * FROM sysobjects WHERE xtype = 'U' AND uid = 1 AND NAME = 'F_ORDER_ITEM_BK20190625')
BEGIN
	SELECT * INTO F_ORDER_ITEM_BK20190625 FROM F_ORDER_ITEM WITH(NOLOCK)
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
	) ON DMA_MART_TEST_DATA

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
    CREATE NONCLUSTERED INDEX [B_ORDER_TRANS_MESSAGE_MART_SOURCE_ID_IX] ON [dbo].[B_ORDER_TRANS_MESSAGE]([MART_SOURCE_ID]) ON DMA_MART_TEST_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_ORDER_TRANS_MESSAGE].[B_ORDER_TRANS_MESSAGE_MART_SOURCE_ID_IX]'
END
GO

--INDEX: B_ORDER_TRANS_MESSAGE_ORDER_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_ORDER_TRANS_MESSAGE]','U') AND i.name = 'B_ORDER_TRANS_MESSAGE_ORDER_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_ORDER_TRANS_MESSAGE_ORDER_KEY_IX] ON [dbo].[B_ORDER_TRANS_MESSAGE]([ORDER_KEY]) ON DMA_MART_TEST_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_ORDER_TRANS_MESSAGE].[B_ORDER_TRANS_MESSAGE_ORDER_KEY_IX]'
END
GO

--INDEX: B_ORDER_TRANS_MESSAGE_CREATED_USER_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_ORDER_TRANS_MESSAGE]','U') AND i.name = 'B_ORDER_TRANS_MESSAGE_CREATED_USER_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_ORDER_TRANS_MESSAGE_CREATED_USER_KEY_IX] ON [dbo].[B_ORDER_TRANS_MESSAGE]([CREATED_USER_KEY]) ON DMA_MART_TEST_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_ORDER_TRANS_MESSAGE].[B_ORDER_TRANS_MESSAGE_CREATED_USER_KEY_IX]'
END
GO

--INDEX: B_ORDER_TRANS_MESSAGE_CREATED_LOCATION_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_ORDER_TRANS_MESSAGE]','U') AND i.name = 'B_ORDER_TRANS_MESSAGE_CREATED_LOCATION_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_ORDER_TRANS_MESSAGE_CREATED_LOCATION_KEY_IX] ON [dbo].[B_ORDER_TRANS_MESSAGE]([CREATED_LOCATION_KEY]) ON DMA_MART_TEST_IDX
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
	) ON DMA_MART_TEST_DATA

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
    CREATE NONCLUSTERED INDEX [B_ORDER_ITEM_TRANS_MESSAGE_MART_SOURCE_ID_IX] ON [dbo].[B_ORDER_ITEM_TRANS_MESSAGE]([MART_SOURCE_ID]) ON DMA_MART_TEST_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_ORDER_ITEM_TRANS_MESSAGE].[B_ORDER_ITEM_TRANS_MESSAGE_MART_SOURCE_ID_IX]'
END
GO

--INDEX: B_ORDER_ITEM_TRANS_MESSAGE_ITEM_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_ORDER_ITEM_TRANS_MESSAGE]','U') AND i.name = 'B_ORDER_ITEM_TRANS_MESSAGE_ITEM_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_ORDER_ITEM_TRANS_MESSAGE_ITEM_KEY_IX] ON [dbo].[B_ORDER_ITEM_TRANS_MESSAGE]([ITEM_KEY]) ON DMA_MART_TEST_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_ORDER_ITEM_TRANS_MESSAGE].[B_ORDER_ITEM_TRANS_MESSAGE_ITEM_KEY_IX]'
END
GO

--INDEX: B_ORDER_ITEM_TRANS_MESSAGE_CREATED_USER_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_ORDER_ITEM_TRANS_MESSAGE]','U') AND i.name = 'B_ORDER_ITEM_TRANS_MESSAGE_CREATED_USER_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_ORDER_ITEM_TRANS_MESSAGE_CREATED_USER_KEY_IX] ON [dbo].[B_ORDER_ITEM_TRANS_MESSAGE]([CREATED_USER_KEY]) ON DMA_MART_TEST_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_ORDER_ITEM_TRANS_MESSAGE].[B_ORDER_ITEM_TRANS_MESSAGE_CREATED_USER_KEY_IX]'
END
GO

--INDEX: B_ORDER_ITEM_TRANS_MESSAGE_CREATED_LOCATION_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_ORDER_ITEM_TRANS_MESSAGE]','U') AND i.name = 'B_ORDER_ITEM_TRANS_MESSAGE_CREATED_LOCATION_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_ORDER_ITEM_TRANS_MESSAGE_CREATED_LOCATION_KEY_IX] ON [dbo].[B_ORDER_ITEM_TRANS_MESSAGE]([CREATED_LOCATION_KEY]) ON DMA_MART_TEST_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_ORDER_ITEM_TRANS_MESSAGE].[B_ORDER_ITEM_TRANS_MESSAGE_CREATED_LOCATION_KEY_IX]'
END
GO


-- Occupant type
/* back original table */
IF EXISTS(SELECT * FROM sysobjects WHERE xtype = 'U' AND uid = 1 AND NAME = 'B_ORDER_PROFILE_VEHICLE')
BEGIN
	EXEC sp_rename 'dbo.B_ORDER_PROFILE_VEHICLE', 'B_ORDER_PROFILE_VEHICLE_BK20190625'; 
	PRINT 'Renamed [DBO].[B_ORDER_PROFILE_VEHICLE] to [B_ORDER_PROFILE_VEHICLE_BK20190625]'
END

IF NOT EXISTS(SELECT * FROM sysobjects WHERE xtype = 'U' AND uid = 1 AND NAME = 'D_DAILY_ENTRANCE_BK20190625')
BEGIN
	SELECT * INTO D_DAILY_ENTRANCE_BK20190625 FROM D_DAILY_ENTRANCE WITH(NOLOCK)
	PRINT 'Backuped D_DAILY_ENTRANCE'
END

IF NOT EXISTS(SELECT * FROM sysobjects WHERE xtype = 'U' AND uid = 1 AND NAME = 'D_RESERVATION_BK20190625')
BEGIN
	SELECT * INTO D_RESERVATION_BK20190625 FROM D_RESERVATION WITH(NOLOCK)
	PRINT 'Backuped D_RESERVATION'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_RESERVATION') AND name='OCCUPANT_TYPE_ADULT_13_AND_OVER_CNT')
BEGIN
        ALTER TABLE D_RESERVATION DROP COLUMN OCCUPANT_TYPE_ADULT_13_AND_OVER_CNT
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_RESERVATION].[OCCUPANT_TYPE_ADULT_13_AND_OVER_CNT]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_RESERVATION') AND name='OCCUPANT_TYPE_ADULT_PRE_PAID_CNT')
BEGIN
        ALTER TABLE D_RESERVATION DROP COLUMN OCCUPANT_TYPE_ADULT_PRE_PAID_CNT
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_RESERVATION].[OCCUPANT_TYPE_ADULT_PRE_PAID_CNT]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_RESERVATION') AND name='OCCUPANT_TYPE_CHILD_12_AND_UNDER_CNT')
BEGIN
        ALTER TABLE D_RESERVATION DROP COLUMN OCCUPANT_TYPE_CHILD_12_AND_UNDER_CNT
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_RESERVATION].[OCCUPANT_TYPE_CHILD_12_AND_UNDER_CNT]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_RESERVATION') AND name='OCCUPANT_TYPE_GROUP_ENTRY_CNT')
BEGIN
        ALTER TABLE D_RESERVATION DROP COLUMN OCCUPANT_TYPE_GROUP_ENTRY_CNT
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_RESERVATION].[OCCUPANT_TYPE_GROUP_ENTRY_CNT]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_RESERVATION') AND name='OCCUPANT_TYPE_ADULT_PARTIAL_CNT')
BEGIN
        ALTER TABLE D_RESERVATION DROP COLUMN OCCUPANT_TYPE_ADULT_PARTIAL_CNT
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_RESERVATION].[OCCUPANT_TYPE_ADULT_PARTIAL_CNT]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_RESERVATION') AND name='OCCUPANT_TYPE_OVERNIGHT_CAMPING_DIFFERENTIAL_CNT')
BEGIN
        ALTER TABLE D_RESERVATION DROP COLUMN OCCUPANT_TYPE_OVERNIGHT_CAMPING_DIFFERENTIAL_CNT
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_RESERVATION].[OCCUPANT_TYPE_OVERNIGHT_CAMPING_DIFFERENTIAL_CNT]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_RESERVATION') AND name='OCCUPANT_TYPE_SPECIAL_PARK_PROGRAMS_CNT')
BEGIN
        ALTER TABLE D_RESERVATION DROP COLUMN OCCUPANT_TYPE_SPECIAL_PARK_PROGRAMS_CNT
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_RESERVATION].[OCCUPANT_TYPE_SPECIAL_PARK_PROGRAMS_CNT]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_RESERVATION') AND name='OCCUPANT_TYPE_GROUP_ADULT_CAMP_TICKET_CNT')
BEGIN
        ALTER TABLE D_RESERVATION DROP COLUMN OCCUPANT_TYPE_GROUP_ADULT_CAMP_TICKET_CNT
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_RESERVATION].[OCCUPANT_TYPE_GROUP_ADULT_CAMP_TICKET_CNT]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_RESERVATION') AND name='OCCUPANT_TYPE_RIO_GRANDE_FESTIVALS_CNT')
BEGIN
        ALTER TABLE D_RESERVATION DROP COLUMN OCCUPANT_TYPE_RIO_GRANDE_FESTIVALS_CNT
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_RESERVATION].[OCCUPANT_TYPE_RIO_GRANDE_FESTIVALS_CNT]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_DAILY_ENTRANCE') AND name='OCCUPANT_TYPE_ADULT_13_AND_OVER_CNT')
BEGIN
        ALTER TABLE D_DAILY_ENTRANCE DROP COLUMN OCCUPANT_TYPE_ADULT_13_AND_OVER_CNT
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_DAILY_ENTRANCE].[OCCUPANT_TYPE_ADULT_13_AND_OVER_CNT]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_DAILY_ENTRANCE') AND name='OCCUPANT_TYPE_ADULT_PRE_PAID_CNT')
BEGIN
        ALTER TABLE D_DAILY_ENTRANCE DROP COLUMN OCCUPANT_TYPE_ADULT_PRE_PAID_CNT
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_DAILY_ENTRANCE].[OCCUPANT_TYPE_ADULT_PRE_PAID_CNT]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_DAILY_ENTRANCE') AND name='OCCUPANT_TYPE_CHILD_12_AND_UNDER_CNT')
BEGIN
        ALTER TABLE D_DAILY_ENTRANCE DROP COLUMN OCCUPANT_TYPE_CHILD_12_AND_UNDER_CNT
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_DAILY_ENTRANCE].[OCCUPANT_TYPE_CHILD_12_AND_UNDER_CNT]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_DAILY_ENTRANCE') AND name='OCCUPANT_TYPE_GROUP_ENTRY_CNT')
BEGIN
        ALTER TABLE D_DAILY_ENTRANCE DROP COLUMN OCCUPANT_TYPE_GROUP_ENTRY_CNT
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_DAILY_ENTRANCE].[OCCUPANT_TYPE_GROUP_ENTRY_CNT]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_DAILY_ENTRANCE') AND name='OCCUPANT_TYPE_ADULT_PARTIAL_CNT')
BEGIN
        ALTER TABLE D_DAILY_ENTRANCE DROP COLUMN OCCUPANT_TYPE_ADULT_PARTIAL_CNT
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_DAILY_ENTRANCE].[OCCUPANT_TYPE_ADULT_PARTIAL_CNT]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_DAILY_ENTRANCE') AND name='OCCUPANT_TYPE_OVERNIGHT_CAMPING_DIFFERENTIAL_CNT')
BEGIN
        ALTER TABLE D_DAILY_ENTRANCE DROP COLUMN OCCUPANT_TYPE_OVERNIGHT_CAMPING_DIFFERENTIAL_CNT
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_DAILY_ENTRANCE].[OCCUPANT_TYPE_OVERNIGHT_CAMPING_DIFFERENTIAL_CNT]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_DAILY_ENTRANCE') AND name='OCCUPANT_TYPE_SPECIAL_PARK_PROGRAMS_CNT')
BEGIN
        ALTER TABLE D_DAILY_ENTRANCE DROP COLUMN OCCUPANT_TYPE_SPECIAL_PARK_PROGRAMS_CNT
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_DAILY_ENTRANCE].[OCCUPANT_TYPE_SPECIAL_PARK_PROGRAMS_CNT]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_DAILY_ENTRANCE') AND name='OCCUPANT_TYPE_GROUP_ADULT_CAMP_TICKET_CNT')
BEGIN
        ALTER TABLE D_DAILY_ENTRANCE DROP COLUMN OCCUPANT_TYPE_GROUP_ADULT_CAMP_TICKET_CNT
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_DAILY_ENTRANCE].[OCCUPANT_TYPE_GROUP_ADULT_CAMP_TICKET_CNT]'
END

IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_DAILY_ENTRANCE') AND name='OCCUPANT_TYPE_RIO_GRANDE_FESTIVALS_CNT')
BEGIN
        ALTER TABLE D_DAILY_ENTRANCE DROP COLUMN OCCUPANT_TYPE_RIO_GRANDE_FESTIVALS_CNT
        PRINT '[INFO] DROPPED COLUMN [DBO].[D_DAILY_ENTRANCE].[OCCUPANT_TYPE_RIO_GRANDE_FESTIVALS_CNT]'
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
	) ON DMA_MART_TEST_DATA

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
    CREATE NONCLUSTERED INDEX [B_RESERVATION_OCCUPANT_ITEM_KEY_OCCUPANT_TYPE_ID_IX] ON [dbo].[B_RESERVATION_OCCUPANT]([ITEM_KEY], [OCCUPANT_TYPE_ID]) ON DMA_MART_TEST_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_RESERVATION_OCCUPANT].[B_RESERVATION_OCCUPANT_ITEM_KEY_OCCUPANT_TYPE_ID_IX]'
END
GO

--INDEX: B_RESERVATION_OCCUPANT_ITEM_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_RESERVATION_OCCUPANT]','U') AND i.name = 'B_RESERVATION_OCCUPANT_ITEM_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_RESERVATION_OCCUPANT_ITEM_KEY_IX] ON [dbo].[B_RESERVATION_OCCUPANT]([ITEM_KEY]) ON DMA_MART_TEST_IDX
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
	) ON DMA_MART_TEST_DATA

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
    CREATE NONCLUSTERED INDEX [B_RESERVATION_VEHICLE_MART_SOURCE_ID_IX] ON [dbo].[B_RESERVATION_VEHICLE]([MART_SOURCE_ID]) ON DMA_MART_TEST_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_RESERVATION_VEHICLE].[B_RESERVATION_VEHICLE_MART_SOURCE_ID_IX]'
END
GO

--INDEX: B_RESERVATION_VEHICLE_ITEM_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_RESERVATION_VEHICLE]','U') AND i.name = 'B_RESERVATION_VEHICLE_ITEM_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_RESERVATION_VEHICLE_ITEM_KEY_IX] ON [dbo].[B_RESERVATION_VEHICLE]([ITEM_KEY]) ON DMA_MART_TEST_IDX
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
	) ON DMA_MART_TEST_DATA

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
    CREATE NONCLUSTERED INDEX [B_RESERVATION_VEHICLE_OCCUPANT_RESERVATION_VEHICLE_KEY_IX] ON [dbo].[B_RESERVATION_VEHICLE_OCCUPANT]([RESERVATION_VEHICLE_KEY]) ON DMA_MART_TEST_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_RESERVATION_VEHICLE_OCCUPANT].[B_RESERVATION_VEHICLE_OCCUPANT_RESERVATION_VEHICLE_KEY_IX]'
END
GO

--INDEX: B_RESERVATION_VEHICLE_OCCUPANT_ITEM_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_RESERVATION_VEHICLE_OCCUPANT]','U') AND i.name = 'B_RESERVATION_VEHICLE_OCCUPANT_ITEM_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_RESERVATION_VEHICLE_OCCUPANT_ITEM_KEY_IX] ON [dbo].[B_RESERVATION_VEHICLE_OCCUPANT]([ITEM_KEY]) ON DMA_MART_TEST_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_RESERVATION_VEHICLE_OCCUPANT].[B_RESERVATION_VEHICLE_OCCUPANT_ITEM_KEY_IX]'
END
GO

--INDEX: B_RESERVATION_VEHICLE_OCCUPANT_PROFILE_VEHICLE_ID_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_RESERVATION_VEHICLE_OCCUPANT]','U') AND i.name = 'B_RESERVATION_VEHICLE_OCCUPANT_PROFILE_VEHICLE_ID_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_RESERVATION_VEHICLE_OCCUPANT_PROFILE_VEHICLE_ID_IX] ON [dbo].[B_RESERVATION_VEHICLE_OCCUPANT]([OCCUPANT_TYPE_ID]) ON DMA_MART_TEST_IDX
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
	) ON DMA_MART_TEST_DATA

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
    CREATE NONCLUSTERED INDEX [B_DAILY_ENTRANCE_OCCUPANT_ITEM_KEY_OCCUPANT_TYPE_ID_IX] ON [dbo].[B_DAILY_ENTRANCE_OCCUPANT]([ITEM_KEY], [OCCUPANT_TYPE_ID]) ON DMA_MART_TEST_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_DAILY_ENTRANCE_OCCUPANT].[B_DAILY_ENTRANCE_OCCUPANT_ITEM_KEY_OCCUPANT_TYPE_ID_IX]'
END
GO

--INDEX: B_DAILY_ENTRANCE_OCCUPANT_ITEM_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_DAILY_ENTRANCE_OCCUPANT]','U') AND i.name = 'B_DAILY_ENTRANCE_OCCUPANT_ITEM_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_DAILY_ENTRANCE_OCCUPANT_ITEM_KEY_IX] ON [dbo].[B_DAILY_ENTRANCE_OCCUPANT]([ITEM_KEY]) ON DMA_MART_TEST_IDX
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
	) ON DMA_MART_TEST_DATA

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
    CREATE NONCLUSTERED INDEX [B_DAILY_ENTRANCE_VEHICLE_MART_SOURCE_ID_IX] ON [dbo].[B_DAILY_ENTRANCE_VEHICLE]([MART_SOURCE_ID]) ON DMA_MART_TEST_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_DAILY_ENTRANCE_VEHICLE].[B_DAILY_ENTRANCE_VEHICLE_MART_SOURCE_ID_IX]'
END
GO

--INDEX: B_DAILY_ENTRANCE_VEHICLE_ITEM_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_DAILY_ENTRANCE_VEHICLE]','U') AND i.name = 'B_DAILY_ENTRANCE_VEHICLE_ITEM_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_DAILY_ENTRANCE_VEHICLE_ITEM_KEY_IX] ON [dbo].[B_DAILY_ENTRANCE_VEHICLE]([ITEM_KEY]) ON DMA_MART_TEST_IDX
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
	) ON DMA_MART_TEST_DATA

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
    CREATE NONCLUSTERED INDEX [B_DAILY_ENTRANCE_VEHICLE_OCCUPANT_DAILY_ENTRANCE_VEHICLE_KEY_IX] ON [dbo].[B_DAILY_ENTRANCE_VEHICLE_OCCUPANT]([DAILY_ENTRANCE_VEHICLE_KEY]) ON DMA_MART_TEST_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_DAILY_ENTRANCE_VEHICLE_OCCUPANT].[B_DAILY_ENTRANCE_VEHICLE_OCCUPANT_DAILY_ENTRANCE_VEHICLE_KEY_IX]'
END
GO

--INDEX: B_DAILY_ENTRANCE_VEHICLE_OCCUPANT_ITEM_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_DAILY_ENTRANCE_VEHICLE_OCCUPANT]','U') AND i.name = 'B_DAILY_ENTRANCE_VEHICLE_OCCUPANT_ITEM_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_DAILY_ENTRANCE_VEHICLE_OCCUPANT_ITEM_KEY_IX] ON [dbo].[B_DAILY_ENTRANCE_VEHICLE_OCCUPANT]([ITEM_KEY]) ON DMA_MART_TEST_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_DAILY_ENTRANCE_VEHICLE_OCCUPANT].[B_DAILY_ENTRANCE_VEHICLE_OCCUPANT_ITEM_KEY_IX]'
END
GO

--INDEX: B_DAILY_ENTRANCE_VEHICLE_OCCUPANT_PROFILE_VEHICLE_ID_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_DAILY_ENTRANCE_VEHICLE_OCCUPANT]','U') AND i.name = 'B_DAILY_ENTRANCE_VEHICLE_OCCUPANT_PROFILE_VEHICLE_ID_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_DAILY_ENTRANCE_VEHICLE_OCCUPANT_PROFILE_VEHICLE_ID_IX] ON [dbo].[B_DAILY_ENTRANCE_VEHICLE_OCCUPANT]([OCCUPANT_TYPE_ID]) ON DMA_MART_TEST_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_DAILY_ENTRANCE_VEHICLE_OCCUPANT].[B_DAILY_ENTRANCE_VEHICLE_OCCUPANT_PROFILE_VEHICLE_ID_IX]'
END
GO


