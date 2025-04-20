------------------------------------------------PROCEDIMIENTOS ALMACENADOS------------------------------------------------

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_LoginUsuario')
DROP PROCEDURE usp_LoginUsuario
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_LeerPermisos')
DROP PROCEDURE usp_LeerPermisos
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ActualizarPermisos')
DROP PROCEDURE usp_ActualizarPermisos
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_LeerUsuario')
DROP PROCEDURE usp_LeerUsuario
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_CrearUsuario')
DROP PROCEDURE usp_CrearUsuario
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ActualizarUsuario')
DROP PROCEDURE usp_ActualizarUsuario
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ActualizarContrasena')
DROP PROCEDURE usp_ActualizarContrasena
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ReestablecerContrasena')
DROP PROCEDURE usp_ReestablecerContrasena
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_EliminarUsuario')
DROP PROCEDURE usp_EliminarUsuario
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_LeerRoles')
DROP PROCEDURE usp_LeerRoles
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_CrearRol')
DROP PROCEDURE usp_CrearRol
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ActualizarRol')
DROP PROCEDURE usp_ActualizarRol
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_EliminarRol')
DROP PROCEDURE usp_EliminarRol
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_LeerMenuPorUsuario')
DROP PROCEDURE usp_LeerMenuPorUsuario
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_VerificarPermiso')
DROP PROCEDURE usp_VerificarPermiso
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_AsignarPermiso')
DROP PROCEDURE usp_AsignarPermiso
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
CREATE OR ALTER PROCEDURE usp_LeerMenuPorUsuario
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
CREATE PROCEDURE usp_LeerPermisosPorRol
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
    ORDER BY p.id_permiso DESC;
END
GO
--------------------------------------------------------------------------------------------------------------------

-- PROCEDIMIENTO PARA ASIGNAR PERMISO
CREATE PROCEDURE usp_AsignarPermiso
    @IdRol INT,
    @IdControlador INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Resultado INT = 0;
    DECLARE @EstadoController BIT;
    
    -- 1. Verificar si el controlador está activo
    SELECT @EstadoController = estado 
    FROM CONTROLLER 
    WHERE id_controlador = @IdControlador;
    
    -- Si el controlador no existe o está inactivo
    IF @EstadoController IS NULL OR @EstadoController = 0
    BEGIN
        SELECT -1 AS Resultado; -- Código de error: Controlador no existe o está inactivo
        RETURN;
    END
    
    -- 2. Verificar si el rol ya tiene este controlador asignado
    IF EXISTS (SELECT 1 FROM PERMISOS 
              WHERE fk_rol = @IdRol AND fk_controlador = @IdControlador)
    BEGIN
        SELECT -2 AS Resultado; -- Código de error: El rol ya tiene este controlador
        RETURN;
    END
    
    -- 3. Si pasa las validaciones, insertar el nuevo permiso
    INSERT INTO PERMISOS (fk_rol, fk_controlador)
    VALUES (@IdRol, @IdControlador);
    
    SET @Resultado = SCOPE_IDENTITY();
    
    SELECT @Resultado AS Resultado;
END
GO
--------------------------------------------------------------------------------------------------------------------

-- PROCEDIMIENTO PARA OBTENER PERMISOS NO ASIGNADOS
CREATE PROCEDURE usp_LeerPermisosNoAsignados
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
    ORDER BY c.id_controlador DESC;
END
GO
--------------------------------------------------------------------------------------------------------------------

-- (5) PROCEDIMIENTO ALMACENADO PARA OBTENER TODOS LOS USUARIOS
CREATE PROCEDURE usp_LeerUsuario
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
        u.telefono,
        u.fk_rol,
        u.estado,
		u.reestablecer,
        u.fecha_registro,
        r.descripcion AS 'DescripcionRol'
    FROM USUARIOS u
    INNER JOIN ROL r ON r.id_rol = u.fk_rol
	ORDER BY u.id_usuario DESC
END
GO
--------------------------------------------------------------------------------------------------------------------

-- (6) PROCEDIMIENTO ALMACENADO PARA REGISTRAR UN NUEVO USUARIO
CREATE PROCEDURE usp_CrearUsuario(
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

	-- Verificar si el numero de telefono ya existe
	IF EXISTS (SELECT * FROM USUARIOS WHERE telefono = @Telefono)
    BEGIN
        SET @Mensaje = 'El numero de telefono ya está registrado'
        RETURN
    END

    -- Insertar el nuevo usuario
    INSERT INTO USUARIOS (pri_nombre, seg_nombre, pri_apellido, seg_apellido, usuario, contrasena, correo, telefono, fk_rol, estado)
    VALUES (@PriNombre, @SegNombre, @PriApellido, @SegApellido, @Usuario, CONVERT(VARBINARY(64), @Clave), @Correo, @Telefono, @FkRol, @Estado)

    SET @Resultado = SCOPE_IDENTITY()
    SET @Mensaje = 'Usuario registrado exitosamente'

    DECLARE @CarpetaRaiz VARCHAR(255) = CONCAT('DEFAULT_', @Usuario)

    -- Insertar la carpeta por defecto del usuario
    INSERT INTO CARPETA (nombre, fk_id_usuario)
    VALUES (@CarpetaRaiz, @Resultado)

END
GO
--------------------------------------------------------------------------------------------------------------------

-- (7) PROCEDIMIENTO ALMACENADO PARA MODIFICAR LOS DATOS DE UN USUARIO
CREATE PROCEDURE usp_ActualizarUsuario
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

	-- Verificar si el numero de telefono ya existe (excluyendo al usuario actual)
    IF EXISTS (SELECT 1 FROM USUARIOS WHERE telefono = @Telefono AND id_usuario != @IdUsuario)
    BEGIN
        SET @Mensaje = 'El numero de telefono ya está registrado'
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
CREATE PROCEDURE usp_ActualizarContrasena
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

-- (8) PROCEDIMIENTO ALMACENADO PARA REESTABLECER LA CONTRASEÑA DE UN USUARIO AL INICIAR SESIÓN POR PRIMERA VEZ
CREATE PROCEDURE usp_ReestablecerContrasena
    @IdUsuario INT,    
    @ClaveActual VARCHAR(100),
    @ClaveNueva VARCHAR(100),
    
    @Resultado INT OUTPUT,
    @Mensaje VARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0
    SET @Mensaje = ''

    BEGIN TRY
        
        IF NOT EXISTS (SELECT 1 FROM USUARIOS WHERE id_usuario = @IdUsuario)
        BEGIN
            SET @Mensaje = 'El usuario no existe'
            RETURN
        END
        
        IF NOT EXISTS (SELECT 1 FROM USUARIOS WHERE id_usuario = @IdUsuario AND contrasena = @ClaveActual)
        BEGIN
            SET @Mensaje = 'La contraseña actual es incorrecta'
            RETURN
        END
       
        UPDATE USUARIOS
        SET 
            contrasena = @ClaveNueva,
            reestablecer = 0
        WHERE id_usuario = @IdUsuario

         -- Verificar si realmente se actualizó el registro
        IF @@ROWCOUNT > 0
        BEGIN
            SET @Resultado = 1;
            SET @Mensaje = 'Contraseña actualizada exitosamente';
        END
        ELSE
        BEGIN
            SET @Mensaje = 'No se pudo actualizar la contraseña';
        END;
        
    END TRY
    BEGIN CATCH
        SET @Resultado = 0;
        SET @Mensaje = 'Error al cambiar la contraseña: ' + ERROR_MESSAGE();
    END CATCH
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
CREATE PROCEDURE usp_LeerRoles
AS
BEGIN
    SELECT * FROM ROL
END
GO
--------------------------------------------------------------------------------------------------------------------

-- (11) PROCEDIMIENTO ALMACENADO PARA REGISTRAR UN NUEVO ROL
CREATE PROCEDURE usp_CrearRol
    @Descripcion VARCHAR(60),    
    @Resultado INT OUTPUT,
	@Mensaje VARCHAR(255) OUTPUT
AS
BEGIN
    SET @Resultado = 0
	SET @Mensaje = ''

	-- Verificar si el nombre del rol ya existe
	IF EXISTS (SELECT * FROM ROL WHERE descripcion = @Descripcion)
	BEGIN
		SET @Mensaje = 'La descripción del Rol ya está en uso'
		RETURN
	END

	INSERT INTO ROL (descripcion) VALUES (@Descripcion)
    
    SET @Resultado = SCOPE_IDENTITY()
	SET @Mensaje = 'Rol registrado exitosamente'
END
GO

--------------------------------------------------------------------------------------------------------------------

-- (12) PROCEDIMIENTO ALMACENADO PARA MODIFICAR LOS DATOS DE UN ROL
CREATE PROCEDURE usp_ActualizarRol
    @IdRol INT,
    @Descripcion VARCHAR(60),
    @Estado BIT,
    @Resultado INT OUTPUT,
	@Mensaje VARCHAR(255) OUTPUT
AS
BEGIN
    SET @Resultado = 0
	SET @Mensaje = ''

	-- Verificar si el rol existe
	IF NOT EXISTS (SELECT 1 FROM ROL WHERE id_rol = @IdRol)
	BEGIN
		SET @Mensaje = 'El rol no existe'
		RETURN
	END

	-- Verificar si la descripción del Rol ya existe (excluyendo al Rol actual)
	IF EXISTS (SELECT 1 FROM ROL WHERE descripcion = @Descripcion AND id_rol != @IdRol)
	BEGIN
		SET @Mensaje = 'La descripción del Rol ya está en uso'
		RETURN
	END
    
    UPDATE ROL
    SET 
        descripcion = @Descripcion,
        estado = @Estado
    WHERE id_rol = @IdRol
   
    SET @Resultado = 1
	SET @Mensaje = 'Rol actualizado exitosamente'
END
GO
--------------------------------------------------------------------------------------------------------------------
    
-- (13) PROCEDIMIENTO ALMACENADO PARA ELIMINAR UN ROL
CREATE PROCEDURE usp_EliminarRol
    @IdRol INT,
    @Resultado INT OUTPUT,
    @Mensaje NVARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Verificar si el rol existe
    IF NOT EXISTS (SELECT 1 FROM ROL WHERE id_rol = @IdRol)
    BEGIN
        SET @Resultado = 0 -- No se pudo realizar la operación
        SET @Mensaje = 'El rol no existe.'
        RETURN
    END
    
    -- Verificar si tiene usuarios asociados
    IF EXISTS (SELECT 1 FROM USUARIOS WHERE fk_rol = @IdRol)
    BEGIN
        SET @Resultado = 2 -- Tiene usuarios asociados
        SET @Mensaje = 'No se puede eliminar el rol porque tiene usuarios asociados.'
        RETURN
    END
    
    -- Si pasa las validaciones, eliminar
    BEGIN TRY
        BEGIN TRANSACTION
        
        DELETE FROM PERMISOS WHERE fk_rol = @IdRol
        DELETE FROM ROL WHERE id_rol = @IdRol
        
        COMMIT TRANSACTION
        SET @Resultado = 1 -- Éxito
        SET @Mensaje = 'Rol eliminado exitosamente.'
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION
            
        SET @Resultado = 0 -- Error
        SET @Mensaje = 'Error al eliminar el rol: ' + ERROR_MESSAGE()
    END CATCH
END
GO

--------------------------------------------------------------------------------------------------------------------

-- (1) PROCEDIMIENTO ALMACENADO PARA OBTENER CARPETAS RECIENTES DEL USUARIO
CREATE PROCEDURE usp_LeerCarpetaRecientes
    @IdUsuario INT,
    @Resultado INT OUTPUT,
    @Mensaje VARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar si el usuario existe
    IF NOT EXISTS (SELECT 1 FROM USUARIOS WHERE id_usuario = @IdUsuario)
    BEGIN
        SET @Resultado = 0
        SET @Mensaje = 'El usuario no existe'
        RETURN
    END

    -- Validar si el usuario tiene carpetas creadas (excluyendo la DEFAULT)
    IF NOT EXISTS (
        SELECT 1 
        FROM CARPETA 
        WHERE fk_id_usuario = @IdUsuario 
          AND nombre <> 'DEFAULT'
    )
    BEGIN
        SET @Resultado = 0
        SET @Mensaje = 'El usuario aún no ha creado carpetas'
        RETURN
    END

    -- Mostrar las 10 carpetas más recientes, excluyendo DEFAULT
    SELECT TOP 10 * 
    FROM CARPETA 
    WHERE fk_id_usuario = @IdUsuario 
      AND estado = 1 
      AND nombre <> 'DEFAULT'
    ORDER BY fecha_registro DESC

    SET @Resultado = 1
    SET @Mensaje = 'Carpetas cargadas correctamente'
END
GO

--------------------------------------------------------------------------------------------------------------------

-- (2) PROCEDIMIENTO ALMACENADO PARA REGISTRAR UNA NUEVA CARPETA
CREATE OR ALTER PROCEDURE usp_CrearCarpeta
    @Nombre VARCHAR(60),
    @IdUsuario INT,
    @CarpetaPadre INT = NULL,
    @Resultado INT OUTPUT,
    @Mensaje VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje = '';

    BEGIN TRY
        -- Verificar si el usuario existe
        IF NOT EXISTS (SELECT 1 FROM USUARIOS WHERE id_usuario = @IdUsuario AND estado = 1)
        BEGIN
            SET @Mensaje = 'El usuario no existe o está inactivo';
            RETURN;
        END

        -- Verificar si ya existe una carpeta con ese nombre para el mismo usuario
        IF EXISTS (
            SELECT 1 
            FROM CARPETA 
            WHERE nombre = @Nombre 
              AND fk_id_usuario = @IdUsuario 
              AND ISNULL(carpeta_padre, 0) = ISNULL(@CarpetaPadre, 0)
              AND estado = 1
        )
        BEGIN
            SET @Mensaje = 'Ya existe una carpeta con este nombre en la ubicación especificada';
            RETURN;
        END

        -- Insertar la nueva carpeta
        INSERT INTO CARPETA (nombre, fk_id_usuario, carpeta_padre) 
        VALUES (@Nombre, @IdUsuario, @CarpetaPadre)

        SET @Resultado = SCOPE_IDENTITY();
        SET @Mensaje = 'Carpeta creada exitosamente';
    END TRY
    BEGIN CATCH
        SET @Resultado = 0;
        SET @Mensaje = 'Error al crear la carpeta: ' + ERROR_MESSAGE();
    END CATCH
END
GO
--------------------------------------------------------------------------------------------------------------------

-- (3) PROCEDIMIENTO ALMACENADO PARA MODIFICAR LOS DATOS DE UNA CARPETA
CREATE PROCEDURE usp_ActualizarCarpeta
    @IdCarpeta INT,
    @Nombre VARCHAR(60),
    @Resultado INT OUTPUT,
    @Mensaje VARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje = '';

    -- Verificar si la carpeta existe
    IF NOT EXISTS (SELECT 1 FROM CARPETA WHERE id_carpeta = @IdCarpeta)
    BEGIN
        SET @Mensaje = 'La carpeta no existe'
        RETURN
    END

    -- Obtener el ID del usuario propietario de esta carpeta
    DECLARE @IdUsuario INT;
    SELECT @IdUsuario = fk_id_usuario FROM CARPETA WHERE id_carpeta = @IdCarpeta;

    -- Verificar si ya existe otra carpeta con ese nombre para el mismo usuario (excluyendo la actual)
    IF EXISTS (
        SELECT 1 
        FROM CARPETA 
        WHERE nombre = @Nombre 
        AND fk_id_usuario = @IdUsuario 
        AND id_carpeta != @IdCarpeta
		AND estado = 1
    )
    BEGIN
        SET @Mensaje = 'Ya existe una carpeta con ese nombre para este usuario'
        RETURN
    END	

    -- Actualizar el nombre de la carpeta
    UPDATE CARPETA
    SET nombre = @Nombre
    WHERE id_carpeta = @IdCarpeta;

    SET @Resultado = 1;
    SET @Mensaje = 'Carpeta actualizada exitosamente'
END
GO


-- (4) PROCEDIMIENTO ALMACENADO PARA ELIMINAR UNA CARPETA
CREATE PROCEDURE usp_EliminarCarpeta
    @IdCarpeta INT,
    @Resultado BIT OUTPUT
AS
BEGIN
    SET @Resultado = 0
    
    IF EXISTS (SELECT 1 FROM CARPETA WHERE id_carpeta = @IdCarpeta)
    BEGIN
        UPDATE CARPETA
		SET estado = 0,
		fecha_eliminacion = GETDATE()
		WHERE id_carpeta = @IdCarpeta;
        SET @Resultado = 1
    END

    IF EXISTS (SELECT 1 FROM ARCHIVO WHERE fk_id_carpeta = @IdCarpeta)
    BEGIN
        UPDATE ARCHIVO
		SET estado = 0,
		fecha_eliminacion = GETDATE()
		WHERE fk_id_carpeta = @IdCarpeta;
        SET @Resultado = 1
    END
END
GO

-- (5) PROCEDIMIENTO ALMACENADO PARA RESTABLECER UNA CARPETA
CREATE PROCEDURE usp_RestablecerCarpeta
    @IdCarpeta INT,
    @Resultado BIT OUTPUT
AS
BEGIN
    SET @Resultado = 0
    
    IF EXISTS (SELECT 1 FROM CARPETA WHERE id_carpeta = @IdCarpeta)
    BEGIN
        UPDATE CARPETA
		SET estado = 1,
		fecha_eliminacion = NULL
		WHERE id_carpeta = @IdCarpeta;
        SET @Resultado = 1
    END

    IF EXISTS (SELECT 1 FROM ARCHIVO WHERE fk_id_carpeta = @IdCarpeta)
    BEGIN
        UPDATE ARCHIVO
		SET estado = 1,
		fecha_eliminacion = NULL
		WHERE fk_id_carpeta = @IdCarpeta;
        SET @Resultado = 1
    END
END
GO

-- (1) PROCEDIMIENTO ALMACENADO PARA SUBIR UN ARCHIVO
CREATE OR ALTER PROCEDURE usp_SubirArchivo
    @Nombre VARCHAR(60),
	@Ruta VARCHAR(255),
	@Size INT,
	@Tipo VARCHAR(60),
    @Carpeta INT,
    
    @Resultado INT OUTPUT,
    @Mensaje VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje = '';

    BEGIN TRY
        -- Verificar si la carpeta existe
        IF NOT EXISTS (SELECT 1 FROM CARPETA WHERE id_carpeta = @Carpeta AND estado = 1)
        BEGIN
            SET @Mensaje = 'La carpeta no existe o fue eliminada';
            RETURN;
        END

        -- Verificar si ya existe un archivo con ese nombre para la misma carpeta
        IF EXISTS (
            SELECT 1 
            FROM ARCHIVO 
            WHERE nombre = @Nombre 
              AND fk_id_carpeta = @Carpeta              
              AND estado = 1
        )
        BEGIN
            SET @Mensaje = 'Ya existe un archivo con este nombre en la carpeta selecionada';
            RETURN;
        END

        -- Insertar la nueva carpeta
        INSERT INTO ARCHIVO(nombre, tipo, size, ruta, fk_id_carpeta) 
        VALUES (@Nombre, @Tipo, @Size, @Ruta, @Carpeta)

        SET @Resultado = SCOPE_IDENTITY();
        SET @Mensaje = 'Archivo subido exitosamente';
    END TRY
    BEGIN CATCH
        SET @Resultado = 0;
        SET @Mensaje = 'Error al subir el archivo: ' + ERROR_MESSAGE();
    END CATCH
END
GO

-- (2) PROCEDIMIENTO ALMACENADO PARA RENOMBRAR ARCHIVO
CREATE PROCEDURE usp_EditarArchivo
    @IdArchivo INT,
    @Nombre VARCHAR(60),
    @Carpeta VARCHAR(255),

    @Resultado INT OUTPUT,
    @Mensaje VARCHAR(255) OUTPUT
AS
BEGIN
    SET @Resultado = 0
    SET @Mensaje = ''

    -- Verificar si el archivo existe
    IF NOT EXISTS (SELECT 1 FROM ARCHIVO WHERE id_archivo = @IdArchivo)
    BEGIN
        SET @Mensaje = 'El archivo no existe'
        RETURN
    END

    -- Verificar si el nombre del archivo ya existe en la carpeta (excluyendo al archivo actual)
    IF EXISTS (SELECT 1 FROM ARCHIVO WHERE nombre = @Nombre AND id_archivo != @IdArchivo AND fk_id_carpeta != @Carpeta)
    BEGIN
        SET @Mensaje = 'El nombre del archivo ya está en uso en la carpeta actual'
        RETURN
    END

    -- Renombrar archivo
    UPDATE ARCHIVO SET nombre = @Nombre WHERE id_archivo = @IdArchivo

    SET @Resultado = 1
    SET @Mensaje = 'Archivo renombrado exitosamente'
END
GO

-- (3) PROCEDIMIENTO ALMACENADO PARA ELIMINAR UN ARCHIVO
CREATE PROCEDURE usp_EliminarArchivo
    @IdArchivo INT,
    @Resultado BIT OUTPUT
AS
BEGIN
    SET @Resultado = 0
    
    IF EXISTS (SELECT 1 FROM ARCHIVO WHERE id_archivo = @IdArchivo)
    BEGIN
        UPDATE ARCHIVO
		SET estado = 0,
		fecha_eliminacion = GETDATE()
		WHERE id_archivo = @IdArchivo;
        SET @Resultado = 1
    END
END
GO

-- (4) PROCEDIMIENTO ALMACENADO PARA RESTABLECER UN ARCHIVO
CREATE PROCEDURE usp_RestablecerArchivo
    @IdArchivo INT,
    @Resultado BIT OUTPUT
AS
BEGIN
    SET @Resultado = 0
    
    IF EXISTS (SELECT 1 FROM ARCHIVO WHERE id_archivo = @IdArchivo)
    BEGIN
        UPDATE ARCHIVO
		SET estado = 1,
		fecha_eliminacion = NULL
		WHERE id_archivo = @IdArchivo;
        SET @Resultado = 1
    END
END
GO

-- (6) PROCEDIMIENTO ALMACENADO PARA ELIMINAR DIFINITIVAMENTE UNA CARPETA
CREATE PROCEDURE usp_EliminarCarpetasExpiradas
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM CARPETA
    WHERE estado = 0
    AND fecha_eliminacion IS NOT NULL
    AND DATEDIFF(DAY, fecha_eliminacion, GETDATE()) > 30;
END
GO

-- (6) PROCEDIMIENTO ALMACENADO PARA ELIMINAR DIFINITIVAMENTE UN ARCHIVO
CREATE PROCEDURE usp_EliminarArchivosExpiradas
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM ARCHIVO
    WHERE estado = 0
    AND fecha_eliminacion IS NOT NULL
    AND DATEDIFF(DAY, fecha_eliminacion, GETDATE()) > 30;
END
GO