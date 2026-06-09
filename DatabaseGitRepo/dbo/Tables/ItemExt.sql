CREATE TABLE [dbo].[ItemExt] (
    [ItemKey]      INT           NOT NULL,
    [ERPItemId]    VARCHAR (50)  NULL,
    [ERPGLAccount] VARCHAR (255) NULL,
    CONSTRAINT [PK_ItemExt] PRIMARY KEY CLUSTERED ([ItemKey] ASC) WITH (FILLFACTOR = 90)
);

