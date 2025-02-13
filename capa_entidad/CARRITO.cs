using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace capa_entidad
{
    public class CARRITO
    {
        public int id_carrito { get; set; }
        public CLIENTES fk_cliente { get; set; }
        public PRODUCTOS fk_producto { get; set; }
        public int cantidad { get; set; }
    }
}
