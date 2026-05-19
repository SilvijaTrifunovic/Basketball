SET NOCOUNT ON;
GO

/* ==========================================================
   FAZA 0: Config - PARAMETRI VOLUMENA
   ========================================================== */

PRINT N'FAZA 0 Start: #SeedConfig je inicijaliziran.';

IF OBJECT_ID('tempdb..#SeedConfig') IS NOT NULL DROP TABLE #SeedConfig;
CREATE TABLE #SeedConfig (
    BrojKorisnika INT NOT NULL,
    IgracaPoTimu INT NOT NULL,
    BrojMjeseci INT NOT NULL,
    MinUtakmicaUMjesecu INT NOT NULL,
    MaxUtakmicaUMjesecu INT NOT NULL,
    BrojPracenihTimova INT NOT NULL,
    BrojPracenihIgraca INT NOT NULL,
    KorisnikTimFaktorKorisnikId INT NOT NULL,
    KorisnikTimFaktorSlot INT NOT NULL,
    KorisnikIgracFaktorKorisnikId INT NOT NULL,
    KorisnikIgracFaktorSlot INT NOT NULL
);

INSERT INTO #SeedConfig 
(BrojKorisnika,IgracaPoTimu,BrojMjeseci,MinUtakmicaUMjesecu,MaxUtakmicaUMjesecu,BrojPracenihTimova,BrojPracenihIgraca,KorisnikTimFaktorKorisnikId,KorisnikTimFaktorSlot,KorisnikIgracFaktorKorisnikId,KorisnikIgracFaktorSlot)
VALUES (100, 14, 3, 60, 80, 4, 3, 17, 3, 29, 11);

/* Validacija config vrijednosti */
DECLARE @BrojTimova INT = 20;  -- Fiksno u 20_seed_static_data.sql
DECLARE @BrojIgraca INT;
SELECT @BrojIgraca = @BrojTimova * IgracaPoTimu FROM #SeedConfig;

IF EXISTS (
    SELECT 1 FROM #SeedConfig 
    WHERE BrojKorisnika < 1
       OR IgracaPoTimu < 1
       OR BrojMjeseci < 1
       OR MinUtakmicaUMjesecu < 1
       OR MaxUtakmicaUMjesecu < MinUtakmicaUMjesecu
       OR BrojPracenihTimova < 1 OR BrojPracenihTimova > @BrojTimova
       OR BrojPracenihIgraca < 1 OR BrojPracenihIgraca > @BrojIgraca
)
BEGIN
    RAISERROR(N'Neispravne config vrijednosti! Provjeri: BrojKorisnika>=1, BrojMjeseci>=1, Min<=Max, BrojPracenihTimova<=20, BrojPracenihIgraca<=%d', 16, 1, @BrojIgraca);
END;

SELECT 
    BrojKorisnika,IgracaPoTimu,BrojMjeseci,
    MinUtakmicaUMjesecu,MaxUtakmicaUMjesecu,
    BrojPracenihTimova,BrojPracenihIgraca,
    KorisnikTimFaktorKorisnikId,KorisnikTimFaktorSlot,
    KorisnikIgracFaktorKorisnikId,KorisnikIgracFaktorSlot
FROM #SeedConfig

PRINT N'FAZA 0 zavrsena: #SeedConfig je inicijaliziran.';


