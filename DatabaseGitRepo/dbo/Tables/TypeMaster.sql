CREATE TABLE [dbo].[TypeMaster] (
    [TypeKey]    SMALLINT     NOT NULL,
    [TypeName]   VARCHAR (50) NULL,
    [IsActive]   BIT          NULL,
    [CreateDate] DATETIME     NULL,
    [UpdateDate] DATETIME     NULL,
    CONSTRAINT [PK_TypeMaster] PRIMARY KEY CLUSTERED ([TypeKey] ASC)
);

