﻿using System.Web;
using System.Web.Optimization;

namespace modulo_admin
{
    public class BundleConfig
    {
        // Para obtener más información sobre las uniones, visite https://go.microsoft.com/fwlink/?LinkId=301862
        public static void RegisterBundles(BundleCollection bundles)
        {
            bundles.Add(new ScriptBundle("~/bundles/jquery").Include(                        
                        "~/Scripts/jquery-{version}.js"));
            
            bundles.Add(new Bundle("~/bundles/bootstrap").Include(
                      "~/Scripts/bootstrap.bundle.js",
                      "~/Scripts/bootstrap.bundle.min.js",
                      "~/Scripts/bootstrap.js"));

            bundles.Add(new Bundle("~/bundles/complementos").Include(
                      "~/Scripts/fontawesome/all.min.js",
                        "~/Scripts/DataTables/jquery.dataTables.js",
                        "~/Scripts/DataTables/dataTables.responsive.js",
                        "~/Scripts/LoadingOverlay/loadingoverlay.min.js",
                        "~/Scripts/metodosGlobales.js",
                        "~/Scripts/sweetalert2.min.js"));

            bundles.Add(new StyleBundle("~/Content/css").Include(
                      "~/Content/bootstrap.css",
                      "~/Content/icheck-bootstrap.min.css",
                      "~/Content/DataTables/css/jquery.dataTables.css",
                      "~/Content/DataTables/css/responsive.dataTables.css",
                      "~/Content/sweetalert2.css",
                      "~/Content/Site.css"));                         
        }
    }
}
