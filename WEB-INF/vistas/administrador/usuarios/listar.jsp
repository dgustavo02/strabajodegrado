<%@ include file="/WEB-INF/vistas/comunes/paginacion.jspf" %>
<c:set var="q" value="${fn:trim(param.q)}"/>
<c:set var="rolF" value="${fn:trim(param.rol)}"/>
<c:set var="estF" value="${fn:trim(param.estado)}"/>
<sql:query var="tot">
  SELECT COUNT(*) AS n FROM users u JOIN role_user ru ON ru.user_id = u.id
   WHERE (? = '' OR u.nombre LIKE CONCAT('%', ?, '%') OR u.documento LIKE CONCAT('%', ?, '%') OR u.email_institucional LIKE CONCAT('%', ?, '%'))
     AND (? = '' OR ru.role_id = ?) AND (? = '' OR u.estado = ?)
  <sql:param value="${q}"/><sql:param value="${q}"/><sql:param value="${q}"/><sql:param value="${q}"/>
  <sql:param value="${rolF}"/><sql:param value="${rolF}"/><sql:param value="${estF}"/><sql:param value="${estF}"/>
</sql:query>
<c:set var="totalFilas" value="${tot.rows[0].n}"/>
<sql:query var="lista">
  SELECT u.id, u.nombre, u.documento, u.email_institucional, u.nivel, u.estado, r.nombre AS rol
    FROM users u JOIN role_user ru ON ru.user_id = u.id JOIN roles r ON r.id = ru.role_id
   WHERE (? = '' OR u.nombre LIKE CONCAT('%', ?, '%') OR u.documento LIKE CONCAT('%', ?, '%') OR u.email_institucional LIKE CONCAT('%', ?, '%'))
     AND (? = '' OR ru.role_id = ?) AND (? = '' OR u.estado = ?)
   ORDER BY u.nombre LIMIT ? OFFSET ?
  <sql:param value="${q}"/><sql:param value="${q}"/><sql:param value="${q}"/><sql:param value="${q}"/>
  <sql:param value="${rolF}"/><sql:param value="${rolF}"/><sql:param value="${estF}"/><sql:param value="${estF}"/>
  <sql:param value="${porPag}"/><sql:param value="${offset}"/>
</sql:query>
<div class="page-header d-flex flex-wrap justify-content-between align-items-center gap-2">
  <div><h1>Usuarios</h1><p>${totalFilas} resultado(s)</p></div>
  <a class="btn btn-primary" href="${ctx}/panel.jsp?v=usuarios/crear"><i class="bi bi-person-plus"></i> Nuevo usuario</a>
</div>
<div class="panel">
  <form class="row g-2 mb-3" method="get" action="${ctx}/panel.jsp">
    <input type="hidden" name="v" value="usuarios/listar">
    <div class="col-md-5"><input class="form-control" type="search" name="q" value="<c:out value='${q}'/>" placeholder="Buscar por nombre, documento o correo"></div>
    <div class="col-md-3"><select class="form-select" name="rol">
      <option value="">Todos los roles</option>
      <option value="1" ${rolF eq '1' ? 'selected' : ''}>Administrador</option>
      <option value="2" ${rolF eq '2' ? 'selected' : ''}>Coordinación/Comité</option>
      <option value="3" ${rolF eq '3' ? 'selected' : ''}>Docente</option>
      <option value="6" ${rolF eq '6' ? 'selected' : ''}>Estudiante</option>
    </select></div>
    <div class="col-md-2"><select class="form-select" name="estado">
      <option value="">Todos</option>
      <option value="Activo" ${estF eq 'Activo' ? 'selected' : ''}>Activos</option>
      <option value="Inactivo" ${estF eq 'Inactivo' ? 'selected' : ''}>Inactivos</option>
    </select></div>
    <div class="col-md-2 d-grid"><button class="btn btn-outline-primary" type="submit"><i class="bi bi-search"></i> Filtrar</button></div>
  </form>
  <div class="table-responsive">
    <table class="table table-hover align-middle mb-3">
      <thead><tr><th>Nombre</th><th>Documento</th><th>Correo</th><th>Rol</th><th>Nivel</th><th>Estado</th><th></th></tr></thead>
      <tbody>
        <c:forEach var="u" items="${lista.rows}">
          <tr>
            <td><a href="${ctx}/panel.jsp?v=usuarios/detalle&id=${u.id}"><c:out value="${u.nombre}"/></a></td>
            <td><c:out value="${u.documento}"/></td>
            <td><c:out value="${u.email_institucional}"/></td>
            <td><c:out value="${u.rol}"/></td>
            <td><c:out value="${empty u.nivel ? '—' : u.nivel}"/></td>
            <td><span class="estado" data-estado="${u.estado}"><c:out value="${u.estado}"/></span></td>
            <td class="text-end text-nowrap">
              <a class="btn btn-sm btn-outline-secondary" href="${ctx}/panel.jsp?v=usuarios/editar&id=${u.id}" title="Editar"><i class="bi bi-pencil"></i></a>
              <c:if test="${u.id ne sessionScope.usuarioId}">
                <form class="d-inline" method="post" action="${ctx}/acciones/usuarios/estado.jsp" data-confirm="¿${u.estado eq 'Activo' ? 'Desactivar' : 'Activar'} a este usuario?">
                  <input type="hidden" name="csrf" value="${sessionScope.csrf}">
                  <input type="hidden" name="id" value="${u.id}">
                  <input type="hidden" name="estado" value="${u.estado eq 'Activo' ? 'Inactivo' : 'Activo'}">
                  <button class="btn btn-sm ${u.estado eq 'Activo' ? 'btn-outline-danger' : 'btn-outline-success'}" type="submit" title="${u.estado eq 'Activo' ? 'Desactivar' : 'Activar'}"><i class="bi ${u.estado eq 'Activo' ? 'bi-person-x' : 'bi-person-check'}"></i></button>
                </form>
              </c:if>
            </td>
          </tr>
        </c:forEach>
        <c:if test="${lista.rowCount eq 0}"><tr><td colspan="7" class="text-center text-muted py-4">No se encontraron usuarios.</td></tr></c:if>
      </tbody>
    </table>
  </div>
  <c:set var="baseV" value="usuarios/listar"/>
  <%@ include file="/WEB-INF/vistas/comunes/paginador.jspf" %>
</div>
