CREATE TABLE [dbo].[CustomerSegments] (
    [CustomerSegmentKey] INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [CustomerSegment]    VARCHAR (200)   NULL,
    [BasePercent]        NUMERIC (18, 2) NULL,
    [IsNacCustomer]      BIT             NULL,
    [MarketKey]          INT             NULL,
    [FSFPercent]         NUMERIC (18, 2) NULL,
    [EffectiveDate]      DATETIME        NULL,
    [EffectiveFrom]      VARCHAR (100)   NULL,
    [CreateDate]         DATETIME        NULL,
    [CreatedUser]        INT             NULL,
    [UpdateDate]         DATETIME        NULL,
    [UpdateUser]         INT             NULL,
    [IsActive]           BIT             NULL,
    [IsDeleted]          BIT             NULL,
    CONSTRAINT [PK_CustomerSegments] PRIMARY KEY CLUSTERED ([CustomerSegmentKey] ASC)
);

