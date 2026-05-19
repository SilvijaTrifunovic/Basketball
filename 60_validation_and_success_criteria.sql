/* ==========================================================
   FAZA 6: VALIDACIJE INTEGRITETA
   ========================================================== */

/* Provjera tablica */
IF OBJECT_ID(N'dbo.Statistika', N'U') IS NULL
    OR OBJECT_ID(N'dbo.Igrac', N'U') IS NULL
    OR OBJECT_ID(N'dbo.Utakmica', N'U') IS NULL
    OR OBJECT_ID(N'dbo.KorisnikTim', N'U') IS NULL
    OR OBJECT_ID(N'dbo.KorisnikIgrac', N'U') IS NULL
    OR OBJECT_ID(N'dbo.Korisnik', N'U') IS NULL
    OR OBJECT_ID(N'dbo.Tim', N'U') IS NULL
BEGIN
    RAISERROR(N'Nedostaju tablice za validaciju. Pokreni FAZU 1.', 16, 1);
    SET NOEXEC ON;
END;
GO

PRINT N'FAZA 6 Start: validacije i sanity check.';


SELECT COUNT(*) AS Orphan_Statistika_Igrac
FROM dbo.Statistika s
LEFT JOIN dbo.Igrac i ON i.IgracId = s.IgracId
WHERE i.IgracId IS NULL;

SELECT COUNT(*) AS Orphan_Statistika_Utakmica
FROM dbo.Statistika s
LEFT JOIN dbo.Utakmica u ON u.UtakmicaId = s.UtakmicaId
WHERE u.UtakmicaId IS NULL;

SELECT COUNT(*) AS Orphan_KorisnikTim_Korisnik
FROM dbo.KorisnikTim kt
LEFT JOIN dbo.Korisnik k ON k.KorisnikId = kt.KorisnikId
WHERE k.KorisnikId IS NULL;

SELECT COUNT(*) AS Orphan_KorisnikTim_Tim
FROM dbo.KorisnikTim kt
LEFT JOIN dbo.Tim t ON t.TimId = kt.TimId
WHERE t.TimId IS NULL;

SELECT COUNT(*) AS Orphan_KorisnikIgrac_Korisnik
FROM dbo.KorisnikIgrac ki
LEFT JOIN dbo.Korisnik k ON k.KorisnikId = ki.KorisnikId
WHERE k.KorisnikId IS NULL;

SELECT COUNT(*) AS Orphan_KorisnikIgrac_Igrac
FROM dbo.KorisnikIgrac ki
LEFT JOIN dbo.Igrac i ON i.IgracId = ki.IgracId
WHERE i.IgracId IS NULL;
GO

/* Distribucije i sanity check */
SELECT
    YEAR(Datum) AS Godina,
    MONTH(Datum) AS Mjesec,
    COUNT(*) AS BrojUtakmicaUMjesecu
FROM dbo.Utakmica
GROUP BY YEAR(Datum), MONTH(Datum)
ORDER BY Godina, Mjesec;

SELECT
    MIN(Minuta) AS MinMinuta,
    MAX(Minuta) AS MaxMinuta,
    AVG(CAST(Poeni AS DECIMAL(10,2))) AS AvgPoeni,
    MAX(Poeni) AS MaxPoeni
FROM dbo.Statistika;

/* Team-level statistika (agregirano po timu) */
SELECT
    i.TimId,
    COUNT(*) AS BrojStatZapisa,
    SUM(CAST(s.Poeni AS BIGINT)) AS UkupnoPoena,
    AVG(CAST(s.Poeni AS DECIMAL(10,2))) AS ProsjekPoena,
    SUM(CAST(s.Asistencije AS BIGINT)) AS UkupnoAsistencija,
    SUM(CAST(s.SkokoviOf + s.SkokoviDef AS BIGINT)) AS UkupnoSkokova,
    SUM(CAST(s.UkradeneLopte AS BIGINT)) AS UkupnoUkradenih,
    SUM(CAST(s.Blokade AS BIGINT)) AS UkupnoBlokada
FROM dbo.Statistika s
JOIN dbo.Igrac i ON i.IgracId = s.IgracId
GROUP BY i.TimId
ORDER BY i.TimId;

/* Team-level po mjesecu */
SELECT
    i.TimId,
    YEAR(u.Datum) AS Godina,
    MONTH(u.Datum) AS Mjesec,
    SUM(CAST(s.Poeni AS BIGINT)) AS UkupnoPoena,
    AVG(CAST(s.Poeni AS DECIMAL(10,2))) AS ProsjekPoena
FROM dbo.Statistika s
JOIN dbo.Igrac i ON i.IgracId = s.IgracId
JOIN dbo.Utakmica u ON u.UtakmicaId = s.UtakmicaId
GROUP BY i.TimId, YEAR(u.Datum), MONTH(u.Datum)
ORDER BY i.TimId, Godina, Mjesec;

/* Team-level sezonska statistika (po godini/sezoni) */
SELECT
    i.TimId,
    YEAR(u.Datum) AS SezonaGodina,
    COUNT(*) AS BrojStatZapisa,
    SUM(CAST(s.Poeni AS BIGINT)) AS UkupnoPoena,
    AVG(CAST(s.Poeni AS DECIMAL(10,2))) AS ProsjekPoena,
    SUM(CAST(s.Asistencije AS BIGINT)) AS UkupnoAsistencija,
    SUM(CAST(s.SkokoviOf + s.SkokoviDef AS BIGINT)) AS UkupnoSkokova,
    SUM(CAST(s.UkradeneLopte AS BIGINT)) AS UkupnoUkradenih,
    SUM(CAST(s.Blokade AS BIGINT)) AS UkupnoBlokada
FROM dbo.Statistika s
JOIN dbo.Igrac i ON i.IgracId = s.IgracId
JOIN dbo.Utakmica u ON u.UtakmicaId = s.UtakmicaId
GROUP BY i.TimId, YEAR(u.Datum)
ORDER BY SezonaGodina, i.TimId;

/* Team-level domaće/gostujuće ukupno */
SELECT
    i.TimId,
    CASE WHEN i.TimId = u.TimDomaci THEN N'Domaci' ELSE N'Gosti' END AS TipUtakmice,
    COUNT(*) AS BrojStatZapisa,
    SUM(CAST(s.Poeni AS BIGINT)) AS UkupnoPoena,
    AVG(CAST(s.Poeni AS DECIMAL(10,2))) AS ProsjekPoena,
    SUM(CAST(s.Asistencije AS BIGINT)) AS UkupnoAsistencija,
    SUM(CAST(s.SkokoviOf + s.SkokoviDef AS BIGINT)) AS UkupnoSkokova,
    SUM(CAST(s.UkradeneLopte AS BIGINT)) AS UkupnoUkradenih,
    SUM(CAST(s.Blokade AS BIGINT)) AS UkupnoBlokada
FROM dbo.Statistika s
JOIN dbo.Igrac i ON i.IgracId = s.IgracId
JOIN dbo.Utakmica u ON u.UtakmicaId = s.UtakmicaId
GROUP BY i.TimId, CASE WHEN i.TimId = u.TimDomaci THEN N'Domaci' ELSE N'Gosti' END
ORDER BY i.TimId, TipUtakmice;

/* Team-level domaće/gostujuće po sezoni */
SELECT
    i.TimId,
    YEAR(u.Datum) AS SezonaGodina,
    CASE WHEN i.TimId = u.TimDomaci THEN N'Domaci' ELSE N'Gosti' END AS TipUtakmice,
    COUNT(*) AS BrojStatZapisa,
    SUM(CAST(s.Poeni AS BIGINT)) AS UkupnoPoena,
    AVG(CAST(s.Poeni AS DECIMAL(10,2))) AS ProsjekPoena,
    SUM(CAST(s.Asistencije AS BIGINT)) AS UkupnoAsistencija,
    SUM(CAST(s.SkokoviOf + s.SkokoviDef AS BIGINT)) AS UkupnoSkokova,
    SUM(CAST(s.UkradeneLopte AS BIGINT)) AS UkupnoUkradenih,
    SUM(CAST(s.Blokade AS BIGINT)) AS UkupnoBlokada
FROM dbo.Statistika s
JOIN dbo.Igrac i ON i.IgracId = s.IgracId
JOIN dbo.Utakmica u ON u.UtakmicaId = s.UtakmicaId
GROUP BY
    i.TimId,
    YEAR(u.Datum),
    CASE WHEN i.TimId = u.TimDomaci THEN N'Domaci' ELSE N'Gosti' END
ORDER BY SezonaGodina, i.TimId, TipUtakmice;

/* Igrac-level statistika (agregirano po igracu) */
SELECT
    s.IgracId,
    i.TimId,
    i.Ime,
    i.Prezime,
    COUNT(*) AS BrojStatZapisa,
    SUM(CAST(s.Poeni AS BIGINT)) AS UkupnoPoena,
    AVG(CAST(s.Poeni AS DECIMAL(10,2))) AS ProsjekPoena,
    SUM(CAST(s.Asistencije AS BIGINT)) AS UkupnoAsistencija,
    SUM(CAST(s.SkokoviOf + s.SkokoviDef AS BIGINT)) AS UkupnoSkokova,
    SUM(CAST(s.UkradeneLopte AS BIGINT)) AS UkupnoUkradenih,
    SUM(CAST(s.Blokade AS BIGINT)) AS UkupnoBlokada
FROM dbo.Statistika s
JOIN dbo.Igrac i ON i.IgracId = s.IgracId
GROUP BY s.IgracId, i.TimId, i.Ime, i.Prezime
ORDER BY i.TimId, UkupnoPoena DESC, s.IgracId;

/* Igrac-level po mjesecu */
SELECT
    s.IgracId,
    i.TimId,
    i.Ime,
    i.Prezime,
    YEAR(u.Datum) AS Godina,
    MONTH(u.Datum) AS Mjesec,
    SUM(CAST(s.Poeni AS BIGINT)) AS UkupnoPoena,
    AVG(CAST(s.Poeni AS DECIMAL(10,2))) AS ProsjekPoena
FROM dbo.Statistika s
JOIN dbo.Igrac i ON i.IgracId = s.IgracId
JOIN dbo.Utakmica u ON u.UtakmicaId = s.UtakmicaId
GROUP BY s.IgracId, i.TimId, i.Ime, i.Prezime, YEAR(u.Datum), MONTH(u.Datum)
ORDER BY i.TimId, s.IgracId, Godina, Mjesec;

PRINT N'FAZA 6 zavrsena: validacije i sanity check su izvrseni.';
GO

SET NOEXEC OFF;
GO
