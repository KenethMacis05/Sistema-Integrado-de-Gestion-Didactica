//Métodos Globales


//Configuración de las dataTable
const dataTableConfig = {
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
    responsive: true,
    ordering: false
};

// Función para formatear la fecha
function formatASPNetDate(jsonDate) {
    if (!jsonDate) return 'Fecha no disponible';

    // Formato /Date(...)/
    if (typeof jsonDate === 'string' && jsonDate.startsWith('/Date(')) {
        var timestamp = parseInt(jsonDate.substr(6));
        var date = new Date(timestamp);
        return date.toLocaleDateString('es-ES', {
            day: '2-digit',
            month: '2-digit',
            year: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        });
    }

    // Si ya es una fecha válida
    try {
        var date = new Date(jsonDate);
        if (!isNaN(date.getTime())) {
            return date.toLocaleDateString('es-ES', {
                day: '2-digit',
                month: '2-digit',
                year: 'numeric',
                hour: '2-digit',
                minute: '2-digit'
            });
        }
    } catch (e) {
        console.error("Error formateando fecha:", e);
    }

    return 'Fecha no disponible';
}

// Configuración de SweetAlert2
const swalConfig = {
    confirmButtonColor: "#3085d6",
    customClass: {
        popup: 'custom-success-alerta',
        confirmButton: 'custom-confirmar-button',
    }
};


//Mostrar Alerta
function showAlert(title, text, icon, isToast = false) {
    const config = {
        title,
        text,
        icon,
        ...swalConfig,
        ...(isToast && {
            toast: true,
            position: 'top-end',
            showConfirmButton: false,
            timer: 3000,
            timerProgressBar: true
        })
    };

    return Swal.fire(config);
}

function confirmarEliminacion(titulo = "¿Estás seguro?", texto = "¡Esta acción no se puede deshacer!") {
    return Swal.fire({
        ...swalConfig,
        title: titulo,
        text: texto,
        icon: "warning",
        showCancelButton: true,
        confirmButtonText: "Sí, eliminar",
        cancelButtonText: "Cancelar",
        reverseButtons: true
    });
}

function showLoadingAlert(titulo = "Eliminando", mensaje = "Por favor espere...") {
    return Swal.fire({
        title: titulo,
        html: mensaje,
        allowOutsideClick: false,
        didOpen: () => {
            Swal.showLoading();
        }
    });
}

//Mostrar Loading
const showLoading = (element) => {
    $(element).LoadingOverlay("show");
};

//Ocultar Loading
const hideLoading = (element) => {
    $(element).LoadingOverlay("hide");
};