CREATE TABLE [dbo].[MailConfig] (
    [ID]           INT           NOT NULL,
    [Description]  VARCHAR (200) NOT NULL,
    [Value]        VARCHAR (200) NOT NULL,
    [IsEditInApp]  BIT           NULL,
    [EditAppGroup] VARCHAR (50)  NULL,
    [DataType]     VARCHAR (50)  NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

