/* ==========================================================
    FAZA 4: RELACIJE
     - Korisnik prati 4 tima i 3 igraca
   ========================================================== */

DECLARE @e_message NVARCHAR(4000);

SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRAN;

        PRINT N'FAZA 4 Start: relacije KorisnikTim i KorisnikIgrac.';

        /* Provjera preduvjeta */
        IF OBJECT_ID('tempdb..#SeedConfig') IS NULL
            RAISERROR(N'#SeedConfig nije inicijaliziran.', 16, 1);
        IF NOT EXISTS (SELECT 1 FROM #SeedConfig)
            RAISERROR(N'#SeedConfig je prazan.', 16, 1);

        IF OBJECT_ID(N'dbo.Korisnik', N'U') IS NULL
            RAISERROR(N'Tablica dbo.Korisnik ne postoji.', 16, 1);
        IF OBJECT_ID(N'dbo.Tim', N'U') IS NULL
            RAISERROR(N'Tablica dbo.Tim ne postoji.', 16, 1);
        IF OBJECT_ID(N'dbo.Igrac', N'U') IS NULL
            RAISERROR(N'Tablica dbo.Igrac ne postoji.', 16, 1);
        IF OBJECT_ID(N'dbo.KorisnikTim', N'U') IS NULL
            RAISERROR(N'Tablica dbo.KorisnikTim ne postoji.', 16, 1);
        IF OBJECT_ID(N'dbo.KorisnikIgrac', N'U') IS NULL
            RAISERROR(N'Tablica dbo.KorisnikIgrac ne postoji.', 16, 1);

        /* Provjera podataka */
        DECLARE @TeamCount INT = (SELECT COUNT(*) FROM dbo.Tim);
        DECLARE @PlayerCount INT = (SELECT COUNT(*) FROM dbo.Igrac);
        DECLARE @KorisnikCount INT = (SELECT COUNT(*) FROM dbo.Korisnik);

        IF @TeamCount = 0
            RAISERROR(N'Tablica dbo.Tim je prazna.', 16, 1);
        IF @PlayerCount = 0
            RAISERROR(N'Tablica dbo.Igrac je prazna.', 16, 1);
        IF @KorisnikCount = 0
            RAISERROR(N'Tablica dbo.Korisnik je prazna.', 16, 1);

        DECLARE @BrojPracenihTimova INT;
        DECLARE @BrojPracenihIgraca INT;
        DECLARE @KorisnikTimFaktorKorisnikId INT;
        DECLARE @KorisnikTimFaktorSlot INT;
        DECLARE @KorisnikIgracFaktorKorisnikId INT;
        DECLARE @KorisnikIgracFaktorSlot INT;

        SELECT TOP (1)
            @BrojPracenihTimova = sc.BrojPracenihTimova,
            @BrojPracenihIgraca = sc.BrojPracenihIgraca,
            @KorisnikTimFaktorKorisnikId = sc.KorisnikTimFaktorKorisnikId,
            @KorisnikTimFaktorSlot = sc.KorisnikTimFaktorSlot,
            @KorisnikIgracFaktorKorisnikId = sc.KorisnikIgracFaktorKorisnikId,
            @KorisnikIgracFaktorSlot = sc.KorisnikIgracFaktorSlot
        FROM #SeedConfig sc;

        /* 
           VAZNO: Koristimo INNER JOIN na stvarne TimId/IgracId vrijednosti
           jer formula pretpostavlja kontinuirane ID-eve bez rupa.
        */
        ;WITH NumeriranTimovi AS (
            SELECT TimId, ROW_NUMBER() OVER (ORDER BY TimId) - 1 AS TimRn
            FROM dbo.Tim
        ),
        /* Stacked CTE - generira brojeve bez ovisnosti o sys.all_objects */
        E1(N) AS (SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1
                  UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1),
        Slotovi AS (
            SELECT TOP (@BrojPracenihTimova)
                ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS RedniBroj
            FROM E1
        )
        INSERT INTO dbo.KorisnikTim (KorisnikId, TimId)
        SELECT k.KorisnikId, t.TimId
        FROM dbo.Korisnik k
        CROSS JOIN Slotovi s
        INNER JOIN NumeriranTimovi t 
            ON t.TimRn = ((k.KorisnikId * @KorisnikTimFaktorKorisnikId + s.RedniBroj * @KorisnikTimFaktorSlot) % @TeamCount);


        ;WITH NumeriranIgraci AS (
            SELECT IgracId, ROW_NUMBER() OVER (ORDER BY IgracId) - 1 AS IgracRn
            FROM dbo.Igrac
        ),
        /* Stacked CTE - generira brojeve bez ovisnosti o sys.all_objects */
        E1(N) AS (SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1
                  UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1),
        Slotovi AS (
            SELECT TOP (@BrojPracenihIgraca)
                ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS RedniBroj
            FROM E1
        )
        INSERT INTO dbo.KorisnikIgrac (KorisnikId, IgracId)
        SELECT k.KorisnikId, i.IgracId
        FROM dbo.Korisnik k
        CROSS JOIN Slotovi s
        INNER JOIN NumeriranIgraci i 
            ON i.IgracRn = ((k.KorisnikId * @KorisnikIgracFaktorKorisnikId + s.RedniBroj * @KorisnikIgracFaktorSlot) % @PlayerCount);

        SELECT COUNT(*) AS BrojKorisnikTim FROM dbo.KorisnikTim;
        SELECT COUNT(*) AS BrojKorisnikIgrac FROM dbo.KorisnikIgrac;

        PRINT N'FAZA 4 zavrsena: relacije KorisnikTim i KorisnikIgrac su upisane.';

    COMMIT TRAN;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRAN;

    SELECT @e_message=ERROR_MESSAGE()
    RAISERROR(@e_message, 16, 1);
END CATCH;

