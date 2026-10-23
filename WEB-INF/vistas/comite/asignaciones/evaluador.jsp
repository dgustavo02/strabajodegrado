<sql:query var="t">
  SELECT t.id, t.estado, COALESCE(i.titulo, pe.titulo) AS titulo
    FROM trabajos_grado t JOIN asignaciones_ideas ai ON ai.id = t.asignacion_idea_id
    LEFT JOIN ideas i ON i.id = ai.idea_id LEFT JOIN propuestas_estudiantes pe ON pe.id = ai.propuesta_estudiante_id WHERE t.id = ?
  <sql:param value="${param.id}"/>
</sql:query>
<c:choose>
  <c:when test="${t.rowCount eq 0}"><div class="alert alert-warning">El trabajo no existe. <a href="${ctx}/panel.jsp?v=trabajos/listar">Volver</a></div></c:when>
  <c:otherwise>
    <sql:query var="dir">SELECT docente_id FROM trabajo_docentes WHERE trabajo_id = ? AND funcion = 'Director'<sql:param value="${t.rows[0].id}"/></sql:query>
    <sql:query var="actual">SELECT docente_id FROM trabajo_docentes WHERE trabajo_id = ? AND funcion = 'Evaluador'<sql:param value="${t.rows[0].id}"/></sql:query>
    <%-- El Director del mismo proyecto no aparece entre los candidatos a Evaluador --%>
    <sql:query var="docentes">
      SELECT u.id, u.nombre, u.email_institucional AS correo,
             (SELECT COUNT(*) FROM trabajo_docentes td JOIN trabajos_grado tg ON tg.id = td.trabajo_id
               WHERE td.docente_id = u.id AND td.funcion = 'Director' AND tg.estado NOT IN ('Rechazado','Finalizado')) AS n_dir,
             (SELECT COUNT(*) FROM trabajo_docentes td JOIN trabajos_grado tg ON tg.id = td.trabajo_id
               WHERE td.docente_id = u.id AND td.funcion = 'Evaluador' AND tg.estado NOT IN ('Rechazado','Finalizado')) AS n_eval
        FROM users u JOIN role_user ru ON ru.user_id = u.id AND ru.role_id = 3
       WHERE u.estado = 'Activo'
         AND u.id NOT IN (SELECT docente_id FROM trabajo_docentes WHERE trabajo_id = ? AND funcion = 'Director')
       ORDER BY u.nombre
      <sql:param value="${t.rows[0].id}"/>
    </sql:query>
    <div class="page-header d-flex justify-content-between align-items-center">
      <div><h1>Asignar Evaluador</h1><p><c:out value="${t.rows[0].titulo}"/></p></div>
      <a class="btn btn-outline-secondary" href="${ctx}/panel.jsp?v=trabajos/detalle&id=${t.rows[0].id}"><i class="bi bi-arrow-left"></i> Volver al trabajo</a>
    </div>
    <c:choose>
      <c:when test="${dir.rowCount eq 0}"><div class="alert alert-warning">Primero debes asignar el Director de este trabajo. <a href="${ctx}/panel.jsp?v=asignaciones/director&id=${t.rows[0].id}">Asignar Director</a></div></c:when>
      <c:otherwise>
        <div class="panel">
          <h2>Docentes disponibles</h2>
          <form method="post" action="${ctx}/acciones/asignaciones/evaluador.jsp" class="validar" novalidate>
            <input type="hidden" name="csrf" value="${sessionScope.csrf}"><input type="hidden" name="trabajo" value="${t.rows[0].id}">
            <div class="table-responsive"><table class="table table-hover align-middle">
              <thead><tr><th></th><th>Docente</th><th>Correo</th><th class="text-center">Como Director</th><th class="text-center">Como Evaluador</th></tr></thead>
              <tbody>
                <c:forEach var="d" items="${docentes.rows}"><tr>
                  <td><input class="form-check-input" type="radio" name="docente" value="${d.id}" id="d${d.id}" required ${actual.rowCount gt 0 and actual.rows[0].docente_id eq d.id ? 'checked' : ''}></td>
                  <td><label for="d${d.id}"><c:out value="${d.nombre}"/> <c:if test="${actual.rowCount gt 0 and actual.rows[0].docente_id eq d.id}"><span class="estado" data-estado="Evaluador">Evaluador actual</span></c:if></label></td>
                  <td><c:out value="${d.correo}"/></td><td class="text-center">${d.n_dir}</td><td class="text-center">${d.n_eval}</td>
                </tr></c:forEach>
                <c:if test="${docentes.rowCount eq 0}"><tr><td colspan="5" class="text-center text-muted py-4">No hay docentes activos disponibles.</td></tr></c:if>
              </tbody></table></div>
            <button class="btn btn-primary" type="submit" ${docentes.rowCount eq 0 ? 'disabled' : ''}><i class="bi bi-person-check"></i> Asignar Evaluador</button>
          </form>
        </div>
      </c:otherwise>
    </c:choose>
  </c:otherwise>
</c:choose>
