using capa_datos;
using capa_entidad;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace capa_negocio
{
    public class CN_Permisos
    {
        private CD_Permisos CD_Permisos = new CD_Permisos();

        public bool VerificarPermiso(int IdUsuario, string controlador, string vista)
        {
            if (IdUsuario <= 0)
                return false;

            if (string.IsNullOrEmpty(controlador) || string.IsNullOrEmpty(vista))
                return false;

            try
            {
                return CD_Permisos.VerificarPermiso(IdUsuario, controlador, vista);
            }
            catch
            {
                return false;
            }
        }

        public List<PERMISOS> ListarPermisosPorRol(int IdRol, out string mensaje)
        {
            mensaje = string.Empty;

            if (IdRol <= 0)
            {
                mensaje = "Por favor, seleccione un rol.";
            }

            return CD_Permisos.ObtenerPermisosPorRol(IdRol);
        }

        public List<CONTROLLER> ListarPermisosNoAsignados(int IdRol, out string mensaje)
        {
            mensaje = string.Empty;  
            
            if (IdRol == 0)
            {
                mensaje = "Por favor, seleccione un rol.";
            }

            return CD_Permisos.ObtenerPermisosNoAsignados(IdRol);
        }
  

        public bool AsignarPermiso(int IdRol, int IdControlador, bool Estado)
        {
            return CD_Permisos.AsignarPermiso(IdRol, IdControlador, Estado);
        }
    }
}
