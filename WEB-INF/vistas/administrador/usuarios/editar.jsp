<sql:query var="r">
  SELECT u.id, u.nombre, u.documento, u.nivel, u.telefono, u.email_institucional, ru.role_id, ro.nombre AS rol
    FROM users u JOIN role_user ru ON ru.user_id = u.id JOIN roles ro ON ro.id = ru.role_id WHERE u.id = ?
  <sql:param value="${param.id}"/>
</sql:query>
<c:choose>
  <c:when test="${r.rowCount eq 0}"><div class="alert alert-warning">El usuario no existe. <a href="${ctx}/panel.jsp?v=usuarios/listar">Volver a la lista</a></div></c:when>
  <c:otherwise>
    <c:set var="u" value="${r.rows[0]}"/>
    <div class="page-header"><h1>Editar usuario</h1><p>Rol: <strong><c:out value="${u.rol}"/></strong> (el rol no se modifica desde aquí)</p></div>
    <div class="panel">
      <form method="post" action="${ctx}/acciones/usuarios/editar.jsp" class="validar" novalidate>
        <input type="hidden" name="csrf" value="${sessionScope.csrf}">
        <input type="hidden" name="id" value="${u.id}">
        <div class="row g-3">
          <div class="col-md-6"><label class="form-label" for="nombre">Nombre completo</label><input class="form-control" id="nombre" name="nombre" maxlength="100" required minlength="3" value="<c:out value='${u.nombre}'/>"></div>
          <div class="col-md-6"><label class="form-label" for="correo">Correo institucional</label><input class="form-control" type="email" id="correo" name="correo" maxlength="150" required value="<c:out value='${u.email_institucional}'/>"></div>
          <div class="col-md-4"><label class="form-label" for="documento">Documento</label><input class="form-control" id="documento" name="documento" maxlength="30" required minlength="5" value="<c:out value='${u.documento}'/>"></div>
          <div class="col-md-4"><label class="form-label" for="telefono">Teléfono</label><input class="form-control" id="telefono" name="telefono" maxlength="20" value="<c:out value='${u.telefono}'/>"></div>
          <div class="col-md-4"><label class="form-label" for="nivel">Nivel académico</label>
            <select class="form-select" id="nivel" name="nivel" ${u.role_id eq 6 ? 'required' : ''}>
              <option value="">No aplica</option>
              <option value="Tecnologico" ${u.nivel eq 'Tecnologico' ? 'selected' : ''}>Tecnológico</option>
              <option value="Profesional" ${u.nivel eq 'Profesional' ? 'selected' : ''}>Profesional</option>
            </select>
          </div>
        </div>
        <div class="mt-4 d-flex gap-2">
          <button class="btn btn-primary" type="submit"><i class="bi bi-check2"></i> Guardar cambios</button>
          <a class="btn btn-outline-secondary" href="${ctx}/panel.jsp?v=usuarios/detalle&id=${u.id}">Cancelar</a>
        </div>
      </form>
    </div>
  </c:otherwise>
</c:choose>
