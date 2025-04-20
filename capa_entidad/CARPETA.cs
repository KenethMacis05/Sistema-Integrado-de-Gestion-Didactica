using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace capa_entidad
{
    public class CARPETA
    {
        public int id_carpeta { get; set; }
        public string nombre { get; set; }
        public DateTime fecha_registro { get; set; }
        public bool estado { get; set; }
        public int fk_id_usuario { get; set; }
        public int carpeta_padre { get; set; }
        public USUARIOS usuario { get; set; }
    }
}
