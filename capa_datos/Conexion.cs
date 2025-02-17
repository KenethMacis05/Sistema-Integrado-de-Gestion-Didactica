using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Security.AccessControl;

namespace capa_datos
{
    public class Conexion
    {
        //public static string conexion = ConfigurationManager.ConnectionStrings["cadena"].ToString();
        public static string conexion;

        static Conexion()
        {
            try
            {
                conexion = ConfigurationManager.ConnectionStrings["cadena"].ConnectionString;
            }
            catch (Exception ex)
            {
                throw new Exception("Error al obtener la cadena de conexión: " + ex.Message);
            }
        }

        public static string TestConnection()
        {
            using (SqlConnection conn = new SqlConnection(conexion))
            {
                try
                {
                    conn.Open();
                    return "Conexion exitosa";
                }
                catch (Exception ex)
                {
                    return "Error: " + ex.Message;
                }
            }
        }

    }
}
