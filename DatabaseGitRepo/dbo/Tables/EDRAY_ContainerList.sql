CREATE TABLE [dbo].[EDRAY_ContainerList] (
    [ContainerKey]       INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [DataKey]            INT           NOT NULL,
    [equipmentNumber]    VARCHAR (50)  NULL,
    [equipmentTypeCode]  VARCHAR (50)  NULL,
    [pieceCount]         VARCHAR (20)  NULL,
    [grossWeight]        VARCHAR (20)  NULL,
    [weightUOM]          VARCHAR (20)  NULL,
    [volume]             VARCHAR (20)  NULL,
    [volumeUOM]          VARCHAR (20)  NULL,
    [freightDescription] VARCHAR (100) NULL,
    [isHazmat]           VARCHAR (20)  NULL,
    [sealNumberList]     VARCHAR (200) NULL,
    PRIMARY KEY CLUSTERED ([ContainerKey] ASC)
);

