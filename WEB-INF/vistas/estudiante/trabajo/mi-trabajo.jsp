<%@ include file="/WEB-INF/vistas/comunes/mi-trabajo.jspf" %>
<c:choose>
  <c:when test="${not tengoTrabajo}">
    <div class="page-header"><h1>Mi trabajo</h1></div>
    <div class="panel"><p class="text-muted">Todavía no tienes un trabajo de grado en curso.</p>
      <a class="btn btn-primary" href="${ctx}/panel.jsp?v=ideas/banco">Ver banco de ideas</a>
      <a class="btn btn-outline-primary ms-2" href="${ctx}/panel.jsp?v=propuestas/crear">Registrar mi propuesta</a></div>
  </c:when>
  <c:otherwise>
    <sql:query var="comp">SELECT u.nombre, u.email_institucional AS correo FROM trabajo_estudiantes te JOIN users u ON u.id = te.estudiante_id WHERE te.trabajo_id = ?<sql:param value="${mt.id}"/></sql:query>
    <%-- El Evaluador no se consulta ni se muestra al estudiante --%>
    <sql:query var="dir">SELECT u.nombre, u.email_institucional AS correo FROM trabajo_docentes td JOIN users u ON u.id = td.docente_id WHERE td.trabajo_id = ? AND td.funcion = 'Director'<sql:param value="${mt.id}"/></sql:query>
    <sql:query var="fases">SELECT f.nombre, tf.estado, tf.fecha_inicio, tf.fecha_limite, tf.fecha_fin FROM trabajo_fases tf JOIN fases f ON f.id = tf.fase_id WHERE tf.trabajo_id = ? ORDER BY f.orden<sql:param value="${mt.id}"/></sql:query>
    <sql:query var="evs">
      SELECT ev.calificacion, ev.estado, ev.observaciones, ev.fecha_evaluacion, f.nombre AS fase, td.funcion,
             IF(td.funcion = 'Director', u.nombre, NULL) AS docente
        FROM evaluaciones ev JOIN fases f ON f.id = ev.fase_id
        LEFT JOIN trabajo_docentes td ON td.trabajo_id = ev.trabajo_id AND td.docente_id = ev.docente_id
        LEFT JOIN users u ON u.id = ev.docente_id
       WHERE ev.trabajo_id = ? ORDER BY ev.id DESC
      <sql:param value="${mt.id}"/>
    </sql:query>
    <sql:query var="actas">SELECT decision, observaciones, fecha_acta FROM actas WHERE trabajo_id = ? ORDER BY id DESC<sql:param value="${mt.id}"/></sql:query>
    <div class="page-header"><h1><c:out value="${mt.titulo}"/></h1><p><span class="estado" data-estado="${mt.estado}">${mt.estado}</span> · <c:out value="${mt.modalidad}"/> · Fase: <c:out value="${mt.fase}"/></p></div>
    <div class="row g-3">
      <div class="col-lg-7">
        <div class="panel"><h2>Descripción</h2><p class="texto-largo mb-0"><c:out value="${mt.descripcion}"/></p></div>
        <div class="panel"><h2>Fases y fechas</h2>
          <div class="table-responsive"><table class="table table-sm align-middle mb-0"><thead><tr><th>Fase</th><th>Estado</th><th>Inicio</th><th>Fecha límite</th><th>Fin</th></tr></thead><tbody>
            <c:forEach var="f" items="${fases.rows}"><tr><td><c:out value="${f.nombre}"/></td><td><span class="estado" data-estado="${f.estado}">${f.estado}</span></td>
              <td><c:choose><c:when test="${empty f.fecha_inicio}">—</c:when><c:otherwise>${fn:substring(f.fecha_inicio, 8, 10)}/${fn:substring(f.fecha_inicio, 5, 7)}/${fn:substring(f.fecha_inicio, 0, 4)}</c:otherwise></c:choose></td>
              <td><c:choose><c:when test="${empty f.fecha_limite}">—</c:when><c:otherwise>${fn:substring(f.fecha_limite, 8, 10)}/${fn:substring(f.fecha_limite, 5, 7)}/${fn:substring(f.fecha_limite, 0, 4)}</c:otherwise></c:choose></td>
              <td><c:choose><c:when test="${empty f.fecha_fin}">—</c:when><c:otherwise>${fn:substring(f.fecha_fin, 8, 10)}/${fn:substring(f.fecha_fin, 5, 7)}/${fn:substring(f.fecha_fin, 0, 4)}</c:otherwise></c:choose></td></tr></c:forEach>
          </tbody></table></div>
        </div>
        <div class="panel"><h2>Observaciones y calificaciones</h2>
          <c:forEach var="v" items="${evs.rows}">
            <div class="border-bottom pb-2 mb-2">
              <div class="d-flex justify-content-between flex-wrap">
                <strong><c:choose><c:when test="${v.funcion eq 'Director'}">Director: <c:out value="${v.docente}"/></c:when><c:otherwise>Evaluación</c:otherwise></c:choose></strong>
                <span><span class="estado" data-estado="${v.estado}">${v.estado}</span> <c:if test="${not empty v.calificacion}"><span class="ms-2 fw-semibold">${v.calificacion}</span></c:if></span>
              </div>
              <div class="texto-largo small"><c:out value="${v.observaciones}"/></div>
              <div class="small text-muted"><c:out value="${v.fase}"/> · ${fn:substring(v.fecha_evaluacion, 8, 10)}/${fn:substring(v.fecha_evaluacion, 5, 7)}/${fn:substring(v.fecha_evaluacion, 0, 4)}</div>
            </div>
          </c:forEach>
          <c:forEach var="a" items="${actas.rows}">
            <div class="border-bottom pb-2 mb-2">
              <div class="d-flex justify-content-between"><strong>Comité</strong><span class="estado" data-estado="${a.decision}">${a.decision}</span></div>
              <div class="texto-largo small"><c:out value="${a.observaciones}"/></div>
              <div class="small text-muted">${fn:substring(a.fecha_acta, 8, 10)}/${fn:substring(a.fecha_acta, 5, 7)}/${fn:substring(a.fecha_acta, 0, 4)} ${fn:substring(a.fecha_acta, 11, 16)}</div>
            </div>
          </c:forEach>
          <c:if test="${evs.rowCount eq 0 and actas.rowCount eq 0}"><p class="text-muted mb-0">Aún no hay observaciones.</p></c:if>
        </div>
      </div>
      <div class="col-lg-5">
        <div class="panel"><h2>Equipo</h2>
          <div class="dato-etiqueta">Estudiante(s)</div>
          <c:forEach var="c" items="${comp.rows}"><div class="mb-1"><c:out value="${c.nombre}"/> <small class="text-muted">· <c:out value="${c.correo}"/></small></div></c:forEach>
          <div class="dato-etiqueta mt-3">Director</div>
          <c:choose><c:when test="${dir.rowCount gt 0}"><c:out value="${dir.rows[0].nombre}"/><br><small class="text-muted"><c:out value="${dir.rows[0].correo}"/></small></c:when><c:otherwise><span class="text-muted">Pendiente de asignación</span></c:otherwise></c:choose>
        </div>
        <div class="panel"><h2>Acciones</h2>
          <c:if test="${puedeAnteproyecto or puedeFinal}"><a class="btn btn-primary btn-sm mb-2" href="${ctx}/panel.jsp?v=entregas/registrar"><i class="bi bi-cloud-upload"></i> Registrar entrega</a><br></c:if>
          <c:if test="${puedeCorregir}"><a class="btn btn-warning btn-sm mb-2" href="${ctx}/panel.jsp?v=entregas/corregir"><i class="bi bi-arrow-counterclockwise"></i> Corregir entrega</a><br></c:if>
          <a class="btn btn-outline-secondary btn-sm" href="${ctx}/panel.jsp?v=entregas/listar">Ver mis entregas</a>
          <a class="btn btn-outline-secondary btn-sm" href="${ctx}/panel.jsp?v=solicitudes/listar">Mis solicitudes</a>
        </div>
      </div>
    </div>
  </c:otherwise>
</c:choose>
