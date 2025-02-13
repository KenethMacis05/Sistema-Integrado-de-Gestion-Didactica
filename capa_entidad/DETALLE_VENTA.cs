using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Principal;
using System.Text;
using System.Threading.Tasks;

namespace capa_entidad
{
    public class DETALLE_VENTA
    {
        public int id_detalle_venta { get; set; }
        public VENTA fk_venta { get; set; }
        public PRODUCTOS fk_producto { get; set; }
        public int cantidad { get; set; }
        public decimal total { get; set; }
        public string transaccion { get; set; }
    }
}
