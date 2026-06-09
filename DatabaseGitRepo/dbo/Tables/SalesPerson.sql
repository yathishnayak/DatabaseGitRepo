CREATE TABLE [dbo].[SalesPerson] (
    [SalesPersonKey]  INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [SalesPersonID]   VARCHAR (10)  NOT NULL,
    [SalesPersonName] VARCHAR (100) NOT NULL,
    [FirstName]       VARCHAR (50)  NULL,
    [LastName]        VARCHAR (50)  NULL,
    [AddrKey]         INT           NOT NULL,
    [LinkedUserKey]   INT           NULL,
    [IsActive]        BIT           CONSTRAINT [DF__SalesPers__IsAct__13FCE2E3] DEFAULT ((0)) NULL,
    [CreateDate]      DATETIME      NULL,
    [CreateUser]      INT           NULL,
    [UpdateDate]      DATETIME      NULL,
    [UpdateUser]      INT           NULL,
    CONSTRAINT [PK__SalesPer__4219E626B278F0E8] PRIMARY KEY CLUSTERED ([SalesPersonKey] ASC)
);


GO

CREATE TRIGGER SalesPerson_DataChange 
   ON  SalesPerson
   AFTER INSERT,UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
	update SalesPerson set SalesPersonName = isnull(FirstName ,'') + ' ' + ISNULL(LastName,'')
END
