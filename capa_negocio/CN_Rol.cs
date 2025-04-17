using capa_datos;
using capa_entidad;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace capa_negocio
{
    public class CN_Rol
    {
        private CD_Rol CD_Rol = new CD_Rol();

        //Listar usuarios
        public List<ROL> Listar()
        {
            return CD_Rol.Listar();
        }

        // Crear rol
        public int Crear(ROL rol, out string mensaje)
        {
            mensaje = string.Empty;

            if (string.IsNullOrEmpty(rol.descripcion))
            {
                mensaje = "Por favor, complete todos los campos.";
                return 0;
            }
            
            int resultado = CD_Rol.Crear(rol, out mensaje);
            if (resultado == 0)
            {
                mensaje = "Error al crear el rol.";
                return 0;
            } else
            {
                mensaje = "Rol creado correctamente.";
            }

            return resultado;
        }

        // Actualizar rol
        public int Editar(ROL rol, out string mensaje)
        {
            mensaje = string.Empty;

            if (string.IsNullOrEmpty(rol.descripcion))
            {
                mensaje = "Por favor, complete todos los campos.";
                return 0;
            }

            bool actualizado = CD_Rol.Editar(rol, out mensaje);
            return actualizado ? 1 : 0;
        }

        // Eliminar rol
        public int Eliminar(int id_rol, out string mensaje)
        {
            bool eliminado = CD_Rol.Eliminar(id_rol, out mensaje);
            return eliminado ? 1 : 0;
        }       
    }
}
