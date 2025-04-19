using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using capa_datos;
using capa_entidad;

namespace capa_negocio
{
    public class CN_Usuario
    {
        private CD_Usuarios CD_Usuarios = new CD_Usuarios();

        //Listar usuarios
        public List<USUARIOS> Listar()
        {
            return CD_Usuarios.Listar();
        }

        // Registrar usuario
        public int Registra(USUARIOS usuario, out string mensaje)
        {
            mensaje = string.Empty;

            // Validación de campos obligatorios
            if (string.IsNullOrEmpty(usuario.pri_nombre) ||
                string.IsNullOrEmpty(usuario.pri_apellido) ||
                string.IsNullOrEmpty(usuario.usuario) ||
                string.IsNullOrEmpty(usuario.correo))
            {
                mensaje = "Por favor, complete todos los campos.";
                return 0;
            }

            if (usuario.fk_rol == 0)
            {
                mensaje = "Por favor, seleccione un rol.";
                return 0;
            }

            // Generación de contraseña aleatoria
            string clave = CN_Recursos.GenerarPassword();

            // Personalización del mensaje de correo
            string asunto = "¡Bienvenido al Sistema Integrado de Gestión Didáctica!";
            string mensaje_correo = $@"
                <div style='font-family: Arial, sans-serif; color: #333; line-height: 1.6;'>
                    <div style='background-color: #02116F; color: #fff; padding: 20px; text-align: center; border-radius: 10px 10px 0 0;'>
                        <h1 style='margin: 0; color: #ffffff'>¡Bienvenido, {usuario.pri_nombre} {usuario.pri_apellido}!</h1>
                    </div>
                    <div style='border: 1px solid #ddd; border-radius: 0 0 10px 10px; padding: 20px; background-color: #f9f9f9;'>
                        <p>
                            Nos complace informarte que tu cuenta ha sido creada exitosamente en nuestro sistema. Aquí tienes los detalles para acceder:
                        </p>
                        <table style='width: 100%; margin: 20px 0; border-collapse: collapse;'>
                            <tr>
                                <td style='font-weight: bold; padding: 10px; background-color: #eaf4fe; border: 1px solid #ddd;'>Usuario:</td>
                                <td style='padding: 10px; border: 1px solid #ddd;'>{usuario.usuario}</td>
                            </tr>
                            <tr>
                                <td style='font-weight: bold; padding: 10px; background-color: #eaf4fe; border: 1px solid #ddd;'>Contraseña:</td>
                                <td style='padding: 10px; border: 1px solid #ddd;'>{clave}</td>
                            </tr>
                        </table>
                        <p style='text-align: center;'>
                            <a href='https://tusistema.com/login' style='display: inline-block; background-color: #007BFF; color: #fff; text-decoration: none; padding: 15px 30px; border-radius: 5px; font-size: 16px;'>
                                Iniciar Sesión
                            </a>
                        </p>
                        <hr style='border: none; border-top: 1px solid #ddd; margin: 40px 0;'>
                        <p style='text-align: center; font-size: 18px; font-weight: bold;'>¡Síguenos en nuestras redes sociales!</p>
                        <div style='text-align: center; margin-top: 20px;'>
                            <a href='https://www.tiktok.com/@unanmanagua' style='margin: 0 10px; text-decoration: none;'>
                                <img src='https://localhost:44344/assets/img/tiktok.png' alt='Sitio Web' style='width: 40px; height: 40px;'>
                            </a>
                            <a href='https://www.facebook.com/UNAN.Managua' style='margin: 0 10px; text-decoration: none;'>
                                <img src='https://localhost:44344/assets/img/facebook.png' alt='Facebook' style='width: 40px; height: 40px;'>
                            </a>
                             <a href='https://x.com/UNANManagua' style='margin: 0 10px; text-decoration: none;'>
                                <img src='https://localhost:44344/assets/img/x.png' alt='Twitter' style='width: 40px; height: 40px;'>
                            </a>
                            <a href='https://www.instagram.com/unan.managua' style='margin: 0 10px; text-decoration: none;'>
                                <img src='https://localhost:44344/assets/img/instagram.png' alt='Instagram' style='width: 40px; height: 40px;'>
                            </a>
                            <a href='https://www.youtube.com/channel/UCaAtEPINZNv738R3vZI2Kjg' style='margin: 0 10px; text-decoration: none;'>
                                <img src='https://localhost:44344/assets/img/youtube.png' alt='YouTube' style='width: 40px; height: 40px;'>
                            </a>
                        </div>
                        <p style='text-align: center; margin-top: 30px; font-size: 14px; color: #666;'>
                            Gracias por unirte a nosotros,<br>
                            <strong>Sistema Integrado de Gestión Didáctica</strong>
                        </p>
                    </div>
                </div>
            ";

            // Envío del correo
            bool correoEnviado = CN_Recursos.EnviarCorreo(usuario.correo, asunto, mensaje_correo);

            if (!correoEnviado)
            {
                mensaje = "Ocurrió un error al enviar el correo.";
                return 0;
            }

            // Encriptar la contraseña y registrar el usuario
            usuario.contrasena = CN_Recursos.EncriptarPassword(clave);
            int resultado = CD_Usuarios.RegistrarUsuario(usuario, out mensaje);

            return resultado > 0 ? 1 : 0;
        }

        // Editar usuario
        public int Editar(USUARIOS usuario, out string mensaje)
        {
            mensaje = string.Empty;

            if (string.IsNullOrEmpty(usuario.pri_nombre) ||
                string.IsNullOrEmpty(usuario.pri_apellido) ||
                string.IsNullOrEmpty(usuario.usuario) ||
                string.IsNullOrEmpty(usuario.correo))
            {
                mensaje = "Por favor, complete todos los campos.";
                return 0;
            }

            if (usuario.fk_rol == 0)
            {
                mensaje = "Por favor, seleccione un rol.";
                return 0;
            }

            bool actualizado = CD_Usuarios.ActualizarUsuario(usuario, out mensaje);
            return actualizado ? 1 : 0;
        }

        //Eliminar usuario
        public int Eliminar(int id_usuario, out string mensaje)
        {
            bool eliminado = CD_Usuarios.EliminarUsuario(id_usuario, out mensaje);
            return eliminado ? 1 : 0;
        }
    }
}
