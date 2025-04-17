const listarUsuariosUrl = config.listarUsuariosUrl;
const listarRolesUrl = config.listarRolesUrl;
const guardarUsuariosUrl = config.guardarUsuariosUrl;
const eliminarUsuariosUrl = config.eliminarUsuariosUrl;
let dataTable;
var filaSeleccionada;

// Cargar roles en el selec
jQuery.ajax({
    url: listarRolesUrl,
    type: "GET",
    dataType: "json",
    contentType: "application/json; charset=utf-8",

    success: function (response) {
        $('#obtenerRol').empty().append('<option value="" disabled selected>Seleccione un rol...</option>');
        $.each(response.data, function (index, rol) {
            $('#obtenerRol').append(`<option value="${rol.id_rol}">${rol.descripcion}</option>`);
        });
    },

    error: () => showAlert("Error", "Error al cargar los Roles", "error")
})

//Abrir modal
function abrirModal(json) {
    $("#idUsuario").val("0");
    $("#usuario").val("");
    $("#correo").val("");
    $("#telefono").val("");
    $("#contrasena").val("");
    $("#priNombre").val("");
    $("#segNombre").val("");
    $("#priApellido").val("");
    $("#segApellido").val("");
    $("#obtenerRol").val("");
    $("#estado").prop("checked", true);

    if (json !== null) {
        $("#idUsuario").val(json.id_usuario);
        $("#usuario").val(json.usuario);
        $("#correo").val(json.correo);
        $("#telefono").val(json.telefono);
        $("#contrasena").val(json.contrasena);
        $("#priNombre").val(json.pri_nombre);
        $("#segNombre").val(json.seg_nombre);
        $("#priApellido").val(json.pri_apellido);
        $("#segApellido").val(json.seg_apellido);               
        if (json.fk_rol) {
            $("#obtenerRol").val(json.fk_rol);
        }
        $("#estado").prop("checked", json.estado === true);
    }

    $("#createUser").modal("show");
}

//Boton seleccionar usuario para editar
$("#datatable tbody").on("click", '.btn-editar', function () {
    filaSeleccionada = $(this).closest("tr");

    var data = dataTable.row(filaSeleccionada).data()

    abrirModal(data)
});

//Boton eliminar usuario
$("#datatable tbody").on("click", '.btn-eliminar', function () {
    const usuarioseleccionado = $(this).closest("tr");
    const data = dataTable.row(usuarioseleccionado).data();    

    // Alerta de confirmación
    Swal.fire({
        ...swalConfig,
        title: "¿Estás seguro?",
        text: "¡Esta acción no se puede deshacer!",
        icon: "warning",
        showCancelButton: true,
        confirmButtonText: "Sí, eliminar",
        cancelButtonText: "Cancelar",
        reverseButtons: true
    }).then((result) => {

        if (result.isConfirmed) {
            // Mostrar loader
            Swal.fire({
                title: "Eliminando usuario",
                html: "Por favor espere...",
                allowOutsideClick: false,
                didOpen: () => {
                    Swal.showLoading();
                }
            });

            // Enviar petición AJAX
            $.ajax({
                url: eliminarUsuariosUrl,
                type: "POST",
                data: JSON.stringify({ id_usuario: data.id_usuario }),
                dataType: "json",
                contentType: "application/json; charset=utf-8",

                success: function (response) {
                    Swal.close();
                    if (response.Respuesta) {
                        // Eliminar fila de DataTable
                        dataTable.row(usuarioseleccionado).remove().draw();

                        // Mostrar alerta de éxito
                        Swal.fire({
                            ...swalConfig,
                            title: "¡Eliminado!",
                            text: response.Mensaje || "Usuario eliminado correctamente",
                            icon: "success",
                            confirmButtonClass: "btn btn-success"
                        });
                    } else {
                        // Mostrar alerta de error
                        Swal.fire({
                            ...swalConfig,
                            title: "Error",
                            text: response.Mensaje || "No se pudo eliminar el usuario",
                            icon: "error"
                        });
                    }
                },

                error: function (xhr) {
                    Swal.fire({
                        ...swalConfig,
                        title: "Error",
                        text: "Error al conectar con el servidor",
                        icon: "error"
                    });
                }
            });
        }
    });
});

function Guardar() {    

    var Usuario = {
        id_usuario: $("#idUsuario").val(),
        pri_nombre: $("#priNombre").val(),
        seg_nombre: $("#segNombre").val(),
        pri_apellido: $("#priApellido").val(),
        seg_apellido: $("#segApellido").val(),
        usuario: $("#usuario").val(),
        contrasena: $("#contrasena").val(),
        correo: $("#correo").val(),
        telefono: $("#telefono").val(),
        fk_rol: $("#rol").val(),
        estado: $("#estado").prop("checked")
    };

    // Mostrar loader de espera
    Swal.fire({
        title: "Procesando",
        html: "Guardando datos del usuario...",
        allowOutsideClick: false,
        didOpen: () => {
            Swal.showLoading();
        }
    });

    jQuery.ajax({
        url: guardarUsuariosUrl,
        type: "POST",
        data: JSON.stringify({ usuario: Usuario }),
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        success: function (data) {
            Swal.close();

            // Usuario Nuevo
            if (Usuario.id_usuario == 0) {
                if (data.Resultado != 0) {
                    Usuario.id_usuario = data.Resultado;
                    dataTable.row.add(Usuario).draw(false);
                    $("#createUser").modal("hide");

                    // Mostrar alerta de éxito
                    Swal.fire({
                        ...swalConfig,
                        title: "¡Éxito!",
                        text: "Usuario creado correctamente",
                        icon: "success",
                        confirmButtonText: "Aceptar"
                    });
                } else {
                    $("#createUser").modal("hide");

                    // Mostrar alerta de error
                    Swal.fire({
                        ...swalConfig,
                        title: "Error",
                        text: data.Mensaje || "No se pudo crear el usuario",
                        icon: "error",
                        confirmButtonText: "Entendido"
                    });
                }
            }
            // Actualizar Usuario
            else {
                if (data.Resultado) {
                    dataTable.row(filaSeleccionada).data(Usuario);
                    filaSeleccionada = null;
                    $("#createUser").modal("hide");

                    // Mostrar alerta de éxito
                    Swal.fire({
                        ...swalConfig,
                        title: "¡Éxito!",
                        text: "Usuario actualizado correctamente",
                        icon: "success",
                        confirmButtonText: "Aceptar"
                    });
                } else {
                    $("#createUser").modal("hide");

                    // Mostrar alerta de error
                    Swal.fire({
                        ...swalConfig,
                        title: "Error",
                        text: data.Mensaje || "No se pudo actualizar el usuario",
                        icon: "error",
                        confirmButtonText: "Entendido"
                    });
                }
            }
        },
        error: function (xhr, status, error) {
            Swal.fire({
                ...swalConfig,
                title: "Error en el servidor",
                text: "Ocurrió un error al procesar la solicitud",
                icon: "error",
                confirmButtonText: "Entendido"
            });

            console.error("Error en la solicitud:", {
                status: status,
                error: error,
                statusCode: xhr.status
            });
        }
    });
}

const dataTableOptions = {
    ...dataTableConfig,

    ajax: {
        url: listarUsuariosUrl,
        type: "GET",
        dataType: "json"
    },
   
    columns: [
        { data: "usuario" },
        {
            data: "pri_nombre",
            render: function (data, type, row) {
                return data + ' ' + row.seg_nombre;
            }
        },
        {
            data: "pri_apellido",
            render: function (data, type, row) {
                return data + ' ' + row.seg_apellido;
            }
        },
        { data: "correo" },
        { data: "telefono" },
        {
            data: "estado",
            render: function (valor) {
                return valor
                    ? "<div class='d-flex justify-content-center align-items-center'><span class='badge text-bg-success'>ACTIVO</span></div>"
                    : "<div class='d-flex justify-content-center align-items-center'><span class='badge text-bg-danger'>NO ACTIVO</span></div>";
            },
            width: "90"
        },
        {
            defaultContent:
                '<button type="button" class="btn btn-primary btn-sm btn-editar"><i class="fa fa-pen"></i></button>' +
                '<button type="button" class="btn btn-danger btn-sm ms-2 btn-eliminar"><i class="fa fa-trash"></i></button>',
            width: "90"
        }
    ]
};

$(document).ready(function () {
    dataTable = $("#datatable").DataTable(dataTableOptions);
});