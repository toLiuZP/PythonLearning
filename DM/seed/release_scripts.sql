USE TX_CAMPING_MART
GO


IF NOT EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.F_PAYMENT_ALLOCATION') AND name='CHECK_NB')
BEGIN
	ALTER TABLE F_PAYMENT_ALLOCATION ADD CHECK_NB varchar(255) NULL
	exec sys.sp_addextendedproperty 'MS_Description', 'Check Number: check number of the check payment.', 'schema', 'dbo', 'table', 'F_PAYMENT_ALLOCATION', 'column', 'CHECK_NB'
	PRINT '[INFO] ADD COLUMN [DBO].[F_PAYMENT_ALLOCATION].[CHECK_NB]'
END

IF NOT EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.F_PAYMENT_ALLOCATION') AND name='CHECK_HOLDER_NM')
BEGIN
	ALTER TABLE F_PAYMENT_ALLOCATION ADD CHECK_HOLDER_NM varchar(255) NULL
	exec sys.sp_addextendedproperty 'MS_Description', 'Check Holder Name: check holder name of the check payment.', 'schema', 'dbo', 'table', 'F_PAYMENT_ALLOCATION', 'column', 'CHECK_HOLDER_NM'
	PRINT '[INFO] ADD COLUMN [DBO].[F_PAYMENT_ALLOCATION].[CHECK_HOLDER_NM]'
END


IF NOT EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.F_PAYMENT_ALLOCATION') AND name='PAYMENT_COMMENT')
BEGIN
	ALTER TABLE F_PAYMENT_ALLOCATION ADD PAYMENT_COMMENT varchar(4000) NULL
	exec sys.sp_addextendedproperty 'MS_Description', 'Payment Comment: comment on the payment.', 'schema', 'dbo', 'table', 'F_PAYMENT_ALLOCATION', 'column', 'PAYMENT_COMMENT'
	PRINT '[INFO] ADD COLUMN [DBO].[F_PAYMENT_ALLOCATION].[PAYMENT_COMMENT]'
END

IF NOT EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.F_PAYMENT_ALLOCATION') AND name='PAYMENT_ALLOCATION_DATE_KEY')
BEGIN
	ALTER TABLE F_PAYMENT_ALLOCATION ADD PAYMENT_ALLOCATION_DATE_KEY bigint NULL
	exec sys.sp_addextendedproperty 'MS_Description', 'Date Key: surrogate key uniquely identifying this record in the mart. Formatted YYYYMMDD', 'schema', 'dbo', 'table', 'F_PAYMENT_ALLOCATION', 'column', 'PAYMENT_ALLOCATION_DATE_KEY'
	PRINT '[INFO] ADD COLUMN [DBO].[F_PAYMENT_ALLOCATION].[PAYMENT_ALLOCATION_DATE_KEY]'
END

IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_PAYMENT_ALLOCATION]','U') AND i.name = 'F_PAYMENT_ALLOCATION_PAYMENT_ALLOC_DATE_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_PAYMENT_ALLOCATION_PAYMENT_ALLOC_DATE_KEY_IX] ON [dbo].[F_PAYMENT_ALLOCATION]([PAYMENT_ALLOCATION_DATE_KEY]) ON {INDEXFG}
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_PAYMENT_ALLOCATION].[F_PAYMENT_ALLOCATION_PAYMENT_ALLOC_DATE_KEY_IX]'
END
GO

IF NOT EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.F_PAYMENT_ALLOCATION') AND name='PAYMENT_ALLOCATION_DTM')
BEGIN
	ALTER TABLE F_PAYMENT_ALLOCATION ADD PAYMENT_ALLOCATION_DTM DATETIME NULL
	exec sys.sp_addextendedproperty 'MS_Description', 'payment allocation datetime', 'schema', 'dbo', 'table', 'F_PAYMENT_ALLOCATION', 'column', 'PAYMENT_ALLOCATION_DTM'
	PRINT '[INFO] ADD COLUMN [DBO].[F_PAYMENT_ALLOCATION].[PAYMENT_ALLOCATION_DTM]'
END


IF NOT EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_USER') AND name='CREATED_DTM')
BEGIN
	ALTER TABLE D_USER ADD CREATED_DTM datetime NULL
	exec sys.sp_addextendedproperty 'MS_Description', 'Created Date: created date of the user.', 'schema', 'dbo', 'table', 'D_USER', 'column', 'CREATED_DTM'
	PRINT '[INFO] ADD COLUMN [DBO].[D_USER].[CREATED_DTM]'
END

IF NOT EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_USER') AND name='ACTIVE_IND')
BEGIN
	ALTER TABLE D_USER ADD ACTIVE_IND smallint NULL
	exec sys.sp_addextendedproperty 'MS_Description', 'Active Indicator: Active Indicator, 1 active, 0 inactive.', 'schema', 'dbo', 'table', 'D_USER', 'column', 'ACTIVE_IND'
	PRINT '[INFO] ADD COLUMN [DBO].[D_USER].[ACTIVE_IND]'
END

IF NOT EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_USER') AND name='ACTIVE_DTM')
BEGIN
	ALTER TABLE D_USER ADD ACTIVE_DTM datetime NULL
	exec sys.sp_addextendedproperty 'MS_Description', 'Active Datetime:Active Datetime', 'schema', 'dbo', 'table', 'D_USER', 'column', 'ACTIVE_DTM'
	PRINT '[INFO] ADD COLUMN [DBO].[D_USER].[ACTIVE_DTM]'
END

IF NOT EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_USER') AND name='INACTIVE_DTM')
BEGIN
	ALTER TABLE D_USER ADD INACTIVE_DTM datetime NULL
	exec sys.sp_addextendedproperty 'MS_Description', 'Inactive Datetime:Inactive Datetime', 'schema', 'dbo', 'table', 'D_USER', 'column', 'INACTIVE_DTM'
	PRINT '[INFO] ADD COLUMN [DBO].[D_USER].[INACTIVE_DTM]'
END