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

DecLARE @IdUsuario INT
EXEC usp_ObtenerPermisos
    @IdUsuario = 3
    SELECT @Resultado AS Resultado, @Mensaje AS Mensaje

DECLARE @Resultado INT, @Mensaje VARCHAR(255)
EXEC usp_ModificarContrasena 
    @IdUsuario = 3, 
    @ClaveActual = 'nueva_clave', 
    @ClaveNueva = '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918',
    @Resultado = @Resultado OUTPUT, 
    @Mensaje = @Mensaje OUTPUT

SELECT @Resultado AS Resultado, @Mensaje AS Mensaje

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


EXEC usp_ObtenerPermisosPorUsuario @IdUsuario = 2

EXEC usp_VerificarPermiso 
    @id_usuario = 2, 
    @controlador = 'Archivo', 
    @vista = 'ListarCarpetas'

SELECT p.id_permisos, 
       r.descripcion AS Rol,
       m.nombre AS Menu,
       CONCAT(m.vista, ' || ', m.controlador) AS Controlador,
       p.estado
FROM PERMISOS p 
    INNER JOIN ROL r ON p.fk_rol = r.id_rol
    INNER JOIN MENU m ON p.fk_menu = m.id_menu
    WHERE p.fk_rol = 1


insert into permisos (fk_rol, fk_menu)
values (2, 1)

-- Obtener menú para usuario ID 1 (solo mostrará vistas)
EXEC usp_ObtenerMenuPorUsuario @IdUsuario = 2;
EXEC usp_ObtenerPermisosPorRol @IdRol = 3;



-- Verificar permiso para Usuario/Listar
EXEC usp_VerificarPermiso 
    @IdUsuario = 1, 
    @Controlador = 'Home',
    @Accion = 'ListarUsuarios'

-- PROCEDIMIENTO PARA ASIGNAR PERMISO
EXEC usp_AsignarPermiso
    @IdRol = 3,
    @IdControlador = 9,
    @Estado = 1;

select * from CONTROLLER

-- PROCEDIMIENTO PARA OBTENER PERMISOS NO ASIGNADOS
EXEC usp_ObtenerPermisosNoAsignados
    @IdRol = 3;

    select * from USUARIOS