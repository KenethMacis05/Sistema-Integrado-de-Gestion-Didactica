$(document).ready(function () {
    const listarCarpetasUrl = config.listarUsuariosUrl;
    var idUsuario = config.idUsuario1;

    jQuery.ajax({
        url: listarCarpetasUrl,
        type: "GET",
        dataType: "json",
        data: { id_usuario: idUsuario },
        contentType: "application/json; charset=utf-8",
        success: function (data) {
            console.log(data)
        }
    })

    //Carpetas
    debugger
    $.ajax({
        url: listarCarpetasUrl,
        type: 'GET',
        dataType: 'json',
        data: { id_usuario: idUsuario },
        contentType: "application/json; charset=utf-8",

        //Si
        success: function (response) {

            if (response.data && response.data.length > 0) {
                var html = '';
                var colors = ['primary', 'warning', 'danger', 'success', 'info', 'secondary'];

                $.each(response.data, function (index, carpeta) {
                    // Seleccionar color rotativo
                    var color = colors[index % colors.length];

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
                                            <a href="#" class="dropdown-toggle file-manager-recent-file-actions" id="file-manager-recent-${index}" data-bs-toggle="dropdown">
                                                <i class="fas fa-ellipsis-v"></i>
                                            </a>
                                            <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="file-manager-recent-${index}">
                                                <li><a class="dropdown-item" href="#"><i class="fas fa-share me-2"></i>Compartir</a></li>
                                                <li><a class="dropdown-item" href="#"><i class="fas fa-download me-2"></i>Descargar</a></li>
                                                <li><a class="dropdown-item" href="#"><i class="fas fa-eye me-2"></i>Ver detalles</a></li>
                                            </ul>
                                        </div>
                                    </div>
                                </div>
                            </div>`;
                });

                $('#contenedor-carpetas').html(html);
            } else {
                $('#contenedor-carpetas').html('<div class="alert alert-light" role="alert">No hay carpetas disponibles</div>');
            }
        },
        error: function (xhr, status, error) {
            console.error(error);
            $('#contenedor-carpetas').html('<div class="alert alert-danger d-flex align-items-center" role="alert"><i class="fa fa-exclamation-triangle me-2"></i><div>Error al cargar las carpetas</div></div></div>');
        }
    });
    

    $(document).on('mouseenter', '.file-manager-group', function () {
        $(this).find('.fa-folder').addClass('d-none');
        $(this).find('.fa-folder-open').removeClass('d-none');
    }).on('mouseleave', '.file-manager-group', function () {
        $(this).find('.fa-folder-open').addClass('d-none');
        $(this).find('.fa-folder').removeClass('d-none');
    });
});