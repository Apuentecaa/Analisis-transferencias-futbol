

# Análisis de Transferencias de Fútbol 2010-2026

## Descripción del Proyecto
Proyecto de análisis de datos del mercado de transferencias de fútbol utilizando **SQL Server**. El objetivo es explorar la relación entre el poder financiero de los clubes y su rendimiento deportivo, identificando patrones de inversión y eficiencia.

## Aplicación en el Sector Financiero
Este proyecto demuestra habilidades críticas para el sector financiero:
- **Análisis de inversión y retorno (ROI)** - Evaluación de gasto en fichajes vs rendimiento
- **Evaluación de riesgos financieros** - Análisis de deuda y sostenibilidad
- **Análisis de rentabilidad** - Relación ingresos/rendimiento
- **Modelado de datos relacionales** - Diseño de base de datos en SQL Server

## Estructura del Proyecto

ANALISIS TRANSFERENCIAS FUTBOL/
├── .gitignore
├── README.md
├── data/
│ ├── raw/ Datos CSV de Kaggle
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

## Autor
**Anthony**  
[![GitHub](https://img.shields.io/badge/GitHub-Apuentecaa-black?logo=github)](https://github.com/Apuentecaa)