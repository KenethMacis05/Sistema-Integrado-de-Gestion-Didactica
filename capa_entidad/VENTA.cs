using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace capa_entidad
{
    public class VENTA
    {
        public int id_venta { get; set; }
        public CLIENTES fk_cliente { get; set; }
        public int total_productos { get; set; }
        public decimal monto_total { get; set; }
        public string contacto { get; set; }
        public string distrito { get; set; }
        public string telefono { get; set; }
        public string direccion { get; set; }
        public string transaccion { get; set; }
        public List<DETALLE_VENTA> fk_detalle_venta { get; set; }
    }
}
