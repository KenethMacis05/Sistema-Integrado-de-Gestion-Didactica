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

            string clave = CN_Recursos.GenerarClave();
            string asunto = "Creación de usuario";
            string mensaje_correo = $"<h3>Su cuenta fue creada correctamente</h3><br><p>Su contraseña para acceder es: {clave}</p>";

            bool correoEnviado = CN_Recursos.EnviarCorreo(usuario.correo, asunto, mensaje_correo);

            if (!correoEnviado)
            {
                mensaje = "Ocurrió un error al enviar el correo.";
                return 0;
            }

            usuario.contrasena = Encriptar.GetSHA256(clave);
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
