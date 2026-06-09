CREATE TABLE [dbo].[VoucherHeader] (
    [VoucherKey]        INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [VoucherNo]         VARCHAR (50)    NOT NULL,
    [VoucherDate]       DATETIME        NOT NULL,
    [BillToAddrKey]     INT             NOT NULL,
    [VoucherAmount]     DECIMAL (18, 2) CONSTRAINT [DF_VoucherHeader_VoucherAmount] DEFAULT ((0)) NOT NULL,
    [DueDate]           DATE            NULL,
    [IsPaymentApproved] BIT             CONSTRAINT [DF_VoucherHeader_IsPaymentApproved] DEFAULT ((0)) NOT NULL,
    [IsPaid]            BIT             CONSTRAINT [DF_VoucherHeader_IsPaid] DEFAULT ((0)) NOT NULL,
    [CompanyKey]        SMALLINT        CONSTRAINT [DF_VoucherHeader_CompanyKey] DEFAULT ((1)) NOT NULL,
    [StatusKey]         SMALLINT        NOT NULL,
    [CreateDate]        DATETIME        CONSTRAINT [DF_VoucherHeader_CreateDate] DEFAULT (getdate()) NOT NULL,
    [CreateUserKey]     INT             NOT NULL,
    [UpdateuserKey]     INT             NULL,
    [UpdateDate]        DATETIME        NULL,
    [PmtApprovedUser]   INT             NULL,
    [DriverNote]        VARCHAR (3000)  NULL,
    [InternalNote]      VARCHAR (3000)  NULL,
    [PaidUserKey]       INT             NULL,
    [PaidDate]          DATETIME        NULL,
    [IsRevised]         BIT             NULL,
    [RevisionUserKey]   INT             NULL,
    [RevisionDate]      DATETIME        NULL,
    [NPAmount]          DECIMAL (18, 2) NULL,
    CONSTRAINT [VoucherHeader_pkey] PRIMARY KEY CLUSTERED ([VoucherKey] ASC),
    CONSTRAINT [FK_VoucherHeader_BilToAddrKey] FOREIGN KEY ([BillToAddrKey]) REFERENCES [dbo].[Address] ([AddrKey]),
    CONSTRAINT [FK_VoucherHeader_CompanyKey] FOREIGN KEY ([CompanyKey]) REFERENCES [dbo].[Company] ([CompanyKey]),
    CONSTRAINT [FK_VoucherHeader_VoucherStatus] FOREIGN KEY ([StatusKey]) REFERENCES [dbo].[VoucherStatus] ([StatusKey])
);


GO
CREATE NONCLUSTERED INDEX [IX_VoucherHeader_StatusKey]
    ON [dbo].[VoucherHeader]([StatusKey] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_VoucherHeader_VoucherDate_Covering]
    ON [dbo].[VoucherHeader]([VoucherDate] ASC)
    INCLUDE([VoucherNo], [IsPaymentApproved], [StatusKey], [IsPaid], [PaidDate], [PaidUserKey]);


GO

CREATE TRIGGER [dbo].[VoucherHeader_AfterInsert]
ON [dbo].[VoucherHeader]
AFTER INSERT
AS
BEGIN
		INSERT INTO [dbo].[VoucherHeaderDMLTracker]
			(
				VoucherKey,VoucherNo,VoucherDate,BillToAddrKey,VoucherAmount,DueDate,IsPaymentApproved,IsPaid,CompanyKey,StatusKey,CreateDate,CreateUserKey,
				UpdateuserKey,UpdateDate,PmtApprovedUser,DriverNote,InternalNote,PaidUserKey,PaidDate,IsRevised,RevisionUserKey,RevisionDate,[Action],ActionDate)
			SELECT	VoucherKey,VoucherNo,VoucherDate,BillToAddrKey,VoucherAmount,DueDate,IsPaymentApproved,IsPaid,CompanyKey,StatusKey,CreateDate,CreateUserKey,
				UpdateuserKey,UpdateDate,PmtApprovedUser,DriverNote,InternalNote,PaidUserKey,PaidDate,IsRevised,RevisionUserKey,RevisionDate,'INSERT',GETDATE()
			FROM INSERTED
END
GO
DISABLE TRIGGER [dbo].[VoucherHeader_AfterInsert]
    ON [dbo].[VoucherHeader];


GO
CREATE TRIGGER [dbo].[VoucherHeader_AfterUpdate]
ON [dbo].[VoucherHeader]
AFTER UPDATE
AS
BEGIN
	IF @@ROWCOUNT>0 		
	BEGIN
		INSERT INTO [dbo].[VoucherHeaderDMLTracker]
			(
				VoucherKey,VoucherNo,VoucherDate,BillToAddrKey,VoucherAmount,DueDate,IsPaymentApproved,IsPaid,CompanyKey,StatusKey,CreateDate,CreateUserKey,
				UpdateuserKey,UpdateDate,PmtApprovedUser,DriverNote,InternalNote,PaidUserKey,PaidDate,IsRevised,RevisionUserKey,RevisionDate,[Action],ActionDate)
			SELECT	VoucherKey,VoucherNo,VoucherDate,BillToAddrKey,VoucherAmount,DueDate,IsPaymentApproved,IsPaid,CompanyKey,StatusKey,CreateDate,CreateUserKey,
				UpdateuserKey,UpdateDate,PmtApprovedUser,DriverNote,InternalNote,PaidUserKey,PaidDate,IsRevised,RevisionUserKey,RevisionDate,'UPDATE',GETDATE()
			FROM INSERTED
	END
END
GO
DISABLE TRIGGER [dbo].[VoucherHeader_AfterUpdate]
    ON [dbo].[VoucherHeader];

