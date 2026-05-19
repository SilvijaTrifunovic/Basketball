/* ==========================================================
   FAZA 1: RESET I CREATE
   ========================================================== */

DECLARE @e_message NVARCHAR(4000);

SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRAN;

        /* ====================================================
        1) CREATE TABLICE AKO NEDOSTAJU (parent -> child)
        ==================================================== */
        IF OBJECT_ID(N'dbo.Tim', N'U') IS NULL
        BEGIN
            CREATE TABLE dbo.Tim (
                TimId INT IDENTITY(1,1) PRIMARY KEY,
                Naziv NVARCHAR(100) NOT NULL,
                Grad NVARCHAR(100) NOT NULL,
                ResponsibleId INT NULL,
                IsDeleted BIT NOT NULL CONSTRAINT DF_Tim_IsDeleted DEFAULT (0),
                DeletedAt DATETIME2(0) NULL,
                CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Tim_CreatedAt DEFAULT (SYSUTCDATETIME()),
                UpdatedAt DATETIME2(0) NULL
            );
        END;

        IF OBJECT_ID(N'dbo.Dvorana', N'U') IS NULL
        BEGIN
            CREATE TABLE dbo.Dvorana (
                DvoranaId INT IDENTITY(1,1) PRIMARY KEY,
                Naziv NVARCHAR(100) NOT NULL,
                Lokacija NVARCHAR(100) NOT NULL,
                Kapacitet INT NOT NULL CHECK (Kapacitet > 0),
                ResponsibleId INT NULL,
                IsDeleted BIT NOT NULL CONSTRAINT DF_Dvorana_IsDeleted DEFAULT (0),
                DeletedAt DATETIME2(0) NULL,
                CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Dvorana_CreatedAt DEFAULT (SYSUTCDATETIME()),
                UpdatedAt DATETIME2(0) NULL
            );
        END;

        IF OBJECT_ID(N'dbo.Korisnik', N'U') IS NULL
        BEGIN
            CREATE TABLE dbo.Korisnik (
                KorisnikId INT IDENTITY(1,1) PRIMARY KEY,
                Ime NVARCHAR(100) NOT NULL,
                Email NVARCHAR(255) NOT NULL,
                IsActive BIT NOT NULL CONSTRAINT DF_Korisnik_IsActive DEFAULT (1),
                ResponsibleId INT NULL,
                IsDeleted BIT NOT NULL CONSTRAINT DF_Korisnik_IsDeleted DEFAULT (0),
                DeletedAt DATETIME2(0) NULL,
                CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Korisnik_CreatedAt DEFAULT (SYSUTCDATETIME()),
                UpdatedAt DATETIME2(0) NULL,
                CONSTRAINT UQ_Korisnik_Email UNIQUE (Email)
            );
        END;

        IF OBJECT_ID(N'dbo.Igrac', N'U') IS NULL
        BEGIN
            CREATE TABLE dbo.Igrac (
                IgracId INT IDENTITY(1,1) PRIMARY KEY,
                Ime NVARCHAR(100) NOT NULL,
                Prezime NVARCHAR(100) NOT NULL,
                Pozicija NVARCHAR(50) NOT NULL,
                TimId INT NOT NULL,
                ResponsibleId INT NULL,
                IsDeleted BIT NOT NULL CONSTRAINT DF_Igrac_IsDeleted DEFAULT (0),
                DeletedAt DATETIME2(0) NULL,
                CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Igrac_CreatedAt DEFAULT (SYSUTCDATETIME()),
                UpdatedAt DATETIME2(0) NULL,
                CONSTRAINT FK_Igrac_Tim
                    FOREIGN KEY (TimId) REFERENCES dbo.Tim(TimId)
            );
        END;

        IF OBJECT_ID(N'dbo.Utakmica', N'U') IS NULL
        BEGIN
            CREATE TABLE dbo.Utakmica (
                UtakmicaId INT IDENTITY(1,1) PRIMARY KEY,
                Datum DATE NOT NULL,
                VrijemePocetka TIME(0) NOT NULL,
                TimDomaci INT NOT NULL,
                TimGosti INT NOT NULL,
                DvoranaId INT NOT NULL,
                ResponsibleId INT NULL,
                IsDeleted BIT NOT NULL CONSTRAINT DF_Utakmica_IsDeleted DEFAULT (0),
                DeletedAt DATETIME2(0) NULL,
                CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Utakmica_CreatedAt DEFAULT (SYSUTCDATETIME()),
                UpdatedAt DATETIME2(0) NULL,
                CONSTRAINT FK_Utakmica_TimDomaci
                    FOREIGN KEY (TimDomaci) REFERENCES dbo.Tim(TimId),
                CONSTRAINT FK_Utakmica_TimGosti
                    FOREIGN KEY (TimGosti) REFERENCES dbo.Tim(TimId),
                CONSTRAINT FK_Utakmica_Dvorana
                    FOREIGN KEY (DvoranaId) REFERENCES dbo.Dvorana(DvoranaId),
                CONSTRAINT CK_Utakmica_RazlicitiTimovi CHECK (TimDomaci <> TimGosti)
            );
        END;

        IF OBJECT_ID(N'dbo.Statistika', N'U') IS NULL
        BEGIN
            CREATE TABLE dbo.Statistika (
                StatistikaId BIGINT IDENTITY(1,1) PRIMARY KEY,
                IgracId INT NOT NULL,
                UtakmicaId INT NOT NULL,
                Minuta TINYINT NOT NULL,
                Poeni TINYINT NOT NULL,
                Asistencije TINYINT NOT NULL,
                SkokoviOf TINYINT NOT NULL,
                SkokoviDef TINYINT NOT NULL,
                UkradeneLopte TINYINT NOT NULL,
                Blokade TINYINT NOT NULL,
                IzgubljeneLopte TINYINT NOT NULL,
                OsobnePogreske TINYINT NOT NULL,
                FGM TINYINT NOT NULL,
                FGA TINYINT NOT NULL,
                FG3M TINYINT NOT NULL,
                FG3A TINYINT NOT NULL,
                FTM TINYINT NOT NULL,
                FTA TINYINT NOT NULL,
                ResponsibleId INT NULL,
                CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Statistika_CreatedAt DEFAULT (SYSUTCDATETIME()),
                CONSTRAINT FK_Statistika_Igrac
                    FOREIGN KEY (IgracId) REFERENCES dbo.Igrac(IgracId),
                CONSTRAINT FK_Statistika_Utakmica
                    FOREIGN KEY (UtakmicaId) REFERENCES dbo.Utakmica(UtakmicaId),
                CONSTRAINT UQ_Statistika_IgracUtakmica UNIQUE (IgracId, UtakmicaId),
                CONSTRAINT CK_Stat_Nenegativno CHECK (
                    Minuta BETWEEN 1 AND 60 AND Poeni >= 0 AND Asistencije >= 0 AND SkokoviOf >= 0 AND SkokoviDef >= 0 AND
                    UkradeneLopte >= 0 AND Blokade >= 0 AND IzgubljeneLopte >= 0 AND OsobnePogreske >= 0 AND
                    FGM >= 0 AND FGA >= 0 AND FG3M >= 0 AND FG3A >= 0 AND FTM >= 0 AND FTA >= 0
                ),
                CONSTRAINT CK_Stat_LogikaSuta CHECK (FGM <= FGA AND FG3M <= FG3A AND FTM <= FTA AND FG3A <= FGA)
            );
        END;

        IF OBJECT_ID(N'dbo.KorisnikTim', N'U') IS NULL
        BEGIN
            CREATE TABLE dbo.KorisnikTim (
                KorisnikId INT NOT NULL,
                TimId INT NOT NULL,
                IsDeleted BIT NOT NULL CONSTRAINT DF_KorisnikTim_IsDeleted DEFAULT (0),
                DeletedAt DATETIME2(0) NULL,
                CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_KorisnikTim_CreatedAt DEFAULT (SYSUTCDATETIME()),
                CONSTRAINT PK_KorisnikTim PRIMARY KEY (KorisnikId, TimId),
                CONSTRAINT FK_KorisnikTim_Korisnik
                    FOREIGN KEY (KorisnikId) REFERENCES dbo.Korisnik(KorisnikId),
                CONSTRAINT FK_KorisnikTim_Tim
                    FOREIGN KEY (TimId) REFERENCES dbo.Tim(TimId)
            );
        END;

        IF OBJECT_ID(N'dbo.KorisnikIgrac', N'U') IS NULL
        BEGIN
            CREATE TABLE dbo.KorisnikIgrac (
                KorisnikId INT NOT NULL,
                IgracId INT NOT NULL,
                IsDeleted BIT NOT NULL CONSTRAINT DF_KorisnikIgrac_IsDeleted DEFAULT (0),
                DeletedAt DATETIME2(0) NULL,
                CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_KorisnikIgrac_CreatedAt DEFAULT (SYSUTCDATETIME()),
                CONSTRAINT PK_KorisnikIgrac PRIMARY KEY (KorisnikId, IgracId),
                CONSTRAINT FK_KorisnikIgrac_Korisnik
                    FOREIGN KEY (KorisnikId) REFERENCES dbo.Korisnik(KorisnikId),
                CONSTRAINT FK_KorisnikIgrac_Igrac
                    FOREIGN KEY (IgracId) REFERENCES dbo.Igrac(IgracId)
            );
        END;

        PRINT N'FAZA 1A: provjera i kreiranje tablica po potrebi uspjesno izvrseno.';

        /* =========================
        2) DATA CLEANUP + RESEED (child -> parent)
        ========================= */
        IF OBJECT_ID(N'dbo.KorisnikIgrac', N'U') IS NOT NULL
            DELETE FROM dbo.KorisnikIgrac;

        IF OBJECT_ID(N'dbo.KorisnikTim', N'U') IS NOT NULL
            DELETE FROM dbo.KorisnikTim;

        IF OBJECT_ID(N'dbo.Statistika', N'U') IS NOT NULL
        BEGIN
            DELETE FROM dbo.Statistika;
            DBCC CHECKIDENT ('dbo.Statistika', RESEED, 0) WITH NO_INFOMSGS;
        END;

        IF OBJECT_ID(N'dbo.Utakmica', N'U') IS NOT NULL
        BEGIN
            DELETE FROM dbo.Utakmica;
            DBCC CHECKIDENT ('dbo.Utakmica', RESEED, 0) WITH NO_INFOMSGS;
        END;

        IF OBJECT_ID(N'dbo.Igrac', N'U') IS NOT NULL
        BEGIN
            DELETE FROM dbo.Igrac;
            DBCC CHECKIDENT ('dbo.Igrac', RESEED, 0) WITH NO_INFOMSGS;
        END;

        IF OBJECT_ID(N'dbo.Korisnik', N'U') IS NOT NULL
        BEGIN
            DELETE FROM dbo.Korisnik;
            DBCC CHECKIDENT ('dbo.Korisnik', RESEED, 0) WITH NO_INFOMSGS;
        END;

        IF OBJECT_ID(N'dbo.Dvorana', N'U') IS NOT NULL
        BEGIN
            DELETE FROM dbo.Dvorana;
            DBCC CHECKIDENT ('dbo.Dvorana', RESEED, 0) WITH NO_INFOMSGS;
        END;

        IF OBJECT_ID(N'dbo.Tim', N'U') IS NOT NULL
        BEGIN
            DELETE FROM dbo.Tim;
            DBCC CHECKIDENT ('dbo.Tim', RESEED, 0) WITH NO_INFOMSGS;
        END;

        PRINT N'FAZA 1A: podaci obrisani i identity resetiran na 0.';

        /* =================================================
        3) INDEKSI ZA SKALIRANJE (create only if missing)
        ================================================= */

        /* ----- TIM ----- */
        IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Tim_Naziv_Grad' AND object_id = OBJECT_ID(N'dbo.Tim'))
            CREATE INDEX IX_Tim_Naziv_Grad ON dbo.Tim (Naziv, Grad);

        IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Tim_Active' AND object_id = OBJECT_ID(N'dbo.Tim'))
            CREATE INDEX IX_Tim_Active ON dbo.Tim (Naziv) INCLUDE (Grad) WHERE IsDeleted = 0;

        /* ----- DVORANA ----- */
        IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Dvorana_Active' AND object_id = OBJECT_ID(N'dbo.Dvorana'))
            CREATE INDEX IX_Dvorana_Active ON dbo.Dvorana (Lokacija) INCLUDE (Naziv, Kapacitet) WHERE IsDeleted = 0;

        /* ----- KORISNIK ----- */
        IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Korisnik_CreatedAt' AND object_id = OBJECT_ID(N'dbo.Korisnik'))
            CREATE INDEX IX_Korisnik_CreatedAt ON dbo.Korisnik (CreatedAt);

        IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Korisnik_IsActive' AND object_id = OBJECT_ID(N'dbo.Korisnik'))
            CREATE INDEX IX_Korisnik_IsActive ON dbo.Korisnik (IsActive) INCLUDE (Ime, Email) WHERE IsDeleted = 0;

        IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Korisnik_Ime' AND object_id = OBJECT_ID(N'dbo.Korisnik'))
            CREATE INDEX IX_Korisnik_Ime ON dbo.Korisnik (Ime) INCLUDE (Email, IsActive) WHERE IsDeleted = 0;

        /* ----- IGRAC ----- */
        IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Igrac_TimId' AND object_id = OBJECT_ID(N'dbo.Igrac'))
            CREATE INDEX IX_Igrac_TimId ON dbo.Igrac (TimId);

        IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Igrac_TimId_Prezime_Ime' AND object_id = OBJECT_ID(N'dbo.Igrac'))
            CREATE INDEX IX_Igrac_TimId_Prezime_Ime ON dbo.Igrac (TimId, Prezime, Ime);

        IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Igrac_Prezime_Ime' AND object_id = OBJECT_ID(N'dbo.Igrac'))
            CREATE INDEX IX_Igrac_Prezime_Ime ON dbo.Igrac (Prezime, Ime) WHERE IsDeleted = 0;

        IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Igrac_Pozicija' AND object_id = OBJECT_ID(N'dbo.Igrac'))
            CREATE INDEX IX_Igrac_Pozicija ON dbo.Igrac (Pozicija) INCLUDE (Ime, Prezime, TimId) WHERE IsDeleted = 0;

        /* ----- UTAKMICA ----- */
        IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Utakmica_Datum' AND object_id = OBJECT_ID(N'dbo.Utakmica'))
            CREATE INDEX IX_Utakmica_Datum ON dbo.Utakmica (Datum);

        IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Utakmica_TimDomaci_Datum' AND object_id = OBJECT_ID(N'dbo.Utakmica'))
            CREATE INDEX IX_Utakmica_TimDomaci_Datum ON dbo.Utakmica (TimDomaci, Datum);

        IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Utakmica_TimGosti_Datum' AND object_id = OBJECT_ID(N'dbo.Utakmica'))
            CREATE INDEX IX_Utakmica_TimGosti_Datum ON dbo.Utakmica (TimGosti, Datum);

        IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Utakmica_DvoranaId_Datum' AND object_id = OBJECT_ID(N'dbo.Utakmica'))
            CREATE INDEX IX_Utakmica_DvoranaId_Datum ON dbo.Utakmica (DvoranaId, Datum);

        IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Utakmica_Datum_Active' AND object_id = OBJECT_ID(N'dbo.Utakmica'))
            CREATE INDEX IX_Utakmica_Datum_Active ON dbo.Utakmica (Datum, VrijemePocetka) INCLUDE (TimDomaci, TimGosti, DvoranaId) WHERE IsDeleted = 0;

        /* ----- STATISTIKA ----- */
        IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Statistika_UtakmicaId' AND object_id = OBJECT_ID(N'dbo.Statistika'))
            CREATE INDEX IX_Statistika_UtakmicaId ON dbo.Statistika (UtakmicaId);

        IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Statistika_IgracId' AND object_id = OBJECT_ID(N'dbo.Statistika'))
            CREATE INDEX IX_Statistika_IgracId ON dbo.Statistika (IgracId);

        IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Statistika_UtakmicaId_Poeni' AND object_id = OBJECT_ID(N'dbo.Statistika'))
            CREATE INDEX IX_Statistika_UtakmicaId_Poeni ON dbo.Statistika (UtakmicaId, Poeni DESC);

        IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Statistika_Poeni_DESC' AND object_id = OBJECT_ID(N'dbo.Statistika'))
            CREATE INDEX IX_Statistika_Poeni_DESC ON dbo.Statistika (Poeni DESC) INCLUDE (IgracId, UtakmicaId, Asistencije, SkokoviOf, SkokoviDef);

        IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Statistika_IgracId_Cover' AND object_id = OBJECT_ID(N'dbo.Statistika'))
            CREATE INDEX IX_Statistika_IgracId_Cover ON dbo.Statistika (IgracId) INCLUDE (Poeni, Asistencije, SkokoviOf, SkokoviDef, UkradeneLopte, Blokade, Minuta);

        IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Statistika_UtakmicaId_Cover' AND object_id = OBJECT_ID(N'dbo.Statistika'))
            CREATE INDEX IX_Statistika_UtakmicaId_Cover ON dbo.Statistika (UtakmicaId) INCLUDE (IgracId, Poeni, Asistencije, SkokoviOf, SkokoviDef, UkradeneLopte, Blokade, Minuta);

        /* ----- KORISNIK-TIM ----- */
        IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_KorisnikTim_TimId' AND object_id = OBJECT_ID(N'dbo.KorisnikTim'))
            CREATE INDEX IX_KorisnikTim_TimId ON dbo.KorisnikTim (TimId);

        IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_KorisnikTim_Active' AND object_id = OBJECT_ID(N'dbo.KorisnikTim'))
            CREATE INDEX IX_KorisnikTim_Active ON dbo.KorisnikTim (KorisnikId) WHERE IsDeleted = 0;

        /* ----- KORISNIK-IGRAC ----- */
        IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_KorisnikIgrac_IgracId' AND object_id = OBJECT_ID(N'dbo.KorisnikIgrac'))
            CREATE INDEX IX_KorisnikIgrac_IgracId ON dbo.KorisnikIgrac (IgracId);

        IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_KorisnikIgrac_Active' AND object_id = OBJECT_ID(N'dbo.KorisnikIgrac'))
            CREATE INDEX IX_KorisnikIgrac_Active ON dbo.KorisnikIgrac (KorisnikId) WHERE IsDeleted = 0;

        PRINT N'FAZA 1A: indeksi provjereni i kreirani po potrebi.';

    COMMIT TRAN;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRAN;

    SELECT @e_message=ERROR_MESSAGE()
    RAISERROR(@e_message, 16, 1);
END CATCH;
