using System;
using System.Collections.Generic;
using System.Linq;
using capa_entidad;
using System.Text;
using System.Threading.Tasks;
using System.Data.SqlClient;
using System.Data;

namespace capa_datos
{
    public class CD_Rol
    {
        public List<ROL> Listar()
        {
            List<ROL> lst = new List<ROL>();

            try
            {
                using (SqlConnection conexion = new SqlConnection(Conexion.conexion))
                {
                    string query = "SELECT * FROM ROL";
                    SqlCommand cmd = new SqlCommand(query, conexion);
                    cmd.CommandType = CommandType.Text;

                    conexion.Open();

                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            lst.Add(
                                new ROL
                                {
                                    id_rol = Convert.ToInt32(dr["id_rol"]),
                                    descripcion = dr["descripcion"].ToString(),                                    
                                    estado = Convert.ToBoolean(dr["estado"]),
                                    fecha_registro = Convert.ToDateTime(dr["fecha_registro"])
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
