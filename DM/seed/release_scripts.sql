PRINT '[INFO] USING DB TX_CAMPING_MART'
USE TX_CAMPING_MART


--------------------------------------------------------------------------------
-- START: D_BATCH.sql

/*
 * NOTES: Creates D_BATCH dimension for AspiraOne datamart 
 *
 * DATE        JIRA      USER             DESCRIPTION
 * ----------  --------  ---------------  ---------------------------------------  
 * 06/27/2019  DMA-4205  Nat Nie          Initialization.
*/

SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL READ COMMITTED

IF OBJECT_ID('DBO.D_BATCH') IS NULL
BEGIN
CREATE TABLE D_BATCH(
    BATCH_KEY                   bigint            IDENTITY(1,1),
    BATCH_DTM                   datetime          NULL,
    BATCH_STATUS                varchar(50)       NULL,
    COUNT_OF_PAYMENTS           int               NULL,
    COUNT_OF_REFUNDS            int               NULL,
    COUNT_OF_TRANSACTIONS       int               NULL,
    TOTAL_PAYMENT_AMT           decimal(38, 6)    NULL,
    TOTAL_REFUND_AMT            decimal(38, 6)    NULL,
    TOTAL_AMT                   decimal(38, 6)    NULL,
    PROCESSED_DTM               datetime          NULL,
    PROCESSING_USER_KEY         bigint            NULL,
    PROCESSING_LOCATION_KEY     bigint            NULL,
    MANUAL_PROCESSING_REASON    varchar(4000)     NULL,
    VOID_DTM                    datetime          NULL,
    VOID_USER_KEY               bigint            NULL,
    VOID_LOCATION_KEY           bigint            NULL,
    VOID_REASON                 varchar(4000)     NULL,
    MART_SOURCE_ID              bigint            NULL,
    MART_CREATED_DTM            datetime          NULL,
    MART_MODIFIED_DTM           datetime          NULL,
    CONSTRAINT PK_D_BATCH PRIMARY KEY CLUSTERED (BATCH_KEY)
)ON TX_CAMPING_MART_DATA


exec sys.sp_addextendedproperty 'MS_Description', 'Batch Key: surrogate key used to uniquely identify a batch record in the data mart.', 'schema', 'dbo', 'table', 'D_BATCH', 'column', 'BATCH_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Batch Date: batch date.', 'schema', 'dbo', 'table', 'D_BATCH', 'column', 'BATCH_DTM'
exec sys.sp_addextendedproperty 'MS_Description', 'Batch Status: batch status.', 'schema', 'dbo', 'table', 'D_BATCH', 'column', 'BATCH_STATUS'
exec sys.sp_addextendedproperty 'MS_Description', 'Count of Payments: total number of payments of the batch.', 'schema', 'dbo', 'table', 'D_BATCH', 'column', 'COUNT_OF_PAYMENTS'
exec sys.sp_addextendedproperty 'MS_Description', 'Count of Refunds: total number of refunds of the batch.', 'schema', 'dbo', 'table', 'D_BATCH', 'column', 'COUNT_OF_REFUNDS'
exec sys.sp_addextendedproperty 'MS_Description', 'Count of Transactions: total number of transactions of the batch.', 'schema', 'dbo', 'table', 'D_BATCH', 'column', 'COUNT_OF_TRANSACTIONS'
exec sys.sp_addextendedproperty 'MS_Description', 'Total Payment Amount: total payment amount of  the batch.', 'schema', 'dbo', 'table', 'D_BATCH', 'column', 'TOTAL_PAYMENT_AMT'
exec sys.sp_addextendedproperty 'MS_Description', 'Total Refund Amount: total refund amount of  the batch.', 'schema', 'dbo', 'table', 'D_BATCH', 'column', 'TOTAL_REFUND_AMT'
exec sys.sp_addextendedproperty 'MS_Description', 'Total  Amount: total amount of  the batch.', 'schema', 'dbo', 'table', 'D_BATCH', 'column', 'TOTAL_AMT'
exec sys.sp_addextendedproperty 'MS_Description', 'Processed Date: processed date.', 'schema', 'dbo', 'table', 'D_BATCH', 'column', 'PROCESSED_DTM'
exec sys.sp_addextendedproperty 'MS_Description', 'User Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'D_BATCH', 'column', 'PROCESSING_USER_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Location Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'D_BATCH', 'column', 'PROCESSING_LOCATION_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Manual Processing Reason: manual processing reason.', 'schema', 'dbo', 'table', 'D_BATCH', 'column', 'MANUAL_PROCESSING_REASON'
exec sys.sp_addextendedproperty 'MS_Description', 'Void Date: void date.', 'schema', 'dbo', 'table', 'D_BATCH', 'column', 'VOID_DTM'
exec sys.sp_addextendedproperty 'MS_Description', 'User Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'D_BATCH', 'column', 'VOID_USER_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Location Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'D_BATCH', 'column', 'VOID_LOCATION_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Void Reason: void reason.', 'schema', 'dbo', 'table', 'D_BATCH', 'column', 'VOID_REASON'
exec sys.sp_addextendedproperty 'MS_Description', 'Mart Source Identifier: source system identifier for this record.', 'schema', 'dbo', 'table', 'D_BATCH', 'column', 'MART_SOURCE_ID'
exec sys.sp_addextendedproperty 'MS_Description', 'Mart Created Datetime: system date and time when this record was created in the mart.', 'schema', 'dbo', 'table', 'D_BATCH', 'column', 'MART_CREATED_DTM'
exec sys.sp_addextendedproperty 'MS_Description', 'Mart Modified Datetime: system date and time when this record was last modified in the mart.', 'schema', 'dbo', 'table', 'D_BATCH', 'column', 'MART_MODIFIED_DTM'
exec sys.sp_addextendedproperty 'MS_Description', 'Batch: credit card batch.', 'schema', 'dbo', 'table', 'D_BATCH'

PRINT '[INFO] CREATED TABLE [DBO].[D_BATCH]'

END
GO


--INDEX: D_BATCH_PROCESSING_USER_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[D_BATCH]','U') AND i.name = 'D_BATCH_PROCESSING_USER_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [D_BATCH_PROCESSING_USER_KEY_IX] ON [dbo].[D_BATCH]([PROCESSING_USER_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[D_BATCH].[D_BATCH_PROCESSING_USER_KEY_IX]'
END
GO

--INDEX: D_BATCH_PROCESSING_LOCATION_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[D_BATCH]','U') AND i.name = 'D_BATCH_PROCESSING_LOCATION_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [D_BATCH_PROCESSING_LOCATION_KEY_IX] ON [dbo].[D_BATCH]([PROCESSING_LOCATION_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[D_BATCH].[D_BATCH_PROCESSING_LOCATION_KEY_IX]'
END
GO

--INDEX: D_BATCH_VOID_USER_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[D_BATCH]','U') AND i.name = 'D_BATCH_VOID_USER_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [D_BATCH_VOID_USER_KEY_IX] ON [dbo].[D_BATCH]([VOID_USER_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[D_BATCH].[D_BATCH_VOID_USER_KEY_IX]'
END
GO

--INDEX: D_BATCH_VOID_LOCATION_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[D_BATCH]','U') AND i.name = 'D_BATCH_VOID_LOCATION_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [D_BATCH_VOID_LOCATION_KEY_IX] ON [dbo].[D_BATCH]([VOID_LOCATION_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[D_BATCH].[D_BATCH_VOID_LOCATION_KEY_IX]'
END
GO

--INDEX: D_BATCH_MART_SOURCE_ID_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[D_BATCH]','U') AND i.name = 'D_BATCH_MART_SOURCE_ID_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [D_BATCH_MART_SOURCE_ID_IX] ON [dbo].[D_BATCH]([MART_SOURCE_ID]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[D_BATCH].[D_BATCH_MART_SOURCE_ID_IX]'
END
GO


GO
