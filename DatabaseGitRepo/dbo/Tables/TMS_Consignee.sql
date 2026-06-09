CREATE TABLE [dbo].[TMS_Consignee] (
    [ConsigneeKey]  INT           NOT NULL,
    [ConsigneeID]   VARCHAR (50)  NULL,
    [Name]          VARCHAR (500) NULL,
    [AddrKey]       INT           NULL,
    [CustKey]       INT           NULL,
    [StatusKey]     SMALLINT      NULL,
    [CreateUserKey] INT           NULL,
    [CreateDate]    DATETIME      NULL,
    [CompanyKey]    SMALLINT      NULL,
    [UpdateUserKey] INT           NULL,
    [UpdateDate]    DATETIME      NULL
);

