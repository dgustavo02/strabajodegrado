<sql:query var="r">
  SELECT u.id, u.nombre, u.documento, u.nivel, u.telefono, u.email_institucional, u.estado, u.ultimo_acceso, u.created_at,
         ru.role_id, ro.nombre AS rol
    FROM users u JOIN role_user ru ON ru.user_id = u.id JOIN roles ro ON ro.id = ru.role_id WHERE u.id = ?
  <sql:param value="${param.id}"/>
</sql:query>
<c:choose>
  <c:when test="${r.rowCount eq 0}"><div class="alert alert-warning">El usuario no existe. <a href="${ctx}/panel.jsp?v=usuarios/listar">Volver a la lista</a></div></c:when>
  <c:otherwise>
    <c:set var="u" value="${r.rows[0]}"/>
    <sql:query var="res">
      SELECT (SELECT COUNT(*) FROM ideas WHERE docente_id = ?) AS ideas,
             (SELECT COUNT(*) FROM trabajo_docentes WHERE docente_id = ?) AS asignados,
             (SELECT COUNT(*) FROM trabajo_estudiantes WHERE estudiante_id = ?) AS trabajos
      <sql:param value="${u.id}"/><sql:param value="${u.id}"/><sql:param value="${u.id}"/>
    </sql:query>
    <div class="page-header d-flex flex-wrap justify-content-between align-items-center gap-2">
      <div><h1><c:out value="${u.nombre}"/></h1><p><c:out value="${u.rol}"/> · <span class="estado" data-estado="${u.estado}">${u.estado}</span></p></div>
      <div class="d-flex gap-2">
        <a class="btn btn-outline-secondary" href="${ctx}/panel.jsp?v=usuarios/listar"><i class="bi bi-arrow-left"></i> Volver</a>
        <a class="btn btn-primary" href="${ctx}/panel.jsp?v=usuarios/editar&id=${u.id}"><i class="bi bi-pencil"></i> Editar</a>
      </div>
    </div>
    <div class="row g-3">
      <div class="col-lg-7"><div class="panel">
        <h2>Información</h2>
        <dl class="row mb-0">
          <dt class="col-sm-4 dato-etiqueta">Documento</dt><dd class="col-sm-8"><c:out value="${u.documento}"/></dd>
          <dt class="col-sm-4 dato-etiqueta">Correo</dt><dd class="col-sm-8"><c:out value="${u.email_institucional}"/></dd>
          <dt class="col-sm-4 dato-etiqueta">Teléfono</dt><dd class="col-sm-8"><c:out value="${empty u.telefono ? '—' : u.telefono}"/></dd>
          <dt class="col-sm-4 dato-etiqueta">Nivel académico</dt><dd class="col-sm-8"><c:out value="${empty u.nivel ? '—' : u.nivel}"/></dd>
          <dt class="col-sm-4 dato-etiqueta">Creado</dt><dd class="col-sm-8">${fn:substring(u.created_at, 8, 10)}/${fn:substring(u.created_at, 5, 7)}/${fn:substring(u.created_at, 0, 4)}</dd>
          <dt class="col-sm-4 dato-etiqueta">Último acceso</dt><dd class="col-sm-8"><c:choose><c:when test="${empty u.ultimo_acceso}">Nunca</c:when><c:otherwise>${fn:substring(u.ultimo_acceso, 8, 10)}/${fn:substring(u.ultimo_acceso, 5, 7)}/${fn:substring(u.ultimo_acceso, 0, 4)} ${fn:substring(u.ultimo_acceso, 11, 16)}</c:otherwise></c:choose></dd>
          <c:if test="${u.role_id eq 3}">
            <dt class="col-sm-4 dato-etiqueta">Ideas propuestas</dt><dd class="col-sm-8">${res.rows[0].ideas}</dd>
            <dt class="col-sm-4 dato-etiqueta">Trabajos asignados</dt><dd class="col-sm-8">${res.rows[0].asignados}</dd>
          </c:if>
          <c:if test="${u.role_id eq 6}">
            <dt class="col-sm-4 dato-etiqueta">Trabajo vigente</dt><dd class="col-sm-8">${res.rows[0].trabajos gt 0 ? 'Sí' : 'No'}</dd>
          </c:if>
        </dl>
      </div></div>
      <div class="col-lg-5"><div class="panel">
        <h2>Credenciales</h2>
        <details class="revision">
          <summary>Restablecer contraseña</summary>
          <form class="mt-3 validar" method="post" action="${ctx}/acciones/usuarios/clave.jsp" novalidate autocomplete="off">
            <input type="hidden" name="csrf" value="${sessionScope.csrf}">
            <input type="hidden" name="id" value="${u.id}">
            <div class="mb-2"><label class="form-label" for="clave">Nueva contraseña</label><input class="form-control" type="password" id="clave" name="clave" minlength="8" maxlength="100" required autocomplete="new-password"></div>
            <div class="mb-3"><label class="form-label" for="confirmar">Confirmar</label><input class="form-control" type="password" id="confirmar" name="confirmar" minlength="8" maxlength="100" required autocomplete="new-password"></div>
            <button class="btn btn-primary btn-sm" type="submit">Guardar contraseña</button>
          </form>
        </details>
        <c:if test="${u.id ne sessionScope.usuarioId}">
          <form class="mt-3" method="post" action="${ctx}/acciones/usuarios/estado.jsp" data-confirm="¿${u.estado eq 'Activo' ? 'Desactivar' : 'Activar'} a este usuario?">
            <input type="hidden" name="csrf" value="${sessionScope.csrf}">
            <input type="hidden" name="id" value="${u.id}">
            <input type="hidden" name="estado" value="${u.estado eq 'Activo' ? 'Inactivo' : 'Activo'}">
            <button class="btn ${u.estado eq 'Activo' ? 'btn-outline-danger' : 'btn-outline-success'} btn-sm" type="submit">${u.estado eq 'Activo' ? 'Desactivar cuenta' : 'Activar cuenta'}</button>
          </form>
        </c:if>
      </div></div>
    </div>
  </c:otherwise>
</c:choose>
