CREATE TABLE [dbo].[Gnosis_Export_BookingSCACPatch] (
    [ExportBookingKey] INT           NULL,
    [BookingNo]        VARCHAR (50)  NULL,
    [SCACCode]         VARCHAR (20)  NULL,
    [SteamShipLinekey] INT           NULL,
    [IsUpdated]        BIT           NULL,
    [Response]         VARCHAR (MAX) NULL,
    [CreatedDate]      DATETIME      NULL,
    [UpdatedDate]      DATETIME      NULL
);

