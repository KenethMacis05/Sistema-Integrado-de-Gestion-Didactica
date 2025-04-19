const listarRolUrl = config.listarRolUrl;
const guardarRolUrl = config.guardarRolUrl;
const eliminarRolUrl = config.eliminarRolUrl;
var filaSeleccionada
let dataTable;

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


$("#datatable tbody").on("click", '.btn-editar', function () {
    filaSeleccionada = $(this).closest("tr");
    var data = dataTable.row(filaSeleccionada).data()
    abrirModal(data)
});

function Guardar() {
    var Rol = {
        id_rol: $("#idRol").val(),
        descripcion: $("#descripcion").val(),
        estado: $("#estado").prop("checked")
    };
    
    showLoadingAlert("Procesando", "Guardando datos del rol...");    

    jQuery.ajax({
        url: guardarRolUrl,
        type: "POST",
        data: JSON.stringify({ rol: Rol }),
        dataType: "json",
        contentType: "application/json; charset=utf-8",

        success: function (data) {
            Swal.close();
            $("#GuardarRol").modal("hide");

            // Rol Nuevo
            if (Rol.id_rol == 0) {
                if (data.Resultado != 0) {
                    Rol.id_rol = data.Resultado;
                    dataTable.row.add(Rol).draw(false);            
                    showAlert("¡Éxito!", `Rol creado correctamente`, "success");
                } else { showAlert("Error", data.Mensaje || "Error al crear el rol", "error"); }
            }
            // Actualizar rol
            else {
                if (data.Resultado) {
                    dataTable.row(filaSeleccionada).data(Rol);
                    filaSeleccionada = null;
                    showAlert("¡Éxito!", `Rol actualizado correctamente`, "success");
                } else { showAlert("Error", data.Mensaje || "Error al actualizar el rol", "error"); }
            }
        },
        error: (xhr) => { showAlert("Error", `Error al conectar con el servidor: ${xhr.statusText}`, "error"); }
    });
}

//Boton eliminar rol
$("#datatable tbody").on("click", '.btn-eliminar', function () {
    const rolseleccionado = $(this).closest("tr");
    const data = dataTable.row(rolseleccionado).data();
    
    confirmarEliminacion().then((result) => {
        if (result.isConfirmed) {
            showLoadingAlert("Eliminando rol", "Por favor espere...")

            // Enviar petición AJAX
            $.ajax({
                url: eliminarRolUrl,
                type: "POST",
                data: JSON.stringify({ id_rol: data.id_rol }),
                dataType: "json",
                contentType: "application/json; charset=utf-8",

                success: function (response) {
                    Swal.close();

                    switch (response.Resultado) {
                        case 1:
                            dataTable.row(rolseleccionado).remove().draw();
                            showAlert("¡Eliminado!", response.Mensaje || "Rol eliminado correctamente", "success");
                            break;
                        case 2:
                            showAlert("No se puede eliminar", response.Mensaje || "El rol está relacionado con uno o más usuarios.", "warning");
                            break;
                        default:
                            showAlert("Error", response.Mensaje || "Ocurrió un error al intentar eliminar el rol.", "error");
                            break;
                    }
                },
                error: (xhr) => { showAlert("Error", `Error al conectar con el servidor: ${xhr.statusText}`, "error"); }
            });
        }
    });
});

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

$(document).ready(function () {
    dataTable = $("#datatable").DataTable(dataTableOptions);   
});