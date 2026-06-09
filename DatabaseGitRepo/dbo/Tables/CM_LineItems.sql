CREATE TABLE [dbo].[CM_LineItems] (
    [LineNo]    INT             NOT NULL,
    [LineItem]  VARCHAR (200)   NOT NULL,
    [Cost]      DECIMAL (18, 4) NULL,
    [Type]      VARCHAR (50)    NULL,
    [Occurence] VARCHAR (50)    NULL,
    [Active]    VARCHAR (20)    NULL,
    [Group1]    VARCHAR (50)    NULL,
    [Group2]    VARCHAR (50)    NULL,
    [Notes]     VARCHAR (200)   NULL
);

