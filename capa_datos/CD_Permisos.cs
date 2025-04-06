using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using capa_entidad;
using System.Data.SqlClient;
using System.Data;
using System.Runtime.Remoting.Messaging;
using System.Web.Mvc;

namespace capa_datos
{
    public class CD_Permisos
    {
        public List<MENU> ObtenerPermisosPorUsuario(int IdUsuario)
        {            
            List<MENU> lst = new List<MENU>();

            try
            {
                using (SqlConnection conexion = new SqlConnection(Conexion.conexion))
                {
                    SqlCommand cmd = new SqlCommand("usp_ObtenerPermisosPorUsuario", conexion);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("IdUsuario", IdUsuario);
                    conexion.Open();
                    SqlDataReader dr = cmd.ExecuteReader();
                    while (dr.Read())
                    {
                        lst.Add(new MENU()
                        {
                            id_menu = Convert.ToInt32(dr["id_menu"]),
                            nombre = dr["nombre"].ToString(),
                            controlador = dr["controlador"].ToString(),
                            vista = dr["vista"].ToString(),
                            icono = dr["icono"].ToString()
                        });
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error al obtener los permisos del usuario: " + ex.Message);
            }
            
            return lst;
        }
    }
}
