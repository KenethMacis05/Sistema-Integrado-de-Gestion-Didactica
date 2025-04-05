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