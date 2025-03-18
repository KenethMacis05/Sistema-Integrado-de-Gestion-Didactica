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
                string contrasenapordefecto = "123456";
                usuario.contrasena = Encriptar.GetSHA256(contrasenapordefecto);

                return cd_usuario.RegistrarUsuario(usuario, out mensaje);
            }
            else
            {
                return 0;
            }
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
