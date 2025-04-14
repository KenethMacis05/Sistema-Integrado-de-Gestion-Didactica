-- Consultas para verificar los registros de la tabla CARPETA
SELECT TOP 10 *
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





-- Obtener menú para usuario ID 1
EXEC usp_LeerMenuPorUsuario @IdUsuario = 2;

-- Obtener permisos por ID ROl
EXEC usp_ObtenerPermisosPorRol @IdRol = 3;

-- Verificar permiso para Usuario/Listar
EXEC usp_VerificarPermiso 
    @IdUsuario = 1, 
    @Controlador = 'Home',
    @Accion = 'ListarUsuarios'

-- PROCEDIMIENTO PARA ASIGNAR PERMISO
EXEC usp_AsignarPermiso
    @IdRol = 3,
    @IdControlador = 10;    
select * from CONTROLLER where id_controlador = 10
-- PROCEDIMIENTO PARA OBTENER PERMISOS NO ASIGNADOS
EXEC usp_ObtenerPermisosNoAsignados @IdRol = 3;
EXEC usp_ObtenerPermisosNoAsignados @IdRol = 2;