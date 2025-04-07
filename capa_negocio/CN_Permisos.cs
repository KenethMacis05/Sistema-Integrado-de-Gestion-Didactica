using capa_datos;
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
            // Validaciones básicas
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
    }
}
