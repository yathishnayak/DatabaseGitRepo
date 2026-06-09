CREATE TABLE [dbo].[TMS_CustomerBaseRate] (
    [Custkey]       INT             NOT NULL,
    [BaseRate]      DECIMAL (18, 2) NOT NULL,
    [EffectiveDate] DATETIME        NOT NULL,
    [IsActive]      BIT             NOT NULL,
    [CreateDate]    DATETIME        NOT NULL,
    [CreateUserkey] INT             NOT NULL
);

