CREATE TABLE [dbo].[DW_ImportTableList] (
    [ID]        INT          IDENTITY (1, 1) NOT NULL,
    [TableName] VARCHAR (50) NOT NULL,
    [IsActive]  BIT          CONSTRAINT [DF_DW_ImportTableList_IsActive] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_DW_ImportTableList] PRIMARY KEY CLUSTERED ([ID] ASC)
);

