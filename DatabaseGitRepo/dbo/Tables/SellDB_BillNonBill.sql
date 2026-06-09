CREATE TABLE [dbo].[SellDB_BillNonBill] (
    [BillNonBillKey]    INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [BillNaonBillValue] VARCHAR (100) NULL,
    [IsActive]          BIT           NULL,
    [IsDeleted]         BIT           NULL,
    [CreatedBy]         INT           NULL,
    [CreateDate]        DATETIME      NULL,
    [UpdatedBy]         INT           NULL,
    [UpdateDate]        DATETIME      NULL,
    CONSTRAINT [PK_SellDB_BillNonBill] PRIMARY KEY CLUSTERED ([BillNonBillKey] ASC)
);

