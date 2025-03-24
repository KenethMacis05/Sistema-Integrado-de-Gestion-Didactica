const listarUsuariosUrl = config.listarUsuariosUrl;
const guardarUsuariosUrl = config.guardarUsuariosUrl;

var filaSeleccionada

function abrirModal(json) {
    $("#idUsuario").val("0");
    $("#usuario").val("");
    $("#correo").val("");
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
        $("#contrasena").val(json.contrasena);
        $("#priNombre").val(json.pri_nombre);
        $("#segNombre").val(json.seg_nombre);
        $("#priApellido").val(json.pri_apellido);
        $("#segApellido").val(json.seg_apellido);        
        $("#estado").prop("checked", json.estado === true);
    }

    $("#createUser").modal("show");
}

$("#datatable tbody").on("click", '.btn-editar', function () {
    filaSeleccionada = $(this).closest("tr");

    var data = dataTable.row(filaSeleccionada).data()

    abrirModal(data)
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
        fk_rol: $("#rol").val(),
        estado: $("#estado").prop("checked")
    };

    jQuery.ajax({
        url: guardarUsuariosUrl,      
        type: "POST",
        data: JSON.stringify({ usuario: Usuario }),
        dataType: "json",
        contentType: "application/json; charset=utf-8",

        beforeSend: function () {
            console.log("Enviando solicitud...");
            // Aquí puedes mostrar un loader o spinner
        },

        success: function (data) {
            // Aquí procesas la respuesta exitosa del servidor
            

            // Usuario Nuevo
            if (Usuario.id_usuario == 0) {
                if (data.Resultado != 0) {
                    Usuario.id_usuario = data.Resultado
                    dataTable.row.add(Usuario).draw(false)

                    $("#createUser").modal("hide");
                } else {

                    $("#createUser").modal("hide");

                    Swal.fire({
                        icon: 'error',
                        title: 'Error al crear el usuario',
                        text: 'No se pudo eliminar el usuario. Por favor, inténtalo de nuevo más tarde.',
                        text: data.Mensaje,
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


            }

            // Actualizar Usuario
            else
            {
                if (data.Resultado) {
                    dataTable.row(filaSeleccionada).data(Usuario)
                    filaSeleccionada = null;

                    $("#createUser").modal("hide");
                } else {

                    $("#createUser").modal("hide");

                    Swal.fire({
                        icon: 'error',
                        title: 'Error al crear el usuario',
                        text: 'No se pudo editar el usuario. Por favor, inténtalo de nuevo más tarde.',
                        text: data.Mensaje,
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

            }

            console.log("Respuesta exitosa:", data);


        },

        error: function (xhr, status, error) {
            console.error("Error en la solicitud:");
            console.error("Estado:", status); // Ejemplo: "error"
            console.error("Código de estado:", xhr.status); // Ejemplo: 404, 500
            console.error("Mensaje de error:", error); // Mensaje de error (si lo hay)
            console.error("Respuesta del servidor:", xhr.responseText); // Mensaje de respuesta del servidor (si lo hay)
            console.error("Usuario:", Usuario);
            console.error("Datos:", JSON.stringify({ usuario: Usuario }));
            console.error("URL:", guardarUsuariosUrl);
            console.error(data.Mensaje);
        },

        complete: function () {
            console.log("Solicitud completada.");
            // Aquí puedes ocultar el loader o realizar acciones post-solicitud
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
        { data: "pri_nombre" },
        { data: "pri_apellido" },
        { data: "correo" },
        {
            data: "estado",
            render: function (valor) {
                return valor
                    ? "<div class='d-flex justify-content-center align-items-center'><span class='badge text-bg-success'>SI</span></div>"
                    : "<div class='d-flex justify-content-center align-items-center'><span class='badge text-bg-danger'>NO</span></div>";
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