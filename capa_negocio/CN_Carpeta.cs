using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using capa_datos;
using capa_entidad;

namespace capa_negocio
{
    public class CN_Carpeta
    {
        private CD_Carpeta CD_Carpeta = new CD_Carpeta();

        public List<CARPETA> ListarCarpeta(int id_usuario, out int resultado, out string mensaje)
        {
            return CD_Carpeta.Listar(id_usuario, out resultado, out mensaje);
        }
    }
}
