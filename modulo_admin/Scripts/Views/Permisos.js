const listarPermisosPorRolUrl = config.listarPermisosPorRolUrl;
const listarPermisosNoAsignados = config.listarPermisosNoAsignados;
const listarRolesUrl = config.listarRolesUrl;
const AsignarPermisos = config.AsignarPermisos;
let dataTableNoAsignados;
let dataTable;

const dataTableOptions = {
    lengthMenu: [5, 10, 15, 20, 100, 200, 500],
    pageLength: 5,
    destroy: true,
    language: {
        lengthMenu: "Mostrar _MENU_ registros por página",
        zeroRecords: "Ningún permiso encontrado",
        info: "Mostrando de _START_ a _END_ de un total de _TOTAL_ registros",
        infoEmpty: "Ningún rol encontrado",
        infoFiltered: "(filtrados desde _MAX_ registros totales)",
        search: "Buscar:",
        loadingRecords: "Cargando...",
        paginate: {
            first: "Primero",
            last: "Último",
            next: "Siguiente",
            previous: "Anterior"
        }
    },
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
    responsive: true,
    ordering: false,
};

const dataTableNoAsignadosOptions = {
    lengthMenu: [5, 10, 15, 20, 100, 200, 500],
    pageLength: 5,
    destroy: true,
    language: {
        lengthMenu: "Mostrar _MENU_ registros por página",
        zeroRecords: "No hay permisos disponibles para asignar",
        info: "Mostrando de _START_ a _END_ de un total de _TOTAL_ registros",
        infoEmpty: "No hay permisos disponibles",
        infoFiltered: "(filtrados desde _MAX_ registros totales)",
        search: "Buscar:",
        loadingRecords: "Cargando...",
        paginate: {
            first: "Primero",
            last: "Último",
            next: "Siguiente",
            previous: "Anterior"
        }
    },
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
    responsive: true,
    ordering: false,
};

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

    error: function (xhr) {
        Swal.fire({
            ...swalConfig,
            title: "Error",
            text: "Error al cargar los Roles",
            icon: "error"
        });
    }
})

// Mostrar permisos del Rol
$("#btnBuscar").click(function () {
    var IdRol = $('#obtenerRol').val();
    if (!IdRol) {
        Swal.fire({
            ...swalConfig,
            title: "¡Atención!",
            text: "Primero debe seleccionar un rol",
            icon: "warning"
        });
        return false;
    }

    $.ajax({
        url: listarPermisosPorRolUrl,
        type: "GET",
        dataType: "json",
        data: { IdRol: IdRol },
        contentType: "application/json; charset=utf-8",

        beforeSend: function () {
            $(".tbody").LoadingOverlay("show");
        },

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

        complete: function () {
            $(".tbody").LoadingOverlay("hide");
        },

        error: function (xhr) {
            Swal.fire({
                ...swalConfig,
                title: "Error",
                text: "Error al conectar con el servidor",
                icon: "error"
            });
        }
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

        beforeSend: function () {
            $("#dataTablePermisosNoAsignados tbody").LoadingOverlay("show");
        },
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
                        `<input type="checkbox" class="form-check-input permiso-checkbox" 
                                   data-id="${permiso.id_controlador}" value="${permiso.id_controlador}">`
                    ]);
                });
                dataTableNoAsignados.draw();
            } else {
                console.warn("Datos no válidos recibidos", data);
            }
        },
        complete: function () {
            $("#dataTablePermisosNoAsignados tbody").LoadingOverlay("hide");
        },
        error: function (xhr) {
            Swal.fire({
                ...swalConfig,
                title: "Error",
                text: "Error al cargar permisos no asignados",
                icon: "error"
            });
        }
    });
}

// Función para abrir el modal y cargar permisos no asignados
function abrirModal() {
    var IdRol = $('#obtenerRol').val();
    if (!IdRol) {
        Swal.fire({
            ...swalConfig,
            title: "¡Atención!",
            text: "Primero debe seleccionar un rol",
            icon: "warning"
        });
        return false;
    }

    cargarPermisosNoAsignados(IdRol);
    $("#modalPermisos").modal("show");
}

// Guardar nuevos permisos
$('#btnGuardarPermisos').click(function () {
    var IdRol = $('#obtenerRol').val();
    var permisosSeleccionados = [];

    $('#dataTablePermisosNoAsignados tbody').find('.permiso-checkbox:checked').each(function () {
        permisosSeleccionados.push($(this).data('id'));
    });

    if (permisosSeleccionados.length === 0) {
        mostrarNotificacion("!Atención¡", "Debe seleccionar al menos un permiso", "warning");
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
                    mostrarNotificacion(
                        exitosos > 0 ? "Nose" : "Nose",
                        `${exitosos} permisos procesados | ${fallidos} con inconvenientes`,
                        exitosos > 0 ? "info" : "warning"
                    );
                } else {
                    Swal.fire({
                        ...swalConfig,
                        title: "¡Éxito!",
                        text: `Todos los permisos (${exitosos}) fueron procesados correctamente`,
                        icon: "success"
                    });
                }

                $('#modalPermisos').modal('hide');
                $('#btnBuscar').click();
            } else {
                Swal.fire({
                    ...swalConfig,
                    title: "Error",
                    text: response.message || "Ocurrió un error al asignar los permisos",
                    icon: "error"
                });
            }
        },
        error: function (xhr) {
            $.LoadingOverlay("hide");

            Swal.fire({
                ...swalConfig,
                title: "Error",
                text: "Error al conectar con el servidor: " + xhr.statusText,
                icon: "error"
            });
        }
    });
});


// Eliminar permiso
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
$(document).ready(function () {
    dataTable = $("#datatable").DataTable(dataTableOptions);
    dataTableNoAsignados = $("#dataTablePermisosNoAsignados").DataTable(dataTableNoAsignadosOptions);
});