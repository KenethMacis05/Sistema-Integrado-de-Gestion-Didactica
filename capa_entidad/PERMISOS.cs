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
        public int fk_rol { get; set; }
        public int fk_controlador { get; set; }
        public bool estado { get; set; } = true;

        // Propiedades de navegación (opcionales)
        public DateTime fecha_registro { get; set; } = DateTime.Now;
        public virtual ROL Rol { get; set; }
        public virtual CONTROLLER Controller { get; set; }
    }
}