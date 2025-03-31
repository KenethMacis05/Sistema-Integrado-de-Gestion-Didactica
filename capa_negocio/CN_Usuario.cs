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
        private CD_Usuarios cd_usuario = new CD_Usuarios();

        //Listar usuarios
        public List<USUARIOS> Listar()
        {
            return cd_usuario.Listar();
        }

        //Registrar usuario
        public int Registra(USUARIOS usuario, out string mensaje)
        {
            mensaje = string.Empty;

            if (string.IsNullOrEmpty(usuario.pri_nombre) || string.IsNullOrEmpty(usuario.pri_apellido) || string.IsNullOrEmpty(usuario.usuario) || string.IsNullOrEmpty(usuario.contrasena) || string.IsNullOrEmpty(usuario.correo))
            {
                mensaje = "Por favor, complete todos los campos.";
                return 0;
            }

            if (usuario.fk_rol == 0)
            {
                mensaje = "Por favor, seleccione un rol.";
                return 0;
            }

            if (string.IsNullOrEmpty(mensaje))
            {
                string clave = CN_Recursos.GenerarClave();

                string asunto = "Creación de usuario";
                string mensaje_correo = "<h3>Su cuenta fue creada correctamente</h3></br><p>Su contraseña para acceder es: !clave!</p>";
                mensaje_correo = mensaje_correo.Replace("!clave!", clave);

                bool resultado = CN_Recursos.EnviarCorreo(usuario.correo, asunto, mensaje_correo);

                if (resultado)
                {
                    usuario.contrasena = Encriptar.GetSHA256(clave);
                    return cd_usuario.RegistrarUsuario(usuario, out mensaje);
                }
                else
                {
                    mensaje = "Ocurrió un error al enviar el correo.";
                    return 0;
                }
            }

            return 0; // Ensure all code paths return a value
        }

        //Editar usuario
        public int Editar(USUARIOS usuario, out string mensaje)
        {
            mensaje = string.Empty;
            if (string.IsNullOrEmpty(usuario.pri_nombre) || string.IsNullOrEmpty(usuario.pri_apellido) || string.IsNullOrEmpty(usuario.usuario) || string.IsNullOrEmpty(usuario.correo))
            {
                mensaje = "Por favor, complete todos los campos.";
                return 0;
            }
            if (usuario.fk_rol == 0)
            {
                mensaje = "Por favor, seleccione un rol.";
                return 0;
            }
            if (string.IsNullOrEmpty(mensaje))
            {
                return cd_usuario.ActualizarUsuario(usuario, out mensaje) ? 1 : 0;
            }
            else
            {
                return 0;
            }
        }

        //Eliminar usuario
        public int Eliminar(int id_usuario, out string mensaje)
        {
            return cd_usuario.EliminarUsuario(id_usuario, out mensaje) ? 1 : 0;
        }
    }
}
