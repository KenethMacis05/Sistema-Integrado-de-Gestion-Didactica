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
        public string usuario { get; set; }
        public string nombre { get; set; }
        public string apellido { get; set; }
        public string correo { get; set; }
        public string contrasena { get; set; }
        public bool restablecer { get; set; }
        public bool estado { get; set; }

    }
}
