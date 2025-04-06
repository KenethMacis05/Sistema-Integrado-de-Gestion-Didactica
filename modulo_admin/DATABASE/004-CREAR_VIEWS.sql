IF EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_PlanesClasesDiarios]'))
DROP VIEW [dbo].[vw_PlanesClasesDiarios]
GO

IF EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_PlanesDidacticosSemestrales]'))
DROP VIEW [dbo].[vw_PlanesDidacticosSemestrales]
GO

IF EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_PlanesSemestralesConTemas]'))
DROP VIEW [dbo].[vw_PlanesSemestralesConTemas]
GO

CREATE VIEW [dbo].[vw_PlanesClasesDiarios]
WITH SCHEMABINDING
AS
SELECT 
    pcd.id_plan_diario,
    pcd.codigo_documento,
    pcd.nombre_plan_clases_diario,
    pcd.ejes,
    pcd.competencias,
    pcd.BOA,
    CONVERT(VARCHAR(10), pcd.fecha_inicio, 103) AS fecha_inicio,
    CONVERT(VARCHAR(10), pcd.fecha_fin, 103) AS fecha_fin,
    pcd.objetivo_aprendizaje,
    pcd.tema_contenido,
    pcd.indicador_logro,
    pcd.tareas_iniciales,
    pcd.tareas_desarrollo,
    pcd.tareas_sintesis,
    pcd.tipo_evaluacion,
    pcd.estrategia_evaluacion,
    pcd.instrumento_evaluacion,
    pcd.evidencias_aprendizaje,
    pcd.criterios_aprendizaje,
    pcd.indicadores_aprendizaje,
    pcd.nivel_aprendizaje,
    CONVERT(VARCHAR(10), pcd.fecha_registro, 103) + ' ' + CONVERT(VARCHAR(8), pcd.fecha_registro, 108) AS fecha_registro_completa,
    pds.nombre_plan_didactico_semestral,
    a.nombre AS nombre_asignatura,
    RTRIM(LTRIM(
        CONCAT(
            u.pri_nombre, 
            CASE WHEN NULLIF(u.seg_nombre, '') IS NOT NULL THEN ' ' + u.seg_nombre ELSE '' END,
            ' ',
            u.pri_apellido,
            CASE WHEN NULLIF(u.seg_apellido, '') IS NOT NULL THEN ' ' + u.seg_apellido ELSE '' END
        )
    )) AS nombre_profesor,
    s.descripcion AS descripcion_semestre,
    pe.anio,
    cc.id_componente_curricular,
    car.nombre AS nombre_carrera,
    dep.nombre AS nombre_departamento,
    ac.nombre AS nombre_area_conocimiento,
    DATEDIFF(DAY, pcd.fecha_inicio, pcd.fecha_fin) + 1 AS dias_duracion
FROM 
    dbo.PlanClasesDiario pcd
INNER JOIN 
    dbo.PlanDidacticoSemestral pds ON pcd.fk_plan_didactico_semestral = pds.id_plan_didactico_semestral
INNER JOIN 
    dbo.Asignatura a ON pcd.fk_asignatura = a.id_asignatura
INNER JOIN 
    dbo.Usuarios u ON pcd.fk_profesor = u.id_usuario
INNER JOIN 
    dbo.Periodo pe ON pcd.fk_periodo = pe.id_periodo
INNER JOIN
    dbo.Semestre s ON pe.fk_semestre = s.id_semestre
LEFT JOIN
    dbo.ComponenteCurricular cc ON pcd.fk_componente_curricular = cc.id_componente_curricular
LEFT JOIN
    dbo.Carrera car ON cc.fk_carrera = car.id_carrera
LEFT JOIN
    dbo.Departamento dep ON cc.fk_departamento = dep.id_departamento
LEFT JOIN
    dbo.AreaConocimiento ac ON cc.fk_area = ac.id_area;
GO

-- Crear índice para mejorar rendimiento (opcional si la vista se usa frecuentemente)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_PlanesDiarios_ID')
CREATE UNIQUE CLUSTERED INDEX IX_PlanesDiarios_ID ON [dbo].[vw_PlanesClasesDiarios] (id_plan_diario);
GO

-- Consultar todos los planes diarios
SELECT * FROM vw_PlanesClasesDiarios;

-- Filtrar por año
SELECT * FROM vw_PlanesClasesDiarios 
WHERE anio = '2025';

-- Filtrar por profesor
SELECT * FROM vw_PlanesClasesDiarios
WHERE nombre_profesor LIKE '%González%';

-- Filtrar por asignatura
SELECT * FROM vw_PlanesClasesDiarios
WHERE nombre_asignatura = 'Matemáticas';

-- Filtrar por rango de fechas
SELECT * FROM vw_PlanesClasesDiarios
WHERE fecha_inicio BETWEEN '01/03/2023' AND '31/03/2023';

-- Ordenar por fecha de inicio (más recientes primero)
SELECT * FROM vw_PlanesClasesDiarios
ORDER BY CONVERT(DATE, fecha_inicio, 103) DESC;

-- Ordenar por profesor y luego por asignatura
SELECT * FROM vw_PlanesClasesDiarios
ORDER BY nombre_profesor, nombre_asignatura;

-- Contar planes por profesor
SELECT 
    nombre_profesor,
    COUNT(*) AS total_planes
FROM vw_PlanesClasesDiarios
GROUP BY nombre_profesor
ORDER BY total_planes DESC;

-- Resumen por asignatura
SELECT 
    nombre_asignatura,
    MIN(fecha_inicio) AS primera_fecha,
    MAX(fecha_fin) AS ultima_fecha,
    COUNT(*) AS cantidad_planes
FROM vw_PlanesClasesDiarios
GROUP BY nombre_asignatura;

-- Buscar planes con duración mayor a 7 días
SELECT * FROM vw_PlanesClasesDiarios
WHERE dias_duracion > 7;

-- Buscar planes que incluyan cierta competencia
SELECT * FROM vw_PlanesClasesDiarios
WHERE competencias LIKE '%pensamiento crítico%';

-- Unir con otras tablas/vistas
SELECT 
    p.*,
    m.nombre_matriz_integracion_componente
FROM 
    vw_PlanesClasesDiarios p
JOIN 
    MatrizIntegracionComponentes m ON p.id_plan_diario = m.id_matriz_integracion;

GO

----------------------------------------------------------------------------------------------------------------------------

-- Crear vista para Planes Didácticos Semestrales
CREATE VIEW [dbo].[vw_PlanesDidacticosSemestrales]
WITH SCHEMABINDING
AS
SELECT 
    pds.id_plan_didactico_semestral,
    pds.codigo_documento,
    pds.nombre_plan_didactico_semestral,
    CONVERT(VARCHAR(10), pds.fecha_inicio, 103) AS fecha_inicio,
    CONVERT(VARCHAR(10), pds.fecha_fin, 103) AS fecha_fin,
    pds.eje_disiplinar,
    pds.curriculum,
    pds.competencias,
    pds.objetivo_integrador,
    pds.eje_transversal,
    pds.bibliografia,
    CONVERT(VARCHAR(10), pds.fecha_registro, 103) + ' ' + CONVERT(VARCHAR(8), pds.fecha_registro, 108) AS fecha_registro_completa,
    
    -- Datos de MatrizIntegracionComponentes
    mic.nombre_matriz_integracion_componente AS matriz_integracion,
    
    -- Datos de Asignatura
    a.nombre AS asignatura,
    
    -- Datos de ComponenteCurricular
    cc.id_componente_curricular,
    asignatura_cc.nombre AS asignatura_componente,
    car.nombre AS carrera,
    dep.nombre AS departamento,
    area.nombre AS area_conocimiento,
    
    -- Datos de Periodo
    per.anio,
    sem.descripcion AS semestre,
    CONCAT(per.anio, ' - ', sem.descripcion) AS periodo_completo,
    
    -- Datos del Profesor
    RTRIM(LTRIM(
        CONCAT(
            u.pri_nombre, 
            CASE WHEN NULLIF(u.seg_nombre, '') IS NOT NULL THEN ' ' + u.seg_nombre ELSE '' END,
            ' ',
            u.pri_apellido,
            CASE WHEN NULLIF(u.seg_apellido, '') IS NOT NULL THEN ' ' + u.seg_apellido ELSE '' END
        )
    )) AS profesor,
    
    -- Campos calculados
    DATEDIFF(WEEK, pds.fecha_inicio, pds.fecha_fin) AS semanas_duracion,
    DATEDIFF(DAY, pds.fecha_inicio, pds.fecha_fin) + 1 AS dias_duracion,
    
    -- Información adicional de temas (agregado)
    (SELECT COUNT(*) FROM dbo.TemaPlanificacionSemestral t WHERE t.fk_plan_didactico_semestral = pds.id_plan_didactico_semestral) AS cantidad_temas,
    
    -- Información de competencias (agregado)
    (SELECT STRING_AGG(c.tipo + ': ' + c.descripcion, ' | ') 
     FROM dbo.Competencia c 
     WHERE c.fk_plan_didactico_semestral = pds.id_plan_didactico_semestral) AS lista_competencias

FROM 
    dbo.PlanDidacticoSemestral pds
INNER JOIN 
    dbo.MatrizIntegracionComponentes mic ON pds.fk_matriz_integracion = mic.id_matriz_integracion
INNER JOIN 
    dbo.Usuarios u ON pds.fk_profesor = u.id_usuario
INNER JOIN 
    dbo.Asignatura a ON pds.fk_asignatura = a.id_asignatura
INNER JOIN 
    dbo.ComponenteCurricular cc ON pds.fk_componente_curricular = cc.id_componente_curricular
INNER JOIN 
    dbo.Asignatura asignatura_cc ON cc.fk_asignatura = asignatura_cc.id_asignatura
INNER JOIN 
    dbo.Carrera car ON cc.fk_carrera = car.id_carrera
INNER JOIN 
    dbo.Departamento dep ON cc.fk_departamento = dep.id_departamento
INNER JOIN 
    dbo.AreaConocimiento area ON cc.fk_area = area.id_area
INNER JOIN 
    dbo.Periodo per ON pds.fk_anio_semestre = per.id_periodo
INNER JOIN 
    dbo.Semestre sem ON per.fk_semestre = sem.id_semestre;
GO

-- Crear índice para mejorar rendimiento
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_PlanesSemestrales_ID')
CREATE UNIQUE CLUSTERED INDEX IX_PlanesSemestrales_ID ON [dbo].[vw_PlanesDidacticosSemestrales] (id_plan_didactico_semestral);
GO

-- Consulta básica
SELECT * FROM vw_PlanesDidacticosSemestrales;

-- Planes por profesor
SELECT profesor, COUNT(*) AS total_planes
FROM vw_PlanesDidacticosSemestrales
GROUP BY profesor
ORDER BY total_planes DESC;

-- Planes por carrera y semestre
SELECT 
    carrera, 
    semestre, 
    anio, 
    COUNT(*) AS cantidad_planes,
    STRING_AGG(asignatura, ', ') AS asignaturas
FROM vw_PlanesDidacticosSemestrales
GROUP BY carrera, semestre, anio;

-- Buscar planes con más de 10 temas
SELECT * FROM vw_PlanesDidacticosSemestrales
WHERE cantidad_temas > 10;

GO
----------------------------------------------------------------------------------------------------------------------------

-- Crear vista para Planes Semestrales con Temas
CREATE VIEW [dbo].[vw_PlanesSemestralesConTemas]
AS
WITH TemasAgrupados AS (
    SELECT 
        fk_plan_didactico_semestral,
        COUNT(*) AS total_temas,
        SUM(horas_teoricas) AS total_horas_teoricas,
        SUM(horas_practicas) AS total_horas_practicas,
        SUM(horas_laboratorio) AS total_horas_laboratorio,
        SUM(horas_investigacion) AS total_horas_investigacion,
        SUM(creditos) AS total_creditos,
        STRING_AGG(tema, ' | ') AS lista_temas
    FROM 
        dbo.TemaPlanificacionSemestral
    GROUP BY 
        fk_plan_didactico_semestral
)
SELECT 
    pds.id_plan_didactico_semestral,
    pds.codigo_documento,
    pds.nombre_plan_didactico_semestral,
    CONVERT(VARCHAR(10), pds.fecha_inicio, 103) AS fecha_inicio,
    CONVERT(VARCHAR(10), pds.fecha_fin, 103) AS fecha_fin,
    pds.eje_disiplinar,
    pds.curriculum,
    pds.competencias,
    pds.objetivo_integrador,
    pds.eje_transversal,
    pds.bibliografia,
    CONVERT(VARCHAR(10), pds.fecha_registro, 103) + ' ' + CONVERT(VARCHAR(8), pds.fecha_registro, 108) AS fecha_registro_completa,
    
    -- Información de la matriz de integración
    mic.nombre_matriz_integracion_componente AS matriz_integracion,
    
    -- Información de asignatura
    a.nombre AS asignatura,
    
    -- Información del componente curricular
    cc.id_componente_curricular,
    car.nombre AS carrera,
    dep.nombre AS departamento,
    area.nombre AS area_conocimiento,
    
    -- Información del periodo académico
    per.anio,
    sem.descripcion AS semestre,
    CONCAT(per.anio, ' - ', sem.descripcion) AS periodo_completo,
    
    -- Información del profesor
    RTRIM(LTRIM(
        CONCAT(
            u.pri_nombre, 
            CASE WHEN NULLIF(u.seg_nombre, '') IS NOT NULL THEN ' ' + u.seg_nombre ELSE '' END,
            ' ',
            u.pri_apellido,
            CASE WHEN NULLIF(u.seg_apellido, '') IS NOT NULL THEN ' ' + u.seg_apellido ELSE '' END
        )
    )) AS profesor,
    
    -- Información de temas (desde la CTE)
    tg.total_temas,
    tg.lista_temas,
    tg.total_horas_teoricas,
    tg.total_horas_practicas,
    tg.total_horas_laboratorio,
    tg.total_horas_investigacion,
    tg.total_creditos,
    
    -- Información detallada de cada tema (en formato JSON)
    (SELECT 
        tema,
        horas_teoricas,
        horas_practicas,
        horas_laboratorio,
        horas_investigacion,
        creditos
     FROM 
        dbo.TemaPlanificacionSemestral t
     WHERE 
        t.fk_plan_didactico_semestral = pds.id_plan_didactico_semestral
     FOR JSON PATH) AS detalle_temas_json,
    
    -- Cálculos de duración
    DATEDIFF(WEEK, pds.fecha_inicio, pds.fecha_fin) AS semanas_duracion,
    DATEDIFF(DAY, pds.fecha_inicio, pds.fecha_fin) + 1 AS dias_duracion

FROM 
    dbo.PlanDidacticoSemestral pds
INNER JOIN 
    dbo.MatrizIntegracionComponentes mic ON pds.fk_matriz_integracion = mic.id_matriz_integracion
INNER JOIN 
    dbo.Usuarios u ON pds.fk_profesor = u.id_usuario
INNER JOIN 
    dbo.Asignatura a ON pds.fk_asignatura = a.id_asignatura
INNER JOIN 
    dbo.ComponenteCurricular cc ON pds.fk_componente_curricular = cc.id_componente_curricular
INNER JOIN 
    dbo.Carrera car ON cc.fk_carrera = car.id_carrera
INNER JOIN 
    dbo.Departamento dep ON cc.fk_departamento = dep.id_departamento
INNER JOIN 
    dbo.AreaConocimiento area ON cc.fk_area = area.id_area
INNER JOIN 
    dbo.Periodo per ON pds.fk_anio_semestre = per.id_periodo
INNER JOIN 
    dbo.Semestre sem ON per.fk_semestre = sem.id_semestre
LEFT JOIN 
    TemasAgrupados tg ON pds.id_plan_didactico_semestral = tg.fk_plan_didactico_semestral;
GO

-- 1. Ver todos los planes con sus temas
SELECT 
    id_plan_didactico_semestral,
    nombre_plan_didactico_semestral,
    asignatura,
    lista_temas,
    total_horas_teoricas,
    total_horas_practicas
FROM 
    vw_PlanesSemestralesConTemas;

-- 2. Buscar planes con más de 50 horas teóricas
SELECT * FROM vw_PlanesSemestralesConTemas
WHERE total_horas_teoricas > 50
ORDER BY total_horas_teoricas DESC;

-- 3. Obtener el detalle JSON de temas para un plan específico
SELECT 
    id_plan_didactico_semestral,
    nombre_plan_didactico_semestral,
    detalle_temas_json
FROM 
    vw_PlanesSemestralesConTemas
WHERE 
    id_plan_didactico_semestral = 1;

-- 4. Resumen por carrera
SELECT 
    carrera,
    COUNT(*) AS cantidad_planes,
    SUM(total_horas_teoricas) AS horas_teoricas_totales,
    SUM(total_creditos) AS creditos_totales
FROM 
    vw_PlanesSemestralesConTemas
GROUP BY 
    carrera
ORDER BY 
    cantidad_planes DESC;