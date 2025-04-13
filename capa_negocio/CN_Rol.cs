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
    }
}
