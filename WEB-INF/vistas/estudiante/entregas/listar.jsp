<%@ include file="/WEB-INF/vistas/comunes/mi-trabajo.jspf" %>
<div class="page-header d-flex flex-wrap justify-content-between align-items-center gap-2">
  <div><h1>Mis entregas</h1><p>Los documentos se registran como enlaces externos.</p></div>
  <c:if test="${tengoTrabajo}">
    <div>
      <c:if test="${puedeAnteproyecto or puedeFinal}"><a class="btn btn-primary" href="${ctx}/panel.jsp?v=entregas/registrar"><i class="bi bi-cloud-upload"></i> Registrar ${puedeFinal ? 'trabajo final' : 'anteproyecto'}</a></c:if>
      <c:if test="${puedeCorregir}"><a class="btn btn-warning" href="${ctx}/panel.jsp?v=entregas/corregir"><i class="bi bi-arrow-counterclockwise"></i> Corregir entrega</a></c:if>
    </div>
  </c:if>
</div>
<c:choose>
  <c:when test="${not tengoTrabajo}"><div class="alert alert-info">Necesitas un trabajo de grado en curso para registrar entregas.</div></c:when>
  <c:otherwise>
    <sql:query var="ent">
      SELECT e.tipo, e.titulo, e.version, e.url, e.estado, e.fecha_entrega, f.nombre AS fase
        FROM entregas e JOIN fases f ON f.id = e.fase_id WHERE e.trabajo_id = ? ORDER BY e.id DESC
      <sql:param value="${mt.id}"/>
    </sql:query>
    <c:if test="${not empty mt.limite_final}"><div class="alert ${mt.vencido eq 1 ? 'alert-danger' : 'alert-secondary'}">Fecha límite del trabajo final: <strong>${fn:substring(mt.limite_final, 8, 10)}/${fn:substring(mt.limite_final, 5, 7)}/${fn:substring(mt.limite_final, 0, 4)}</strong>${mt.vencido eq 1 ? ' (vencida)' : ''}</div></c:if>
    <div class="panel">
      <div class="table-responsive"><table class="table align-middle mb-0">
        <thead><tr><th>Documento</th><th>Fase</th><th>Versión</th><th>Estado</th><th>Fecha</th><th></th></tr></thead>
        <tbody>
          <c:forEach var="e" items="${ent.rows}"><tr>
            <td><c:out value="${e.tipo}"/><br><small class="text-muted"><c:out value="${e.titulo}"/></small></td><td><c:out value="${e.fase}"/></td><td>v${e.version}</td>
            <td><span class="estado" data-estado="${e.estado}">${e.estado}</span></td><td>${fn:substring(e.fecha_entrega, 8, 10)}/${fn:substring(e.fecha_entrega, 5, 7)}/${fn:substring(e.fecha_entrega, 0, 4)}</td>
            <td class="text-end"><a class="btn btn-sm btn-outline-secondary" href="<c:out value='${e.url}'/>" target="_blank" rel="noopener noreferrer"><i class="bi bi-box-arrow-up-right"></i> Abrir</a></td>
          </tr></c:forEach>
          <c:if test="${ent.rowCount eq 0}"><tr><td colspan="6" class="text-center text-muted py-4">Aún no has registrado entregas.</td></tr></c:if>
        </tbody></table></div>
    </div>
  </c:otherwise>
</c:choose>
