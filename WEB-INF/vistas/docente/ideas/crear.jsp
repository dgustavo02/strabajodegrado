<div class="page-header"><h1>Proponer una idea</h1><p>El Comité la revisará. Si la aprueba, pasará al banco de ideas para los estudiantes.</p></div>
<div class="panel">
  <form method="post" action="${ctx}/acciones/ideas/crear.jsp" class="validar" novalidate>
    <input type="hidden" name="csrf" value="${sessionScope.csrf}">
    <div class="row g-3">
      <div class="col-md-8"><label class="form-label" for="titulo">Título</label><input class="form-control" id="titulo" name="titulo" maxlength="200" minlength="5" required></div>
      <div class="col-md-4"><label class="form-label" for="modalidad">Modalidad</label>
        <select class="form-select" id="modalidad" name="modalidad" required>
          <option value="">Selecciona…</option>
          <option value="Desarrollo tecnologico">Desarrollo tecnológico</option>
          <option value="Emprendimiento">Emprendimiento</option>
          <option value="Monografia">Monografía</option>
          <option value="Proyecto de investigacion">Proyecto de investigación</option>
        </select></div>
      <div class="col-12"><label class="form-label" for="descripcion">Descripción</label><textarea class="form-control" id="descripcion" name="descripcion" rows="7" maxlength="5000" minlength="20" required data-max="5000"></textarea>
        <div class="form-text">Describe el problema, el alcance esperado y los resultados.</div></div>
    </div>
    <div class="mt-4 d-flex gap-2">
      <button class="btn btn-primary" type="submit"><i class="bi bi-send"></i> Enviar al Comité</button>
      <a class="btn btn-outline-secondary" href="${ctx}/panel.jsp?v=ideas/mis-ideas">Cancelar</a>
    </div>
  </form>
</div>
