const listarCarpetasUrl = config.listarCarpetasUrl;
const guardarCarpetaUrl = config.guardarCarpetaUrl;
const eliminarCarpetaUrl = config.eliminarCarpetaUrl;
const compartirCarpetaUrl = config.compartirCarpetaUrl;
const subirArchivoUrl = config.subirArchivoUrl;

function abrirModalCarpeta(json) {
    $("#idCarpeta").val("0");
    $("#nombre").val("");

    if (json !== null) {
        $("#idCarpeta").val(json.id_carpeta);        
        $("#nombre").val(json.nombre);        
    }

    $("#createCarpeta").modal("show");
}

// Seleccionar los datos de la carpeta para editar
$(document).on('click', '.btn-editar', function (e) {
    e.preventDefault();
    const data = {
        id_carpeta: $(this).data('carpeta-id'),
        nombre: $(this).data('carpeta-nombre')
    };
    abrirModalCarpeta(data);
});

function GuardarCarpeta() {

    var Carpeta = {
        id_carpeta: $("#idCarpeta").val(),
        nombre: $("#nombre").val(),        
    };

    if (!Carpeta.nombre) {
        Swal.fire("Campo obligatorio", "El nombre de la carpeta no puede estar vacío", "warning");
        return;
    }

    showLoadingAlert("Procesando", "Guardando datos la carpeta...");    

    jQuery.ajax({
        url: guardarCarpetaUrl,
        type: "POST",
        data: JSON.stringify(Carpeta),
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        success: function (data) {
            Swal.close();                        
            $("#createCarpeta").modal("hide");

            if (data.Resultado || data.Respuesta) {
                const mensaje = data.Mensaje || (Carpeta.id_carpeta == 0 ? "Carpeta creada correctamente" : "Carpeta actualizada correctamente");
                showAlert("¡Éxito!", mensaje, "success");
                cargarCarpetas();
            }
            else {
                const mensaje = data.Mensaje || (Carpeta.id_carpeta == 0 ? "No se pudo crear la carpeta" : "No se pudo actualizar la carpeta");                
                showAlert("Error", mensaje, "error");
            }
        },
        error: (xhr) => { showAlert("Error", `Error al conectar con el servidor: ${xhr.statusText}`, "error"); }
    });
}

// Eliminar carpeta
$(document).on('click', '.btn-eliminar', function (e) {
    e.preventDefault();
    const idCarpeta = $(this).data('carpeta-id');    
    
    confirmarEliminacion().then((result) => {

        if (result.isConfirmed) {
            showLoadingAlert("Eliminando carpeta", "Por favor espere...")
            
            // Enviar petición AJAX
            $.ajax({
                url: eliminarCarpetaUrl,
                type: "POST",
                data: JSON.stringify({ id_carpeta: idCarpeta }),
                dataType: "json",
                contentType: "application/json; charset=utf-8",

                success: function (response) {
                    Swal.close();
                    if (response.Respuesta) {
                        showAlert("¡Eliminado!", response.Mensaje || "Carpeta eliminada correctamente", "success", true);
                        cargarCarpetas();
                    } else { showAlert("Error", response.Mensaje || "No se pudo eliminar la carpeta", "error"); }                    
                },                
                error: (xhr) => { showAlert("Error", `Error al conectar con el servidor: ${xhr.statusText}`, "error"); }
            });
        }
    });
});

// Función para cargar las carpetas
function cargarCarpetas() {
    $.ajax({
        url: config.listarCarpetasUrl,
        type: 'GET',
        dataType: 'json',
        beforeSend: () => $('#contenedor-carpetas').LoadingOverlay("show"),        
        success: function (response) {
            if (response.data && response.data.length > 0) {
                let html = '';
                const colors = ['primary', 'warning', 'danger', 'success', 'info', 'secondary'];

                $.each(response.data, function (index, carpeta) {
                    const color = colors[index % colors.length];
                    html += `
                    <div class="col-sm-6 col-md-4 col-lg-3">
                        <div class="card file-manager-group h-100 shadow-sm">
                            <div class="card-body d-flex align-items-center">
                                <i class="fas fa-folder-open fa-2x text-${color} me-3 d-none"></i>
                                <i class="fas fa-folder fa-2x text-${color} me-3"></i>
                                <div class="file-manager-group-info flex-fill">
                                    <a href="#" class="file-manager-group-title h5 d-block text-decoration-none text-dark">${carpeta.nombre}</a>
                                    <span class="file-manager-group-about text-muted small">${formatASPNetDate(carpeta.fecha_registro)}</span>
                                </div>
                                <div class="ms-auto">
                                    <a href="#" class="dropdown-toggle file-manager-recent-file-actions" 
                                        data-bs-toggle="dropdown" data-carpeta-id="${carpeta.id_carpeta}">
                                        <i class="fas fa-ellipsis-v"></i>
                                    </a>
                                    <ul class="dropdown-menu dropdown-menu-end">
                                        <li>
                                            <a class="dropdown-item btn-subirArchivo" href="#"
                                            data-carpeta-id="${carpeta.id_carpeta}" 
                                            data-carpeta-nombre="${carpeta.nombre}">
                                            <i class="fas fa-file me-2"></i>Subir Archivo</a>
                                        </li>
                                        <li><a class="dropdown-item btn-compartir" href="#" 
                                            data-carpeta-id="${carpeta.id_carpeta}">
                                            <i class="fas fa-share me-2"></i>Compartir</a></li>
                                        <li><a class="dropdown-item btn-descargar" href="#" 
                                            data-carpeta-id="${carpeta.id_carpeta}">
                                            <i class="fas fa-download me-2"></i>Descargar</a></li>
                                        <li>
                                            <a class="dropdown-item btn-editar" href="#" 
                                            data-carpeta-id="${carpeta.id_carpeta}" 
                                            data-carpeta-nombre="${carpeta.nombre}">
                                            <i class="fas fa-edit me-2"></i>Renombrar</a>
                                        </li>
                                        <li><a class="dropdown-item btn-eliminar" href="#" 
                                            data-carpeta-id="${carpeta.id_carpeta}">
                                            <i class="fas fa-trash me-2"></i>Eliminar</a></li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>`;
                });

                $('#contenedor-carpetas').html(html);
            } else {
                $('#contenedor-carpetas').html('<div class="alert alert-light">No hay carpetas disponibles</div>');
            }
        },
        error: function () {
            $('#contenedor-carpetas').html('<div class="alert alert-danger">Error al cargar las carpetas</div>');
        },
        complete: () => $('#contenedor-carpetas').LoadingOverlay("hide")
    });
}

// EN DESARROLLO (Abrir modal para subir archivo)
function abrirModalSubirArchivo(json) {
    $("#idCarpeta2").val("0");
    $("#nombre2").val("");
    $("#file").val("");

    if (json !== null) {
        $("#idCarpeta2").val(json.id_carpeta);
        $("#nombre2").val(json.nombre);
    }
    $("#subirArchivo").modal("show");
}

// EN DESARROLLO (Seleccionar los datos de la carpeta para subir un archivo)
$(document).on('click', '.btn-subirArchivo', function (e) {
    e.preventDefault();
    const data = {
        id_carpeta: $(this).data('carpeta-id'),
        nombre: $(this).data('carpeta-nombre')
    };
    abrirModalSubirArchivo(data);
});

// EN DESARROLLO (Subir archivo)
function SubirArchivo() {
    var ArchivoSelecionado = $("#file")[0].files[0];
    var Carpeta = {
        id_carpeta: 16,
        nombre: "DEFAULT_KMACIS",
    };

    // Validar que se haya seleccionado un archivo
    if (!ArchivoSelecionado) {
        Swal.fire("Campo obligatorio", "No ingresó ningún archivo para subir", "warning");
        return;
    }

    // Validar tamaño del archivo (10 MB como máximo)
    if (ArchivoSelecionado.size > 10 * 1024 * 1024) {
        Swal.fire("Archivo demasiado grande", "El archivo no debe superar los 10 MB", "error");
        return;
    }

    // Validar tipo de archivo permitido
    const tiposPermitidos = ["image/jpeg", "image/png", "application/pdf"];
    if (!tiposPermitidos.includes(ArchivoSelecionado.type)) {
        Swal.fire("Tipo de archivo no permitido", "Solo se permiten imágenes y PDFs", "error");
        return;
    }

    // Preparar el objeto FormData
    var request = new FormData();
    request.append("CARPETAJSON", JSON.stringify(Carpeta));
    request.append("ARCHIVO", ArchivoSelecionado);

    showLoadingAlert("Procesando", "Subiendo archivo...");

    jQuery.ajax({
        url: subirArchivoUrl,
        type: "POST",
        data: request,
        processData: false,
        contentType: false,
        success: function (data) {
            Swal.close();
            $("#subirArchivo").modal("hide");

            if (data.Respuesta) {
                Swal.fire("Éxito", data.Mensaje, "success");
                // Aquí puedes agregar lógica adicional, como recargar la lista de archivos
            } else {
                Swal.fire("Error", data.Mensaje, "error");
            }
        },
        error: (xhr) => {
            Swal.fire("Error", `Error al conectar con el servidor: ${xhr.statusText}`, "error");
        }
    });
}

// Efectos hover para carpetas
$(document).on('mouseenter', '.file-manager-group', function () {
    $(this).find('.fa-folder').addClass('d-none');
    $(this).find('.fa-folder-open').removeClass('d-none');
}).on('mouseleave', '.file-manager-group', function () {
    $(this).find('.fa-folder-open').addClass('d-none');
    $(this).find('.fa-folder').removeClass('d-none');
});

// Inicialización
$(document).ready(function () {
    cargarCarpetas();
});




















// Compartir carpeta
$(document).on('click', '.btn-compartir', function (e) {
    e.preventDefault();
    const idCarpeta = $(this).data('carpeta-id');
    console.log(idCarpeta);
    $('#modalCompartir').modal('show');
});
// Función para compartir carpeta
function compartirCarpeta() {
    const idCarpeta = $('#idCarpetaCompartir').val();
    const correo = $('#correoCompartir').val();
    const permisos = $('#permisosCompartir').val();

    Swal.fire({
        title: "Compartiendo",
        html: "Procesando solicitud...",
        allowOutsideClick: false,
        didOpen: () => Swal.showLoading()
    });

    $.ajax({
        url: config.compartirCarpetaUrl,
        type: "POST",
        data: JSON.stringify({
            id_carpeta: idCarpeta,
            correo: correo,
            permisos: permisos
        }),
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        success: function (data) {
            Swal.close();
            if (data.Respuesta) {
                Swal.fire({
                    ...swalConfig,
                    title: "¡Éxito!",
                    text: data.Mensaje || "Carpeta compartida",
                    icon: "success"
                });
                $('#modalCompartir').modal('hide');
                $('#correoCompartir').val('');
            } else {
                Swal.fire({
                    ...swalConfig,
                    title: "Error",
                    text: data.Mensaje || "Error al compartir",
                    icon: "error"
                });
            }
        },
        error: function () {
            Swal.fire({
                ...swalConfig,
                title: "Error",
                text: "Error en el servidor",
                icon: "error"
            });
        }
    });
}

// Descargar carpeta
$(document).on('click', '.btn-descargar', function (e) {
    e.preventDefault();
    const idCarpeta = $(this).data('carpeta-id');
    console.log(idCarpeta);
    // Lógica para descargar (puedes hacer una redirección o AJAX)
    /*window.location.href = '@Url.Action("DescargarCarpeta", "Archivo")' + '?id=' + idCarpeta;*/
});


// Funciones para los modales
function compartirCarpeta() {
    const correo = $('#correoCompartir').val();
    const permisos = $('#permisosCompartir').val();

    // Aquí tu lógica AJAX para compartir
    console.log('Compartir con:', correo, 'Permisos:', permisos);
    $('#modalCompartir').modal('hide');
}