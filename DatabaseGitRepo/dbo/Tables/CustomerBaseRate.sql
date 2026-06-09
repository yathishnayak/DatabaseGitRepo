CREATE TABLE [dbo].[CustomerBaseRate] (
    [Custkey]       INT             NOT NULL,
    [BaseRate]      DECIMAL (18, 2) NOT NULL,
    [EffectiveDate] DATETIME        NOT NULL,
    [IsActive]      BIT             CONSTRAINT [DF_CustomerBaseRate_IsActive] DEFAULT ((0)) NOT NULL,
    [CreateDate]    DATETIME        CONSTRAINT [DF_CustomerBaseRate_CreateDate] DEFAULT (getdate()) NOT NULL,
    [CreateUserkey] INT             NOT NULL
);

