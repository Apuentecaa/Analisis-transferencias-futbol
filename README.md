

# Análisis de Transferencias de Fútbol 2010-2026

## Descripción del Proyecto
Proyecto de análisis de datos del mercado de transferencias de fútbol utilizando **SQL Server**. El objetivo es explorar la relación entre el poder financiero de los clubes y su rendimiento deportivo, identificando patrones de inversión y eficiencia.


### Top 5 Hallazgos

1. **Transferencia más cara:** €200M (múltiples en 2013, principalmente a clubes saudíes)
2. **Club que más gasta (% ingresos):** Al-Nassr (6,270% de sus ingresos)
3. **Club que más ingresa por ventas:** Manchester City (€9,667.20M)
4. **Jugador más valioso:** Ivan Lee (€696.50M en 6 transferencias)
5. **Liga que más gasta:** Premier League (€114,567.70M)

### Insights Clave

| # | Insight | Dato Clave |
|---|---------|------------|
| 1 | **Mercado en Crecimiento** | Gasto total de €348,673.50M en 16 años |
| 2 | **Dominio de la Premier League** | Lidera en gasto (€114,567.70M) y asistencia (36,507) |
| 3 | **Inversión Saudí Agresiva** | Clubes como Al-Nassr invierten 60x sus ingresos |
| 4 | **Internacionalización del Mercado** | 88.8% de las transferencias son internacionales |
| 5 | **Edad Óptima** | Jugadores de 26-29 años tienen el mayor valor promedio (€28.15M) |
| 6 | **Jugadores Más Valiosos** | Ivan Lee lidera con €696.50M en 6 fichajes |
| 7 | **Eficiencia Financiera** | Clubes europeos mantienen mejor balance que clubes saudíes |

## Estructura del Proyecto

ANALISIS TRANSFERENCIAS FUTBOL/
├── .gitignore
├── README.md
├── data/
│ ├── raw/ git Datos CSV de Kaggle
│ └── processed/ Datos procesados
├── docs/
│ └── diagrams/ Diagrama ER y documentación
└── sql/
├── scripts/ Creación de tablas y carga
├── queries/ 10 preguntas de análisis
└── results/ Resultados de las queries


## Cómo Ejecutar
1. Crear la base de datos en SQL Server
2. Ejecutar `sql/scripts/01_create_tables.sql`
3. Ejecutar `sql/scripts/02_load_data.sql`
4. Ejecutar `sql/queries/01_preguntas_analisis.sql`
5. Revisar resultados en `sql/results/`

## Tecnologías Usadas
- **SQL Server** - Base de datos relacional
- **SSMS** - SQL Server Management Studio
- **Git & GitHub** - Control de versiones


## Carga de Datos

### Método Utilizado
Los datos fueron importados utilizando el **SQL Server Import and Export Wizard** (Wizard de Importación y Exportación de SQL Server).


## Descripción de las Columnas

### transfers_history (14,990 registros)
- `transfer_id`: ID único de la transferencia
- `year`: Año de la transferencia
- `date`: Fecha exacta
- `season`: Temporada (ej: 2012-2013)
- `transfer_window`: Verano (summer) o Invierno (winter)
- `player_name`: Nombre del jugador
- `position`: Posición (FW, CM, GK, etc.)
- `age`: Edad en años
- `from_club`: Club vendedor
- `from_league`: Liga del club vendedor
- `from_country`: País del club vendedor
- `to_club`: Club comprador
- `to_league`: Liga del club comprador
- `to_country`: País del club comprador
- `fee_eur_m`: Monto en millones de euros
- `is_free_transfer`: 1=Libre, 0=Pagada
- `is_loan`: 1=Cesión, 0=Compra
- `is_intra_league`: 1=Misma liga
- `is_intra_country`: 1=Mismo país

### club_financials (884 registros)
- `year`: Año fiscal
- `club_name`: Nombre del club
- `league`: Liga a la que pertenece
- `country`: País del club
- `stadium_capacity`: Capacidad del estadio
- `revenue_eur_m`: Ingresos totales (millones €)
- `wage_bill_eur_m`: Gasto en salarios (millones €)
- `wages_to_revenue_pct`: % gasto salarios vs ingresos
- `net_transfer_spend_eur_m`: Balance en transferencias
- `operating_profit_eur_m`: Beneficio operativo

### league_metrics (170 registros)
- `year`: Año
- `league`: Nombre de la liga
- `country`: País
- `num_teams`: Número de equipos
- `total_revenue_eur_m`: Ingresos totales (millones €)
- `avg_attendance`: Asistencia promedio
- `avg_ticket_eur`: Precio promedio de entrada
- `foreign_players_pct`: % de jugadores extranjeros

## Vistas de la Base de Datos

| Vista | Registros | Propósito |
|-------|-----------|-----------|
| `vw_transfers_history` | 14,990 | Análisis de transferencias |
| `vw_player_market_values` | 1,025 | Valor de mercado de jugadores |
| `vw_club_financials` | 884 | Finanzas de clubes |
| `vw_league_metrics` | 170 | Métricas de ligas |
| `vw_record_transfers` | 57 | Récords de transferencias |

**Total:** 17,126 registros analizados