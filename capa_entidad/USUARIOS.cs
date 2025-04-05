using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace capa_entidad
{ 
    public class USUARIOS
    {
        public int id_usuario { get; set; }
        public string pri_nombre { get; set; }
        public string seg_nombre { get; set; }
        public string pri_apellido { get; set; }
        public string seg_apellido { get; set; }
        public string usuario { get; set; }
        public string contrasena { get; set; }
        public int telefono { get; set; }
        public string correo { get; set; }
        public int fk_rol { get; set; }
        public string descripcion { get; set; }
        public bool estado { get; set; }
        public bool reestablecer { get; set; }

    }
}
