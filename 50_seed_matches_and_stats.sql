
/* ==========================================================
    FAZA 5: TRANSAKCIJE I OPTERECENJE 
      - Raspored utakmica: 60-80 mjesečno
        - 75% mjeseci unatrag (povijesne - sa statistikama)
        - 25% mjeseci unaprijed (buduće - bez statistika)
      - Statistika: samo odigrane utakmice, svi igraci oba tima, 15+ kategorija
   ========================================================== */

DECLARE @e_message NVARCHAR(4000);

SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRAN;

        PRINT N'FAZA 5 Start: utakmice i statistike.';

        IF OBJECT_ID('tempdb..#SeedConfig') IS NULL
            RAISERROR(N'#SeedConfig nije inicijaliziran. Pokreni FAZU 0.', 16, 1);
        IF NOT EXISTS (SELECT 1 FROM #SeedConfig)
            RAISERROR(N'#SeedConfig je prazan.', 16, 1);

        /* Provjera tablica */
        IF OBJECT_ID(N'dbo.Tim', N'U') IS NULL
            RAISERROR(N'Tablica dbo.Tim ne postoji.', 16, 1);
        IF OBJECT_ID(N'dbo.Igrac', N'U') IS NULL
            RAISERROR(N'Tablica dbo.Igrac ne postoji.', 16, 1);
        IF OBJECT_ID(N'dbo.Dvorana', N'U') IS NULL
            RAISERROR(N'Tablica dbo.Dvorana ne postoji.', 16, 1);
        IF OBJECT_ID(N'dbo.Utakmica', N'U') IS NULL
            RAISERROR(N'Tablica dbo.Utakmica ne postoji.', 16, 1);
        IF OBJECT_ID(N'dbo.Statistika', N'U') IS NULL
            RAISERROR(N'Tablica dbo.Statistika ne postoji.', 16, 1);

        /* Provjera podataka */
        IF NOT EXISTS (SELECT 1 FROM dbo.Tim)
            RAISERROR(N'Tablica dbo.Tim je prazna.', 16, 1);
        IF NOT EXISTS (SELECT 1 FROM dbo.Igrac)
            RAISERROR(N'Tablica dbo.Igrac je prazna.', 16, 1);
        IF NOT EXISTS (SELECT 1 FROM dbo.Dvorana)
            RAISERROR(N'Tablica dbo.Dvorana je prazna.', 16, 1);

        DECLARE @Danas DATE = CAST(SYSUTCDATETIME() AS DATE);
        
        /* Dinamički izračun: 75% prošlost, 25% budućnost (min 1 mjesec budućih) */
        DECLARE @BrojMjeseci INT = (SELECT TOP (1) BrojMjeseci FROM #SeedConfig);
        DECLARE @MjeseciUnatrag INT = CASE 
            WHEN @BrojMjeseci <= 1 THEN 0  -- Sve buduće ako je samo 1 mjesec
            ELSE @BrojMjeseci - CEILING(@BrojMjeseci * 0.25)  -- 75% prošlost
        END;
        DECLARE @PocetakSezone DATE = DATEADD(MONTH, -@MjeseciUnatrag, DATEFROMPARTS(YEAR(@Danas), MONTH(@Danas), 1));

        IF OBJECT_ID('tempdb..#PlanMjeseci') IS NOT NULL DROP TABLE #PlanMjeseci;
        CREATE TABLE #PlanMjeseci (
            MjesecStart DATE NOT NULL,
            MjesecIndex INT NOT NULL,
            BrojUtakmica INT NOT NULL,
            JeProsla BIT NOT NULL  -- 1 = prošla (treba statistiku), 0 = buduća
        );

        WITH SeedConfig AS (
            SELECT TOP (1)
                sc.BrojMjeseci,
                sc.MinUtakmicaUMjesecu,
                sc.MaxUtakmicaUMjesecu
            FROM #SeedConfig sc
        ),
        Mjeseci AS (
            SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS M
            FROM sys.all_objects
        )
        INSERT INTO #PlanMjeseci (MjesecStart, MjesecIndex, BrojUtakmica, JeProsla)
        SELECT 
            DATEADD(MONTH, m.M, @PocetakSezone),
            m.M + 1,
            sc.MinUtakmicaUMjesecu + ABS(CHECKSUM(NEWID())) % (sc.MaxUtakmicaUMjesecu - sc.MinUtakmicaUMjesecu + 1),
            CASE WHEN DATEADD(MONTH, m.M, @PocetakSezone) < DATEFROMPARTS(YEAR(@Danas), MONTH(@Danas), 1) THEN 1 ELSE 0 END
        FROM Mjeseci m
        CROSS JOIN SeedConfig sc
        WHERE m.M < sc.BrojMjeseci;

        /* Utakmice - kompleksna CTE logika */
        WITH Dani AS (
            SELECT TOP (28) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS DanOffset
            FROM sys.all_objects
        ),
        Parovi AS (
            SELECT t1.TimId AS TimA, t2.TimId AS TimB
            FROM dbo.Tim t1
            JOIN dbo.Tim t2 ON t1.TimId < t2.TimId
        ),
        Kandidati AS (
            SELECT
                p.MjesecStart,
                p.MjesecIndex,
                p.BrojUtakmica,
                DATEADD(DAY, d.DanOffset, p.MjesecStart) AS Datum,
                pa.TimA,
                pa.TimB,
                ROW_NUMBER() OVER (
                    PARTITION BY p.MjesecStart
                    ORDER BY CHECKSUM(NEWID())
                ) AS RnMjesec
            FROM #PlanMjeseci p
            CROSS JOIN Dani d
            CROSS JOIN Parovi pa
        ),
        NumeriraDvorane AS (
            SELECT DvoranaId, ROW_NUMBER() OVER (ORDER BY DvoranaId) - 1 AS DvoranaRn
            FROM dbo.Dvorana
        )
        INSERT INTO dbo.Utakmica (Datum, VrijemePocetka, TimDomaci, TimGosti, DvoranaId, ResponsibleId)
        SELECT
            k.Datum,
            TIMEFROMPARTS(16 + (k.RnMjesec % 6), 0, 0, 0, 0),
            CASE WHEN k.RnMjesec % 2 = 0 THEN k.TimA ELSE k.TimB END AS TimDomaci,
            CASE WHEN k.RnMjesec % 2 = 0 THEN k.TimB ELSE k.TimA END AS TimGosti,
            d.DvoranaId,
            -125  -- System seed
        FROM Kandidati k
        INNER JOIN NumeriraDvorane d 
            ON d.DvoranaRn = ((k.RnMjesec + k.MjesecIndex) % (SELECT COUNT(*) FROM dbo.Dvorana))
        WHERE k.RnMjesec <= k.BrojUtakmica;

        /* Statistika: SAMO ODIGRANE utakmice (prošlost), svi igraci oba tima, 15+ kategorija */
        /* Buduće utakmice nemaju statistiku - još se nisu odigrale */
        INSERT INTO dbo.Statistika (
            IgracId,
            UtakmicaId,
            Minuta,
            Poeni,
            Asistencije,
            SkokoviOf,
            SkokoviDef,
            UkradeneLopte,
            Blokade,
            IzgubljeneLopte,
            OsobnePogreske,
            FGM,
            FGA,
            FG3M,
            FG3A,
            FTM,
            FTA,
            ResponsibleId
        )
        SELECT
            i.IgracId,
            u.UtakmicaId,
            s.Minuta,
            ((s.FGM - s.FG3M) * 2) + (s.FG3M * 3) + s.FTM AS Poeni,
            s.Asistencije,
            s.SkokoviOf,
            s.SkokoviDef,
            s.UkradeneLopte,
            s.Blokade,
            s.IzgubljeneLopte,  
            s.OsobnePogreske,
            s.FGM,
            s.FGA,
            s.FG3M,
            s.FG3A,
            s.FTM,
            s.FTA,
            -125  -- System seed
        FROM dbo.Utakmica u
        JOIN dbo.Igrac i ON i.TimId IN (u.TimDomaci, u.TimGosti)
        CROSS APPLY (
            SELECT
                CAST(8 + ABS(CHECKSUM(NEWID())) % 33 AS TINYINT) AS Minuta,
                CAST(ABS(CHECKSUM(NEWID())) % 9 AS TINYINT) AS Asistencije,
                CAST(ABS(CHECKSUM(NEWID())) % 5 AS TINYINT) AS SkokoviOf,
                CAST(ABS(CHECKSUM(NEWID())) % 12 AS TINYINT) AS SkokoviDef,
                CAST(ABS(CHECKSUM(NEWID())) % 6 AS TINYINT) AS UkradeneLopte,
                CAST(ABS(CHECKSUM(NEWID())) % 5 AS TINYINT) AS Blokade,
                CAST(ABS(CHECKSUM(NEWID())) % 8 AS TINYINT) AS IzgubljeneLopte,
                CAST(ABS(CHECKSUM(NEWID())) % 6 AS TINYINT) AS OsobnePogreske,
                CAST(8 + ABS(CHECKSUM(NEWID())) % 18 AS TINYINT) AS FGA,
                CAST(ABS(CHECKSUM(NEWID())) % 11 AS TINYINT) AS FG3A,
                CAST(1 + ABS(CHECKSUM(NEWID())) % 10 AS TINYINT) AS FTA
        ) b
        CROSS APPLY (
            SELECT
                CAST(ABS(CHECKSUM(NEWID())) % (b.FGA + 1) AS TINYINT) AS FGM,
                CAST(CASE
                    WHEN b.FG3A > b.FGA THEN b.FGA
                    ELSE b.FG3A
                END AS TINYINT) AS FG3AAdjusted,
                CAST(ABS(CHECKSUM(NEWID())) % (b.FTA + 1) AS TINYINT) AS FTM
        ) c
        CROSS APPLY (
            SELECT
                b.Minuta,
                b.Asistencije,
                b.SkokoviOf,
                b.SkokoviDef,
                b.UkradeneLopte,
                b.Blokade,
                b.IzgubljeneLopte,
                b.OsobnePogreske,
                c.FGM,
                b.FGA,
                CAST(ABS(CHECKSUM(NEWID())) % (CASE WHEN c.FG3AAdjusted < c.FGM THEN c.FG3AAdjusted ELSE c.FGM END + 1) AS TINYINT) AS FG3M,
                c.FG3AAdjusted AS FG3A,
                c.FTM,
                b.FTA
        ) s
        WHERE u.Datum < @Danas;  -- Samo odigrane utakmice!

        /* Prikaz statistike */
        SELECT COUNT(*) AS BrojUtakmica FROM dbo.Utakmica;
        SELECT COUNT(*) AS BrojUtakmicaOdigranih FROM dbo.Utakmica WHERE Datum < @Danas;
        SELECT COUNT(*) AS BrojUtakmicaBuducih FROM dbo.Utakmica WHERE Datum >= @Danas;
        SELECT COUNT(*) AS BrojStatistika FROM dbo.Statistika;

        PRINT N'FAZA 5 zavrsena: utakmice i statistike su upisane.';

    COMMIT TRAN;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRAN;

    SELECT @e_message=ERROR_MESSAGE()
    RAISERROR(@e_message, 16, 1);
END CATCH;
GO

