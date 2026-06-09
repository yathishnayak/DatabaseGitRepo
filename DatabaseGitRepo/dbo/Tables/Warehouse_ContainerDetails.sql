CREATE TABLE [dbo].[Warehouse_ContainerDetails] (
    [OrderDetailKey]     INT            NOT NULL,
    [ContainerMode]      VARCHAR (2)    NULL,
    [PalletCount]        INT            NULL,
    [ContainerSize]      INT            NULL,
    [InDate]             DATETIME       NULL,
    [OutDate]            DATETIME       NULL,
    [IsNoOutDate]        BIT            CONSTRAINT [DF__Warehouse__IsNoO__7C5041DB] DEFAULT ((0)) NULL,
    [TodaysDate]         DATETIME       NULL,
    [StorageDays]        INT            NULL,
    [IsStoring]          BIT            CONSTRAINT [DF__Warehouse__IsSto__7D446614] DEFAULT ((0)) NULL,
    [StatusKey]          INT            NOT NULL,
    [CreateUserKey]      INT            NULL,
    [CreateDate]         DATETIME       NULL,
    [UpdateUserKey]      INT            NULL,
    [UpdateDate]         DATETIME       NULL,
    [PalletRestriction]  NVARCHAR (200) NULL,
    [WHLocation]         NVARCHAR (200) NULL,
    [DOWorkScope]        NVARCHAR (200) NULL,
    [SpecialInstruction] NVARCHAR (200) NULL,
    [Priority]           INT            NULL,
    [Sorting]            INT            NULL,
    CONSTRAINT [PK__Warehous__A8FDFD6AB087B605] PRIMARY KEY CLUSTERED ([OrderDetailKey] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'F = Floor, P = Palletised', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Warehouse_ContainerDetails', @level2type = N'COLUMN', @level2name = N'ContainerMode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'40 Vs 20 (From ContainerSize Table)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Warehouse_ContainerDetails', @level2type = N'COLUMN', @level2name = N'ContainerSize';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'If 0, then OutGate should be sent as N/A', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Warehouse_ContainerDetails', @level2type = N'COLUMN', @level2name = N'IsNoOutDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Y/N (if Yes, Keep open in the Que, but allow invoice to be created)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Warehouse_ContainerDetails', @level2type = N'COLUMN', @level2name = N'IsStoring';

