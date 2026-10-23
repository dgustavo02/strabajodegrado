<%@ include file="/WEB-INF/vistas/comunes/mi-trabajo.jspf" %>
<div class="page-header"><h1>Registrar entrega</h1><p>Pega los enlaces a tus documentos (deben empezar por https://).</p></div>
<c:choose>
  <c:when test="${not tengoTrabajo}"><div class="alert alert-info">Necesitas un trabajo de grado en curso.</div></c:when>
  <c:when test="${puedeAnteproyecto}">
    <div class="panel">
      <h2>Anteproyecto</h2>
      <form method="post" action="${ctx}/acciones/entregas/registrar.jsp" class="validar" novalidate>
        <input type="hidden" name="csrf" value="${sessionScope.csrf}">
        <div class="mb-3"><label class="form-label" for="titulo">Título del documento</label><input class="form-control" id="titulo" name="titulo" maxlength="200" minlength="5" required value="<c:out value='${mt.titulo}'/>"></div>
        <div class="mb-3"><label class="form-label" for="url">Enlace del anteproyecto</label><input class="form-control" type="url" id="url" name="url" maxlength="1000" placeholder="https://..." required pattern="https://.*"></div>
        <button class="btn btn-primary" type="submit"><i class="bi bi-cloud-upload"></i> Enviar al Director</button>
      </form>
    </div>
  </c:when>
  <c:when test="${puedeFinal}">
    <div class="alert alert-info">Fecha límite: <strong>${fn:substring(mt.limite_final, 8, 10)}/${fn:substring(mt.limite_final, 5, 7)}/${fn:substring(mt.limite_final, 0, 4)}</strong>. Debes enviar los tres documentos.</div>
    <div class="panel">
      <h2>Trabajo final</h2>
      <form method="post" action="${ctx}/acciones/entregas/registrar.jsp" class="validar" novalidate>
        <input type="hidden" name="csrf" value="${sessionScope.csrf}">
        <div class="mb-3"><label class="form-label" for="u1">Documento final</label><input class="form-control" type="url" id="u1" name="url" maxlength="1000" placeholder="https://..." required pattern="https://.*"></div>
        <div class="mb-3"><label class="form-label" for="u2">Manual</label><input class="form-control" type="url" id="u2" name="url" maxlength="1000" placeholder="https://..." required pattern="https://.*"></div>
        <div class="mb-3"><label class="form-label" for="u3">Código fuente</label><input class="form-control" type="url" id="u3" name="url" maxlength="1000" placeholder="https://..." required pattern="https://.*"></div>
        <button class="btn btn-primary" type="submit"><i class="bi bi-cloud-upload"></i> Enviar al Director</button>
      </form>
    </div>
  </c:when>
  <c:when test="${puedeCorregir}"><div class="alert alert-warning">Tu entrega fue aplazada. Usa la opción <a href="${ctx}/panel.jsp?v=entregas/corregir">Corregir entrega</a>.</div></c:when>
  <c:when test="${mt.vencido eq 1}"><div class="alert alert-danger">El plazo del trabajo final venció. Registra una solicitud de prórroga al Comité.</div></c:when>
  <c:otherwise><div class="alert alert-secondary">Por ahora no hay una entrega habilitada para tu trabajo.</div></c:otherwise>
</c:choose>
