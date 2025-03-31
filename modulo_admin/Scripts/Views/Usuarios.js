const listarUsuariosUrl = config.listarUsuariosUrl;
const guardarUsuariosUrl = config.guardarUsuariosUrl;
const eliminarUsuariosUrl = config.eliminarUsuariosUrl;

var filaSeleccionada

// Configuración común para todas las alertas
const swalConfig = {
    confirmButtonColor: "#3085d6",
    customClass: {
        popup: 'custom-success-alerta',
        confirmButton: 'custom-confirmar-button',
    }
};

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
    $("#rol").val("1");
    $("#estado").prop("checked", true);

    if (json !== null) {
        $("#idUsuario").val(json.id_usuario);
        $("#usuario").val(json.usuario);
        $("#correo").val(json.correo);
        $("#telefono    ").val(json.telefono);
        $("#contrasena").val(json.contrasena);
        $("#priNombre").val(json.pri_nombre);
        $("#segNombre").val(json.seg_nombre);
        $("#priApellido").val(json.pri_apellido);
        $("#segApellido").val(json.seg_apellido);        
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

jQuery.ajax({
    url: listarUsuariosUrl,
    type: "GET",
    dataType: "json",
    contentType: "application/json; charset=utf-8",
    success: function (data) {
        console.log(data)
    }
})

let dataTable;

const dataTableOptions = {
    lengthMenu: [5, 10, 15, 20, 100, 200, 500],
    pageLength: 5,
    destroy: true,
    language: {
        lengthMenu: "Mostrar _MENU_ registros por página",
        zeroRecords: "Ningún usuario encontrado",
        info: "Mostrando de _START_ a _END_ de un total de _TOTAL_ registros",
        infoEmpty: "Ningún usuario encontrado",
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
    responsive: true,
    ordering: false,

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

///////////////////////////////////////////////

//== Class definition
var SweetAlert2Demo = (function () {
    //== Demos
    var initDemos = function () {
        // Alerta de advertencia
        document.getElementById("alertWarning").addEventListener("click", function () {
            Swal.fire({
                title: "¡Atención!",
                text: "Esta acción no se puede deshacer. ¿Estás seguro de continuar?",
                icon: "warning",
                confirmButtonText: "Sí, continuar",
                confirmButtonClass: "btn btn-warning",
                showCancelButton: true,
                cancelButtonText: "Cancelar",
            });
        });

        // Alerta de error al eliminar usuario
        document.getElementById("alertErrorDeleteUser").addEventListener("click", function () {
            Swal.fire({
                icon: 'error',
                title: 'Error al eliminar usuario',
                text: 'No se pudo eliminar el usuario. Por favor, inténtalo de nuevo más tarde.',
                confirmButtonText: "Entendido",
                confirmButtonColor: "#3085d6",
                customClass: {
                    popup: 'custom-success-alerta',
                    confirmButton: 'custom-confirmar-button',
                }
            }).then(() => {
                window.location.href = '#';
            });
        });

        // Alerta de éxito al crear usuario
        document.getElementById("alertCreateUser").addEventListener("click", function () {
            Swal.fire({
                icon: 'success',
                title: '¡Usuario creado!',
                text: 'El usuario se ha creado correctamente.',
                confirmButtonText: "Aceptar",
                confirmButtonColor: "#3085d6",
                customClass: {
                    popup: 'custom-success-alerta',
                    confirmButton: 'custom-confirmar-button',
                }
            }).then(() => {
                window.location.href = '#';
            });
        });

        // Alerta informativa
        document.getElementById("alertInfo").addEventListener("click", function () {
            Swal.fire({
                title: "Información importante",
                text: "Este proceso puede tardar unos minutos. Por favor, no cierres la ventana.",
                icon: "info",
                confirmButtonText: "Entendido",
                confirmButtonClass: "btn btn-info",
            });
        });

        // Alerta de error en la base de datos
        document.getElementById("alertErrorDataBase").addEventListener("click", function () {
            Swal.fire({
                icon: 'warning',
                title: 'Error en la base de datos',
                text: 'Hubo un problema al conectar con la base de datos. ¿Deseas volver a la pantalla anterior?',
                confirmButtonText: "Sí, volver",
                cancelButtonText: "No, quedarme aquí",
                showCancelButton: true,
                customClass: {
                    popup: 'custom-success-alerta',
                    confirmButton: 'custom-confirmar-button',
                }
            }).then((result) => {
                if (result.isConfirmed) {
                    window.location.href = '#';
                }
            });
        });
    };

    return {
        //== Init
        init: function () {
            initDemos();
        },
    };
})();

// Inicialización
document.addEventListener("DOMContentLoaded", function () {
    SweetAlert2Demo.init();
});

//== Class Initialization
jQuery(document).ready(function () {
    SweetAlert2Demo.init();
});



// Alerta de error al eliminar usuario
function alertErrorCreateUser() {
    Swal.fire({
        icon: 'error',
        title: 'Error al eliminar usuario',
        text: 'No se pudo eliminar el usuario. Por favor, inténtalo de nuevo más tarde.',
        confirmButtonText: "Entendido",
        confirmButtonColor: "#3085d6",
        customClass: {
            popup: 'custom-success-alerta',
            confirmButton: 'custom-confirmar-button',
        }
    }).then(() => {
        window.location.href = '#';
    });
}


//Alerta de: "¿Desea eliminar este usuario?"
function alertDeleteUser() {
    Swal.fire({
        position: 'top-center',
        icon: 'question',
        title: "¿Desea eliminar este usuario?",
        text: "Si acepta se eliminara el usuario",
        showDenyButton: true,
        confirmButtonColor: "#3085d6",
        cancelButtonColor: "#d33",
        confirmButtonText: "¡Sí, bórralo!",
        denyButtonText: `Cancelar`,
        customClass: {
            popup: 'custom-alerta',
            confirmButton: 'custom-confirmar-button',
            denyButton: 'custom-cancelar-button',
        }
    }).then((result) => {
        if (result.isConfirmed) {
            window.location.href = '#';
        } else if (result.isDenied) {
            console.log("Error al eleminar el usuario")
        }
    });
}