CREATE TABLE [dbo].[Gnosis_Export_BookingRequestResponse] (
    [ExportBookingKey] INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [RequestSent]      NVARCHAR (MAX) NULL,
    [ResponseRcvd]     NVARCHAR (MAX) NULL,
    [CreatedDate]      DATETIME       NULL,
    CONSTRAINT [PK_Gnosis_ExportBookingRequestResponse] PRIMARY KEY CLUSTERED ([ExportBookingKey] ASC) WITH (FILLFACTOR = 90)
);

