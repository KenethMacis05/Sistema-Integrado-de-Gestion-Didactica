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
        public bool VerificarPermiso(int IdUsuario, string controlador, string accion)
        {
            bool tienePermiso = false;

            try
            {
                using (SqlConnection conexion = new SqlConnection(Conexion.conexion))
                {
                    SqlCommand cmd = new SqlCommand("usp_VerificarPermiso", conexion);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("IdUsuario", IdUsuario);
                    cmd.Parameters.AddWithValue("Controlador", controlador);
                    cmd.Parameters.AddWithValue("Accion", accion);

                    conexion.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            tienePermiso = Convert.ToBoolean(dr["tiene_permiso"]);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error al verificar permiso: " + ex.Message);
            }

            return tienePermiso;
        }

        public List<PERMISOS> ObtenerPermisosPorRol(int IdRol)
        {

            List<PERMISOS> lst = new List<PERMISOS>();

            try
            {
                using (SqlConnection conexion = new SqlConnection(Conexion.conexion))
                {

                    SqlCommand cmd = new SqlCommand("usp_LeerPermisosPorRol", conexion);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("IdRol", IdRol);

                    conexion.Open();

                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            lst.Add(
                                new PERMISOS
                                {
                                    id_permiso = Convert.ToInt32(dr["id_permiso"]),

                                    Controller = new CONTROLLER
                                    {
                                        id_controlador = Convert.ToInt32(dr["id_controlador"]),
                                        controlador = dr["controlador"].ToString(),
                                        accion = dr["accion"].ToString(),
                                        descripcion = dr["descripcion"].ToString(),
                                        tipo = dr["tipo"].ToString(),                                                                            
                                    },
                                    estado = Convert.ToBoolean(dr["estado"])
                                }
                            );
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error al listar los permisos: " + ex.Message);
            }
            return lst;
        }

        public List<CONTROLLER> ObtenerPermisosNoAsignados(int IdRol)
        {
            List<CONTROLLER> lst = new List<CONTROLLER>();

            try
            {
                using (SqlConnection conexion = new SqlConnection(Conexion.conexion))
                {

                    SqlCommand cmd = new SqlCommand("usp_LeerPermisosNoAsignados", conexion);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("IdRol", IdRol);

                    conexion.Open();

                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            lst.Add(
                                new CONTROLLER
                                {
                                    id_controlador = Convert.ToInt32(dr["id_controlador"]),
                                    controlador = dr["controlador"].ToString(),
                                    accion = dr["accion"].ToString(),
                                    descripcion = dr["descripcion"].ToString(),
                                    tipo = dr["tipo"].ToString(),                                    
                                }
                            );
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error al listar los permisos: " + ex.Message);
            }
            return lst;
        }

        public int AsignarPermiso(int IdRol, int IdControlador)
        {
            try
            {
                using (SqlConnection conexion = new SqlConnection(Conexion.conexion))
                {
                    SqlCommand cmd = new SqlCommand("usp_AsignarPermiso", conexion);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("IdRol", IdRol);
                    cmd.Parameters.AddWithValue("IdControlador", IdControlador);

                    conexion.Open();
                    return Convert.ToInt32(cmd.ExecuteScalar());
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error al asignar permiso: " + ex.Message);
            }
        }
    }
}
