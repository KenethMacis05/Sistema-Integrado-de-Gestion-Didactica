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

function mostrarAlerta(titulo, mensaje, tipo) {
    const config = {
        title: titulo,
        text: mensaje,
        icon: tipo,
        ...swalConfig,
    }

    Swal.fire(config);
}

// Mostrar notificacion
function mostrarNotificacion(titulo, mensaje, tipo) {
    const config = {
        toast: true,
        position: 'top-end',
        showConfirmButton: false,
        timer: 3000,
        timerProgressBar: true,
        ...swalConfig,
        title: titulo,
        text: mensaje,
        icon: tipo
    };

    Swal.fire(config);
}


$('.checkboxIcheck').iCheck({
    checkboxClass: 'icheckbox_flat-blue',
    radioClass: 'iradio_flat-blue'
});
