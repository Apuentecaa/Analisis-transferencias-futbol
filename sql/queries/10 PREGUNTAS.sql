

-- ============================================
-- PROYECTO: ANÁLISIS DE TRANSFERENCIAS DE FÚTBOL
-- BASE DE DATOS: FootballTransfersDB
-- DESCRIPCIÓN: 10 preguntas de análisis con tablas unidas
-- ============================================

USE FootballTransfersDB;
GO

-- ============================================
-- PREGUNTA 1: Panorama General del Mercado de Transferencias
-- ============================================
-- Objetivo: Mostrar las estadísticas globales del mercado de transferencias 
-- con información financiera de clubes y ligas.

SELECT 
    COUNT(DISTINCT t.transfer_id) AS Total_Transferencias,
    COUNT(DISTINCT t.player_name) AS Jugadores_Unicos,
    COUNT(DISTINCT t.to_club) AS Clubes_Compradores,
    COUNT(DISTINCT t.to_league) AS Ligas_Participantes,
    ROUND(SUM(t.transfer_fee_eur_m), 2) AS Gasto_Total_Millones,
    ROUND(AVG(t.transfer_fee_eur_m), 2) AS Gasto_Promedio_Millones,
    ROUND(AVG(f.revenue_eur_m), 2) AS Ingreso_Promedio_Club_Millones,
    ROUND(AVG(l.total_revenue_eur_m), 2) AS Ingreso_Promedio_Liga_Millones,
    MIN(t.year) AS Primer_Año,
    MAX(t.year) AS Ultimo_Año
FROM vw_master_data t
LEFT JOIN vw_club_financials f ON t.to_club = f.club_name AND t.year = f.year
LEFT JOIN vw_league_metrics l ON t.to_league = l.league AND t.year = l.year
WHERE t.transfer_fee_eur_m > 0;
GO

-- ============================================
-- PREGUNTA 2: Top 10 Transferencias Más Caras con Información Financiera
-- ============================================
-- Objetivo: Identificar las transferencias récord y su contexto financiero.

SELECT TOP 10
    t.transfer_id,
    t.year,
    t.player_name,
    t.position,
    t.age,
    t.from_club,
    t.to_club,
    ROUND(t.transfer_fee_eur_m, 2) AS Precio_Millones,
    ROUND(f.revenue_eur_m, 2) AS Ingresos_Club_Comprador_Millones,
    ROUND(f.wage_bill_eur_m, 2) AS Gasto_Salarios_Club_Millones,
    ROUND(l.total_revenue_eur_m, 2) AS Ingresos_Liga_Millones,
    l.avg_attendance AS Asistencia_Promedio_Liga,
    CASE 
        WHEN t.is_free_transfer = 1 THEN 'Libre'
        WHEN t.is_loan = 1 THEN 'Cesión'
        ELSE 'Compra'
    END AS Tipo_Operacion
FROM vw_master_data t
LEFT JOIN vw_club_financials f ON t.to_club = f.club_name AND t.year = f.year
LEFT JOIN vw_league_metrics l ON t.to_league = l.league AND t.year = l.year
WHERE t.transfer_fee_eur_m > 0
ORDER BY t.transfer_fee_eur_m DESC;
GO

-- ============================================
-- PREGUNTA 3: Clubes con Mayor Gasto en Transferencias vs Ingresos
-- ============================================
-- Objetivo: Evaluar qué clubes invierten más en fichajes en relación a sus ingresos.

SELECT TOP 10
    t.to_club AS Club,
    t.year,
    COUNT(t.transfer_id) AS Compras,
    ROUND(SUM(t.transfer_fee_eur_m), 2) AS Gasto_Transferencias_Millones,
    ROUND(AVG(f.revenue_eur_m), 2) AS Ingresos_Club_Millones,
    ROUND(AVG(f.wage_bill_eur_m), 2) AS Gasto_Salarios_Millones,
    ROUND((SUM(t.transfer_fee_eur_m) / NULLIF(AVG(f.revenue_eur_m), 0)) * 100, 2) AS Pct_Gasto_Ingresos,
    ROUND(AVG(f.operating_profit_eur_m), 2) AS Beneficio_Operativo_Millones
FROM vw_master_data t
INNER JOIN vw_club_financials f ON t.to_club = f.club_name AND t.year = f.year
WHERE t.transfer_fee_eur_m > 0 AND f.revenue_eur_m > 0
GROUP BY t.to_club, t.year
HAVING COUNT(t.transfer_id) >= 3
ORDER BY Pct_Gasto_Ingresos DESC;
GO

-- ============================================
-- PREGUNTA 4: Clubes con Mayor Ingreso por Ventas
-- ============================================
-- Objetivo: Identificar los clubes que generan más ingresos vendiendo jugadores.

SELECT TOP 10
    t.from_club AS Club,
    COUNT(t.transfer_id) AS Ventas,
    ROUND(SUM(t.transfer_fee_eur_m), 2) AS Ingresos_Ventas_Millones,
    ROUND(AVG(t.transfer_fee_eur_m), 2) AS Ingreso_Promedio_Millones,
    SUM(CASE WHEN t.is_free_transfer = 1 THEN 1 ELSE 0 END) AS Ventas_Libres,
    SUM(CASE WHEN t.is_loan = 1 THEN 1 ELSE 0 END) AS Cesiones_Realizadas
FROM vw_master_data t
WHERE t.transfer_fee_eur_m > 0 AND t.from_club IS NOT NULL
GROUP BY t.from_club
ORDER BY SUM(t.transfer_fee_eur_m) DESC;
GO

-- ============================================
-- PREGUNTA 5: Análisis de Ligas - Gasto vs Asistencia
-- ============================================
-- Objetivo: Relacionar el gasto en transferencias con la asistencia 
-- y el porcentaje de jugadores extranjeros.

SELECT TOP 10
    t.to_league AS Liga,
    COUNT(t.transfer_id) AS Transferencias,
    ROUND(SUM(t.transfer_fee_eur_m), 2) AS Gasto_Transferencias_Millones,
    ROUND(AVG(l.total_revenue_eur_m), 2) AS Ingresos_Liga_Millones,
    ROUND(AVG(l.avg_attendance), 0) AS Asistencia_Promedio,
    ROUND(AVG(l.avg_ticket_eur), 2) AS Ticket_Promedio_EUR,
    ROUND(AVG(l.foreign_players_pct), 2) AS Porcentaje_Extranjeros,
    ROUND(SUM(t.transfer_fee_eur_m) / NULLIF(AVG(l.total_revenue_eur_m), 0) * 100, 2) AS Pct_Gasto_Ingresos_Liga
FROM vw_master_data t
INNER JOIN vw_league_metrics l ON t.to_league = l.league AND t.year = l.year
WHERE t.transfer_fee_eur_m > 0
GROUP BY t.to_league
ORDER BY SUM(t.transfer_fee_eur_m) DESC;
GO

-- ============================================
-- PREGUNTA 6: Jugadores Más Valiosos (Mayor Suma de Transferencias)
-- ============================================
-- Objetivo: Identificar los jugadores que han generado más dinero en el mercado.

SELECT TOP 10
    t.player_name,
    COUNT(t.transfer_id) AS Veces_Transferido,
    ROUND(SUM(t.transfer_fee_eur_m), 2) AS Total_Millones,
    ROUND(AVG(t.transfer_fee_eur_m), 2) AS Promedio_Millones,
    MIN(t.year) AS Primer_Año,
    MAX(t.year) AS Ultimo_Año,
    ROUND(AVG(p.market_value_eur_m), 2) AS Valor_Mercado_Promedio_Millones,
    SUM(CASE WHEN p.is_peak_year = 1 THEN 1 ELSE 0 END) AS Veces_En_Pico_Valor
FROM vw_master_data t
LEFT JOIN vw_player_market_values p ON t.player_name = p.player_name AND t.year = p.year
WHERE t.transfer_fee_eur_m > 0
GROUP BY t.player_name
HAVING COUNT(t.transfer_id) > 1
ORDER BY SUM(t.transfer_fee_eur_m) DESC;
GO

-- ============================================
-- PREGUNTA 7: Relación entre Edad y Valor de Transferencia
-- ============================================
-- Objetivo: Determinar la edad óptima para una transferencia rentable.

SELECT 
    CASE 
        WHEN t.age <= 21 THEN '18-21 años'
        WHEN t.age BETWEEN 22 AND 25 THEN '22-25 años'
        WHEN t.age BETWEEN 26 AND 29 THEN '26-29 años'
        WHEN t.age >= 30 THEN '30+ años'
        ELSE 'Sin edad'
    END AS Rango_Edad,
    COUNT(t.transfer_id) AS Transferencias,
    ROUND(AVG(t.transfer_fee_eur_m), 2) AS Gasto_Promedio_Millones,
    ROUND(SUM(t.transfer_fee_eur_m), 2) AS Gasto_Total_Millones,
    ROUND(AVG(f.revenue_eur_m), 2) AS Ingreso_Club_Promedio_Millones,
    SUM(CASE WHEN t.is_free_transfer = 1 THEN 1 ELSE 0 END) AS Transferencias_Libres
FROM vw_master_data t
LEFT JOIN vw_club_financials f ON t.to_club = f.club_name AND t.year = f.year
WHERE t.age IS NOT NULL AND t.transfer_fee_eur_m > 0
GROUP BY 
    CASE 
        WHEN t.age <= 21 THEN '18-21 años'
        WHEN t.age BETWEEN 22 AND 25 THEN '22-25 años'
        WHEN t.age BETWEEN 26 AND 29 THEN '26-29 años'
        WHEN t.age >= 30 THEN '30+ años'
        ELSE 'Sin edad'
    END
ORDER BY Gasto_Promedio_Millones DESC;
GO

-- ============================================
-- PREGUNTA 8: Transferencias Internacionales vs Nacionales
-- ============================================
-- Objetivo: Analizar si las transferencias internacionales son más caras.

SELECT 
    CASE 
        WHEN t.is_intra_country = 1 THEN 'Transferencia Nacional'
        ELSE 'Transferencia Internacional'
    END AS Tipo_Transferencia,
    COUNT(t.transfer_id) AS Cantidad,
    ROUND(SUM(t.transfer_fee_eur_m), 2) AS Gasto_Total_Millones,
    ROUND(AVG(t.transfer_fee_eur_m), 2) AS Gasto_Promedio_Millones,
    ROUND(AVG(t.age), 1) AS Edad_Promedio,
    SUM(CASE WHEN t.is_free_transfer = 1 THEN 1 ELSE 0 END) AS Libres,
    SUM(CASE WHEN t.is_loan = 1 THEN 1 ELSE 0 END) AS Cesiones,
    COUNT(DISTINCT t.from_country) AS Paises_Origen,
    COUNT(DISTINCT t.to_country) AS Paises_Destino
FROM vw_master_data t
WHERE t.transfer_fee_eur_m > 0
GROUP BY CASE WHEN t.is_intra_country = 1 THEN 'Transferencia Nacional' ELSE 'Transferencia Internacional' END
ORDER BY Gasto_Total_Millones DESC;
GO

-- ============================================
-- PREGUNTA 9: Eficiencia Financiera de Clubes
-- ============================================
-- Objetivo: Evaluar qué clubes son más eficientes financieramente.

SELECT TOP 10
    t.to_club AS Club,
    COUNT(t.transfer_id) AS Compras,
    ROUND(SUM(t.transfer_fee_eur_m), 2) AS Gasto_Transferencias_Millones,
    ROUND(AVG(f.revenue_eur_m), 2) AS Ingresos_Promedio_Millones,
    ROUND(AVG(f.wages_to_revenue_pct), 2) AS Pct_Salarios_Ingresos,
    ROUND(AVG(f.operating_profit_eur_m), 2) AS Beneficio_Promedio_Millones,
    ROUND((SUM(t.transfer_fee_eur_m) / NULLIF(AVG(f.revenue_eur_m), 0)) * 100, 2) AS Pct_Inversion_Ingresos,
    CASE 
        WHEN AVG(f.wages_to_revenue_pct) < 50 THEN 'Excelente'
        WHEN AVG(f.wages_to_revenue_pct) < 70 THEN 'Bueno'
        ELSE 'Riesgo'
    END AS Estado_Financiero
FROM vw_master_data t
INNER JOIN vw_club_financials f ON t.to_club = f.club_name AND t.year = f.year
WHERE t.transfer_fee_eur_m > 0 AND f.revenue_eur_m > 0
GROUP BY t.to_club
HAVING COUNT(t.transfer_id) >= 3
ORDER BY Pct_Inversion_Ingresos ASC;
GO

-- ============================================
-- PREGUNTA 10: Impacto de Jugadores en su Pico de Valor
-- ============================================
-- Objetivo: Analizar si los jugadores en su pico de valor generan 
-- transferencias más caras.

SELECT 
    CASE 
        WHEN p.is_peak_year = 1 THEN 'En Pico de Valor'
        ELSE 'No en Pico de Valor'
    END AS Estado_Valor,
    COUNT(t.transfer_id) AS Transferencias,
    ROUND(SUM(t.transfer_fee_eur_m), 2) AS Gasto_Total_Millones,
    ROUND(AVG(t.transfer_fee_eur_m), 2) AS Gasto_Promedio_Millones,
    ROUND(AVG(p.market_value_eur_m), 2) AS Valor_Mercado_Promedio_Millones,
    ROUND(AVG(t.age), 1) AS Edad_Promedio,
    SUM(CASE WHEN t.is_free_transfer = 1 THEN 1 ELSE 0 END) AS Libres,
    SUM(CASE WHEN t.is_loan = 1 THEN 1 ELSE 0 END) AS Cesiones
FROM vw_master_data t
INNER JOIN vw_player_market_values p ON t.player_name = p.player_name AND t.year = p.year
WHERE t.transfer_fee_eur_m > 0 AND p.market_value_eur_m > 0
GROUP BY p.is_peak_year;
GO

-- ============================================
-- PREGUNTA EXTRA: Top 10 Transferencias por Año
-- ============================================
-- Objetivo: Mostrar las 10 transferencias más caras de cada año.

WITH TransferenciasRanked AS (
    SELECT 
        transfer_id,
        year,
        player_name,
        from_club,
        to_club,
        transfer_fee_eur_m,
        season,
        CASE 
            WHEN is_free_transfer = 1 THEN 'Libre'
            WHEN is_loan = 1 THEN 'Cesión'
            ELSE 'Compra'
        END AS Tipo_Operacion,
        ROW_NUMBER() OVER (PARTITION BY year ORDER BY transfer_fee_eur_m DESC) AS Ranking
    FROM vw_master_data
    WHERE transfer_fee_eur_m > 0 AND year IS NOT NULL
)
SELECT 
    year,
    Ranking,
    transfer_id,
    player_name,
    from_club,
    to_club,
    ROUND(transfer_fee_eur_m, 2) AS Monto_Millones_EUR,
    season,
    Tipo_Operacion
FROM TransferenciasRanked
WHERE Ranking <= 10
ORDER BY year DESC, Ranking ASC;
GO

PRINT '=== TODAS LAS CONSULTAS EJECUTADAS EXITOSAMENTE ===';