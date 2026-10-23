<div class="page-header"><h1>Nuevo usuario</h1><p>Solo el administrador puede crear cuentas. No existe registro público.</p></div>
<div class="panel">
  <form method="post" action="${ctx}/acciones/usuarios/crear.jsp" class="validar" novalidate autocomplete="off">
    <input type="hidden" name="csrf" value="${sessionScope.csrf}">
    <div class="row g-3">
      <div class="col-md-6"><label class="form-label" for="nombre">Nombre completo</label><input class="form-control" id="nombre" name="nombre" maxlength="100" required minlength="3"></div>
      <div class="col-md-6"><label class="form-label" for="correo">Correo institucional</label><input class="form-control" type="email" id="correo" name="correo" maxlength="150" required></div>
      <div class="col-md-4"><label class="form-label" for="documento">Documento</label><input class="form-control" id="documento" name="documento" maxlength="30" required minlength="5"></div>
      <div class="col-md-4"><label class="form-label" for="telefono">Teléfono (opcional)</label><input class="form-control" id="telefono" name="telefono" maxlength="20"></div>
      <div class="col-md-4"><label class="form-label" for="rol">Rol</label>
        <select class="form-select" id="rol" name="rol" required>
          <option value="">Selecciona…</option>
          <option value="6">Estudiante</option>
          <option value="3">Docente</option>
          <option value="2">Coordinación/Comité</option>
          <option value="1">Administrador</option>
        </select>
        <div class="form-text">Director y Evaluador se asignan por proyecto a los docentes.</div>
      </div>
      <div class="col-md-4"><label class="form-label" for="nivel">Nivel académico</label>
        <select class="form-select" id="nivel" name="nivel">
          <option value="">No aplica</option>
          <option value="Tecnologico">Tecnológico</option>
          <option value="Profesional">Profesional</option>
        </select>
        <div class="form-text">Obligatorio para estudiantes.</div>
      </div>
      <div class="col-md-4"><label class="form-label" for="clave">Contraseña inicial</label><input class="form-control" type="password" id="clave" name="clave" minlength="8" maxlength="100" required autocomplete="new-password"><div class="form-text">Mínimo 8 caracteres, con letras y números.</div></div>
      <div class="col-md-4"><label class="form-label" for="confirmar">Confirmar contraseña</label><input class="form-control" type="password" id="confirmar" name="confirmar" minlength="8" maxlength="100" required autocomplete="new-password"></div>
    </div>
    <div class="mt-4 d-flex gap-2">
      <button class="btn btn-primary" type="submit"><i class="bi bi-check2"></i> Crear usuario</button>
      <a class="btn btn-outline-secondary" href="${ctx}/panel.jsp?v=usuarios/listar">Cancelar</a>
    </div>
  </form>
</div>
