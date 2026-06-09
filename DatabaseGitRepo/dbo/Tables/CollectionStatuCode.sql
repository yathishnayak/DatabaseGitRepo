CREATE TABLE [dbo].[CollectionStatuCode] (
    [StatusCodeKey]  INT          IDENTITY (1, 1) NOT NULL,
    [StatusCodeName] VARCHAR (30) NULL,
    [IsActive]       BIT          NULL,
    [IsDelete]       BIT          NULL,
    [CreatedDate]    DATETIME     NULL,
    [CreatedUser]    INT          NULL
);

