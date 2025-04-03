using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace capa_entidad
{
    internal class ARCHIVO
    {
        public int id_archivo { get; set; }
        public string nombre { get; set; }
        public string tipo { get; set; }
        public DateTime fecha_subida { get; set; }
        public bool estado { get; set; }
        public int fk_id_arpeta { get; set; }
        public byte[] Contenido { get; set; } // Para almacenar el archivo físico        
    }
}
