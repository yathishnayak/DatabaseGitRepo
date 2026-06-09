CREATE TABLE [dbo].[ContainerTypes] (
    [ContainerTypeKey] SMALLINT      NOT NULL,
    [TypeID]           VARCHAR (50)  NOT NULL,
    [TypeDescription]  VARCHAR (500) NULL,
    [LinkedItemKey]    INT           NULL,
    [isActive]         BIT           NULL,
    [CreatedDate]      DATETIME      NULL,
    [UpdatedDate]      DATETIME      NULL,
    [ContainerTypes]   INT           NULL,
    [ItemKey]          INT           NULL,
    [ShortCode]        VARCHAR (50)  NULL,
    [OrderBy]          INT           NULL,
    [ColorCode]        VARCHAR (100) NULL,
    [IsStops]          BIT           NULL,
    [IsOnlyLegs]       BIT           NULL,
    [IsOnlyStops]      BIT           NULL,
    PRIMARY KEY CLUSTERED ([ContainerTypeKey] ASC)
);

