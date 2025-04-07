using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace capa_entidad
{
    public class CONTROLLER
    {
        public int id_controlador { get; set; }
        public string controlador { get; set; }
        public string accion { get; set; }
        public string descripcion { get; set; }
        public string tipo { get; set; } // 'Vista' o 'API'

        public DateTime fecha_registro { get; set; } = DateTime.Now;
        public bool estado { get; set; } = true;
        public string controlador_accion => $"{controlador}/{accion}";
    }
}
