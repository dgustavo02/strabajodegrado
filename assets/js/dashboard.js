(function () {
  // Menú lateral en móviles
  var menu = document.getElementById('sidebar');
  var btn = document.getElementById('btnMenu');
  if (menu && btn) {
    btn.addEventListener('click', function () { menu.classList.toggle('abierto'); });
    document.addEventListener('click', function (e) {
      if (menu.classList.contains('abierto') && !menu.contains(e.target) && !btn.contains(e.target)) {
        menu.classList.remove('abierto');
      }
    });
  }

  // Mensajes que desaparecen solos
  document.querySelectorAll('[data-autodismiss]').forEach(function (a) {
    setTimeout(function () {
      if (window.bootstrap && a.isConnected) { bootstrap.Alert.getOrCreateInstance(a).close(); }
    }, 7000);
  });

  // Confirmación antes de enviar formularios sensibles
  document.querySelectorAll('form[data-confirm]').forEach(function (f) {
    f.addEventListener('submit', function (e) {
      if (!window.confirm(f.getAttribute('data-confirm'))) { e.preventDefault(); }
    });
  });

  // Evita envíos dobles y valida campos requeridos con estilos de Bootstrap
  document.querySelectorAll('form.validar').forEach(function (f) {
    f.addEventListener('submit', function (e) {
      if (!f.checkValidity()) {
        e.preventDefault();
        f.classList.add('was-validated');
        return;
      }
      // Se deshabilita después de armar los datos para no perder el valor del botón pulsado
      setTimeout(function () {
        f.querySelectorAll('button[type="submit"]').forEach(function (b) { b.disabled = true; });
      }, 0);
    });
  });

  // Contador de caracteres para textareas con data-max
  document.querySelectorAll('textarea[data-max]').forEach(function (t) {
    var aviso = document.createElement('div');
    aviso.className = 'form-text text-end';
    t.parentNode.appendChild(aviso);
    function act() { aviso.textContent = t.value.length + ' / ' + t.getAttribute('data-max'); }
    t.addEventListener('input', act); act();
  });
})();

// Nuevo usuario: el nivel académico es obligatorio solo para estudiantes
(function () {
  var rol = document.getElementById('rol');
  var nivel = document.getElementById('nivel');
  if (!rol || !nivel) return;
  function ajustar() { nivel.required = rol.value === '6'; }
  rol.addEventListener('change', ajustar); ajustar();
})();
