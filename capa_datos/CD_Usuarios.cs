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
        //Listar usuarios
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
                                    pri_nombre = dr["pri_nombre"].ToString(),
                                    seg_nombre = dr["seg_nombre"].ToString(),
                                    pri_apellido = dr["pri_apellido"].ToString(),
                                    seg_apellido = dr["seg_apellido"].ToString(),
                                    usuario = dr["usuario"].ToString(),
                                    contrasena = dr["contrasena"].ToString(),
                                    correo = dr["correo"].ToString(),
                                    fk_rol = Convert.ToInt32(dr["fk_rol"]),
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

        //Login usuario
        public USUARIOS LoginUsuario(string usuario, string contrasena)
        {
            USUARIOS usuarioAutenticado = null; // Usar un solo objeto en lugar de una lista

            using (SqlConnection conexion = new SqlConnection(Conexion.conexion))
            {
                try
                {
                    // Consulta SQL con parámetros
                    string query = "SELECT * FROM USUARIOS WHERE usuario = @usuario AND contrasena = @contrasena AND estado = 1;";
                    SqlCommand cmd = new SqlCommand(query, conexion);

                    // Agregar parámetros
                    cmd.Parameters.AddWithValue("@usuario", usuario);
                    cmd.Parameters.AddWithValue("@contrasena", contrasena);
                    cmd.CommandType = CommandType.Text;

                    conexion.Open();

                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read()) // Si encuentra un registro
                        {
                            usuarioAutenticado = new USUARIOS
                            {
                                id_usuario = Convert.ToInt32(dr["id_usuario"]),
                                pri_nombre = dr["pri_nombre"].ToString(),
                                seg_nombre = dr["seg_nombre"].ToString(),
                                pri_apellido = dr["pri_apellido"].ToString(),
                                seg_apellido = dr["seg_apellido"].ToString(),
                                usuario = dr["usuario"].ToString(),
                                contrasena = dr["contrasena"].ToString(),                                
                                correo = dr["correo"].ToString(),
                                fk_rol = Convert.ToInt32(dr["fk_rol"]),
                                estado = Convert.ToBoolean(dr["estado"])
                            };
                        }
                    }
                }
                catch (Exception ex)
                {
                    throw new Exception("Error al autenticar el usuario: " + ex.Message);
                }
            }

            return usuarioAutenticado; // Retorna el usuario autenticado o null si no se encontró
        }
    }
}
