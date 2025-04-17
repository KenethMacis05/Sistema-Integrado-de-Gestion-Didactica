const listarRolUrl = config.listarRolUrl;
const guardarRolUrl = config.guardarRolUrl;
const eliminarRolUrl = config.eliminarRolUrl;
var filaSeleccionada
let dataTable;

const dataTableOptions = {
    ...dataTableConfig,

    ajax: {
        url: listarRolUrl,
        type: "GET",
        dataType: "json"
    },

    columns: [        
        { data: "descripcion" },        
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
    ],
};

function abrirModal(json) {
    $("#idRol").val("0");
    $("#descripcion").val("");
    $("#estado").prop("checked", true);

    if (json !== null) {
        $("#idRol").val(json.id_rol);
        $("#descripcion").val(json.descripcion);
        $("#estado").prop("checked", json.estado === true);
    }

    $("#GuardarRol").modal("show");
}

//Boton seleccionar rol para editar
$("#datatable tbody").on("click", '.btn-editar', function () {
    filaSeleccionada = $(this).closest("tr");

    var data = dataTable.row(filaSeleccionada).data()

    abrirModal(data)
});

//Boton eliminar usuario
$("#datatable tbody").on("click", '.btn-eliminar', function () {
    const rolseleccionado = $(this).closest("tr");
    const data = dataTable.row(rolseleccionado).data();

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
                title: "Eliminando rol",
                html: "Por favor espere...",
                allowOutsideClick: false,
                didOpen: () => {
                    Swal.showLoading();
                }
            });

            // Enviar petición AJAX
            $.ajax({
                url: eliminarRolUrl,
                type: "POST",
                data: JSON.stringify({ id_rol: data.id_rol }),
                dataType: "json",
                contentType: "application/json; charset=utf-8",

                success: function (response) {
                    Swal.close();
                    if (response.Respuesta) {

                        dataTable.row(rolseleccionado).remove().draw();

                        showAlert("¡Eliminado!", response.Mensaje || "Rol eliminado correctamente", "success");

                    } else {
                        // Mostrar alerta de error

                        showAlert("Error", response.Mensaje || "No se pudo eliminar el rol", "error");
                    }
                },
                error: (xhr) => {
                    showAlert("Error", `Error al conectar con el servidor: ${xhr.statusText}`, "error");
                }
            });
        }
    });
});

function Guardar() {    
    var Rol = {
        id_rol: $("#idRol").val(),
        descripcion: $("#descripcion").val(),
        estado: $("#estado").prop("checked")
    };

    // Mostrar loader de espera
    Swal.fire({
        title: "Procesando",
        html: "Guardando datos del rol...",
        allowOutsideClick: false,
        didOpen: () => {
            Swal.showLoading();
        }
    });

    jQuery.ajax({
        url: guardarRolUrl,
        type: "POST",
        data: JSON.stringify({ rol: Rol }),
        dataType: "json",
        contentType: "application/json; charset=utf-8",

        success: function (data) {
            Swal.close();

            // Rol Nuevo
            if (Rol.id_rol == 0) {
                if (data.Resultado != 0) {
                    Rol.id_rol = data.Resultado;
                    dataTable.row.add(Rol).draw(false);
                    $("#GuardarRol").modal("hide");

                    showAlert("¡Éxito!", `Rol creado correctamente`, "success");
                    
                } else {
                    $("#GuardarRol").modal("hide");

                    showAlert("Error", data.Mensaje, "error");
                   
                }
            }
            // Actualizar rol
            else {
                if (data.Resultado) {
                    dataTable.row(filaSeleccionada).data(Rol);
                    filaSeleccionada = null;
                    $("#GuardarRol").modal("hide");

                    showAlert("¡Éxito!", `Rol actualizado correctamente`, "success");
                    
                } else {
                    $("#GuardarRol").modal("hide");

                    showAlert("Error", data.Mensaje, "error");
                   
                }
            }
        },
        error: (xhr) => {            
            showAlert("Error", `Error al conectar con el servidor: ${xhr.statusText}`, "error");
        }
    });
}

$(document).ready(function () {
    dataTable = $("#datatable").DataTable(dataTableOptions);   
});