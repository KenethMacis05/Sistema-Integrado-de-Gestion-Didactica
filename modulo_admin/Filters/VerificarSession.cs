﻿using capa_entidad;
using capa_negocio;
using modulo_admin.Controllers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace modulo_admin.Filters
{
    public class VerificarSession : ActionFilterAttribute
    {
        public override void OnActionExecuting(ActionExecutingContext filterContext)
        {
            var controller = filterContext.Controller as Controller;
            USUARIOS sesionUsuario = null;

            // Verificar si hay sesión activa
            if (controller != null)
            {
                sesionUsuario = (USUARIOS)controller.Session["UsuarioAutenticado"];
            }

            // Redirigir si no hay sesión y no está en AccesoController
            if (sesionUsuario == null)
            {
                if (!(controller is AccesoController))
                {
                    filterContext.Result = new RedirectResult("~/Acceso/Index");
                    return;
                }
            }            
            else
            {

                if (sesionUsuario.reestablecer && !(controller is AccesoController))
                {
                    // Redirigir si necesita restablecer contraseña
                    filterContext.Result = new RedirectResult("~/Acceso/Reestablecer");
                    return;
                    
                }

                else
                {
                    // Redirigir si ya está autenticado y trata de acceder a AccesoController
                    if (controller is AccesoController)
                    {
                        filterContext.Result = new RedirectResult("~/Home/Index");
                        return;
                    }

                }
            }

            // Asignar valores al ViewBag (incluye casos donde sesionUsuario es null)
            try
            {
                sesionUsuario = sesionUsuario ?? new USUARIOS(); // Si es null, crea uno nuevo
                controller.ViewBag.NombreUsuario = $"{sesionUsuario.pri_nombre} {sesionUsuario.pri_apellido}";
                controller.ViewBag.RolUsuario = sesionUsuario.descripcion;
                controller.ViewBag.idUsuario = sesionUsuario.id_usuario;
            }
            catch (Exception)
            {
                controller.ViewBag.Mensaje = "Error al cargar los datos del usuario";
            }

            // Obtener información de la ruta solicitada
            string controlador = filterContext.ActionDescriptor.ControllerDescriptor.ControllerName;
            string accion = filterContext.ActionDescriptor.ActionName;

            // No verificar permisos para Home/Index ni Home/SinPermisos
            if (!
                (controlador.Equals("Home", StringComparison.OrdinalIgnoreCase) ||
                 controlador.Equals("Acceso", StringComparison.OrdinalIgnoreCase) &&

                 (accion.Equals("Index", StringComparison.OrdinalIgnoreCase) ||
                  accion.Equals("CerrarSesion", StringComparison.OrdinalIgnoreCase) ||
                  accion.Equals("Reestablecer", StringComparison.OrdinalIgnoreCase)
                  )))
            {
                
                CN_Permisos CN_Permisos = new CN_Permisos();
                bool tienePermiso = CN_Permisos.VerificarPermiso(sesionUsuario.id_usuario, controlador, accion);

                if (!tienePermiso)
                {
                    filterContext.Result = new RedirectResult("~/Home/Index");
                    controller.ViewBag.MensajeNoTienePermisos = "Usted no tiene permisos para realizar esta acción";
                    return;
                }
            }

            base.OnActionExecuting(filterContext);
        }
    }
}