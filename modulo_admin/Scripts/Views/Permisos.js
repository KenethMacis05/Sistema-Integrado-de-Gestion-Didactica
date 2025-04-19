const listarPermisosPorRolUrl = config.listarPermisosPorRolUrl;
const listarPermisosNoAsignados = config.listarPermisosNoAsignados;
const listarRolesUrl = config.listarRolesUrl;
const AsignarPermisos = config.AsignarPermisos;
let dataTableNoAsignados;
let dataTable;

// Cargar roles en el selec
jQuery.ajax({
    url: listarRolesUrl,
    type: "GET",
    dataType: "json",
    contentType: "application/json; charset=utf-8",

    success: function (response) {
        $('#obtenerRol').empty().append('<option value="">Seleccione un rol</option>');
        $.each(response.data, function (index, rol) {
            $('#obtenerRol').append(`<option value="${rol.id_rol}">${rol.descripcion}</option>`);
        });
    },

    error: (xhr) => { showAlert("Error", `Error al conectar con el servidor: ${xhr.statusText}`, "error"); }
})

// Mostrar permisos del Rol
$("#btnBuscar").click(function () {
    var IdRol = $('#obtenerRol').val();
    if (!IdRol) {
        showAlert("¡Atención!", "Primero debe seleccionar un rol", "warning");
        return false;
    }

    $.ajax({
        url: listarPermisosPorRolUrl,
        type: "GET",
        dataType: "json",
        data: { IdRol: IdRol },
        contentType: "application/json; charset=utf-8",

        beforeSend: () => $(".tbody").LoadingOverlay("show"),

        success: function (data) {
            dataTable.clear().draw();

            if (data && data.data && Array.isArray(data.data)) {
                try {
                    $.each(data.data, function (index, permiso) {
                        const controller = permiso.Controller;

                        dataTable.row.add([
                            index + 1,
                            controller.controlador,
                            controller.accion,
                            controller.descripcion,
                            controller.tipo
                        ]);
                    });
                    dataTable.draw();
                } catch (e) {
                    console.error("Error al agregar filas:", e);
                }
            } else {
                console.warn("Datos no válidos recibidos", data);
            }
        },
        complete: () => $(".tbody").LoadingOverlay("hide"),
        error: (xhr) => { showAlert("Error", `Error al conectar con el servidor: ${xhr.statusText}`, "error"); }
    })
});

// Función para cargar permisos no asignados
function cargarPermisosNoAsignados(IdRol) {

    $.ajax({
        url: listarPermisosNoAsignados,
        type: "GET",
        dataType: "json",
        data: { IdRol: IdRol },
        contentType: "application/json; charset=utf-8",

        beforeSend: () => $("#dataTablePermisosNoAsignados tbody").LoadingOverlay("show"),

        success: function (data) {
            dataTableNoAsignados.clear().draw();

            if (data && data.data && Array.isArray(data.data)) {
                $.each(data.data, function (index, permiso) {
                    dataTableNoAsignados.row.add([
                        index + 1,
                        permiso.controlador,
                        permiso.accion,
                        permiso.descripcion,
                        permiso.tipo,
                        `<div class="icheck-primary">
                            <input type="checkbox" class="checkboxIcheck permisoCheckbox"
                                   id="permiso_${permiso.id_controlador}" 
                                   data-id="${permiso.id_controlador}">
                            <label for="permiso_${permiso.id_controlador}"></label>
                         </div>`
                    ]);
                });
                dataTableNoAsignados.draw();

            } else {
                console.warn("Datos no válidos recibidos", data);
            }
        },
        complete: () => $("#dataTablePermisosNoAsignados tbody").LoadingOverlay("hide"),
        error: (xhr) => { showAlert("Error", `Error al conectar con el servidor: ${xhr.statusText}`, "error"); }
    });
}

// Función para abrir el modal y cargar permisos no asignados
function abrirModal() {
    var IdRol = $('#obtenerRol').val();
    if (!IdRol) {
        showAlert("¡Atención!", "Primero debe seleccionar un rol", "warning");
        return false;
    }

    cargarPermisosNoAsignados(IdRol);
    $("#modalPermisos").modal("show");
}

// Guardar nuevos permisos
$('#btnGuardarPermisos').click(function () {
    var IdRol = $('#obtenerRol').val();
    var permisosSeleccionados = [];

    $('#dataTablePermisosNoAsignados tbody').find('.permisoCheckbox:checked').each(function () {
        permisosSeleccionados.push($(this).data('id'));
    });

    if (permisosSeleccionados.length === 0) {
        showAlert("!Atención¡", "Debe seleccionar al menos un permiso", "warning", true);
        return;
    }

    $.LoadingOverlay("hide");

    $.ajax({
        url: AsignarPermisos,
        type: 'POST',
        contentType: 'application/json',
        data: JSON.stringify({
            IdRol: IdRol,
            IdsControladores: permisosSeleccionados
        }),
        success: function (response) {
            $.LoadingOverlay("hide");

            if (response.success) {
                var exitosos = response.totalExitosos;
                var fallidos = response.totalFallidos;

                if (fallidos > 0) {
                    showAlert(
                        exitosos > 0 ? "Proceso parcialmente exitoso" : "Proceso con errores",
                        `${exitosos} permisos procesados correctamente | ${fallidos} con inconvenientes`,
                        exitosos > 0 ? "info" : "warning"
                    );
                } else {
                    showAlert("¡Éxito!", `Todos los permisos (${exitosos}) fueron procesados correctamente`, "success");
                }

                $('#modalPermisos').modal('hide');
                $('#btnBuscar').click();
            } else {
                showAlert("Error", response.message || "Ocurrió un error al asignar los permisos", "error");
            }
        },
        error: (xhr) => {
            $.LoadingOverlay("hide");
            showAlert("Error", `Error al conectar con el servidor: ${xhr.statusText}`, "error");
        }
    });
});


// EN DESAROLLO (Eliminar permiso)
$('#tbPermisos').on('click', '.btn-eliminar-permiso', function () {
    var idPermiso = $(this).data('id');
    var idRol = $('#cboRol').val();

    if (confirm('¿Está seguro de eliminar este permiso?')) {
        $.ajax({
            url: '/Permisos/EliminarPermiso',
            type: 'POST',
            data: {
                idRol: idRol,
                idPermiso: idPermiso
            },
            success: function (response) {
                if (response.success) {
                    $('#btnBuscar').click(); // Refrescar tabla
                }
            }
        });
    }
});

const dataTableOptions = {
    ...dataTableConfig,
    columns: [
        { title: "#" },
        { title: "Controlador" },
        { title: "Acción" },
        { title: "Descripcion" },
        { title: "Tipo" },
        {
            defaultContent:
                '<button type="button" class="btn btn-primary btn-sm btn-editar"><i class="fa fa-pen"></i></button>' +
                '<button type="button" class="btn btn-danger btn-sm ms-2 btn-eliminar"><i class="fa fa-trash"></i></button>',
            width: "90"
        }
    ],
};

const dataTableNoAsignadosOptions = {
    ...dataTableConfig,
    columns: [
        { title: "#" },
        { title: "Controlador" },
        { title: "Acción" },
        { title: "Descripción" },
        { title: "Tipo" },
        {
            title: "Seleccionar",
            orderable: false,
            width: "100px"
        }
    ],
};

$(document).ready(function () {
    dataTable = $("#datatable").DataTable(dataTableOptions);
    dataTableNoAsignados = $("#dataTablePermisosNoAsignados").DataTable(dataTableNoAsignadosOptions);
});