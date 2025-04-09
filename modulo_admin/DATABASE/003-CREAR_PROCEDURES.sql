------------------------------------------------PROCEDIMIENTOS ALMACENADOS------------------------------------------------

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_LoginUsuario')
DROP PROCEDURE usp_LoginUsuario
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ObtenerDetalleUsuario')
DROP PROCEDURE usp_ObtenerDetalleUsuario
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ObtenerPermisos')
DROP PROCEDURE usp_ObtenerPermisos
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ActualizarPermisos')
DROP PROCEDURE usp_ActualizarPermisos
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ObtenerUsuario')
DROP PROCEDURE usp_ObtenerUsuario
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_RegistrarUsuario')
DROP PROCEDURE usp_RegistrarUsuario
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ModificarUsuario')
DROP PROCEDURE usp_ModificarUsuario
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ModificarContrasena')
DROP PROCEDURE usp_ModificarContrasena
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_EliminarUsuario')
DROP PROCEDURE usp_EliminarUsuario
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ObtenerRoles')
DROP PROCEDURE usp_ObtenerRoles
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_RegistrarRol')
DROP PROCEDURE usp_RegistrarRol
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ModificarRol')
DROP PROCEDURE usp_ModificarRol
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_EliminarRol')
DROP PROCEDURE usp_EliminarRol
GO

--------------------------------------------------------------------------------------------------------------------

-- (1) PROCEDIMIENTO ALMACENADO PARA INICIAR SESIÓN DE USUARIO
CREATE PROCEDURE usp_LoginUsuario(    
	@Usuario VARCHAR(60),
    @Clave VARCHAR(100),
	@IdUsuario INT OUTPUT,
    @Mensaje VARCHAR(255) OUTPUT
)   
AS
BEGIN
    SET @IdUsuario = 0
    SET @Mensaje = ''

    -- Verificar si el usuario existe y está activo
    IF EXISTS (SELECT * FROM USUARIOS WHERE usuario = @Usuario AND estado = 1)
    BEGIN
        -- Verificar si la contraseña es correcta
        IF EXISTS (SELECT * FROM USUARIOS WHERE usuario = @Usuario AND contrasena = @Clave AND estado = 1)
        BEGIN
            SET @IdUsuario = (SELECT TOP 1 id_usuario FROM USUARIOS WHERE usuario = @Usuario AND contrasena = @Clave AND estado = 1)
            SET @Mensaje = 'Inicio de sesión exitoso'
        END
        ELSE
        BEGIN
            SET @Mensaje = 'Contraseña incorrecta'
        END
    END
    ELSE
    BEGIN
        SET @Mensaje = 'El usuario no existe o está inactivo'
    END
END
GO
--------------------------------------------------------------------------------------------------------------------

-- (3) PROCEDIMIENTO ALMACENADO PARA OBTENER LOS MENUS DE UN ROL DE UN USUARIO
CREATE OR ALTER PROCEDURE usp_ObtenerMenuPorUsuario
    @IdUsuario INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Verificar si el usuario existe y está activo
    IF NOT EXISTS (SELECT 1 FROM USUARIOS WHERE id_usuario = @IdUsuario AND estado = 1)
    BEGIN
        RAISERROR('Usuario no encontrado o inactivo', 16, 1);
        RETURN;
    END
    
    -- Obtener menús asignados al rol del usuario (solo tipo Vista)
    SELECT 
        m.id_menu,
        m.nombre,
        c.controlador,
        c.accion AS vista,
        m.icono,
        m.orden
    FROM MENU_ROL mr
    INNER JOIN MENU m ON mr.fk_menu = m.id_menu
    LEFT JOIN CONTROLLER c ON m.fk_controlador = c.id_controlador
    INNER JOIN USUARIOS u ON mr.fk_rol = u.fk_rol
    WHERE u.id_usuario = @IdUsuario
    AND mr.estado = 1
    AND m.estado = 1
    AND (c.tipo = 'Vista' OR c.tipo IS NULL) -- Solo vistas o menús padres
    AND (
        m.fk_controlador IS NULL 
        OR 
        EXISTS (
            SELECT 1 FROM PERMISOS p 
            WHERE p.fk_rol = u.fk_rol 
            AND p.fk_controlador = m.fk_controlador
            AND p.estado = 1
        )
    )
    ORDER BY m.orden;
END
GO

-- PROCEDIMIENTO ALMACENADO PARA VERIFICAR LOS PERMISOS DE UN USUARIO
CREATE OR ALTER PROCEDURE usp_VerificarPermiso
    @IdUsuario INT,
    @Controlador VARCHAR(60),
    @Accion VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @TienePermiso BIT = 0;
    DECLARE @IdRol INT;
    
    -- Obtener el rol del usuario
    SELECT @IdRol = fk_rol 
    FROM USUARIOS 
    WHERE id_usuario = @IdUsuario AND estado = 1;
    
    -- Si no encuentra usuario o está inactivo
    IF @IdRol IS NULL
    BEGIN
        SELECT @TienePermiso AS tiene_permiso;
        RETURN;
    END;
    
    -- Verificar si la acción es pública (no requiere permiso)
    IF (@Controlador = 'Home' AND @Accion = 'Index')
    BEGIN
        SET @TienePermiso = 1;
    END
    ELSE
    BEGIN
        -- Verificar permiso en la tabla de permisos
        IF EXISTS (
            SELECT 1 
            FROM PERMISOS p
            INNER JOIN CONTROLLER c ON p.fk_controlador = c.id_controlador
            WHERE p.fk_rol = @IdRol
            AND c.controlador = @Controlador
            AND c.accion = @Accion
            AND p.estado = 1            
        )
        BEGIN
            SET @TienePermiso = 1;
        END;
    END;
    
    SELECT @TienePermiso AS tiene_permiso;
END
GO

--------------------------------------------------------------------------------------------------------------------
-- PROCEMIENTO ALMACENADO PARA OBTENER LOS PERMISOS DE UN ROL
CREATE PROCEDURE usp_ObtenerPermisosPorRol
    @IdRol INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT DISTINCT
        p.id_permiso,
        c.id_controlador,
        c.controlador,
        c.accion,
        c.descripcion,
        c.tipo,
        p.estado
    FROM PERMISOS p
    INNER JOIN CONTROLLER c ON p.fk_controlador = c.id_controlador
    WHERE p.fk_rol = @IdRol
    AND p.estado = 1    
    ORDER BY c.controlador, c.accion;
END
GO
--------------------------------------------------------------------------------------------------------------------

-- PROCEDIMIENTO PARA ASIGNAR PERMISO
CREATE PROCEDURE usp_AsignarPermiso
    @IdRol INT,
    @IdControlador INT,
    @Estado BIT
AS
BEGIN
    SET NOCOUNT ON;
    
    IF EXISTS (SELECT 1 FROM PERMISOS WHERE fk_rol = @IdRol AND fk_controlador = @IdControlador)
    BEGIN
        -- Actualizar permiso existente
        UPDATE PERMISOS 
        SET estado = @Estado 
        WHERE fk_rol = @IdRol AND fk_controlador = @IdControlador;
    END
    ELSE
    BEGIN
        -- Insertar nuevo permiso
        INSERT INTO PERMISOS (fk_rol, fk_controlador, estado)
        VALUES (@IdRol, @IdControlador, @Estado);
    END
    
    SELECT @@ROWCOUNT AS Resultado;
END
GO
--------------------------------------------------------------------------------------------------------------------

-- PROCEDIMIENTO PARA OBTENER PERMISOS NO ASIGNADOS
CREATE PROCEDURE usp_ObtenerPermisosNoAsignados
    @IdRol INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        c.id_controlador,
        c.controlador,
        c.accion,
        c.descripcion,
        c.tipo
    FROM CONTROLLER c
    WHERE c.estado = 1
    AND NOT EXISTS (
        SELECT 1 FROM PERMISOS p 
        WHERE p.fk_rol = @IdRol 
        AND p.fk_controlador = c.id_controlador
        AND p.estado = 1
    )
    ORDER BY c.controlador, c.accion;
END
GO
--------------------------------------------------------------------------------------------------------------------

-- (5) PROCEDIMIENTO ALMACENADO PARA OBTENER TODOS LOS USUARIOS
CREATE PROCEDURE usp_ObtenerUsuario
AS
BEGIN
    SELECT 
        u.id_usuario,
        u.pri_nombre,
        u.seg_nombre,
        u.pri_apellido,
        u.seg_apellido,
        u.usuario,
        u.correo,
        u.fk_rol,
        u.estado,
        u.fecha_registro,
        r.descripcion AS 'DescripcionRol'
    FROM USUARIOS u
    INNER JOIN ROL r ON r.id_rol = u.fk_rol
END
GO
--------------------------------------------------------------------------------------------------------------------

-- (6) PROCEDIMIENTO ALMACENADO PARA REGISTRAR UN NUEVO USUARIO
CREATE PROCEDURE usp_RegistrarUsuario(
    @PriNombre VARCHAR(60),
    @SegNombre VARCHAR(60),
    @PriApellido VARCHAR(60),
    @SegApellido VARCHAR(60),
    @Usuario VARCHAR(50),
    @Clave VARCHAR(100),
    @Correo VARCHAR(60),
    @Telefono INT,
    @FkRol INT,
    @Estado BIT,    
    @Resultado INT OUTPUT,
    @Mensaje VARCHAR(255) OUTPUT
)
AS
BEGIN
    SET @Resultado = 0
    SET @Mensaje = ''

    -- Verificar si el nombre de usuario ya existe
    IF EXISTS (SELECT * FROM USUARIOS WHERE usuario = @Usuario)
    BEGIN
        SET @Mensaje = 'El nombre de usuario ya está en uso'
        RETURN
    END

    -- Verificar si el correo electrónico ya existe
    IF EXISTS (SELECT * FROM USUARIOS WHERE correo = @Correo)
    BEGIN
        SET @Mensaje = 'El correo electrónico ya está registrado'
        RETURN
    END

    -- Insertar el nuevo usuario
    INSERT INTO USUARIOS (pri_nombre, seg_nombre, pri_apellido, seg_apellido, usuario, contrasena, correo, telefono, fk_rol, estado)
    VALUES (@PriNombre, @SegNombre, @PriApellido, @SegApellido, @Usuario, CONVERT(VARBINARY(64), @Clave), @Correo, @Telefono, @FkRol, @Estado)

    SET @Resultado = SCOPE_IDENTITY()
    SET @Mensaje = 'Usuario registrado exitosamente'
END
GO
--------------------------------------------------------------------------------------------------------------------

-- (7) PROCEDIMIENTO ALMACENADO PARA MODIFICAR LOS DATOS DE UN USUARIO
CREATE PROCEDURE usp_ModificarUsuario
    @IdUsuario INT,
    @PriNombre VARCHAR(60),
    @SegNombre VARCHAR(60),
    @PriApellido VARCHAR(60),
    @SegApellido VARCHAR(60),
    @Usuario VARCHAR(50),    
    @Correo VARCHAR(60),
    @Telefono INT,
    @FkRol INT,
    @Estado BIT,

    @Resultado INT OUTPUT,
    @Mensaje VARCHAR(255) OUTPUT
AS
BEGIN
    SET @Resultado = 0
    SET @Mensaje = ''

    -- Verificar si el usuario existe
    IF NOT EXISTS (SELECT 1 FROM USUARIOS WHERE id_usuario = @IdUsuario)
    BEGIN
        SET @Mensaje = 'El usuario no existe'
        RETURN
    END

    -- Verificar si el nombre de usuario ya existe (excluyendo al usuario actual)
    IF EXISTS (SELECT 1 FROM USUARIOS WHERE usuario = @Usuario AND id_usuario != @IdUsuario)
    BEGIN
        SET @Mensaje = 'El nombre de usuario ya está en uso'
        RETURN
    END

    -- Verificar si el correo electrónico ya existe (excluyendo al usuario actual)
    IF EXISTS (SELECT 1 FROM USUARIOS WHERE correo = @Correo AND id_usuario != @IdUsuario)
    BEGIN
        SET @Mensaje = 'El correo electrónico ya está registrado'
        RETURN
    END

    -- Actualizar el usuario
    UPDATE USUARIOS
    SET 
        pri_nombre = @PriNombre,
        seg_nombre = @SegNombre,
        pri_apellido = @PriApellido,
        seg_apellido = @SegApellido,
        usuario = @Usuario,        
        correo = @Correo,
        telefono = @Telefono,
        fk_rol = @FkRol,
        estado = @Estado
    WHERE id_usuario = @IdUsuario

    SET @Resultado = 1
    SET @Mensaje = 'Usuario actualizado exitosamente'
END
GO
--------------------------------------------------------------------------------------------------------------------

-- (8) PROCEDIMIENTO ALMACENADO PARA MODIFICAR LA CONTRASEÑA DE UN USUARIO
CREATE PROCEDURE usp_ModificarContrasena
    @IdUsuario INT,    
    @ClaveActual VARCHAR(100),
    @ClaveNueva VARCHAR(100),
    
    @Resultado INT OUTPUT,
    @Mensaje VARCHAR(255) OUTPUT
AS
BEGIN
    SET @Resultado = 0
    SET @Mensaje = ''

    -- Verificar si el usuario existe
    IF NOT EXISTS (SELECT 1 FROM USUARIOS WHERE id_usuario = @IdUsuario)
    BEGIN
        SET @Mensaje = 'El usuario no existe'
        RETURN
    END

    -- Verificar si la contraseña actual es correcta
    IF NOT EXISTS (SELECT 1 FROM USUARIOS WHERE id_usuario = @IdUsuario AND contrasena = CONVERT(VARBINARY(64), @ClaveActual))
    BEGIN
        SET @Mensaje = 'La contraseña actual es incorrecta'
        RETURN
    END

    -- Actualizar la contraseña
    UPDATE USUARIOS
    SET contrasena = CONVERT(VARBINARY(64), @ClaveNueva)
    WHERE id_usuario = @IdUsuario

    SET @Resultado = 1
    SET @Mensaje = 'Usuario actualizado exitosamente'
END
GO
--------------------------------------------------------------------------------------------------------------------

-- (9) PROCEDIMIENTO ALMACENADO PARA ELIMINAR UN USUARIO
CREATE PROCEDURE usp_EliminarUsuario
    @IdUsuario INT,
    @Resultado BIT OUTPUT
AS
BEGIN
    SET @Resultado = 0
    
    IF EXISTS (SELECT 1 FROM USUARIOS WHERE id_usuario = @IdUsuario)
    BEGIN
        DELETE FROM USUARIOS WHERE id_usuario = @IdUsuario
        SET @Resultado = 1
    END
END
GO
--------------------------------------------------------------------------------------------------------------------

-- (10) PROCEDIMIENTO ALMACENADO PARA OBTENER TODOS LOS ROLES
CREATE PROCEDURE usp_ObtenerRoles
AS
BEGIN
    SELECT id_rol, descripcion, estado FROM ROL
END
GO
--------------------------------------------------------------------------------------------------------------------

-- (11) PROCEDIMIENTO ALMACENADO PARA REGISTRAR UN NUEVO ROL

--------------------------------------------------------------------------------------------------------------------

-- (12) PROCEDIMIENTO ALMACENADO PARA MODIFICAR LOS DATOS DE UN ROL
CREATE PROCEDURE usp_ModificarRol
    @IdRol INT,
    @Descripcion VARCHAR(60),
    @Estado BIT,
    @Resultado BIT OUTPUT
AS
BEGIN
    SET @Resultado = 1
    IF NOT EXISTS (SELECT * FROM ROL WHERE descripcion = @Descripcion AND id_rol != @IdRol)
    BEGIN
        UPDATE ROL
        SET 
            descripcion = @Descripcion,
            estado = @Estado
        WHERE id_rol = @IdRol
    END
    ELSE
        SET @Resultado = 0
END
GO
--------------------------------------------------------------------------------------------------------------------
    
-- (13) PROCEDIMIENTO ALMACENADO PARA ELIMINAR UN ROL
CREATE PROCEDURE usp_EliminarRol
    @IdRol INT,
    @Resultado BIT OUTPUT
AS
BEGIN
    SET @Resultado = 1
    IF NOT EXISTS (SELECT * FROM USUARIOS WHERE fk_rol = @IdRol)
    BEGIN
        DELETE FROM PERMISOS WHERE fk_rol = @IdRol
        DELETE FROM ROL WHERE id_rol = @IdRol
    END
    ELSE
        SET @Resultado = 0
END
GO
--------------------------------------------------------------------------------------------------------------------