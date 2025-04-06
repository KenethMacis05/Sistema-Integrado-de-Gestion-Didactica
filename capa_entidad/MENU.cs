using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Principal;
using System.Text;
using System.Threading.Tasks;

namespace capa_entidad
{
    public class MENU
    {       
        public int id_menu { get; set; }
        public string nombre { get; set; }
        public string controlador { get; set; }
        public string vista { get; set; }
        public string icono { get; set; }
        public bool estado { get; set; }
        public DateTime fecha_registro { get; set; }        
    }
}
