


-- ============================================
-- Crear VISTA con datos convertidos
-- ============================================
CREATE VIEW vw_transfers_history AS
SELECT 
    transfer_id,  -- Lo dejamos como texto (T000001, T000002, etc.)
    TRY_CAST(year AS INT) AS year,
    TRY_CAST(date AS DATE) AS date,
    season,
    transfer_window,
    player_name,
    position,
    TRY_CAST(age AS INT) AS age,
    from_club,
    from_league,
    from_country,
    to_club,
    to_league,
    to_country,
    TRY_CAST(fee_eur_m AS DECIMAL(10,2)) AS fee_eur_m,
    CASE 
        WHEN LOWER(is_free_transfer) IN ('true', '1', 'yes', 'sí', 'si') THEN 1 
        ELSE 0 
    END AS is_free_transfer,
    CASE 
        WHEN LOWER(is_loan) IN ('true', '1', 'yes', 'sí', 'si') THEN 1 
        ELSE 0 
    END AS is_loan,
    CASE 
        WHEN LOWER(is_intra_league) IN ('true', '1', 'yes', 'sí', 'si') THEN 1 
        ELSE 0 
    END AS is_intra_league,
    CASE 
        WHEN LOWER(is_intra_country) IN ('true', '1', 'yes', 'sí', 'si') THEN 1 
        ELSE 0 
    END AS is_intra_country
FROM transfers_history;



--VISTA DE vw_club_financials

CREATE VIEW vw_club_financials AS
SELECT 
    TRY_CAST(year AS INT) AS year,
    club_name,
    league,
    country,
    TRY_CAST(stadium_capacity AS INT) AS stadium_capacity,
    TRY_CAST(revenue_eur_m AS DECIMAL(15,2)) AS revenue_eur_m,
    TRY_CAST(wage_bill_eur_m AS DECIMAL(15,2)) AS wage_bill_eur_m,
    TRY_CAST(wages_to_revenue_pct AS DECIMAL(5,2)) AS wages_to_revenue_pct,
    TRY_CAST(net_transfer_spend_eur_m AS DECIMAL(15,2)) AS net_transfer_spend_eur_m,
    TRY_CAST(operating_profit_eur_m AS DECIMAL(15,2)) AS operating_profit_eur_m
FROM club_financials;
GO


--Vista de vw_league_metrics

CREATE VIEW vw_league_metrics AS
SELECT 
    TRY_CAST(year AS INT) AS year,
    league,
    country,
    TRY_CAST(num_teams AS INT) AS num_teams,
    TRY_CAST(total_revenue_eur_m AS DECIMAL(15,2)) AS total_revenue_eur_m,
    TRY_CAST(avg_attendance AS INT) AS avg_attendance,
    TRY_CAST(avg_ticket_eur AS DECIMAL(10,2)) AS avg_ticket_eur,
    TRY_CAST(foreign_players_pct AS DECIMAL(5,2)) AS foreign_players_pct
FROM league_metrics;
GO




-- ============================================
-- VISTA: vw_record_transfers
-- ============================================
DROP VIEW IF EXISTS vw_record_transfers;
GO

CREATE VIEW vw_record_transfers AS
SELECT 
    transfer_id,
    TRY_CAST(date AS DATE) AS date,
    TRY_CAST(year AS INT) AS year,
    season,
    player_name,
    position,
    TRY_CAST(age_at_transfer AS INT) AS age_at_transfer,
    from_club,
    to_club,
    TRY_CAST(fee_eur_m AS DECIMAL(10,2)) AS fee_eur_m,
    CASE 
        WHEN LOWER(is_free_transfer) IN ('true', '1', 'yes', 'sí', 'si') THEN 1 
        ELSE 0 
    END AS is_free_transfer,
    CASE 
        WHEN LOWER(is_loan) IN ('true', '1', 'yes', 'sí', 'si') THEN 1 
        ELSE 0 
    END AS is_loan,
    CASE 
        WHEN LOWER(is_extension) IN ('true', '1', 'yes', 'sí', 'si') THEN 1 
        ELSE 0 
    END AS is_extension
FROM record_transfers;
GO


 --============================================
-- VISTA: vw_player_market_values
-- ============================================
DROP VIEW IF EXISTS vw_player_market_values;
GO

CREATE VIEW vw_player_market_values AS
SELECT 
    TRY_CAST(year AS INT) AS year,
    player_name,
    TRY_CAST(age AS INT) AS age,
    position,
    TRY_CAST(market_value_eur_m AS DECIMAL(10,2)) AS market_value_eur_m,
    CASE 
        WHEN LOWER(is_peak_year) IN ('true', '1', 'yes', 'sí', 'si') THEN 1 
        ELSE 0 
    END AS is_peak_year
FROM player_market_values;
GO



DROP VIEW IF EXISTS vw_master_data;
GO



-- vista uniendo todas las tablas

CREATE VIEW vw_master_data AS
SELECT 
    -- Datos de transfers_history
    t.transfer_id,
    t.year,
    t.date,
    t.season,
    t.transfer_window,
    t.player_name,
    t.position,
    t.age,
    t.from_club,
    t.from_league,
    t.from_country,
    t.to_club,
    t.to_league,
    t.to_country,
    t.fee_eur_m AS transfer_fee_eur_m,
    t.is_free_transfer,
    t.is_loan,
    t.is_intra_league,
    t.is_intra_country,
    
    -- Datos de club_financials (club comprador)
    f.revenue_eur_m AS club_revenue_eur_m,
    f.wage_bill_eur_m AS club_wage_bill_eur_m,
    f.wages_to_revenue_pct AS club_wages_to_revenue_pct,
    f.net_transfer_spend_eur_m AS club_net_transfer_spend_eur_m,
    f.operating_profit_eur_m AS club_operating_profit_eur_m,
    f.stadium_capacity AS club_stadium_capacity,
    
    -- Datos de league_metrics (liga del club comprador)
    l.total_revenue_eur_m AS league_total_revenue_eur_m,
    l.avg_attendance AS league_avg_attendance,
    l.avg_ticket_eur AS league_avg_ticket_eur,
    l.foreign_players_pct AS league_foreign_players_pct,
    l.num_teams AS league_num_teams,
    
    -- Datos de player_market_values
    p.market_value_eur_m AS player_market_value_eur_m,
    p.is_peak_year AS player_is_peak_year

FROM vw_transfers_history t

LEFT JOIN vw_club_financials f 
    ON t.to_club = f.club_name 
    AND t.year = f.year

LEFT JOIN vw_league_metrics l 
    ON t.to_league = l.league 
    AND t.year = l.year

LEFT JOIN vw_player_market_values p 
    ON t.player_name = p.player_name 
    AND t.year = p.year;
GO




-- ============================================
-- VERIFICAR TODAS LAS VISTAS
-- ============================================
SELECT 'vw_transfers_history' AS Vista, COUNT(*) AS Registros FROM vw_transfers_history
UNION ALL
SELECT 'vw_club_financials', COUNT(*) FROM vw_club_financials
UNION ALL
SELECT 'vw_league_metrics', COUNT(*) FROM vw_league_metrics
UNION ALL
SELECT 'vw_player_market_values', COUNT(*) FROM vw_player_market_values
UNION ALL
SELECT 'vw_record_transfers', COUNT(*) FROM vw_record_transfers
ORDER BY Registros DESC;