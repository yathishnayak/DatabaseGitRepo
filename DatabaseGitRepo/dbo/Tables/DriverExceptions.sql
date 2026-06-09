CREATE TABLE [dbo].[DriverExceptions] (
    [DriverExceptionKey] INT           IDENTITY (1, 1) NOT NULL,
    [DriverException]    VARCHAR (200) NULL,
    [ExceptionType]      VARCHAR (20)  NULL,
    [OrderBy]            INT           NULL,
    [AllowEntry]         BIT           NULL,
    [IsActive]           BIT           NULL,
    [IsDeleted]          BIT           NULL,
    [CreatedDate]        DATETIME      NULL,
    CONSTRAINT [PK_DriverExceptionDetails] PRIMARY KEY CLUSTERED ([DriverExceptionKey] ASC)
);

