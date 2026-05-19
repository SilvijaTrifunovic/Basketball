/* ==========================================================
   FAZA 1B: AUDIT LOG TABLICE
   Konvencija log_Action: 'IN' = Insert, 'UP' = Update, 'DE' = Delete
   ========================================================== */

SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRAN;

        /* ====================================================
           log_Igrac
        ==================================================== */
        IF OBJECT_ID(N'dbo.log_Igrac', N'U') IS NULL
        BEGIN
            CREATE TABLE dbo.log_Igrac
            (
                log_IdRow           INT          NOT NULL IDENTITY(1,1),
                log_DateTS          DATETIME2(0) NOT NULL CONSTRAINT DF_log_Igrac_DateTS DEFAULT (SYSUTCDATETIME()),
                log_IdResponsible   INT          NULL,
                log_Action          CHAR(2)       NOT NULL,
                log_ColumnsUpdated  VARCHAR(1500) NULL,
                -- Snapshot podataka
                IgracId             INT          NOT NULL,
                Ime                 NVARCHAR(100) NULL,
                Prezime             NVARCHAR(100) NULL,
                Pozicija            NVARCHAR(50)  NULL,
                TimId               INT           NULL,
                ResponsibleId       INT           NULL,
                IsDeleted           BIT           NULL,
                DeletedAt           DATETIME2(0)  NULL
            );

            ALTER TABLE dbo.log_Igrac
                ADD CONSTRAINT PK_log_Igrac PRIMARY KEY CLUSTERED (log_IdRow);

            CREATE NONCLUSTERED INDEX IX_log_Igrac_IgracId_Action_DateTS
                ON dbo.log_Igrac (IgracId, log_Action, log_DateTS);
        END;

        /* ====================================================
           log_Utakmica
        ==================================================== */
        IF OBJECT_ID(N'dbo.log_Utakmica', N'U') IS NULL
        BEGIN
            CREATE TABLE dbo.log_Utakmica
            (
                log_IdRow           INT          NOT NULL IDENTITY(1,1),
                log_DateTS          DATETIME2(0) NOT NULL CONSTRAINT DF_log_Utakmica_DateTS DEFAULT (SYSUTCDATETIME()),
                log_IdResponsible   INT          NULL,
                log_Action          CHAR(2)       NOT NULL,
                log_ColumnsUpdated  VARCHAR(1500) NULL,
                -- Snapshot podataka
                UtakmicaId          INT          NOT NULL,
                Datum               DATE          NULL,
                VrijemePocetka      TIME(0)       NULL,
                TimDomaci           INT           NULL,
                TimGosti            INT           NULL,
                DvoranaId           INT           NULL,
                ResponsibleId       INT           NULL,
                IsDeleted           BIT           NULL,
                DeletedAt           DATETIME2(0)  NULL
            );

            ALTER TABLE dbo.log_Utakmica
                ADD CONSTRAINT PK_log_Utakmica PRIMARY KEY CLUSTERED (log_IdRow);

            CREATE NONCLUSTERED INDEX IX_log_Utakmica_UtakmicaId_Action_DateTS
                ON dbo.log_Utakmica (UtakmicaId, log_Action, log_DateTS);
        END;

        /* ====================================================
           log_Korisnik
        ==================================================== */
        IF OBJECT_ID(N'dbo.log_Korisnik', N'U') IS NULL
        BEGIN
            CREATE TABLE dbo.log_Korisnik
            (
                log_IdRow           INT          NOT NULL IDENTITY(1,1),
                log_DateTS          DATETIME2(0) NOT NULL CONSTRAINT DF_log_Korisnik_DateTS DEFAULT (SYSUTCDATETIME()),
                log_IdResponsible   INT          NULL,
                log_Action          CHAR(2)       NOT NULL,
                log_ColumnsUpdated  VARCHAR(1500) NULL,
                -- Snapshot podataka
                KorisnikId          INT          NOT NULL,
                Ime                 NVARCHAR(100) NULL,
                Email               NVARCHAR(255) NULL,
                IsActive            BIT           NULL,
                ResponsibleId       INT           NULL,
                IsDeleted           BIT           NULL,
                DeletedAt           DATETIME2(0)  NULL
            );

            ALTER TABLE dbo.log_Korisnik
                ADD CONSTRAINT PK_log_Korisnik PRIMARY KEY CLUSTERED (log_IdRow);

            CREATE NONCLUSTERED INDEX IX_log_Korisnik_KorisnikId_Action_DateTS
                ON dbo.log_Korisnik (KorisnikId, log_Action, log_DateTS);
        END;

        PRINT N'FAZA 1B: audit log tablice provjerene i kreirane po potrebi.';

    COMMIT TRAN;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRAN;

    DECLARE @e_message NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR(@e_message, 16, 1);
END CATCH;
GO
