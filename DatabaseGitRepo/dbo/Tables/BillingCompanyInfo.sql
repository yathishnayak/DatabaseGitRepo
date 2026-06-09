CREATE TABLE [dbo].[BillingCompanyInfo] (
    [Companykey]  INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [CompanyName] VARCHAR (500) NULL,
    [CreateDate]  DATETIME      NULL,
    [CreateUser]  INT           NULL,
    [UpdateDate]  DATETIME      NULL,
    [UpdateUser]  INT           NULL,
    [IsActive]    BIT           NULL,
    PRIMARY KEY CLUSTERED ([Companykey] ASC)
);

