(function () {
  var form = document.getElementById('formLogin');
  var boton = document.getElementById('verClave');
  var clave = document.getElementById('clave');
  if (boton && clave) {
    boton.addEventListener('click', function () {
      var visible = clave.type === 'text';
      clave.type = visible ? 'password' : 'text';
      boton.querySelector('i').className = visible ? 'bi bi-eye' : 'bi bi-eye-slash';
    });
  }
  if (form) {
    form.addEventListener('submit', function (e) {
      if (!form.checkValidity()) {
        e.preventDefault();
        form.classList.add('was-validated');
        return;
      }
      var envio = form.querySelector('button[type="submit"]');
      if (envio) { envio.disabled = true; envio.textContent = 'Ingresando...'; }
    });
  }
})();
