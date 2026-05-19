/* ==========================================================
   FAZA 7.1: TABLE-VALUED FUNKCIJE (TVF)
   ========================================================== */

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

/* Provjera tablica */
IF OBJECT_ID(N'dbo.Igrac', N'U') IS NULL
    OR OBJECT_ID(N'dbo.Tim', N'U') IS NULL
    OR OBJECT_ID(N'dbo.Statistika', N'U') IS NULL
    OR OBJECT_ID(N'dbo.Utakmica', N'U') IS NULL
    OR OBJECT_ID(N'dbo.Dvorana', N'U') IS NULL
BEGIN
    RAISERROR(N'Nedostaju tablice za kreiranje funkcija.', 16, 1);
    SET NOEXEC ON;
END;
GO

PRINT N'FAZA 7.1 Start: kreiranje funkcija.';
GO

/* ---------------------------------------------------------
   fnIgraciPoPoziciji - Svi igraci odredene pozicije
   
   Pozicije: 'Point Guard', 'Shooting Guard', 'Small Forward', 
             'Power Forward', 'Center'
   --------------------------------------------------------- */
CREATE OR ALTER FUNCTION dbo.fnIgraciPoPoziciji
(
    @Pozicija NVARCHAR(50)
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        i.IgracId,
        i.Ime,
        i.Prezime,
        i.Ime + N' ' + i.Prezime AS PunoIme,
        i.Pozicija,
        i.TimId,
        t.Naziv AS Tim,
        t.Grad AS TimGrad,
        i.CreatedAt
    FROM dbo.Igrac i
    JOIN dbo.Tim t ON t.TimId = i.TimId
    WHERE i.Pozicija = @Pozicija
      AND i.IsDeleted = 0
      AND t.IsDeleted = 0
);
GO

/* ---------------------------------------------------------
   fnStatistikaIgraca - Prosjecna karijerna statistika igraca
   --------------------------------------------------------- */
CREATE OR ALTER FUNCTION dbo.fnStatistikaIgraca
(
    @IgracId INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        i.IgracId,
        i.Ime,
        i.Prezime,
        i.Ime + N' ' + i.Prezime AS PunoIme,
        i.Pozicija,
        i.TimId,
        t.Naziv AS Tim,
        COUNT(*) AS BrojUtakmica,
        SUM(s.Minuta) AS UkupnoMinuta,
        CAST(AVG(CAST(s.Minuta AS DECIMAL(5,1))) AS DECIMAL(5,1)) AS MPG,
        SUM(s.Poeni) AS UkupnoPoena,
        CAST(AVG(CAST(s.Poeni AS DECIMAL(5,1))) AS DECIMAL(5,1)) AS PPG,
        MAX(s.Poeni) AS MaxPoena,
        SUM(s.Asistencije) AS UkupnoAsistencija,
        CAST(AVG(CAST(s.Asistencije AS DECIMAL(5,1))) AS DECIMAL(5,1)) AS APG,
        SUM(s.SkokoviOf) AS UkupnoSkokovaOf,
        SUM(s.SkokoviDef) AS UkupnoSkokovaDef,
        SUM(s.SkokoviOf + s.SkokoviDef) AS UkupnoSkokova,
        CAST(AVG(CAST(s.SkokoviOf + s.SkokoviDef AS DECIMAL(5,1))) AS DECIMAL(5,1)) AS RPG,
        SUM(s.UkradeneLopte) AS UkupnoUkradenihLopti,
        CAST(AVG(CAST(s.UkradeneLopte AS DECIMAL(5,1))) AS DECIMAL(5,1)) AS SPG,
        SUM(s.Blokade) AS UkupnoBlokada,
        CAST(AVG(CAST(s.Blokade AS DECIMAL(5,1))) AS DECIMAL(5,1)) AS BPG,
        SUM(s.IzgubljeneLopte) AS UkupnoIzgubljenihLopti,
        CAST(AVG(CAST(s.IzgubljeneLopte AS DECIMAL(5,1))) AS DECIMAL(5,1)) AS TPG,
        SUM(s.OsobnePogreske) AS UkupnoFaulova,
        SUM(s.FGM) AS FGM,
        SUM(s.FGA) AS FGA,
        CAST(CASE 
            WHEN SUM(s.FGA) > 0 
            THEN CAST(SUM(s.FGM) AS DECIMAL(10,2)) / SUM(s.FGA) * 100 
            ELSE 0 
        END AS DECIMAL(5,1)) AS FGPct,
        SUM(s.FG3M) AS FG3M,
        SUM(s.FG3A) AS FG3A,
        CAST(CASE 
            WHEN SUM(s.FG3A) > 0 
            THEN CAST(SUM(s.FG3M) AS DECIMAL(10,2)) / SUM(s.FG3A) * 100 
            ELSE 0 
        END AS DECIMAL(5,1)) AS FG3Pct,
        SUM(s.FTM) AS FTM,
        SUM(s.FTA) AS FTA,
        CAST(CASE 
            WHEN SUM(s.FTA) > 0 
            THEN CAST(SUM(s.FTM) AS DECIMAL(10,2)) / SUM(s.FTA) * 100 
            ELSE 0 
        END AS DECIMAL(5,1)) AS FTPct
    FROM dbo.Statistika s
    JOIN dbo.Igrac i ON i.IgracId = s.IgracId
    JOIN dbo.Tim t ON t.TimId = i.TimId
    WHERE s.IgracId = @IgracId
    GROUP BY i.IgracId, i.Ime, i.Prezime, i.Pozicija, i.TimId, t.Naziv
);
GO

/* ---------------------------------------------------------
   fnRasporedTima - Sve utakmice odabranog tima
   --------------------------------------------------------- */
CREATE OR ALTER FUNCTION dbo.fnRasporedTima
(
    @TimId INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        u.UtakmicaId,
        u.Datum,
        u.VrijemePocetka,
        CASE 
            WHEN u.TimDomaci = @TimId THEN N'Domaci'
            ELSE N'Gosti'
        END AS Uloga,
        CASE 
            WHEN u.TimDomaci = @TimId THEN u.TimGosti
            ELSE u.TimDomaci
        END AS ProtivnikId,
        CASE 
            WHEN u.TimDomaci = @TimId THEN tg.Naziv
            ELSE td.Naziv
        END AS Protivnik,
        CASE 
            WHEN u.TimDomaci = @TimId THEN tg.Grad
            ELSE td.Grad
        END AS ProtivnikGrad,
        u.DvoranaId,
        d.Naziv AS Dvorana,
        d.Lokacija,
        d.Kapacitet
    FROM dbo.Utakmica u
    JOIN dbo.Tim td ON td.TimId = u.TimDomaci
    JOIN dbo.Tim tg ON tg.TimId = u.TimGosti
    JOIN dbo.Dvorana d ON d.DvoranaId = u.DvoranaId
    WHERE (u.TimDomaci = @TimId OR u.TimGosti = @TimId)
      AND u.IsDeleted = 0
);
GO

/* ---------------------------------------------------------
   fnBoxScoreUtakmice - Statistika svih igraca na utakmici
   --------------------------------------------------------- */
CREATE OR ALTER FUNCTION dbo.fnBoxScoreUtakmice
(
    @UtakmicaId INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        s.StatistikaId,
        u.Datum,
        u.VrijemePocetka,
        s.IgracId,
        i.Ime,
        i.Prezime,
        i.Ime + N' ' + i.Prezime AS PunoIme,
        i.Pozicija,
        i.TimId,
        t.Naziv AS Tim,
        CASE WHEN i.TimId = u.TimDomaci THEN N'Domaci' ELSE N'Gosti' END AS TipIgraca,
        s.Minuta,
        s.Poeni,
        s.Asistencije,
        s.SkokoviOf,
        s.SkokoviDef,
        s.SkokoviOf + s.SkokoviDef AS SkokoviUkupno,
        s.UkradeneLopte,
        s.Blokade,
        s.IzgubljeneLopte,
        s.OsobnePogreske,
        s.FGM,
        s.FGA,
        CAST(CASE WHEN s.FGA > 0 THEN CAST(s.FGM AS DECIMAL(5,2)) / s.FGA * 100 ELSE 0 END AS DECIMAL(5,1)) AS FGPct,
        s.FG3M,
        s.FG3A,
        CAST(CASE WHEN s.FG3A > 0 THEN CAST(s.FG3M AS DECIMAL(5,2)) / s.FG3A * 100 ELSE 0 END AS DECIMAL(5,1)) AS FG3Pct,
        s.FTM,
        s.FTA,
        CAST(CASE WHEN s.FTA > 0 THEN CAST(s.FTM AS DECIMAL(5,2)) / s.FTA * 100 ELSE 0 END AS DECIMAL(5,1)) AS FTPct
    FROM dbo.Statistika s
    JOIN dbo.Igrac i ON i.IgracId = s.IgracId
    JOIN dbo.Tim t ON t.TimId = i.TimId
    JOIN dbo.Utakmica u ON u.UtakmicaId = s.UtakmicaId
    WHERE s.UtakmicaId = @UtakmicaId
      AND i.IsDeleted = 0
);
GO

/* ---------------------------------------------------------
   fnZavrseneUtakmiceOd - Utakmice završene od određenog datuma
   
   Za webhook notifikacije - dohvaća utakmice koje su završene
   (datum u prošlosti) i koje su unesene/ažurirane od zadanog
   vremena. Uključuje rezultate (zbroj poena po timu).
   --------------------------------------------------------- */
CREATE OR ALTER FUNCTION dbo.fnZavrseneUtakmiceOd
(
    @OdVremena DATETIME2
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        u.UtakmicaId,
        u.Datum,
        u.VrijemePocetka,
        u.TimDomaci AS TimDomaciId,
        td.Naziv AS Domaci,
        td.Grad AS DomaciGrad,
        u.TimGosti AS TimGostiId,
        tg.Naziv AS Gosti,
        tg.Grad AS GostiGrad,
        u.DvoranaId,
        d.Naziv AS Dvorana,
        d.Lokacija,
        ISNULL(dom.PoeniDomaci, 0) AS PoeniDomaci,
        ISNULL(gos.PoeniGosti, 0) AS PoeniGosti,
        CASE 
            WHEN ISNULL(dom.PoeniDomaci, 0) > ISNULL(gos.PoeniGosti, 0) THEN td.Naziv
            WHEN ISNULL(gos.PoeniGosti, 0) > ISNULL(dom.PoeniDomaci, 0) THEN tg.Naziv
            ELSE N'Neriješeno'
        END AS Pobjednik,
        u.CreatedAt AS UtakmicaCreatedAt
    FROM dbo.Utakmica u
    JOIN dbo.Tim td ON td.TimId = u.TimDomaci
    JOIN dbo.Tim tg ON tg.TimId = u.TimGosti
    JOIN dbo.Dvorana d ON d.DvoranaId = u.DvoranaId
    LEFT JOIN (
        SELECT s.UtakmicaId, SUM(s.Poeni) AS PoeniDomaci
        FROM dbo.Statistika s
        JOIN dbo.Igrac i ON i.IgracId = s.IgracId
        JOIN dbo.Utakmica u2 ON u2.UtakmicaId = s.UtakmicaId
        WHERE i.TimId = u2.TimDomaci
        GROUP BY s.UtakmicaId
    ) dom ON dom.UtakmicaId = u.UtakmicaId
    LEFT JOIN (
        SELECT s.UtakmicaId, SUM(s.Poeni) AS PoeniGosti
        FROM dbo.Statistika s
        JOIN dbo.Igrac i ON i.IgracId = s.IgracId
        JOIN dbo.Utakmica u2 ON u2.UtakmicaId = s.UtakmicaId
        WHERE i.TimId = u2.TimGosti
        GROUP BY s.UtakmicaId
    ) gos ON gos.UtakmicaId = u.UtakmicaId
    WHERE u.Datum < CAST(GETDATE() AS DATE)
      AND u.CreatedAt >= @OdVremena
      AND u.IsDeleted = 0
);
GO

/* ==========================================================
   PRIMJERI KORISTENJA FUNKCIJA
   ========================================================== */
PRINT N'=== PRIMJERI KORISTENJA FUNKCIJA ===';

-- Svi centri
SELECT * FROM dbo.fnIgraciPoPoziciji(N'Bek') ORDER BY Tim, Prezime;

-- Svi point guardi
SELECT * FROM dbo.fnIgraciPoPoziciji(N'Krilo') ORDER BY Tim, Prezime;

-- Statistika igraca #1
SELECT * FROM dbo.fnStatistikaIgraca(1);

-- Raspored Cibone (TimId = 1)
SELECT * FROM dbo.fnRasporedTima(1) ORDER BY Datum;

-- Box score utakmice #1
SELECT * FROM dbo.fnBoxScoreUtakmice(1) ORDER BY TipIgraca, Poeni DESC;

-- Završene utakmice u zadnjih 24 sata (za webhook)
SELECT * FROM dbo.fnZavrseneUtakmiceOd(DATEADD(HOUR, -24, GETDATE())) ORDER BY Datum DESC;

PRINT N'FAZA 7.1 zavrsena: funkcije kreirane.';
GO

SET NOEXEC OFF;
GO
