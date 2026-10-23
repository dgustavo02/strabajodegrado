<%@ include file="/WEB-INF/vistas/comunes/mi-trabajo.jspf" %>
<div class="page-header"><h1>Corregir entrega</h1><p>Vuelve a cargar tus documentos con las correcciones solicitadas.</p></div>
<c:choose>
  <c:when test="${not tengoTrabajo or not puedeCorregir}"><div class="alert alert-info">Tu trabajo no tiene correcciones pendientes. <a href="${ctx}/panel.jsp?v=entregas/listar">Ver mis entregas</a></div></c:when>
  <c:otherwise>
    <sql:query var="ap">SELECT fase_id, titulo FROM entregas WHERE trabajo_id = ? AND estado = 'Aplazada' ORDER BY id DESC LIMIT 1<sql:param value="${mt.id}"/></sql:query>
    <sql:query var="obs">
      SELECT x.observaciones, x.fecha FROM (
        SELECT ev.observaciones, ev.fecha_evaluacion AS fecha FROM evaluaciones ev WHERE ev.trabajo_id = ?
        UNION ALL SELECT a.observaciones, a.fecha_acta FROM actas a WHERE a.trabajo_id = ?
      ) x ORDER BY x.fecha DESC LIMIT 1
      <sql:param value="${mt.id}"/><sql:param value="${mt.id}"/>
    </sql:query>
    <c:if test="${obs.rowCount gt 0}"><div class="panel"><h2>Última observación recibida</h2><div class="texto-largo"><c:out value="${obs.rows[0].observaciones}"/></div></div></c:if>
    <c:if test="${mt.vencido eq 1 and mt.fase_actual_id eq 5}"><div class="alert alert-danger">El plazo del trabajo final venció: el sistema no recibirá correcciones. Solicita una prórroga al Comité.</div></c:if>
    <c:if test="${ap.rowCount gt 0}">
      <div class="panel">
        <form method="post" action="${ctx}/acciones/entregas/corregir.jsp" class="validar" novalidate>
          <input type="hidden" name="csrf" value="${sessionScope.csrf}">
          <c:choose>
            <c:when test="${ap.rows[0].fase_id eq 3}">
              <h2>Anteproyecto corregido</h2>
              <div class="mb-3"><label class="form-label" for="titulo">Título del documento</label><input class="form-control" id="titulo" name="titulo" maxlength="200" minlength="5" required value="<c:out value='${ap.rows[0].titulo}'/>"></div>
              <div class="mb-3"><label class="form-label" for="url">Enlace del documento corregido</label><input class="form-control" type="url" id="url" name="url" maxlength="1000" placeholder="https://..." required pattern="https://.*"></div>
            </c:when>
            <c:otherwise>
              <h2>Trabajo final corregido</h2>
              <div class="mb-3"><label class="form-label" for="u1">Documento final</label><input class="form-control" type="url" id="u1" name="url" maxlength="1000" placeholder="https://..." required pattern="https://.*"></div>
              <div class="mb-3"><label class="form-label" for="u2">Manual</label><input class="form-control" type="url" id="u2" name="url" maxlength="1000" placeholder="https://..." required pattern="https://.*"></div>
              <div class="mb-3"><label class="form-label" for="u3">Código fuente</label><input class="form-control" type="url" id="u3" name="url" maxlength="1000" placeholder="https://..." required pattern="https://.*"></div>
            </c:otherwise>
          </c:choose>
          <button class="btn btn-warning" type="submit"><i class="bi bi-cloud-upload"></i> Reenviar a revisión</button>
        </form>
      </div>
    </c:if>
  </c:otherwise>
</c:choose>
