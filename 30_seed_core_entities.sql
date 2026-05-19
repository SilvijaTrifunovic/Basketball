/* ==========================================================
   FAZA 3: CORE ENTITETI (B sloj)
     - Igraci: 14 po timu
     - Korisnici: 100.000 set based
   
   NAPOMENA: Ova skripta insertira ~100.000 redova u jednoj
   transakciji. Na bazama s malim transaction logom (manje od 1GB)
   može doći do log overflow errora. U tom slučaju:
     - Povećajte transaction log
     - Ili postavite Simple recovery model
   ========================================================== */

DECLARE @e_message NVARCHAR(4000);

SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRAN;

        PRINT N'FAZA 3 Start: core entiteti (Igrac, Korisnik).';

        /* Provjera preduvjeta */
        IF OBJECT_ID('tempdb..#SeedConfig') IS NULL
            RAISERROR(N'#SeedConfig nije inicijaliziran.', 16, 1);
        IF NOT EXISTS (SELECT 1 FROM #SeedConfig)
            RAISERROR(N'#SeedConfig je prazan.', 16, 1);

        IF OBJECT_ID(N'dbo.Tim', N'U') IS NULL
            RAISERROR(N'Tablica dbo.Tim ne postoji.', 16, 1);
        IF NOT EXISTS (SELECT 1 FROM dbo.Tim)
            RAISERROR(N'Tablica dbo.Tim je prazna.', 16, 1);

        IF OBJECT_ID(N'dbo.Igrac', N'U') IS NULL
            RAISERROR(N'Tablica dbo.Igrac ne postoji.', 16, 1);
        IF OBJECT_ID(N'dbo.Korisnik', N'U') IS NULL
            RAISERROR(N'Tablica dbo.Korisnik ne postoji.', 16, 1);
        
        /* Igraci: 14 po timu */
        WITH SeedConfig AS (
            SELECT TOP (1) sc.IgracaPoTimu
            FROM #SeedConfig sc
        ),
        /* Stacked CTE - generira brojeve bez ovisnosti o sys.all_objects */
        E1(N) AS (SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1
                  UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1),
        E2(N) AS (SELECT 1 FROM E1 a CROSS JOIN E1 b),  -- 100
        Brojevi AS (
            SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS N
            FROM E2
        )
        INSERT INTO dbo.Igrac (Ime, Prezime, Pozicija, TimId, ResponsibleId)
        SELECT
            CONCAT(N'Igrac', t.TimId, N'_', b.N),
            CONCAT(N'Prezime', b.N),
            CASE b.N % 5
                WHEN 1 THEN N'Playmaker'
                WHEN 2 THEN N'Bek'
                WHEN 3 THEN N'Krilo'
                WHEN 4 THEN N'Krilni centar'
                ELSE N'Centar'
            END,
            t.TimId,
            -125  -- System seed
        FROM dbo.Tim t
        CROSS JOIN Brojevi b
        CROSS JOIN SeedConfig sc
        WHERE b.N <= sc.IgracaPoTimu;

        /* 100.000 korisnika */
        WITH SeedConfig AS (
            SELECT TOP (1) sc.BrojKorisnika
            FROM #SeedConfig sc
        ),
        /* Stacked CTE - generira do 1M brojeva */
        E1(N) AS (SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1
                  UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1),
        E2(N) AS (SELECT 1 FROM E1 a CROSS JOIN E1 b),       -- 100
        E3(N) AS (SELECT 1 FROM E2 a CROSS JOIN E2 b),       -- 10,000
        E4(N) AS (SELECT 1 FROM E3 a CROSS JOIN E2 b),       -- 1,000,000
        Brojevi AS (
            SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS N
            FROM E4
        )
        INSERT INTO dbo.Korisnik (Ime, Email, IsActive, CreatedAt, ResponsibleId)
        SELECT
            CONCAT(N'Korisnik', b.N),
            CONCAT(N'korisnik', b.N, N'@basket.hr'),
            1,
            DATEADD(DAY, -1 * (b.N % 365), SYSUTCDATETIME()),
            -125  -- System seed
        FROM Brojevi b
        CROSS JOIN SeedConfig sc
        WHERE b.N <= sc.BrojKorisnika;

        SELECT COUNT(*) AS BrojIgraca FROM dbo.Igrac;
        SELECT COUNT(*) AS BrojKorisnika FROM dbo.Korisnik;

        PRINT N'FAZA 3 zavrsena: core entiteti (Igrac, Korisnik) su upisani.';

    COMMIT TRAN;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRAN;

    SELECT @e_message=ERROR_MESSAGE()
    RAISERROR(@e_message, 16, 1);
END CATCH;

