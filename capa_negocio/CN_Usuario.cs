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
        public List<USUARIOS> Listar()
        {
            return cd_usuario.Listar();
        }
    }
}
