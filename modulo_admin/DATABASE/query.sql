select * from USUARIOS;
SELECT id_usuario, pri_nombre, seg_nombre, pri_apellido, seg_apellido, usuario, correo, telefono, fk_rol, estado, reestablecer FROM USUARIOS WHERE id_usuario = 3
-- Registrar Usuario
DECLARE @Resultado INT
DECLARE @Mensaje VARCHAR(255)

EXEC usp_RegistrarUsuario
    @PriNombre = 'Juan',
    @SegNombre = 'Carlos',
    @PriApellido = 'Pérez',
    @SegApellido = 'Gómez',
    @Usuario = 'juanperez',
    @Clave = '12345',
    @Correo = 'juan.perez@example.com',
    @Telefono = 12345677,
    @FkRol = 1,
    @Estado = 1,
    @Resultado = @Resultado OUTPUT,
    @Mensaje = @Mensaje OUTPUT

SELECT @Resultado AS Resultado, @Mensaje AS Mensaje

-- Editar Usuario
DECLARE @Resultado INT
DECLARE @Mensaje VARCHAR(255)

EXEC usp_ModificarUsuario
    @IdUsuario = 3, -- Asegúrate de usar un ID válido
    @PriNombre = 'Ana',
    @SegNombre = 'María',
    @PriApellido = 'López',
    @SegApellido = 'García',
    @Usuario = 'ana.lopez',
    @Clave = 'nueva_clave',
    @Correo = 'ana.lopez@example.com',
    @Telefono = 12345676,
    @FkRol = 2,
    @Estado = 1, -- Activo (1) o Inactivo (0)
    @Resultado = @Resultado OUTPUT,
    @Mensaje = @Mensaje OUTPUT

SELECT @Resultado AS Resultado, @Mensaje AS Mensaje
SELECT * FROM USUARIOS WHERE id_usuario = 3

-- Elimanar usuario
DECLARE @Resultado BIT

EXEC usp_EliminarUsuario
    @IdUsuario = 6,
    @Resultado = @Resultado OUTPUT

SELECT @Resultado AS Resultado

---Usuario login
DECLARE @IdUsuario INT
DECLARE @Mensaje VARCHAR(255)


EXEC usp_LoginUsuario
    @Usuario = 'admin',
    @Clave = 'admin',
    @IdUsuario = @IdUsuario OUTPUT,
    @Mensaje = @Mensaje OUTPUT

PRINT 'ID Usuario: ' + CAST(@IdUsuario AS VARCHAR)
PRINT 'Mensaje: ' + @Mensaje
GO

DECLARE @Resultado INT, @Mensaje VARCHAR(255)
EXEC usp_ModificarContrasena 
    @IdUsuario = 3, 
    @ClaveActual = 'nueva_clave', 
    @ClaveNueva = '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918',
    @Resultado = @Resultado OUTPUT, 
    @Mensaje = @Mensaje OUTPUT

SELECT @Resultado AS Resultado, @Mensaje AS Mensaje


-- Vista de Matrices de Integración
SELECT 
    mic.id_matriz_integracion,
    mic.codigo_documento,
    mic.nombre_matriz_integracion_componente,
    mic.competencias,
    mic.objetivo_anio,
    mic.objetivo_semestre,
    mic.objetivo_integrador,
    mic.accion_integradora,
    mic.tipo_evaluacion,
    mic.fecha_registro,
    
    -- Datos del profesor
    u.id_usuario AS profesor_id,
    u.pri_nombre + ' ' + ISNULL(u.seg_nombre + ' ', '') + 
    u.pri_apellido + ' ' + ISNULL(u.seg_apellido, '') AS profesor_nombre_completo,
    u.usuario AS profesor_usuario,
    u.correo AS profesor_email,
    
    -- Lista de asignaturas integradas (como cadena concatenada)
    STUFF((
        SELECT ', ' + a.nombre 
        FROM MatrizAsignatura ma
        JOIN Asignatura a ON ma.fk_asignatura = a.id_asignatura
        WHERE ma.fk_matriz_integracion = mic.id_matriz_integracion
        FOR XML PATH('')
    ), 1, 2, '') AS asignaturas_integradas,
    
    -- Detalle de cada asignatura (como subconsulta)
    (
        SELECT 
            a.id_asignatura,
            a.nombre,
            ma.descripcion
        FROM 
            MatrizAsignatura ma
        JOIN 
            Asignatura a ON ma.fk_asignatura = a.id_asignatura
        WHERE 
            ma.fk_matriz_integracion = mic.id_matriz_integracion
        FOR JSON PATH
    ) AS detalle_asignaturas_json

FROM 
    MatrizIntegracionComponentes mic
JOIN 
    Usuarios u ON mic.fk_profesor = u.id_usuario
ORDER BY 
    mic.fecha_registro DESC;

-- Vista de Planes Semestrales
SELECT 
    pds.id_plan_didactico_semestral,
    pds.codigo_documento,
    pds.nombre_plan_didactico_semestral,
    pds.fecha_inicio,
    pds.fecha_fin,
    pds.eje_disiplinar,
    pds.curriculum,
    pds.competencias,
    pds.objetivo_integrador,
    pds.eje_transversal,
    pds.bibliografia,
    pds.fecha_registro,
    
    -- Datos de MatrizIntegracionComponentes
    mic.nombre_matriz_integracion_componente AS matriz_integracion,
    
    -- Datos de Asignatura
    a.nombre AS asignatura,
    
    -- Datos de ComponenteCurricular (con joins a las tablas relacionadas)
    cc.id_componente_curricular,
    asignatura_cc.nombre AS asignatura_componente,
    car.nombre AS carrera,
    dep.nombre AS departamento,
    area.nombre AS area_conocimiento,
    
    -- Datos de Periodo (año y semestre)
    per.anio,
    sem.descripcion AS semestre,
    
    -- Datos del Profesor
    u.pri_nombre + ' ' + ISNULL(u.seg_nombre + ' ', '') + u.pri_apellido + ' ' + ISNULL(u.seg_apellido, '') AS profesor

FROM 
    PlanDidacticoSemestral pds
JOIN 
    MatrizIntegracionComponentes mic ON pds.fk_matriz_integracion = mic.id_matriz_integracion
JOIN 
    Usuarios u ON pds.fk_profesor = u.id_usuario
JOIN 
    Asignatura a ON pds.fk_asignatura = a.id_asignatura
JOIN 
    ComponenteCurricular cc ON pds.fk_componente_curricular = cc.id_componente_curricular
JOIN 
    Asignatura asignatura_cc ON cc.fk_asignatura = asignatura_cc.id_asignatura
JOIN 
    Carrera car ON cc.fk_carrera = car.id_carrera
JOIN 
    Departamento dep ON cc.fk_departamento = dep.id_departamento
JOIN 
    AreaConocimiento area ON cc.fk_area = area.id_area
JOIN 
    Periodo per ON pds.fk_anio_semestre = per.id_periodo
JOIN 
    Semestre sem ON per.fk_semestre = sem.id_semestre;

GO

-- Consultas para verificar los registros de la tabla CARPETA
SELECT TOP 10 nombre, fecha_registro
FROM CARPETA 
WHERE fk_id_usuario = 2
ORDER BY fecha_registro DESC

-- Consultas para verificar los registros de la tabla ARCHIVO
SELECT TOP 10 
    A.nombre AS nombre_archivo,
    A.tipo,
    A.fecha_subida,
    C.nombre AS nombre_carpeta
FROM 
    ARCHIVO A
INNER JOIN 
    CARPETA C ON A.fk_id_carpeta = C.id_carpeta
WHERE 
    A.fk_id_carpeta = 1
ORDER BY 
    A.fecha_subida DESC;

-- Consultas para verificar los registros de la tabla DETALLEARCHIVO
-- Detalles con información de archivo y carpeta
SELECT 
    D.id_detalle_archivo,
    D.correo,
    U.pri_nombre AS nombre_usuario,
    A.nombre AS nombre_archivo,
    A.tipo AS tipo_archivo,
    C.nombre AS nombre_carpeta,
    D.fecha_subida
FROM 
    DETALLEARCHIVO D
INNER JOIN ARCHIVO A ON D.fk_id_archivo = A.id_archivo
INNER JOIN CARPETA C ON D.fk_id_carpeta = C.id_carpeta
INNER JOIN USUARIOS U ON D.fk_id_usuario = U.id_usuario;

-- Archivos compartidos por correo electrónico
SELECT 
    D.correo,
    COUNT(D.id_detalle_archivo) AS total_archivos_compartidos
FROM 
    DETALLEARCHIVO D
GROUP BY 
    D.correo
ORDER BY 
    total_archivos_compartidos DESC;

-- Detalles de archivos en una carpeta específica
SELECT 
    D.id_detalle_archivo,
    D.correo,
    A.nombre AS nombre_archivo,
    D.fecha_subida
FROM 
    DETALLEARCHIVO D
INNER JOIN ARCHIVO A ON D.fk_id_archivo = A.id_archivo
WHERE 
    D.fk_id_carpeta = 2;

-- Archivos compartidos por un usuario específico
SELECT 
    D.correo,
    A.nombre AS nombre_archivo,
    C.nombre AS nombre_carpeta,
    D.fecha_subida
FROM 
    DETALLEARCHIVO D
INNER JOIN ARCHIVO A ON D.fk_id_archivo = A.id_archivo
INNER JOIN CARPETA C ON D.fk_id_carpeta = C.id_carpeta
WHERE 
    D.fk_id_usuario = 1;

-- Últimos 10 archivos compartidos
SELECT TOP 10
    D.correo,
    A.nombre AS nombre_archivo,
    C.nombre AS nombre_carpeta,
    D.fecha_subida
FROM 
    DETALLEARCHIVO D
INNER JOIN ARCHIVO A ON D.fk_id_archivo = A.id_archivo
INNER JOIN CARPETA C ON D.fk_id_carpeta = C.id_carpeta
ORDER BY 
    D.fecha_subida DESC;


EXEC sp_sproc_columns 
    @procedure_name = 'usp_ModificarUsuario',
    @procedure_owner = 'dbo'; -- Esquema por defecto