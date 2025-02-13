using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace capa_entidad
{
 //   id_usuario INT PRIMARY KEY IDENTITY(1, 1),
	//nombre VARCHAR(45) NOT NULL,
 //   apellido VARCHAR(45),
	//correo VARCHAR(45) NOT NULL UNIQUE,
	//contrasena VARCHAR(255) NOT NULL,
 //   restablecer BIT DEFAULT 1,
	//estado BIT DEFAULT 1,
	//fecha_registro DATETIME DEFAULT GETDATE()
    public class USUARIOS
    {
        public int id_usuario { get; set; }
        public string nombre { get; set; }
        public string apellido { get; set; }
        public string correo { get; set; }
        public string contrasena { get; set; }
        public bool restablecer { get; set; }
        public bool estado { get; set; }

    }
}
