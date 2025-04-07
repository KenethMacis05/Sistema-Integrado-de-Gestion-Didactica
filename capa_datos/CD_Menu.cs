using capa_entidad;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace capa_datos
{
    public class CD_Menu
    {
        public List<MENU> ObtenerMenuPorUsuario(int IdUsuario)
        {
            List<MENU> lista = new List<MENU>();

            try
            {
                using (SqlConnection conexion = new SqlConnection(Conexion.conexion))
                {
                    SqlCommand cmd = new SqlCommand("usp_ObtenerMenuPorUsuario", conexion);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("IdUsuario", IdUsuario);

                    conexion.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            var menu = new MENU()
                            {
                                id_menu = Convert.ToInt32(dr["id_menu"]),
                                nombre = dr["nombre"].ToString(),
                                icono = dr["icono"].ToString(),
                                orden = dr["orden"] != DBNull.Value ? Convert.ToInt32(dr["orden"]) : 0,                                
                            };

                            // Si tiene controlador asociado, cargar sus datos
                            if (dr["controlador"] != DBNull.Value)
                            {
                                menu.Controller = new CONTROLLER()
                                {
                                    controlador = dr["controlador"].ToString(),
                                    accion = dr["vista"].ToString() // Nota: vista = accion en el SP
                                };
                            }

                            lista.Add(menu);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                lista = new List<MENU>();
                throw new Exception("Error al obtener menú del usuario: " + ex.Message);
            }

            return lista;
        }
    }
}
