using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Principal;
using System.Text;
using System.Threading.Tasks;

namespace capa_entidad
{
    public class ROL
    {        
        public int id_rol { get; set; }
        public string descripcion { get; set; }
        public bool estado { get; set; } = true;
        public DateTime fecha_registro { get; set; } = DateTime.Now;
    }
}