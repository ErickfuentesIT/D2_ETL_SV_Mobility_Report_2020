CREATE DATABASE movilidad_sv;

USE movilidad_sv;

-- Tabla base con nombres alternativos
CREATE TABLE movilidad_cruda (
    id_registro INT IDENTITY(1,1) PRIMARY KEY,
    cod_pais VARCHAR(100),
    nombre_pais VARCHAR(100),
    region_principal VARCHAR(100),
    region_secundaria VARCHAR(100),
    zona_metro VARCHAR(100),
    codigo_iso VARCHAR(100),
    cod_censo VARCHAR(100),
    id_lugar VARCHAR(100),
    fecha_registro VARCHAR(100),
    variacion_recreacion_comercial VARCHAR(100),
    variacion_farmacias_super VARCHAR(100),
    variacion_parques VARCHAR(100),
    variacion_transporte VARCHAR(100),
    variacion_laboral VARCHAR(100),
    variacion_residencial VARCHAR(100)
);

-- Dimensión de fechas
SELECT DISTINCT 
    CONVERT(DATE, fecha_registro) AS fecha_completa,
    YEAR(fecha_registro) AS anio,
    MONTH(fecha_registro) AS mes,
    DAY(fecha_registro) AS dia,
    DATENAME(MONTH, fecha_registro) AS nombre_mes
INTO dim_tiempo
FROM movilidad_cruda;

-- Dimensión geográfica
SELECT DISTINCT 
    region_principal,
    region_secundaria
INTO dim_zona
FROM movilidad_cruda;

-- Agregar claves primarias con IDENTITY
ALTER TABLE dim_tiempo ADD id_tiempo INT IDENTITY(1,1) PRIMARY KEY;
ALTER TABLE dim_zona ADD id_zona INT IDENTITY(1,1) PRIMARY KEY;

-- Tabla de hechos con nombres alternativos
SELECT 
    t.id_tiempo,
    z.id_zona,
    CAST(m.variacion_recreacion_comercial AS FLOAT) AS recreacion,
    CAST(m.variacion_farmacias_super AS FLOAT) AS farmacias_super,
    CAST(m.variacion_parques AS FLOAT) AS parques,
    CAST(m.variacion_transporte AS FLOAT) AS transporte,
    CAST(m.variacion_laboral AS FLOAT) AS trabajo,
    CAST(m.variacion_residencial AS FLOAT) AS residencial
INTO hechos_movilidad_detalle
FROM movilidad_cruda m
JOIN dim_tiempo t ON CONVERT(DATE, m.fecha_registro) = t.fecha_completa
JOIN dim_zona z ON m.region_principal = z.region_principal AND m.region_secundaria = z.region_secundaria;

-- Borrado de tabla de hechos si se requiere reiniciar
DROP TABLE hechos_movilidad_detalle;

SELECT * FROM hechos_movilidad_detalle;

-- Permisos para el servicio de Analysis Services
USE sv_mobility_report;
CREATE USER [NT SERVICE\MSSQLServerOLAPService] FOR LOGIN [NT SERVICE\MSSQLServerOLAPService];
ALTER ROLE db_datareader ADD MEMBER [NT SERVICE\MSSQLServerOLAPService];
