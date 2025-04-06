using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Security.Principal;
using System.Text;
using System.Threading.Tasks;

namespace capa_entidad
{
    public class PERMISOS
    {
        public int id_permisos { get; set; }
        public ROL fk_rol { get; set; }
        public MENU fk_menu { get; set; }
        public List<MENU> menus { get; set; }
        public bool estado { get; set; }
        public DateTime fecha_registro { get; set; }        
    }
}