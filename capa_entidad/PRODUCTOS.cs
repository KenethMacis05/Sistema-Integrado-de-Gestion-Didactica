using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Principal;
using System.Text;
using System.Threading.Tasks;

namespace capa_entidad
{
    public class PRODUCTOS
    {
        public int id_producto { get; set; }
        public string nombre { get; set; }
        public string descripcion { get; set; }
        public MARCAS fk_marca { get; set; }
        public CATEGORIAS fk_categoria { get; set; }
        public decimal precio { get; set; }
        public int cantidad_producto { get; set; }
        public string ruta_imagen { get; set; }
        public string nombre_imagen { get; set; }
        public bool estado { get; set; }
    }
}