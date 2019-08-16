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
CREATE TABLE DBO.D_BATCH(
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

-- END: D_BATCH.sql
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- START: D_RECONCILIATION_JOB.sql

/*
 * NOTES: Creates D_RECONCILIATION_JOB dimension for AspiraOne datamart 
 *
 * DATE        JIRA      USER             DESCRIPTION
 * ----------  --------  ---------------  ---------------------------------------  
 * 06/27/2019  DMA-4205  Nat Nie          Initialization.
*/

SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL READ COMMITTED

IF OBJECT_ID('DBO.D_RECONCILIATION_JOB') IS NULL
BEGIN
CREATE TABLE DBO.D_RECONCILIATION_JOB(
    RECONCILIATION_JOB_KEY      bigint            IDENTITY(1,1),
    RECONCILIATION_STATUS       varchar(50)       NULL,
    RUN_DTM                     datetime          NULL,
    END_DTM                     datetime          NULL,
    COUNT_OF_TRANSACTIONS       int               NULL,
    COUNT_OF_PAYMENTS           int               NULL,
    COUNT_OF_REFUNDS            int               NULL,
    TOTAL_AMT                   decimal(38, 6)    NULL,
    TOTAL_PAYMENT_AMT           decimal(38, 6)    NULL,
    TOTAL_REFUND_AMT            decimal(38, 6)    NULL,
    FILE_NM                     varchar(100)      NULL,
    RECONCILING_USER_KEY        bigint            NULL,
    RECONCILING_LOCATION_KEY    bigint            NULL,
    MART_SOURCE_ID              bigint            NULL,
    MART_CREATED_DTM            datetime          NULL,
    MART_MODIFIED_DTM           datetime          NULL,
    CONSTRAINT PK_D_RECONCILIATION_JOB PRIMARY KEY CLUSTERED (RECONCILIATION_JOB_KEY)
)ON TX_CAMPING_MART_DATA



exec sys.sp_addextendedproperty 'MS_Description', 'Reconciliation Job Key: surrogate key used to uniquely identify a reconciliation job record in the data mart.', 'schema', 'dbo', 'table', 'D_RECONCILIATION_JOB', 'column', 'RECONCILIATION_JOB_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Reconciliation Job Status: reconciliation job status.', 'schema', 'dbo', 'table', 'D_RECONCILIATION_JOB', 'column', 'RECONCILIATION_STATUS'
exec sys.sp_addextendedproperty 'MS_Description', 'Run Date: run date.', 'schema', 'dbo', 'table', 'D_RECONCILIATION_JOB', 'column', 'RUN_DTM'
exec sys.sp_addextendedproperty 'MS_Description', 'End Date: end date.', 'schema', 'dbo', 'table', 'D_RECONCILIATION_JOB', 'column', 'END_DTM'
exec sys.sp_addextendedproperty 'MS_Description', 'Count of Transactions: total number of transactions of the reconciliation job.', 'schema', 'dbo', 'table', 'D_RECONCILIATION_JOB', 'column', 'COUNT_OF_TRANSACTIONS'
exec sys.sp_addextendedproperty 'MS_Description', 'Count of Payments: total number of payments of the reconciliation job.', 'schema', 'dbo', 'table', 'D_RECONCILIATION_JOB', 'column', 'COUNT_OF_PAYMENTS'
exec sys.sp_addextendedproperty 'MS_Description', 'Count of Refunds: total number of refunds of the reconciliation job.', 'schema', 'dbo', 'table', 'D_RECONCILIATION_JOB', 'column', 'COUNT_OF_REFUNDS'
exec sys.sp_addextendedproperty 'MS_Description', 'Total  Amount: total amount of  the  reconciliation job.', 'schema', 'dbo', 'table', 'D_RECONCILIATION_JOB', 'column', 'TOTAL_AMT'
exec sys.sp_addextendedproperty 'MS_Description', 'Total Payment Amount: total payment amount of  the  reconciliation job.', 'schema', 'dbo', 'table', 'D_RECONCILIATION_JOB', 'column', 'TOTAL_PAYMENT_AMT'
exec sys.sp_addextendedproperty 'MS_Description', 'Total Refund Amount: total refund amount of  the  reconciliation job.', 'schema', 'dbo', 'table', 'D_RECONCILIATION_JOB', 'column', 'TOTAL_REFUND_AMT'
exec sys.sp_addextendedproperty 'MS_Description', 'File Name: file name.', 'schema', 'dbo', 'table', 'D_RECONCILIATION_JOB', 'column', 'FILE_NM'
exec sys.sp_addextendedproperty 'MS_Description', 'User Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'D_RECONCILIATION_JOB', 'column', 'RECONCILING_USER_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Location Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'D_RECONCILIATION_JOB', 'column', 'RECONCILING_LOCATION_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Mart Source Identifier: source system identifier for this record.', 'schema', 'dbo', 'table', 'D_RECONCILIATION_JOB', 'column', 'MART_SOURCE_ID'
exec sys.sp_addextendedproperty 'MS_Description', 'Mart Created Datetime: system date and time when this record was created in the mart.', 'schema', 'dbo', 'table', 'D_RECONCILIATION_JOB', 'column', 'MART_CREATED_DTM'
exec sys.sp_addextendedproperty 'MS_Description', 'Mart Modified Datetime: system date and time when this record was last modified in the mart.', 'schema', 'dbo', 'table', 'D_RECONCILIATION_JOB', 'column', 'MART_MODIFIED_DTM'
exec sys.sp_addextendedproperty 'MS_Description', 'Reconciliation Job: reconciliation job.', 'schema', 'dbo', 'table', 'D_RECONCILIATION_JOB'




PRINT '[INFO] CREATED TABLE [DBO].[D_RECONCILIATION_JOB]'

END
GO


--INDEX: D_RECONCILIATION_JOB_RECONCILING_USER_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[D_RECONCILIATION_JOB]','U') AND i.name = 'D_RECONCILIATION_JOB_RECONCILING_USER_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [D_RECONCILIATION_JOB_RECONCILING_USER_KEY_IX] ON [dbo].[D_RECONCILIATION_JOB]([RECONCILING_USER_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[D_RECONCILIATION_JOB].[D_RECONCILIATION_JOB_RECONCILING_USER_KEY_IX]'
END
GO

--INDEX: D_RECONCILIATION_JOB_RECONCILING_LOCATION_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[D_RECONCILIATION_JOB]','U') AND i.name = 'D_RECONCILIATION_JOB_RECONCILING_LOCATION_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [D_RECONCILIATION_JOB_RECONCILING_LOCATION_KEY_IX] ON [dbo].[D_RECONCILIATION_JOB]([RECONCILING_LOCATION_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[D_RECONCILIATION_JOB].[D_RECONCILIATION_JOB_RECONCILING_LOCATION_KEY_IX]'
END
GO

--INDEX: D_RECONCOLIATION_JOB_MART_SOURCE_ID_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[D_RECONCILIATION_JOB]','U') AND i.name = 'D_RECONCOLIATION_JOB_MART_SOURCE_ID_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [D_RECONCOLIATION_JOB_MART_SOURCE_ID_IX] ON [dbo].[D_RECONCILIATION_JOB]([MART_SOURCE_ID]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[D_RECONCILIATION_JOB].[D_RECONCOLIATION_JOB_MART_SOURCE_ID_IX]'
END
GO


GO
-- END: D_RECONCILIATION_JOB.sql
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- START: D_VOUCHER.sql

/*
 * NOTES: Creates D_VOUCHER dimension for AspiraOne datamart 
 *
 * DATE        JIRA      USER             DESCRIPTION
 * ----------  --------  ---------------  ---------------------------------------  
 * 06/27/2019  DMA-4205  Nat Nie          Initialization.
*/



SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL READ COMMITTED

IF OBJECT_ID('DBO.D_VOUCHER') IS NULL
BEGIN
CREATE TABLE DBO.D_VOUCHER(
    VOUCHER_KEY              bigint            IDENTITY(1,1),
    VOUCHER_STATUS           varchar(50)       NULL,
    VOUCHER_PROGRAM_KEY      bigint            NULL,
    ORIGINAL_AMT             decimal(38, 6)    NULL,
    BALANCE                  decimal(38, 6)    NULL,
    CREATE_USER_KEY          bigint            NULL,
    CREATE_LOCATION_KEY      bigint            NULL,
    CREATE_DTM               datetime          NULL,
    REFUNDED_USER_KEY        bigint            NULL,
    REFUNDED_LOCATION_KEY    bigint            NULL,
    REFUNDED_DTM             datetime          NULL,
    REFUNDED_TO_REFUND_ID    bigint            NULL,
    REFUNDED_COMMENTS        varchar(4000)     NULL,
    VOID_USER_KEY            bigint            NULL,
    VOID_LOCATION_KEY        bigint            NULL,
    VOID_DTM                 datetime          NULL,
    MART_SOURCE_ID           bigint            NULL,
    MART_CREATED_DTM         datetime          NULL,
    MART_MODIFIED_DTM        datetime          NULL,
    CONSTRAINT PK_D_VOUCHER_ PRIMARY KEY CLUSTERED (VOUCHER_KEY)
)ON TX_CAMPING_MART_DATA


exec sys.sp_addextendedproperty 'MS_Description', 'Voucher Key: surrogate key used to uniquely identify a voucher record in the data mart.', 'schema', 'dbo', 'table', 'D_VOUCHER', 'column', 'VOUCHER_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Voucher Status: voucher status.', 'schema', 'dbo', 'table', 'D_VOUCHER', 'column', 'VOUCHER_STATUS'
exec sys.sp_addextendedproperty 'MS_Description', 'Voucher Program Key: surrogate key used to uniquely identify a voucher program record in the data mart.', 'schema', 'dbo', 'table', 'D_VOUCHER', 'column', 'VOUCHER_PROGRAM_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Original Amount: orginal amount of the voucher.', 'schema', 'dbo', 'table', 'D_VOUCHER', 'column', 'ORIGINAL_AMT'
exec sys.sp_addextendedproperty 'MS_Description', 'Balance: balance of the voucher.', 'schema', 'dbo', 'table', 'D_VOUCHER', 'column', 'BALANCE'
exec sys.sp_addextendedproperty 'MS_Description', 'User Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'D_VOUCHER', 'column', 'CREATE_USER_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Location Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'D_VOUCHER', 'column', 'CREATE_LOCATION_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Create Date: create date.', 'schema', 'dbo', 'table', 'D_VOUCHER', 'column', 'CREATE_DTM'
exec sys.sp_addextendedproperty 'MS_Description', 'User Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'D_VOUCHER', 'column', 'REFUNDED_USER_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Location Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'D_VOUCHER', 'column', 'REFUNDED_LOCATION_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Refunded Date: refunded date.', 'schema', 'dbo', 'table', 'D_VOUCHER', 'column', 'REFUNDED_DTM'
exec sys.sp_addextendedproperty 'MS_Description', 'Refunded to Refund ID: refunded to refund ID in AO.', 'schema', 'dbo', 'table', 'D_VOUCHER', 'column', 'REFUNDED_TO_REFUND_ID'
exec sys.sp_addextendedproperty 'MS_Description', 'Refunded Comments: refunded comments.', 'schema', 'dbo', 'table', 'D_VOUCHER', 'column', 'REFUNDED_COMMENTS'
exec sys.sp_addextendedproperty 'MS_Description', 'User Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'D_VOUCHER', 'column', 'VOID_USER_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Location Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'D_VOUCHER', 'column', 'VOID_LOCATION_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Void Date: void date.', 'schema', 'dbo', 'table', 'D_VOUCHER', 'column', 'VOID_DTM'
exec sys.sp_addextendedproperty 'MS_Description', 'Mart Source Identifier: source system identifier for this record.', 'schema', 'dbo', 'table', 'D_VOUCHER', 'column', 'MART_SOURCE_ID'
exec sys.sp_addextendedproperty 'MS_Description', 'Mart Created Datetime: system date and time when this record was created in the mart.', 'schema', 'dbo', 'table', 'D_VOUCHER', 'column', 'MART_CREATED_DTM'
exec sys.sp_addextendedproperty 'MS_Description', 'Mart Modified Datetime: system date and time when this record was last modified in the mart.', 'schema', 'dbo', 'table', 'D_VOUCHER', 'column', 'MART_MODIFIED_DTM'
exec sys.sp_addextendedproperty 'MS_Description', 'Voucher: voucher', 'schema', 'dbo', 'table', 'D_VOUCHER'


PRINT '[INFO] CREATED TABLE [DBO].[D_VOUCHER]'

END
GO

--INDEX: D_VOUCHER_VOUCHER_PROGRAM_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[D_VOUCHER]','U') AND i.name = 'D_VOUCHER_VOUCHER_PROGRAM_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [D_VOUCHER_VOUCHER_PROGRAM_KEY_IX] ON [dbo].[D_VOUCHER]([VOUCHER_PROGRAM_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[D_VOUCHER].[D_VOUCHER_VOUCHER_PROGRAM_KEY_IX]'
END
GO

--INDEX: D_VOUCHER_CREATE_USER_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[D_VOUCHER]','U') AND i.name = 'D_VOUCHER_CREATE_USER_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [D_VOUCHER_CREATE_USER_KEY_IX] ON [dbo].[D_VOUCHER]([CREATE_USER_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[D_VOUCHER].[D_VOUCHER_CREATE_USER_KEY_IX]'
END
GO

--INDEX: D_VOUCHER_REFUNDED_USER_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[D_VOUCHER]','U') AND i.name = 'D_VOUCHER_REFUNDED_USER_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [D_VOUCHER_REFUNDED_USER_KEY_IX] ON [dbo].[D_VOUCHER]([REFUNDED_USER_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[D_VOUCHER].[D_VOUCHER_REFUNDED_USER_KEY_IX]'
END
GO

--INDEX: D_VOUCHER_VOID_USER_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[D_VOUCHER]','U') AND i.name = 'D_VOUCHER_VOID_USER_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [D_VOUCHER_VOID_USER_KEY_IX] ON [dbo].[D_VOUCHER]([VOID_USER_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[D_VOUCHER].[D_VOUCHER_VOID_USER_KEY_IX]'
END
GO

--INDEX: D_VOUCHER_CREATE_LOCATION_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[D_VOUCHER]','U') AND i.name = 'D_VOUCHER_CREATE_LOCATION_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [D_VOUCHER_CREATE_LOCATION_KEY_IX] ON [dbo].[D_VOUCHER]([CREATE_LOCATION_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[D_VOUCHER].[D_VOUCHER_CREATE_LOCATION_KEY_IX]'
END
GO

--INDEX: D_VOUCHER_REFUNDED_LOCATION_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[D_VOUCHER]','U') AND i.name = 'D_VOUCHER_REFUNDED_LOCATION_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [D_VOUCHER_REFUNDED_LOCATION_KEY_IX] ON [dbo].[D_VOUCHER]([REFUNDED_LOCATION_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[D_VOUCHER].[D_VOUCHER_REFUNDED_LOCATION_KEY_IX]'
END
GO

--INDEX: D_VOUCHER_VOID_LOCATION_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[D_VOUCHER]','U') AND i.name = 'D_VOUCHER_VOID_LOCATION_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [D_VOUCHER_VOID_LOCATION_KEY_IX] ON [dbo].[D_VOUCHER]([VOID_LOCATION_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[D_VOUCHER].[D_VOUCHER_VOID_LOCATION_KEY_IX]'
END
GO

--INDEX: D_VOUCHER_MART_SOURCE_ID_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[D_VOUCHER]','U') AND i.name = 'D_VOUCHER_MART_SOURCE_ID_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [D_VOUCHER_MART_SOURCE_ID_IX] ON [dbo].[D_VOUCHER]([MART_SOURCE_ID]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[D_VOUCHER].[D_VOUCHER_MART_SOURCE_ID_IX]'
END
GO

GO
-- END: D_VOUCHER.sql
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- START: D_VOUCHER_PROGRAM.sql

/*
 * NOTES: Creates D_VOUCHER_PROGRAM dimension for AspiraOne datamart 
 *
 * DATE        JIRA      USER             DESCRIPTION
 * ----------  --------  ---------------  ---------------------------------------  
 * 06/27/2019  DMA-4205  Nat Nie          Initialization.
*/



SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL READ COMMITTED

IF OBJECT_ID('DBO.D_VOUCHER_PROGRAM') IS NULL
BEGIN
CREATE TABLE DBO.D_VOUCHER_PROGRAM(
    VOUCHER_PROGRAM_KEY          bigint           IDENTITY(1,1),
    VOUCHER_PROGRAM_NM           varchar(1024)    NULL,
    VOUCHER_PROGRAM_TYPE         varchar(512)     NULL,
    EFFECTIVE_START_DT           date             NULL,
    EFFECTIVE_END_DT             date             NULL,
    EMERGENCY_CANCEL_IND         smallint         NULL,
    REDIRECT_REFUND_IND          smallint         NULL,
    WEB_REDIRECT_REFUND_IND      smallint         NULL,
    SAME_BILLING_CUSTOMER_IND    smallint         NULL,
    EXPIRY_IND                   smallint         NULL,
    ACCOUNT_KEY                  bigint           NULL,
    ACTIVE_IND                   smallint         NULL,
    DELETED_IND                  smallint         NULL,
    MART_SOURCE_ID               bigint           NULL,
    MART_CREATED_DTM             datetime         NULL,
    MART_MODIFIED_DTM            datetime         NULL,
    CONSTRAINT PK_D_VOUCHER_PROGRAM PRIMARY KEY CLUSTERED (VOUCHER_PROGRAM_KEY)
)ON TX_CAMPING_MART_DATA

exec sys.sp_addextendedproperty 'MS_Description', 'Voucher Program Key: surrogate key used to uniquely identify a voucher program record in the data mart.', 'schema', 'dbo', 'table', 'D_VOUCHER_PROGRAM', 'column', 'VOUCHER_PROGRAM_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Voucher Program Name: the name of voucher program.', 'schema', 'dbo', 'table', 'D_VOUCHER_PROGRAM', 'column', 'VOUCHER_PROGRAM_NM'
exec sys.sp_addextendedproperty 'MS_Description', 'Voucher Programe Type: voucher programe type.', 'schema', 'dbo', 'table', 'D_VOUCHER_PROGRAM', 'column', 'VOUCHER_PROGRAM_TYPE'
exec sys.sp_addextendedproperty 'MS_Description', 'Effective Start Date: effective start date.', 'schema', 'dbo', 'table', 'D_VOUCHER_PROGRAM', 'column', 'EFFECTIVE_START_DT'
exec sys.sp_addextendedproperty 'MS_Description', 'Effective End Date: effective end date.', 'schema', 'dbo', 'table', 'D_VOUCHER_PROGRAM', 'column', 'EFFECTIVE_END_DT'
exec sys.sp_addextendedproperty 'MS_Description', 'Emergency Cancel Indicator: emergency cancel indicator.', 'schema', 'dbo', 'table', 'D_VOUCHER_PROGRAM', 'column', 'EMERGENCY_CANCEL_IND'
exec sys.sp_addextendedproperty 'MS_Description', 'Redirect Refund Indicator: redirect refund indicator.', 'schema', 'dbo', 'table', 'D_VOUCHER_PROGRAM', 'column', 'REDIRECT_REFUND_IND'
exec sys.sp_addextendedproperty 'MS_Description', 'Web Redirect Refund Indicator: web redirect refund indicator.', 'schema', 'dbo', 'table', 'D_VOUCHER_PROGRAM', 'column', 'WEB_REDIRECT_REFUND_IND'
exec sys.sp_addextendedproperty 'MS_Description', 'Same Billing Customer Indicator: same billing customer indicator.', 'schema', 'dbo', 'table', 'D_VOUCHER_PROGRAM', 'column', 'SAME_BILLING_CUSTOMER_IND'
exec sys.sp_addextendedproperty 'MS_Description', 'Expiry Indicator: expiry indicator.', 'schema', 'dbo', 'table', 'D_VOUCHER_PROGRAM', 'column', 'EXPIRY_IND'
exec sys.sp_addextendedproperty 'MS_Description', 'Account Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'D_VOUCHER_PROGRAM', 'column', 'ACCOUNT_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Active Indicator: 1 if this record is active in the source system, otherwise 0.', 'schema', 'dbo', 'table', 'D_VOUCHER_PROGRAM', 'column', 'ACTIVE_IND'
exec sys.sp_addextendedproperty 'MS_Description', 'Deleted Indicator: 1 if this record has been deleted in the source system, otherwise 0.', 'schema', 'dbo', 'table', 'D_VOUCHER_PROGRAM', 'column', 'DELETED_IND'
exec sys.sp_addextendedproperty 'MS_Description', 'Mart Source Identifier: source system identifier for this record.', 'schema', 'dbo', 'table', 'D_VOUCHER_PROGRAM', 'column', 'MART_SOURCE_ID'
exec sys.sp_addextendedproperty 'MS_Description', 'Mart Created Datetime: system date and time when this record was created in the mart.', 'schema', 'dbo', 'table', 'D_VOUCHER_PROGRAM', 'column', 'MART_CREATED_DTM'
exec sys.sp_addextendedproperty 'MS_Description', 'Mart Modified Datetime: system date and time when this record was last modified in the mart.', 'schema', 'dbo', 'table', 'D_VOUCHER_PROGRAM', 'column', 'MART_MODIFIED_DTM'
exec sys.sp_addextendedproperty 'MS_Description', 'Voucher Program: voucher program.', 'schema', 'dbo', 'table', 'D_VOUCHER_PROGRAM'

PRINT '[INFO] CREATED TABLE [DBO].[D_VOUCHER_PROGRAM]'

END
GO

--INDEX: D_VOUCHER_PROGRAM_ACCOUNT_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[D_VOUCHER_PROGRAM]','U') AND i.name = 'D_VOUCHER_PROGRAM_ACCOUNT_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [D_VOUCHER_PROGRAM_ACCOUNT_KEY_IX] ON [dbo].[D_VOUCHER_PROGRAM]([ACCOUNT_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[D_VOUCHER_PROGRAM].[D_VOUCHER_PROGRAM_ACCOUNT_KEY_IX]'
END
GO

--INDEX: D_VOUCHER_PROGRAM_MART_SOURCE_ID_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[D_VOUCHER_PROGRAM]','U') AND i.name = 'D_VOUCHER_PROGRAM_MART_SOURCE_ID_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [D_VOUCHER_PROGRAM_MART_SOURCE_ID_IX] ON [dbo].[D_VOUCHER_PROGRAM]([MART_SOURCE_ID]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[D_VOUCHER_PROGRAM].[D_VOUCHER_PROGRAM_MART_SOURCE_ID_IX]'
END
GO

GO

-- END: D_VOUCHER_PROGRAM.sql
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- START: B_REFUND_ISSUANCE_ATTRIBUTE.sql

/*
 * NOTES: Creates B_REFUND_ISSUANCE_ATTRIBUTE bridge for AspiraOne datamart 
 *
 * DATE        JIRA      USER             DESCRIPTION
 * ----------  --------  ---------------  ---------------------------------------  
 * 06/27/2019  DMA-4205  Nat Nie          Initialization.
*/



SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL READ COMMITTED

IF OBJECT_ID('DBO.B_REFUND_ISSUANCE_ATTRIBUTE') IS NULL
BEGIN
CREATE TABLE B_REFUND_ISSUANCE_ATTRIBUTE(
    REFUND_ISSUANCE_ATTRIBUTE_KEY    bigint          IDENTITY(1,1),
    REFUND_ISSUANCE_KEY              bigint          NULL,
    ATTRIBUTE_NM                     varchar(255)    NULL,
    ATTRIBUTE_VALUE                  varchar(255)    NULL,
    MART_SOURCE_ID                   bigint          NULL,
    MART_MODIFIED_DTM                datetime        NULL,
    MART_CREATED_DTM                 datetime        NULL,
    CONSTRAINT PK_B_REFUND_ISSUANCE_ATTRIBUTE PRIMARY KEY CLUSTERED (REFUND_ISSUANCE_ATTRIBUTE_KEY)
)ON TX_CAMPING_MART_DATA


exec sys.sp_addextendedproperty 'MS_Description', 'Refund Issuance Attribute Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'B_REFUND_ISSUANCE_ATTRIBUTE', 'column', 'REFUND_ISSUANCE_ATTRIBUTE_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Refund Issuance Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'B_REFUND_ISSUANCE_ATTRIBUTE', 'column', 'REFUND_ISSUANCE_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Attribute Name: attribute name.', 'schema', 'dbo', 'table', 'B_REFUND_ISSUANCE_ATTRIBUTE', 'column', 'ATTRIBUTE_NM'
exec sys.sp_addextendedproperty 'MS_Description', 'Attribute Value: attribute value.', 'schema', 'dbo', 'table', 'B_REFUND_ISSUANCE_ATTRIBUTE', 'column', 'ATTRIBUTE_VALUE'
exec sys.sp_addextendedproperty 'MS_Description', 'Mart Source Identifier: source system identifier for this record.', 'schema', 'dbo', 'table', 'B_REFUND_ISSUANCE_ATTRIBUTE', 'column', 'MART_SOURCE_ID'
exec sys.sp_addextendedproperty 'MS_Description', 'Mart Modified Datetime: system date and time when this record was last modified in the mart.', 'schema', 'dbo', 'table', 'B_REFUND_ISSUANCE_ATTRIBUTE', 'column', 'MART_MODIFIED_DTM'
exec sys.sp_addextendedproperty 'MS_Description', 'Mart Created Datetime: system date and time when this record was created in the mart.', 'schema', 'dbo', 'table', 'B_REFUND_ISSUANCE_ATTRIBUTE', 'column', 'MART_CREATED_DTM'
exec sys.sp_addextendedproperty 'MS_Description', 'Refund_Issuance_Attribute: the attribute and values that links to a refund issue record.', 'schema', 'dbo', 'table', 'B_REFUND_ISSUANCE_ATTRIBUTE'


PRINT '[INFO] CREATED TABLE [DBO].[B_REFUND_ISSUANCE_ATTRIBUTE]'

END
GO

--INDEX: B_REFUND_ISSUANCE_ATTRIBUTE_ISSUANCE_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_REFUND_ISSUANCE_ATTRIBUTE]','U') AND i.name = 'B_REFUND_ISSUANCE_ATTRIBUTE_ISSUANCE_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_REFUND_ISSUANCE_ATTRIBUTE_ISSUANCE_KEY_IX] ON [dbo].[B_REFUND_ISSUANCE_ATTRIBUTE]([REFUND_ISSUANCE_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_REFUND_ISSUANCE_ATTRIBUTE].[B_REFUND_ISSUANCE_ATTRIBUTE_ISSUANCE_KEY_IX]'
END
GO

--INDEX: B_REFUND_ISSUANCE_ATTRIBUTE_MART_SOURCE_ID_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_REFUND_ISSUANCE_ATTRIBUTE]','U') AND i.name = 'B_REFUND_ISSUANCE_ATTRIBUTE_MART_SOURCE_ID_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_REFUND_ISSUANCE_ATTRIBUTE_MART_SOURCE_ID_IX] ON [dbo].[B_REFUND_ISSUANCE_ATTRIBUTE]([MART_SOURCE_ID]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_REFUND_ISSUANCE_ATTRIBUTE].[B_REFUND_ISSUANCE_ATTRIBUTE_MART_SOURCE_ID_IX]'
END
GO

GO

-- END: B_REFUND_ISSUANCE_ATTRIBUTE.sql
--------------------------------------------------------------------------------



--------------------------------------------------------------------------------
-- START: F_REFUND_ISSUANCE.sql

/*
 * NOTES: Creates F_REFUND_ISSUANCE fact for AspiraOne datamart 
 *
 * DATE        JIRA      USER             DESCRIPTION
 * ----------  --------  ---------------  ---------------------------------------  
 * 06/27/2019  DMA-4205  Nat Nie          Initialization.
*/



SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL READ COMMITTED

IF OBJECT_ID('DBO.F_REFUND_ISSUANCE') IS NULL
BEGIN
CREATE TABLE F_REFUND_ISSUANCE(
    REFUND_ISSUANCE_KEY          bigint            IDENTITY(1,1),
    REFUND_STATUS_KEY            bigint            NOT NULL,
    REFUND_TYPE_KEY              bigint            NOT NULL,
    REFUND_GROUP_KEY             bigint            NOT NULL,
    REFUND_AMT                   decimal(38, 6)    NOT NULL,
    BATCH_KEY                    bigint            NULL,
    RECONCILIATION_JOB_KEY       bigint            NULL,
    REFERENCE_NB                 varchar(50)       NULL,
    FINANCIAL_SESSION_KEY        bigint            NULL,
    CUSTOMER_KEY                 bigint            NULL,
    ORDER_KEY                    bigint            NULL,
    ORDER_DATE_KEY               bigint            NULL,
    ORDER_NB                     varchar(255)      NULL,
    RECEIPT_NB                   varchar(80)       NULL,
    REQUEST_USER_KEY             bigint            NULL,
    PIN_USER_KEY                 bigint            NULL,
    REQUEST_LOCATION_KEY         bigint            NULL,
    REQUEST_DATE_KEY             bigint            NULL,
    REQUEST_TIME_KEY             bigint            NULL,
    APPROVE_USER_KEY             bigint            NULL,
    APPROVE_LOCATION_KEY         bigint            NULL,
    APPROVE_DATE_KEY             bigint            NULL,
    APPROVE_TIME_KEY             bigint            NULL,
    VOID_USER_KEY                bigint            NULL,
    VOID_LOCATION_KEY            bigint            NULL,
    VOID_DATE_KEY                bigint            NULL,
    VOID_TIME_KEY                bigint            NULL,
    ISSUE_STATUS_KEY             bigint            NULL,
    ISSUE_TYPE_KEY               bigint            NULL,
    ISSUE_SALES_CHANNEL_KEY      bigint            NULL,
    ISSUE_USER_KEY               bigint            NULL,
    ISSUE_LOCATION_KEY           bigint            NULL,
    REFUND_STATION_KEY           bigint            NULL,
    ISSUE_DATE_KEY               bigint            NULL,
    ISSUE_TIME_KEY               bigint            NULL,
    REISSUE_REASON               varchar(4000)     NULL,
    ISSUE_CENTRALLY_USER_KEY     bigint            NULL,
    ISSUE_CENTRALLY_IND          smallint          NULL,
    ISSUE_CENTRALLY_DTM          datetime          NULL,
    SOURCE_PAYMENT_ID            bigint            NULL,
    SOURCE_PAYMENT_TYPE_KEY      bigint            NULL,
    SOURCE_PAYMENT_STATUS_KEY    bigint            NULL,
    SOURCE_PAYMENT_GROUP_KEY     bigint            NULL,
    SOURCE_PAYMENT_AMT           decimal(38, 6)    NULL,
    ACCOUNT_KEY                  bigint            NULL,
    REFUND_NOTE                  varchar(4000)     NULL,
    FIELD_REFUND_NOTE            varchar(4000)     NULL,
    SUPPORT_REFUND_NOTE          varchar(4000)     NULL,
    GIFT_CARD_KEY                bigint            NULL,
    VOUCHER_KEY                  bigint            NULL,
    ACTIVE_IND                   smallint          NULL,
    MART_SOURCE_ID               bigint            NULL,
    MART_CREATED_DTM             datetime          NULL,
    MART_MODIFIED_DTM            datetime          NULL,
	REFUND_ID                    bigint            NULL,
    CONSTRAINT PK_F_REFUND_ISSUANCE PRIMARY KEY CLUSTERED (REFUND_ISSUANCE_KEY)
)ON TX_CAMPING_MART_DATA

exec sys.sp_addextendedproperty 'MS_Description', 'Refund Issuance Key: surrogate key used to uniquely identify a refund issuance record in the data mart.', 'schema', 'dbo', 'table', 'F_REFUND_ISSUANCE', 'column', 'REFUND_ISSUANCE_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Payament Status Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'F_REFUND_ISSUANCE', 'column', 'REFUND_STATUS_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Payment Type Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'F_REFUND_ISSUANCE', 'column', 'REFUND_TYPE_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Payment Group Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'F_REFUND_ISSUANCE', 'column', 'REFUND_GROUP_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Refund Amount: the amount on the refund.', 'schema', 'dbo', 'table', 'F_REFUND_ISSUANCE', 'column', 'REFUND_AMT'
exec sys.sp_addextendedproperty 'MS_Description', 'Batch Key: surrogate key used to uniquely identify a batch record in the data mart.', 'schema', 'dbo', 'table', 'F_REFUND_ISSUANCE', 'column', 'BATCH_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Reconciliation Job Key: surrogate key used to uniquely identify a reconciliation job record in the data mart.', 'schema', 'dbo', 'table', 'F_REFUND_ISSUANCE', 'column', 'RECONCILIATION_JOB_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Reference Number: the reference number in the settlement transaction.', 'schema', 'dbo', 'table', 'F_REFUND_ISSUANCE', 'column', 'REFERENCE_NB'
exec sys.sp_addextendedproperty 'MS_Description', 'Financial Session Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'F_REFUND_ISSUANCE', 'column', 'FINANCIAL_SESSION_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Customer Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'F_REFUND_ISSUANCE', 'column', 'CUSTOMER_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Order Key: surrogate key uniquely identifying this record in the mart.', 'schema', 'dbo', 'table', 'F_REFUND_ISSUANCE', 'column', 'ORDER_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Date Key: surrogate key uniquely identifying this record in the mart. Formatted YYYYMMDD', 'schema', 'dbo', 'table', 'F_REFUND_ISSUANCE', 'column', 'ORDER_DATE_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Order Number: order number.', 'schema', 'dbo', 'table', 'F_REFUND_ISSUANCE', 'column', 'ORDER_NB'
exec sys.sp_addextendedproperty 'MS_Description', 'Receipt Number: receipt number.', 'schema', 'dbo', 'table', 'F_REFUND_ISSUANCE', 'column', 'RECEIPT_NB'
exec sys.sp_addextendedproperty 'MS_Description', 'User Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'F_REFUND_ISSUANCE', 'column', 'REQUEST_USER_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'User Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'F_REFUND_ISSUANCE', 'column', 'PIN_USER_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Location Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'F_REFUND_ISSUANCE', 'column', 'REQUEST_LOCATION_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Date Key: surrogate key uniquely identifying this record in the mart. Formatted YYYYMMDD', 'schema', 'dbo', 'table', 'F_REFUND_ISSUANCE', 'column', 'REQUEST_DATE_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Time Key: surrogate key uniquely identifying this record in the mart. Same as the number of seconds within a day: 0-86399.', 'schema', 'dbo', 'table', 'F_REFUND_ISSUANCE', 'column', 'REQUEST_TIME_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'User Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'F_REFUND_ISSUANCE', 'column', 'APPROVE_USER_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Location Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'F_REFUND_ISSUANCE', 'column', 'APPROVE_LOCATION_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Date Key: surrogate key uniquely identifying this record in the mart. Formatted YYYYMMDD', 'schema', 'dbo', 'table', 'F_REFUND_ISSUANCE', 'column', 'APPROVE_DATE_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Time Key: surrogate key uniquely identifying this record in the mart. Same as the number of seconds within a day: 0-86399.', 'schema', 'dbo', 'table', 'F_REFUND_ISSUANCE', 'column', 'APPROVE_TIME_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'User Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'F_REFUND_ISSUANCE', 'column', 'VOID_USER_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Location Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'F_REFUND_ISSUANCE', 'column', 'VOID_LOCATION_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Date Key: surrogate key uniquely identifying this record in the mart. Formatted YYYYMMDD', 'schema', 'dbo', 'table', 'F_REFUND_ISSUANCE', 'column', 'VOID_DATE_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Time Key: surrogate key uniquely identifying this record in the mart. Same as the number of seconds within a day: 0-86399.', 'schema', 'dbo', 'table', 'F_REFUND_ISSUANCE', 'column', 'VOID_TIME_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Payament Status Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'F_REFUND_ISSUANCE', 'column', 'ISSUE_STATUS_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Payment Type Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'F_REFUND_ISSUANCE', 'column', 'ISSUE_TYPE_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Sales Channel Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'F_REFUND_ISSUANCE', 'column', 'ISSUE_SALES_CHANNEL_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'User Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'F_REFUND_ISSUANCE', 'column', 'ISSUE_USER_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Location Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'F_REFUND_ISSUANCE', 'column', 'ISSUE_LOCATION_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Location Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'F_REFUND_ISSUANCE', 'column', 'REFUND_STATION_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Date Key: surrogate key uniquely identifying this record in the mart. Formatted YYYYMMDD', 'schema', 'dbo', 'table', 'F_REFUND_ISSUANCE', 'column', 'ISSUE_DATE_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Time Key: surrogate key uniquely identifying this record in the mart. Same as the number of seconds within a day: 0-86399.', 'schema', 'dbo', 'table', 'F_REFUND_ISSUANCE', 'column', 'ISSUE_TIME_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Reissue Reason: reissue reason.', 'schema', 'dbo', 'table', 'F_REFUND_ISSUANCE', 'column', 'REISSUE_REASON'
exec sys.sp_addextendedproperty 'MS_Description', 'User Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'F_REFUND_ISSUANCE', 'column', 'ISSUE_CENTRALLY_USER_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Issue Centrally Indicator: indicates whether the refund is issued centrally, 0 locally, 1 centrally.', 'schema', 'dbo', 'table', 'F_REFUND_ISSUANCE', 'column', 'ISSUE_CENTRALLY_IND'
exec sys.sp_addextendedproperty 'MS_Description', 'Issue Centrally Date: issue centrally date.', 'schema', 'dbo', 'table', 'F_REFUND_ISSUANCE', 'column', 'ISSUE_CENTRALLY_DTM'
exec sys.sp_addextendedproperty 'MS_Description', 'Source Payment Identifier: the ID of the source payment in AO.', 'schema', 'dbo', 'table', 'F_REFUND_ISSUANCE', 'column', 'SOURCE_PAYMENT_ID'
exec sys.sp_addextendedproperty 'MS_Description', 'Payment Type Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'F_REFUND_ISSUANCE', 'column', 'SOURCE_PAYMENT_TYPE_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Payament Status Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'F_REFUND_ISSUANCE', 'column', 'SOURCE_PAYMENT_STATUS_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Payment Group Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'F_REFUND_ISSUANCE', 'column', 'SOURCE_PAYMENT_GROUP_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Source Payment Amount: the amount of the source payment.', 'schema', 'dbo', 'table', 'F_REFUND_ISSUANCE', 'column', 'SOURCE_PAYMENT_AMT'
exec sys.sp_addextendedproperty 'MS_Description', 'Account Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'F_REFUND_ISSUANCE', 'column', 'ACCOUNT_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Refund Note: refund note.', 'schema', 'dbo', 'table', 'F_REFUND_ISSUANCE', 'column', 'REFUND_NOTE'
exec sys.sp_addextendedproperty 'MS_Description', 'Field Refund Note: field refund note.', 'schema', 'dbo', 'table', 'F_REFUND_ISSUANCE', 'column', 'FIELD_REFUND_NOTE'
exec sys.sp_addextendedproperty 'MS_Description', 'Support Refund Note: support refund note.', 'schema', 'dbo', 'table', 'F_REFUND_ISSUANCE', 'column', 'SUPPORT_REFUND_NOTE'
exec sys.sp_addextendedproperty 'MS_Description', 'Item Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'F_REFUND_ISSUANCE', 'column', 'GIFT_CARD_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Voucher Key: surrogate key used to uniquely identify a voucher record in the data mart.', 'schema', 'dbo', 'table', 'F_REFUND_ISSUANCE', 'column', 'VOUCHER_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Active Indicator: 1 if this record is active in the source system, otherwise 0.', 'schema', 'dbo', 'table', 'F_REFUND_ISSUANCE', 'column', 'ACTIVE_IND'
exec sys.sp_addextendedproperty 'MS_Description', 'Mart Source Identifier: source system identifier for this record.', 'schema', 'dbo', 'table', 'F_REFUND_ISSUANCE', 'column', 'MART_SOURCE_ID'
exec sys.sp_addextendedproperty 'MS_Description', 'Mart Created Datetime: system date and time when this record was created in the mart.', 'schema', 'dbo', 'table', 'F_REFUND_ISSUANCE', 'column', 'MART_CREATED_DTM'
exec sys.sp_addextendedproperty 'MS_Description', 'Mart Modified Datetime: system date and time when this record was last modified in the mart.', 'schema', 'dbo', 'table', 'F_REFUND_ISSUANCE', 'column', 'MART_MODIFIED_DTM'
exec sys.sp_addextendedproperty 'MS_Description', 'Refund Identifier: identifier of the refund.', 'schema', 'dbo', 'table', 'F_REFUND_ISSUANCE', 'column', 'REFUND_ID'
exec sys.sp_addextendedproperty 'MS_Description', 'Refund Issuance: one row per refund issuance, including inactive ones.', 'schema', 'dbo', 'table', 'F_REFUND_ISSUANCE'

PRINT '[INFO] CREATED TABLE [DBO].[F_REFUND_ISSUANCE]'

END
GO


--INDEX: F_REFUND_ISSUANCE_FINANCIAL_SESSION_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_REFUND_ISSUANCE]','U') AND i.name = 'F_REFUND_ISSUANCE_FINANCIAL_SESSION_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_REFUND_ISSUANCE_FINANCIAL_SESSION_KEY_IX] ON [dbo].[F_REFUND_ISSUANCE]([FINANCIAL_SESSION_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_REFUND_ISSUANCE].[F_REFUND_ISSUANCE_FINANCIAL_SESSION_KEY_IX]'
END
GO

--INDEX: F_REFUND_ISSUANCE_CUSTOMER_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_REFUND_ISSUANCE]','U') AND i.name = 'F_REFUND_ISSUANCE_CUSTOMER_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_REFUND_ISSUANCE_CUSTOMER_KEY_IX] ON [dbo].[F_REFUND_ISSUANCE]([CUSTOMER_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_REFUND_ISSUANCE].[F_REFUND_ISSUANCE_CUSTOMER_KEY_IX]'
END
GO

--INDEX: F_REFUND_ISSUANCE_ORDER_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_REFUND_ISSUANCE]','U') AND i.name = 'F_REFUND_ISSUANCE_ORDER_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_REFUND_ISSUANCE_ORDER_KEY_IX] ON [dbo].[F_REFUND_ISSUANCE]([ORDER_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_REFUND_ISSUANCE].[F_REFUND_ISSUANCE_ORDER_KEY_IX]'
END
GO

--INDEX: F_REFUND_ISSUANCE_ORDER_DATE_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_REFUND_ISSUANCE]','U') AND i.name = 'F_REFUND_ISSUANCE_ORDER_DATE_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_REFUND_ISSUANCE_ORDER_DATE_KEY_IX] ON [dbo].[F_REFUND_ISSUANCE]([ORDER_DATE_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_REFUND_ISSUANCE].[F_REFUND_ISSUANCE_ORDER_DATE_KEY_IX]'
END
GO

--INDEX: F_REFUND_ISSUANCE_ORDER_NB_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_REFUND_ISSUANCE]','U') AND i.name = 'F_REFUND_ISSUANCE_ORDER_NB_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_REFUND_ISSUANCE_ORDER_NB_IX] ON [dbo].[F_REFUND_ISSUANCE]([ORDER_NB]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_REFUND_ISSUANCE].[F_REFUND_ISSUANCE_ORDER_NB_IX]'
END
GO

--INDEX: F_REFUND_ISSUANCE_RECEIPT_NB_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_REFUND_ISSUANCE]','U') AND i.name = 'F_REFUND_ISSUANCE_RECEIPT_NB_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_REFUND_ISSUANCE_RECEIPT_NB_IX] ON [dbo].[F_REFUND_ISSUANCE]([RECEIPT_NB]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_REFUND_ISSUANCE].[F_REFUND_ISSUANCE_RECEIPT_NB_IX]'
END
GO

--INDEX: F_REFUND_ISSUANCE_REQUEST_USER_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_REFUND_ISSUANCE]','U') AND i.name = 'F_REFUND_ISSUANCE_REQUEST_USER_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_REFUND_ISSUANCE_REQUEST_USER_KEY_IX] ON [dbo].[F_REFUND_ISSUANCE]([REQUEST_USER_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_REFUND_ISSUANCE].[F_REFUND_ISSUANCE_REQUEST_USER_KEY_IX]'
END
GO

--INDEX: F_REFUND_ISSUANCE_REQUEST_LOCATION_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_REFUND_ISSUANCE]','U') AND i.name = 'F_REFUND_ISSUANCE_REQUEST_LOCATION_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_REFUND_ISSUANCE_REQUEST_LOCATION_KEY_IX] ON [dbo].[F_REFUND_ISSUANCE]([REQUEST_LOCATION_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_REFUND_ISSUANCE].[F_REFUND_ISSUANCE_REQUEST_LOCATION_KEY_IX]'
END
GO

--INDEX: F_REFUND_ISSUANCE_REQUEST_DATE_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_REFUND_ISSUANCE]','U') AND i.name = 'F_REFUND_ISSUANCE_REQUEST_DATE_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_REFUND_ISSUANCE_REQUEST_DATE_KEY_IX] ON [dbo].[F_REFUND_ISSUANCE]([REQUEST_DATE_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_REFUND_ISSUANCE].[F_REFUND_ISSUANCE_REQUEST_DATE_KEY_IX]'
END
GO

--INDEX: F_REFUND_ISSUANCE_REQUEST_TIME_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_REFUND_ISSUANCE]','U') AND i.name = 'F_REFUND_ISSUANCE_REQUEST_TIME_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_REFUND_ISSUANCE_REQUEST_TIME_KEY_IX] ON [dbo].[F_REFUND_ISSUANCE]([REQUEST_TIME_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_REFUND_ISSUANCE].[F_REFUND_ISSUANCE_REQUEST_TIME_KEY_IX]'
END
GO

--INDEX: F_REFUND_ISSUANCE_APPROVE_USER_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_REFUND_ISSUANCE]','U') AND i.name = 'F_REFUND_ISSUANCE_APPROVE_USER_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_REFUND_ISSUANCE_APPROVE_USER_KEY_IX] ON [dbo].[F_REFUND_ISSUANCE]([APPROVE_USER_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_REFUND_ISSUANCE].[F_REFUND_ISSUANCE_APPROVE_USER_KEY_IX]'
END
GO

--INDEX: F_REFUND_ISSUANCE_APPROVE_LOCATION_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_REFUND_ISSUANCE]','U') AND i.name = 'F_REFUND_ISSUANCE_APPROVE_LOCATION_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_REFUND_ISSUANCE_APPROVE_LOCATION_KEY_IX] ON [dbo].[F_REFUND_ISSUANCE]([APPROVE_LOCATION_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_REFUND_ISSUANCE].[F_REFUND_ISSUANCE_APPROVE_LOCATION_KEY_IX]'
END
GO

--INDEX: F_REFUND_ISSUANCE_APPROVE_DATE_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_REFUND_ISSUANCE]','U') AND i.name = 'F_REFUND_ISSUANCE_APPROVE_DATE_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_REFUND_ISSUANCE_APPROVE_DATE_KEY_IX] ON [dbo].[F_REFUND_ISSUANCE]([APPROVE_DATE_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_REFUND_ISSUANCE].[F_REFUND_ISSUANCE_APPROVE_DATE_KEY_IX]'
END
GO

--INDEX: F_REFUND_ISSUANCE_APPROVE_TIME_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_REFUND_ISSUANCE]','U') AND i.name = 'F_REFUND_ISSUANCE_APPROVE_TIME_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_REFUND_ISSUANCE_APPROVE_TIME_KEY_IX] ON [dbo].[F_REFUND_ISSUANCE]([APPROVE_TIME_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_REFUND_ISSUANCE].[F_REFUND_ISSUANCE_APPROVE_TIME_KEY_IX]'
END
GO

--INDEX: F_REFUND_ISSUANCE_VOID_USER_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_REFUND_ISSUANCE]','U') AND i.name = 'F_REFUND_ISSUANCE_VOID_USER_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_REFUND_ISSUANCE_VOID_USER_KEY_IX] ON [dbo].[F_REFUND_ISSUANCE]([VOID_USER_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_REFUND_ISSUANCE].[F_REFUND_ISSUANCE_VOID_USER_KEY_IX]'
END
GO

--INDEX: F_REFUND_ISSUANCE_VOID_LOCATION_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_REFUND_ISSUANCE]','U') AND i.name = 'F_REFUND_ISSUANCE_VOID_LOCATION_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_REFUND_ISSUANCE_VOID_LOCATION_KEY_IX] ON [dbo].[F_REFUND_ISSUANCE]([VOID_LOCATION_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_REFUND_ISSUANCE].[F_REFUND_ISSUANCE_VOID_LOCATION_KEY_IX]'
END
GO

--INDEX: F_REFUND_ISSUANCE_VOID_DATE_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_REFUND_ISSUANCE]','U') AND i.name = 'F_REFUND_ISSUANCE_VOID_DATE_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_REFUND_ISSUANCE_VOID_DATE_KEY_IX] ON [dbo].[F_REFUND_ISSUANCE]([VOID_DATE_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_REFUND_ISSUANCE].[F_REFUND_ISSUANCE_VOID_DATE_KEY_IX]'
END
GO

--INDEX: F_REFUND_ISSUANCE_VOID_TIME_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_REFUND_ISSUANCE]','U') AND i.name = 'F_REFUND_ISSUANCE_VOID_TIME_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_REFUND_ISSUANCE_VOID_TIME_KEY_IX] ON [dbo].[F_REFUND_ISSUANCE]([VOID_TIME_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_REFUND_ISSUANCE].[F_REFUND_ISSUANCE_VOID_TIME_KEY_IX]'
END
GO

--INDEX: F_REFUND_ISSUANCE_ISSUE_USER_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_REFUND_ISSUANCE]','U') AND i.name = 'F_REFUND_ISSUANCE_ISSUE_USER_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_REFUND_ISSUANCE_ISSUE_USER_KEY_IX] ON [dbo].[F_REFUND_ISSUANCE]([ISSUE_USER_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_REFUND_ISSUANCE].[F_REFUND_ISSUANCE_ISSUE_USER_KEY_IX]'
END
GO

--INDEX: F_REFUND_ISSUANCE_ISSUE_LOCATION_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_REFUND_ISSUANCE]','U') AND i.name = 'F_REFUND_ISSUANCE_ISSUE_LOCATION_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_REFUND_ISSUANCE_ISSUE_LOCATION_KEY_IX] ON [dbo].[F_REFUND_ISSUANCE]([ISSUE_LOCATION_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_REFUND_ISSUANCE].[F_REFUND_ISSUANCE_ISSUE_LOCATION_KEY_IX]'
END
GO

--INDEX: F_REFUND_ISSUANCE_ISSUE_DATE_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_REFUND_ISSUANCE]','U') AND i.name = 'F_REFUND_ISSUANCE_ISSUE_DATE_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_REFUND_ISSUANCE_ISSUE_DATE_KEY_IX] ON [dbo].[F_REFUND_ISSUANCE]([ISSUE_DATE_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_REFUND_ISSUANCE].[F_REFUND_ISSUANCE_ISSUE_DATE_KEY_IX]'
END
GO

--INDEX: F_REFUND_ISSUANCE_ISSUE_TIME_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_REFUND_ISSUANCE]','U') AND i.name = 'F_REFUND_ISSUANCE_ISSUE_TIME_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_REFUND_ISSUANCE_ISSUE_TIME_KEY_IX] ON [dbo].[F_REFUND_ISSUANCE]([ISSUE_TIME_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_REFUND_ISSUANCE].[F_REFUND_ISSUANCE_ISSUE_TIME_KEY_IX]'
END
GO

--INDEX: F_REFUND_ISSUANCE_ISSUE_CENTRALLY_USER_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_REFUND_ISSUANCE]','U') AND i.name = 'F_REFUND_ISSUANCE_ISSUE_CENTRALLY_USER_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_REFUND_ISSUANCE_ISSUE_CENTRALLY_USER_KEY_IX] ON [dbo].[F_REFUND_ISSUANCE]([ISSUE_CENTRALLY_USER_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_REFUND_ISSUANCE].[F_REFUND_ISSUANCE_ISSUE_CENTRALLY_USER_KEY_IX]'
END
GO

--INDEX: F_REFUND_ISSUANCE_ACCOUNT_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_REFUND_ISSUANCE]','U') AND i.name = 'F_REFUND_ISSUANCE_ACCOUNT_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_REFUND_ISSUANCE_ACCOUNT_KEY_IX] ON [dbo].[F_REFUND_ISSUANCE]([ACCOUNT_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_REFUND_ISSUANCE].[F_REFUND_ISSUANCE_ACCOUNT_KEY_IX]'
END
GO

--INDEX: F_REFUND_ISSUANCE_BATCH_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_REFUND_ISSUANCE]','U') AND i.name = 'F_REFUND_ISSUANCE_BATCH_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_REFUND_ISSUANCE_BATCH_KEY_IX] ON [dbo].[F_REFUND_ISSUANCE]([BATCH_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_REFUND_ISSUANCE].[F_REFUND_ISSUANCE_BATCH_KEY_IX]'
END
GO


--INDEX: F_REFUND_ISSUANCE_RECONCILIATION_JOB_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_REFUND_ISSUANCE]','U') AND i.name = 'F_REFUND_ISSUANCE_RECONCILIATION_JOB_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_REFUND_ISSUANCE_RECONCILIATION_JOB_KEY_IX] ON [dbo].[F_REFUND_ISSUANCE]([RECONCILIATION_JOB_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_REFUND_ISSUANCE].[F_REFUND_ISSUANCE_RECONCILIATION_JOB_KEY_IX]'
END
GO

--INDEX: F_REFUND_ISSUANCE_GIFT_CARD_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_REFUND_ISSUANCE]','U') AND i.name = 'F_REFUND_ISSUANCE_GIFT_CARD_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_REFUND_ISSUANCE_GIFT_CARD_KEY_IX] ON [dbo].[F_REFUND_ISSUANCE]([GIFT_CARD_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_REFUND_ISSUANCE].[F_REFUND_ISSUANCE_GIFT_CARD_KEY_IX]'
END
GO

--INDEX: F_REFUND_ISSUANCE_VOUCHER_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_REFUND_ISSUANCE]','U') AND i.name = 'F_REFUND_ISSUANCE_VOUCHER_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_REFUND_ISSUANCE_VOUCHER_KEY_IX] ON [dbo].[F_REFUND_ISSUANCE]([VOUCHER_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_REFUND_ISSUANCE].[F_REFUND_ISSUANCE_VOUCHER_KEY_IX]'
END
GO

--INDEX: F_REFUND_ISSUANCE_PIN_USER_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_REFUND_ISSUANCE]','U') AND i.name = 'F_REFUND_ISSUANCE_PIN_USER_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_REFUND_ISSUANCE_PIN_USER_KEY_IX] ON [dbo].[F_REFUND_ISSUANCE]([PIN_USER_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_REFUND_ISSUANCE].[F_REFUND_ISSUANCE_PIN_USER_KEY_IX]'
END
GO

--INDEX: F_REFUND_ISSUANCE_REFUND_STATION_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_REFUND_ISSUANCE]','U') AND i.name = 'F_REFUND_ISSUANCE_REFUND_STATION_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_REFUND_ISSUANCE_REFUND_STATION_KEY_IX] ON [dbo].[F_REFUND_ISSUANCE]([REFUND_STATION_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_REFUND_ISSUANCE].[F_REFUND_ISSUANCE_REFUND_STATION_KEY_IX]'
END
GO

--INDEX: F_REFUND_ISSUANCE_MART_SOURCE_ID_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_REFUND_ISSUANCE]','U') AND i.name = 'F_REFUND_ISSUANCE_MART_SOURCE_ID_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_REFUND_ISSUANCE_MART_SOURCE_ID_IX] ON [dbo].[F_REFUND_ISSUANCE]([MART_SOURCE_ID]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_REFUND_ISSUANCE].[F_REFUND_ISSUANCE_MART_SOURCE_ID_IX]'
END
GO

GO


-- END: F_REFUND_ISSUANCE.sql
--------------------------------------------------------------------------------



IF NOT EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_LOCATION') AND name='SHORT_NM')
BEGIN
	ALTER TABLE D_LOCATION ADD SHORT_NM varchar(255) NULL
	exec sys.sp_addextendedproperty 'MS_Description', 'Short Name: short name of the location.', 'schema', 'dbo', 'table', 'D_LOCATION', 'column', 'SHORT_NM'
	PRINT '[INFO] ADD COLUMN [DBO].[D_LOCATION].[SHORT_NM]'
END


IF NOT EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_FINANCIAL_SESSION') AND name='CLOSE_USER_KEY')
BEGIN
	ALTER TABLE D_FINANCIAL_SESSION ADD CLOSE_USER_KEY bigint NULL
	exec sys.sp_addextendedproperty 'MS_Description', 'User Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'D_FINANCIAL_SESSION', 'column', 'CLOSE_USER_KEY'
	PRINT '[INFO] ADD COLUMN [DBO].[D_FINANCIAL_SESSION].[CLOSE_USER_KEY]'
END


IF NOT EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_FINANCIAL_SESSION') AND name='DEPOSIT_USER_KEY')
BEGIN
	ALTER TABLE D_FINANCIAL_SESSION ADD DEPOSIT_USER_KEY bigint NULL
	exec sys.sp_addextendedproperty 'MS_Description', 'User Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'D_FINANCIAL_SESSION', 'column', 'DEPOSIT_USER_KEY'
	PRINT '[INFO] ADD COLUMN [DBO].[D_FINANCIAL_SESSION].[DEPOSIT_USER_KEY]'
END

IF NOT EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_FINANCIAL_SESSION') AND name='LOCATION_KEY')
BEGIN
	ALTER TABLE D_FINANCIAL_SESSION ADD LOCATION_KEY bigint NULL
	exec sys.sp_addextendedproperty 'MS_Description', 'Location Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'D_FINANCIAL_SESSION', 'column', 'LOCATION_KEY'
	PRINT '[INFO] ADD COLUMN [DBO].[D_FINANCIAL_SESSION].[LOCATION_KEY]'
END


--INDEX: D_FINANCIAL_SESSION_CLOSE_USER_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[D_FINANCIAL_SESSION]','U') AND i.name = 'D_FINANCIAL_SESSION_CLOSE_USER_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [D_FINANCIAL_SESSION_CLOSE_USER_KEY_IX] ON [dbo].[D_FINANCIAL_SESSION]([CLOSE_USER_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[D_FINANCIAL_SESSION].[D_FINANCIAL_SESSION_CLOSE_USER_KEY_IX]'
END
GO


--INDEX: D_FINANCIAL_SESSION_DEPOSIT_USER_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[D_FINANCIAL_SESSION]','U') AND i.name = 'D_FINANCIAL_SESSION_DEPOSIT_USER_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [D_FINANCIAL_SESSION_DEPOSIT_USER_KEY_IX] ON [dbo].[D_FINANCIAL_SESSION]([DEPOSIT_USER_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[D_FINANCIAL_SESSION].[D_FINANCIAL_SESSION_DEPOSIT_USER_KEY_IX]'
END
GO

--INDEX: D_FINANCIAL_SESSION_LOCATION_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[D_FINANCIAL_SESSION]','U') AND i.name = 'D_FINANCIAL_SESSION_LOCATION_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [D_FINANCIAL_SESSION_LOCATION_KEY_IX] ON [dbo].[D_FINANCIAL_SESSION]([LOCATION_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[D_FINANCIAL_SESSION].[D_FINANCIAL_SESSION_LOCATION_KEY_IX]'
END
GO


--------------------------------------------------------------------------------
-- START: D_VEHICLE_EQUIPMENT_SET.sql

/*
 * NOTES: Creates D_VEHICLE_EQUIPMENT_SET dimension for AspiraOne datamart 
 *
 * DATE        JIRA      USER             DESCRIPTION
 * ----------  --------  ---------------  ---------------------------------------  
 * 06/27/2019  DMA-4214  Nat Nie          Initialization.
*/

SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL READ COMMITTED

IF OBJECT_ID('DBO.D_VEHICLE_EQUIPMENT_SET') IS NULL
BEGIN
CREATE TABLE DBO.D_VEHICLE_EQUIPMENT_SET(
    VEHICLE_EQUIPMENT_SET_KEY    bigint           IDENTITY(1,1),
    VEHICLE_EQUIPMENT_SET_NM     varchar(255)     NULL,
    VEHICLE_EQUIPMENT_SET_DSC    varchar(255)     NULL,
    BASE_VEHICLE_NB              bigint           NULL,
    TOTAL_VEHICLE_MAX_NB         bigint           NULL,
    CAMPING_VEHICLE_MAX_NB       bigint           NULL,
    APPLIES_TO_NAME              varchar(255)     NULL,
    DISPLAY_NOTE                 varchar(4000)    NULL,
    DELETED_IND                  smallint         NULL,
    MART_SOURCE_ID               bigint           NULL,
    MART_CREATED_DTM             datetime         NULL,
    MART_MODIFIED_DTM            datetime         NULL,
    CONSTRAINT PK_D_VEHICLE_EQUIPMENT_SET PRIMARY KEY CLUSTERED (VEHICLE_EQUIPMENT_SET_KEY)
)ON TX_CAMPING_MART_DATA


exec sys.sp_addextendedproperty 'MS_Description', 'Vehicle Equipment Set Key: surrogate key used to uniquely identify a vehicle equipment set record in the data mart.', 'schema', 'dbo', 'table', 'D_VEHICLE_EQUIPMENT_SET', 'column', 'VEHICLE_EQUIPMENT_SET_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Vehicle Equipment Set Name: name of the vehicle equipment set.', 'schema', 'dbo', 'table', 'D_VEHICLE_EQUIPMENT_SET', 'column', 'VEHICLE_EQUIPMENT_SET_NM'
exec sys.sp_addextendedproperty 'MS_Description', 'Vehicle Equipment Set Description: description of the vehicle equipment set.', 'schema', 'dbo', 'table', 'D_VEHICLE_EQUIPMENT_SET', 'column', 'VEHICLE_EQUIPMENT_SET_DSC'
exec sys.sp_addextendedproperty 'MS_Description', 'Base Vehicle Number: base vehicle number.', 'schema', 'dbo', 'table', 'D_VEHICLE_EQUIPMENT_SET', 'column', 'BASE_VEHICLE_NB'
exec sys.sp_addextendedproperty 'MS_Description', 'Total Vehicle Max Number: total vehicle max number.', 'schema', 'dbo', 'table', 'D_VEHICLE_EQUIPMENT_SET', 'column', 'TOTAL_VEHICLE_MAX_NB'
exec sys.sp_addextendedproperty 'MS_Description', 'Camping Vehicle Max Number: camping vehicle max number.', 'schema', 'dbo', 'table', 'D_VEHICLE_EQUIPMENT_SET', 'column', 'CAMPING_VEHICLE_MAX_NB'
exec sys.sp_addextendedproperty 'MS_Description', 'Applies to Name: applies to name.', 'schema', 'dbo', 'table', 'D_VEHICLE_EQUIPMENT_SET', 'column', 'APPLIES_TO_NAME'
exec sys.sp_addextendedproperty 'MS_Description', 'Display Note: display note.', 'schema', 'dbo', 'table', 'D_VEHICLE_EQUIPMENT_SET', 'column', 'DISPLAY_NOTE'
exec sys.sp_addextendedproperty 'MS_Description', 'Deleted Indicator: 1 if this record has been deleted in the source system, otherwise 0.', 'schema', 'dbo', 'table', 'D_VEHICLE_EQUIPMENT_SET', 'column', 'DELETED_IND'
exec sys.sp_addextendedproperty 'MS_Description', 'Mart Source Identifier: source system identifier for this record.', 'schema', 'dbo', 'table', 'D_VEHICLE_EQUIPMENT_SET', 'column', 'MART_SOURCE_ID'
exec sys.sp_addextendedproperty 'MS_Description', 'Mart Created Datetime: system date and time when this record was created in the mart.', 'schema', 'dbo', 'table', 'D_VEHICLE_EQUIPMENT_SET', 'column', 'MART_CREATED_DTM'
exec sys.sp_addextendedproperty 'MS_Description', 'Mart Modified Datetime: system date and time when this record was last modified in the mart.', 'schema', 'dbo', 'table', 'D_VEHICLE_EQUIPMENT_SET', 'column', 'MART_MODIFIED_DTM'
exec sys.sp_addextendedproperty 'MS_Description', 'Vehicle Equipment Set: vehicle equipment set.', 'schema', 'dbo', 'table', 'D_VEHICLE_EQUIPMENT_SET'

PRINT '[INFO] CREATED TABLE [DBO].[D_VEHICLE_EQUIPMENT_SET]'

END
GO

--INDEX: D_VEHICLE_EQUIPMENT_SET_MART_SOURCE_ID_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[D_VEHICLE_EQUIPMENT_SET]','U') AND i.name = 'D_VEHICLE_EQUIPMENT_SET_MART_SOURCE_ID_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [D_VEHICLE_EQUIPMENT_SET_MART_SOURCE_ID_IX] ON [dbo].[D_VEHICLE_EQUIPMENT_SET]([MART_SOURCE_ID]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[D_VEHICLE_EQUIPMENT_SET].[D_VEHICLE_EQUIPMENT_SET_MART_SOURCE_ID_IX]'
END
GO

GO
-- END: D_VEHICLE_EQUIPMENT_SET.sql
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- START: B_VEHICLE_EQUIPMENT_ITEM.sql

/*
 * NOTES: Creates B_VEHICLE_EQUIPMENT_ITEM bridge for AspiraOne datamart 
 *
 * DATE        JIRA      USER             DESCRIPTION
 * ----------  --------  ---------------  ---------------------------------------  
 * 06/27/2019  DMA-4214  Nat Nie          Initialization.
*/

SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL READ COMMITTED

IF OBJECT_ID('DBO.B_VEHICLE_EQUIPMENT_ITEM') IS NULL
BEGIN
CREATE TABLE DBO.B_VEHICLE_EQUIPMENT_ITEM(
    VEHICLE_EQUIPMENT_ITEM_KEY    bigint          IDENTITY(1,1),
    VEHICLE_EQUIPMENT_SET_KEY     bigint          NULL,
    SELECTION_TYPE_NM             varchar(255)    NULL,
    VEHICLE_TYPE_NM               varchar(255)    NULL,
    COUNT_AS_NM                   varchar(255)    NULL,
	DELETED_IND                   smallint        NULL,
    MART_SOURCE_ID                bigint          NULL,
    MART_CREATED_DTM              datetime        NULL,
    MART_MODIFIED_DTM             datetime        NULL,
    CONSTRAINT PK_B_VEHICLE_EQUIPMENT_ITEM PRIMARY KEY CLUSTERED (VEHICLE_EQUIPMENT_ITEM_KEY)
)ON TX_CAMPING_MART_DATA



exec sys.sp_addextendedproperty 'MS_Description', 'Vehicle Equipment Item Key: surrogate key used to uniquely identify a vehicle equipment item in the data mart.', 'schema', 'dbo', 'table', 'B_VEHICLE_EQUIPMENT_ITEM', 'column', 'VEHICLE_EQUIPMENT_ITEM_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Vehicle Equipment Set Key: surrogate key used to uniquely identify a vehicle equipment set record in the data mart.', 'schema', 'dbo', 'table', 'B_VEHICLE_EQUIPMENT_ITEM', 'column', 'VEHICLE_EQUIPMENT_SET_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Selection Type Name: selection type name.', 'schema', 'dbo', 'table', 'B_VEHICLE_EQUIPMENT_ITEM', 'column', 'SELECTION_TYPE_NM'
exec sys.sp_addextendedproperty 'MS_Description', 'Vechile Type Name: vechile type name.', 'schema', 'dbo', 'table', 'B_VEHICLE_EQUIPMENT_ITEM', 'column', 'VEHICLE_TYPE_NM'
exec sys.sp_addextendedproperty 'MS_Description', 'Count as Name: count as name.', 'schema', 'dbo', 'table', 'B_VEHICLE_EQUIPMENT_ITEM', 'column', 'COUNT_AS_NM'
exec sys.sp_addextendedproperty 'MS_Description', 'Deleted Indicator: 1 if this record has been deleted in the source system, otherwise 0.', 'schema', 'dbo', 'table', 'B_VEHICLE_EQUIPMENT_ITEM', 'column', 'DELETED_IND'
exec sys.sp_addextendedproperty 'MS_Description', 'Mart Source Identifier: source system identifier for this record.', 'schema', 'dbo', 'table', 'B_VEHICLE_EQUIPMENT_ITEM', 'column', 'MART_SOURCE_ID'
exec sys.sp_addextendedproperty 'MS_Description', 'Mart Created Datetime: system date and time when this record was created in the mart.', 'schema', 'dbo', 'table', 'B_VEHICLE_EQUIPMENT_ITEM', 'column', 'MART_CREATED_DTM'
exec sys.sp_addextendedproperty 'MS_Description', 'Mart Modified Datetime: system date and time when this record was last modified in the mart.', 'schema', 'dbo', 'table', 'B_VEHICLE_EQUIPMENT_ITEM', 'column', 'MART_MODIFIED_DTM'
exec sys.sp_addextendedproperty 'MS_Description', 'Vehicle_Equipment_Item: vehicle equipment item', 'schema', 'dbo', 'table', 'B_VEHICLE_EQUIPMENT_ITEM'

PRINT '[INFO] CREATED TABLE [DBO].[B_VEHICLE_EQUIPMENT_ITEM]'

END
GO

--INDEX: B_VEHICLE_EQUIPMENT_ITEM_VEHICLE_EQUIPMENT_SET_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_VEHICLE_EQUIPMENT_ITEM]','U') AND i.name = 'B_VEHICLE_EQUIPMENT_ITEM_VEHICLE_EQUIPMENT_SET_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_VEHICLE_EQUIPMENT_ITEM_VEHICLE_EQUIPMENT_SET_KEY_IX] ON [dbo].[B_VEHICLE_EQUIPMENT_ITEM]([VEHICLE_EQUIPMENT_SET_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_VEHICLE_EQUIPMENT_ITEM].[B_VEHICLE_EQUIPMENT_ITEM_VEHICLE_EQUIPMENT_SET_KEY_IX]'
END
GO

--INDEX: B_VEHICLE_EQUIPMENT_ITEM_MART_SOURCE_ID_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[B_VEHICLE_EQUIPMENT_ITEM]','U') AND i.name = 'B_VEHICLE_EQUIPMENT_ITEM_MART_SOURCE_ID_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [B_VEHICLE_EQUIPMENT_ITEM_MART_SOURCE_ID_IX] ON [dbo].[B_VEHICLE_EQUIPMENT_ITEM]([MART_SOURCE_ID]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[B_VEHICLE_EQUIPMENT_ITEM].[B_VEHICLE_EQUIPMENT_ITEM_MART_SOURCE_ID_IX]'
END
GO

GO

-- END: B_VEHICLE_EQUIPMENT_ITEM.sql
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- START: F_VEHICLE_EQUIPMENT_SET_ASSIGNMENT.sql

/*
 * NOTES: Creates F_VEHICLE_EQUIPMENT_SET_ASSIGNMENT fact for AspiraOne datamart 
 *
 * DATE        JIRA      USER             DESCRIPTION
 * ----------  --------  ---------------  ---------------------------------------  
 * 06/27/2019  DMA-4214  Nat Nie          Initialization.
*/

SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL READ COMMITTED

IF OBJECT_ID('DBO.F_VEHICLE_EQUIPMENT_SET_ASSIGNMENT') IS NULL
BEGIN
CREATE TABLE DBO.F_VEHICLE_EQUIPMENT_SET_ASSIGNMENT(
    VEHICLE_EQUIPMENT_SET_ASSIGNMENT_KEY    bigint          IDENTITY(1,1),
    VEHICLE_EQUIPMENT_SET_KEY               bigint          NULL,
    FACILITY_KEY                            bigint          NULL,
    LOOP_KEY                                bigint          NULL,
    SITE_KEY                                bigint          NULL,
    ASSIGNMENT_TYPE_NM                      varchar(255)    NULL,
    ASSIGNED_IND                            smallint        NULL,
	DELETED_IND                             smallint        NULL,
    MART_SOURCE_ID                          varchar(255)    NULL,
    MART_CREATED_DTM                        datetime        NULL,
    MART_MODIFIED_DTM                       datetime        NULL,
    CONSTRAINT PK_F_VEHICLE_EQUIPMENT_SET_ASSIGNMENT PRIMARY KEY CLUSTERED (VEHICLE_EQUIPMENT_SET_ASSIGNMENT_KEY)
)ON TX_CAMPING_MART_DATA


exec sys.sp_addextendedproperty 'MS_Description', 'Vehicle Equipment Set Assignment Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'F_VEHICLE_EQUIPMENT_SET_ASSIGNMENT', 'column', 'VEHICLE_EQUIPMENT_SET_ASSIGNMENT_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Vehicle Equipment Set Key: surrogate key used to uniquely identify a vehicle equipment set record in the data mart.', 'schema', 'dbo', 'table', 'F_VEHICLE_EQUIPMENT_SET_ASSIGNMENT', 'column', 'VEHICLE_EQUIPMENT_SET_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Location Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'F_VEHICLE_EQUIPMENT_SET_ASSIGNMENT', 'column', 'FACILITY_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Location Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'F_VEHICLE_EQUIPMENT_SET_ASSIGNMENT', 'column', 'LOOP_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Product Key: surrogate key used to uniquely identify a record in the data mart.', 'schema', 'dbo', 'table', 'F_VEHICLE_EQUIPMENT_SET_ASSIGNMENT', 'column', 'SITE_KEY'
exec sys.sp_addextendedproperty 'MS_Description', 'Assignment Type Name: the user defined type of the assignment, possible values are Site / Loop / Facility.', 'schema', 'dbo', 'table', 'F_VEHICLE_EQUIPMENT_SET_ASSIGNMENT', 'column', 'ASSIGNMENT_TYPE_NM'
exec sys.sp_addextendedproperty 'MS_Description', 'Assigned Indicator: indicates if the record is assigned.', 'schema', 'dbo', 'table', 'F_VEHICLE_EQUIPMENT_SET_ASSIGNMENT', 'column', 'ASSIGNED_IND'
exec sys.sp_addextendedproperty 'MS_Description', 'Deleted Indicator: 1 if this record has been deleted in the source system, otherwise 0.', 'schema', 'dbo', 'table', 'F_VEHICLE_EQUIPMENT_SET_ASSIGNMENT', 'column', 'DELETED_IND'
exec sys.sp_addextendedproperty 'MS_Description', 'Mart Source Identifier: source system identifier for this record.', 'schema', 'dbo', 'table', 'F_VEHICLE_EQUIPMENT_SET_ASSIGNMENT', 'column', 'MART_SOURCE_ID'
exec sys.sp_addextendedproperty 'MS_Description', 'Mart Created Datetime: system date and time when this record was created in the mart.', 'schema', 'dbo', 'table', 'F_VEHICLE_EQUIPMENT_SET_ASSIGNMENT', 'column', 'MART_CREATED_DTM'
exec sys.sp_addextendedproperty 'MS_Description', 'Mart Modified Datetime: system date and time when this record was last modified in the mart.', 'schema', 'dbo', 'table', 'F_VEHICLE_EQUIPMENT_SET_ASSIGNMENT', 'column', 'MART_MODIFIED_DTM'
exec sys.sp_addextendedproperty 'MS_Description', 'Vehicle Equipment Set Assignment: one row per assignment, including unassigned records, can be a site / loop / facility assignment. ', 'schema', 'dbo', 'table', 'F_VEHICLE_EQUIPMENT_SET_ASSIGNMENT'


PRINT '[INFO] CREATED TABLE [DBO].[F_VEHICLE_EQUIPMENT_SET_ASSIGNMENT]'

END
GO

--INDEX: F_VEHICLE_EQUIPMENT_SET_ASSIGNMENT_VEHICLE_EQUIPMENT_SET_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_VEHICLE_EQUIPMENT_SET_ASSIGNMENT]','U') AND i.name = 'F_VEHICLE_EQUIPMENT_SET_ASSIGNMENT_VEHICLE_EQUIPMENT_SET_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_VEHICLE_EQUIPMENT_SET_ASSIGNMENT_VEHICLE_EQUIPMENT_SET_KEY_IX] ON [dbo].[F_VEHICLE_EQUIPMENT_SET_ASSIGNMENT]([VEHICLE_EQUIPMENT_SET_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_VEHICLE_EQUIPMENT_SET_ASSIGNMENT].[F_VEHICLE_EQUIPMENT_SET_ASSIGNMENT_VEHICLE_EQUIPMENT_SET_KEY_IX]'
END
GO

--INDEX: F_VEHICLE_EQUIPMENT_SET_ASSIGNMENT_FACILITY_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_VEHICLE_EQUIPMENT_SET_ASSIGNMENT]','U') AND i.name = 'F_VEHICLE_EQUIPMENT_SET_ASSIGNMENT_FACILITY_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_VEHICLE_EQUIPMENT_SET_ASSIGNMENT_FACILITY_KEY_IX] ON [dbo].[F_VEHICLE_EQUIPMENT_SET_ASSIGNMENT]([FACILITY_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_VEHICLE_EQUIPMENT_SET_ASSIGNMENT].[F_VEHICLE_EQUIPMENT_SET_ASSIGNMENT_FACILITY_KEY_IX]'
END
GO

--INDEX: F_VEHICLE_EQUIPMENT_SET_ASSIGNMENT_LOOP_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_VEHICLE_EQUIPMENT_SET_ASSIGNMENT]','U') AND i.name = 'F_VEHICLE_EQUIPMENT_SET_ASSIGNMENT_LOOP_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_VEHICLE_EQUIPMENT_SET_ASSIGNMENT_LOOP_KEY_IX] ON [dbo].[F_VEHICLE_EQUIPMENT_SET_ASSIGNMENT]([LOOP_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_VEHICLE_EQUIPMENT_SET_ASSIGNMENT].[F_VEHICLE_EQUIPMENT_SET_ASSIGNMENT_LOOP_KEY_IX]'
END
GO

--INDEX: F_VEHICLE_EQUIPMENT_SET_ASSIGNMENT_SITE_KEY_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_VEHICLE_EQUIPMENT_SET_ASSIGNMENT]','U') AND i.name = 'F_VEHICLE_EQUIPMENT_SET_ASSIGNMENT_SITE_KEY_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_VEHICLE_EQUIPMENT_SET_ASSIGNMENT_SITE_KEY_IX] ON [dbo].[F_VEHICLE_EQUIPMENT_SET_ASSIGNMENT]([SITE_KEY]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_VEHICLE_EQUIPMENT_SET_ASSIGNMENT].[F_VEHICLE_EQUIPMENT_SET_ASSIGNMENT_SITE_KEY_IX]'
END
GO

--INDEX: F_VEHICLE_EQUIPMENT_SET_ASSIGNMENT_MART_SOURCE_ID_IX
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[F_VEHICLE_EQUIPMENT_SET_ASSIGNMENT]','U') AND i.name = 'F_VEHICLE_EQUIPMENT_SET_ASSIGNMENT_MART_SOURCE_ID_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [F_VEHICLE_EQUIPMENT_SET_ASSIGNMENT_MART_SOURCE_ID_IX] ON [dbo].[F_VEHICLE_EQUIPMENT_SET_ASSIGNMENT]([MART_SOURCE_ID]) ON TX_CAMPING_MART_IDX
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[F_VEHICLE_EQUIPMENT_SET_ASSIGNMENT].[F_VEHICLE_EQUIPMENT_SET_ASSIGNMENT_MART_SOURCE_ID_IX]'
END
GO

GO

-- END: F_VEHICLE_EQUIPMENT_SET_ASSIGNMENT.sql
--------------------------------------------------------------------------------

IF NOT EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_LOCATION') AND name='LOCATION_NM')
BEGIN
	ALTER TABLE D_LOCATION ADD LOCATION_NM varchar(255) NULL
	exec sys.sp_addextendedproperty 'MS_Description', 'Location Name: name of the location.', 'schema', 'dbo', 'table', 'D_LOCATION', 'column', 'LOCATION_NM'
	PRINT '[INFO] ADD COLUMN [DBO].[D_LOCATION].[LOCATION_NM]'
END

IF NOT EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_LOCATION') AND name='LOOP_NM')
BEGIN
	ALTER TABLE D_LOCATION ADD LOOP_NM varchar(255) NULL
	exec sys.sp_addextendedproperty 'MS_Description', 'Loop Name: name if the location is a loop.', 'schema', 'dbo', 'table', 'D_LOCATION', 'column', 'LOOP_NM'
	PRINT '[INFO] ADD COLUMN [DBO].[D_LOCATION].[LOOP_NM]'
END

IF NOT EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_LOCATION') AND name='STATION_NM')
BEGIN
	ALTER TABLE D_LOCATION ADD STATION_NM varchar(255) NULL
	exec sys.sp_addextendedproperty 'MS_Description', 'Station Name: name if the location is a station.', 'schema', 'dbo', 'table', 'D_LOCATION', 'column', 'STATION_NM'
	PRINT '[INFO] ADD COLUMN [DBO].[D_LOCATION].[STATION_NM]'
END

IF NOT EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_LOCATION') AND name='CATEGORY_NM')
BEGIN
	ALTER TABLE D_LOCATION ADD CATEGORY_NM varchar(255) NULL
	exec sys.sp_addextendedproperty 'MS_Description', 'Category Name: name of the location category.', 'schema', 'dbo', 'table', 'D_LOCATION', 'column', 'CATEGORY_NM'
	PRINT '[INFO] ADD COLUMN [DBO].[D_LOCATION].[CATEGORY_NM]'
END

IF NOT EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_LOCATION') AND name='TYPE_NM')
BEGIN
	ALTER TABLE D_LOCATION ADD TYPE_NM varchar(255) NULL
	exec sys.sp_addextendedproperty 'MS_Description', 'Type Name: name of the location type.', 'schema', 'dbo', 'table', 'D_LOCATION', 'column', 'TYPE_NM'
	PRINT '[INFO] ADD COLUMN [DBO].[D_LOCATION].[TYPE_NM]'
END

IF NOT EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_SITE') AND name='LOOP_NM')
BEGIN
	ALTER TABLE D_SITE ADD LOOP_NM varchar(255) NULL
	exec sys.sp_addextendedproperty 'MS_Description', 'Loop Name: name of the loop in which the site is located.', 'schema', 'dbo', 'table', 'D_SITE', 'column', 'LOOP_NM'
	PRINT '[INFO] ADD COLUMN [DBO].[D_SITE].[LOOP_NM]'
END