CREATE TABLE [dbo].[CustomerItemRate] (
    [BaseRateKey]       INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [ClientOrBrokerKey] INT             NULL,
    [IsClient]          BIT             NULL,
    [IsBroker]          BIT             NULL,
    [CustomerKey]       INT             NULL,
    [CityKey]           INT             NULL,
    [UnitPrice]         DECIMAL (18, 2) NULL,
    [EmailContact]      VARCHAR (50)    NULL,
    [CreateDate]        DATETIME        NULL,
    [CreateUserKey]     INT             NULL,
    [LastUpdateDate]    DATETIME        NULL,
    [LastUpdateUserKey] INT             NULL,
    [EffectiveDate]     DATE            NULL,
    [Itemkey]           INT             NULL,
    [CompanyKey]        SMALLINT        NULL,
    CONSTRAINT [PK__BaseRate__AC7F444B78497D67] PRIMARY KEY CLUSTERED ([BaseRateKey] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_BaseRate_Customer] FOREIGN KEY ([CustomerKey]) REFERENCES [dbo].[Customer] ([CustKey]),
    CONSTRAINT [FK_BaseRate_LocationData] FOREIGN KEY ([CityKey]) REFERENCES [dbo].[LocationData] ([CityKey]),
    CONSTRAINT [FK_CustomerItemRate_Broker] FOREIGN KEY ([ClientOrBrokerKey]) REFERENCES [dbo].[Broker] ([BrokerKey])
);


GO
CREATE NONCLUSTERED INDEX [IX_CustomerItemRate_CustomerKey_Itemkey_EffectiveDate]
    ON [dbo].[CustomerItemRate]([CustomerKey] ASC, [Itemkey] ASC, [EffectiveDate] ASC)
    INCLUDE([CityKey]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_CustomerItemRate_Itemkey_EffectiveDate]
    ON [dbo].[CustomerItemRate]([Itemkey] ASC, [EffectiveDate] ASC)
    INCLUDE([CityKey], [UnitPrice]) WITH (FILLFACTOR = 90);


GO
CREATE TRIGGER [dbo].[TR_BaseRate_AfterUpdate]
ON [dbo].[CustomerItemRate] AFTER UPDATE
AS
BEGIN
	IF @@ROWCOUNT>0 AND 
		(	
			UPDATE(UnitPrice)
		)
	BEGIN
		DECLARE @User VARCHAR(50)
		SET @User=( SELECT SYSTEM_USER )

			INSERT INTO [dbo].[AuditLog]
           ( [CompanyKey],[FieldName],[IDValue],[NewValue],[OldValue],[Operation]
			,[ProgramName],[SysDate],[TableName],[UserID],[NewKey],[OldKey]  )
			SELECT	A.CompanyKey, 'UnitPrice',A.BaseRateKey,A.UnitPrice,
					B.UnitPrice,'Update',NULL,GETDATE(),'CustomerItemRate',@User,
					A.BaseRateKey,B.BaseRateKey
			FROM INSERTED A 
				INNER JOIN DELETED B ON A.BaseRateKey=B.BaseRateKey			
			WHERE ISNULL(A.UnitPrice,0)<>ISNULL(B.UnitPrice,0)		
	END
END
