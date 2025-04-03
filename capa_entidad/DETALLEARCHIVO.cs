using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace capa_entidad
{
    internal class DETALLEARCHIVO
    {
        public int id_detalle_archivo { get; set; }
        public string correo { get; set; }
        public bool estado { get; set; }
        public DateTime fecha_subida { get; set; }
        public ARCHIVO fk_id_archivo { get; set; }
        public CARPETA fk_id_carpeta { get; set; }
        public USUARIOS fk_id_usuario { get; set; }
    }
}
