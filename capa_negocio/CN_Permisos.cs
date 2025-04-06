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

        public List<capa_entidad.MENU> ListarPermisosPorUsuario(int IdUsuario)
        {
            return CD_Permisos.ObtenerPermisosPorUsuario(IdUsuario);
        }
    }
}
