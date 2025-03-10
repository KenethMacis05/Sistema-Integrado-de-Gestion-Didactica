using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using capa_entidad;
using System.Data.SqlClient;
using System.Data;
using System.Runtime.Remoting.Messaging;

namespace capa_datos
{
    public class CD_Usuarios
    {
        public List<USUARIOS> Listar()
        {
            List<USUARIOS> lst = new List<USUARIOS>();

            try
            {
                using (SqlConnection conexion = new SqlConnection(Conexion.conexion))
                {
                    string query = "SELECT * FROM USUARIOS";
                    SqlCommand cmd = new SqlCommand(query, conexion);
                    cmd.CommandType = CommandType.Text;

                    conexion.Open();

                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            lst.Add(
                                new USUARIOS
                                {
                                    id_usuario = Convert.ToInt32(dr["id_usuario"]),
                                    usuario = dr["usuario"].ToString(),
                                    nombre = dr["nombre"].ToString(),
                                    apellido = dr["apellido"].ToString(),
                                    correo = dr["correo"].ToString(),
                                    contrasena = dr["contrasena"].ToString(),
                                    restablecer = Convert.ToBoolean(dr["restablecer"]),
                                    estado = Convert.ToBoolean(dr["estado"])
                                }
                                );
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error al listar los usuarios: " + ex.Message);
            }
            return lst;
        }
    }
}
