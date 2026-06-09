CREATE TABLE [dbo].[CSR] (
    [CsrKey]              INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [CsrName]             VARCHAR (100) NOT NULL,
    [FirstName]           VARCHAR (50)  NULL,
    [LastName]            VARCHAR (50)  NULL,
    [CreateDate]          DATETIME      CONSTRAINT [DF_CSR_CreateDate] DEFAULT (getdate()) NOT NULL,
    [StatusKey]           SMALLINT      CONSTRAINT [DF__CSR__Status__73E5190C] DEFAULT ((1)) NOT NULL,
    [StatusDate]          DATETIME      CONSTRAINT [DF_CSR_StatusDate] DEFAULT (getdate()) NOT NULL,
    [AddrKey]             INT           NULL,
    [LinkedUserKey]       INT           NULL,
    [IsManager]           BIT           NULL,
    [CSRManagerKey]       INT           NULL,
    [TerminalLocationKey] INT           NULL,
    [CreateUser]          INT           NULL,
    [UpdateDate]          DATETIME      NULL,
    [UpdateUser]          INT           NULL,
    [IsActive]            BIT           NULL,
    [IsDelete]            BIT           NULL,
    [IsDefault]           BIT           NULL,
    CONSTRAINT [PK_CSR] PRIMARY KEY CLUSTERED ([CsrKey] ASC),
    CONSTRAINT [FK_CSR_Manager] FOREIGN KEY ([CSRManagerKey]) REFERENCES [dbo].[CSR] ([CsrKey]),
    CONSTRAINT [FK_CSR_Status] FOREIGN KEY ([StatusKey]) REFERENCES [dbo].[Status] ([StatusKey]),
    CONSTRAINT [FK_CSR_TerminalLocation] FOREIGN KEY ([TerminalLocationKey]) REFERENCES [dbo].[TerminalLocations] ([TerminalLocationKey])
);


GO
CREATE TRIGGER CSR_DataChange 
   ON  CSR
   AFTER INSERT,UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
	update CSR set CSRName = isnull(FirstName ,'') + ' ' + ISNULL(LastName,'')
END

GO
DISABLE TRIGGER [dbo].[CSR_DataChange]
    ON [dbo].[CSR];

