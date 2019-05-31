USE NJMigraQA;
GO

SELECT TOP 100 LA.* 
FROM dbo.[Transaction] AS T WITH(NOLOCK) 
INNER JOIN dbo.TransactionHeader AS TH WITH(NOLOCK) 
    ON T.TransactionID = TH.TransactionID
INNER JOIN dbo.TransactionDetail TD WITH(NOLOCK) 
    ON TD.TransactionHeaderID = TH.TransactionHeaderID
INNER JOIN dbo.TransactionType TT WITH(NOLOCK) 
    ON TD.TransactionTypeID = TT.TransactionTypeID
INNER JOIN dbo.LicenseAction LA WITH(NOLOCK) ON LA.TransactionDetailID = TD.TransactionDetailID
	WHERE TD.TransactionTypeID = 5


SELECT TOP 100 
	* 
FROM F_TRANSACTION_DETAIL FTD WITH(NOLOCK)