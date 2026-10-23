<%@ page contentType="text/html;charset=UTF-8" %>
<c:set var="rolRequerido" value="comite"/>
<%@ include file="/WEB-INF/vistas/comunes/guardia-accion.jspf" %>
<c:set var="destinoOk" value="trabajos/detalle"/>
<c:set var="destinoErr" value="trabajos/detalle"/>
<c:set var="destinoId" value="${param.trabajo}"/>
<c:set var="decision" value="${param.decision}"/>
<c:set var="obs" value="${fn:trim(param.observaciones)}"/>
<sql:query var="ab">SELECT fase_id FROM entregas WHERE trabajo_id = ? AND estado = 'En comite' ORDER BY id DESC LIMIT 1<sql:param value="${param.trabajo}"/></sql:query>
<c:if test="${ab.rowCount eq 0}"><c:set var="errValidacion" value="Este trabajo no tiene entregas pendientes de decisión del Comité."/></c:if>
<c:if test="${empty errValidacion and decision ne 'Aprobada' and decision ne 'Aplazada' and decision ne 'Rechazada'}"><c:set var="errValidacion" value="Decisión no válida."/></c:if>
<c:if test="${empty errValidacion and (fn:length(obs) lt 5 or fn:length(obs) gt 3000)}"><c:set var="errValidacion" value="Las observaciones son obligatorias (entre 5 y 3000 caracteres)."/></c:if>
<c:if test="${empty errValidacion}">
  <c:set var="faseId" value="${ab.rows[0].fase_id}"/>
  <c:if test="${decision eq 'Aprobada' and faseId eq 3}">
    <c:set var="plazoOk" value="false"/>
    <c:catch var="ignorar">
      <c:set var="plazo" value="${fn:trim(param.plazo) + 0}"/>
      <c:if test="${plazo ge 90 and plazo le 180}"><c:set var="plazoOk" value="true"/></c:if>
    </c:catch>
    <c:if test="${plazoOk ne 'true'}"><c:set var="errValidacion" value="Indica el plazo para el trabajo final: entre 90 y 180 días."/></c:if>
  </c:if>
</c:if>
<c:if test="${empty errValidacion}">
  <c:catch var="err">
    <sql:transaction>
      <sql:update>INSERT INTO actas (usuario_comite_id, trabajo_id, tipo, decision, observaciones) VALUES (?, ?, 'Decision de trabajo', ?, ?)
        <sql:param value="${sessionScope.usuarioId}"/><sql:param value="${param.trabajo}"/><sql:param value="${decision}"/><sql:param value="${obs}"/>
      </sql:update>
      <c:set var="nTrabajo" value="${param.trabajo}"/>
      <c:choose>
        <c:when test="${decision eq 'Aprobada' and faseId eq 3}">
          <sql:update>UPDATE entregas SET estado = 'Aprobada' WHERE trabajo_id = ? AND fase_id = 3 AND estado = 'En comite'<sql:param value="${param.trabajo}"/></sql:update>
          <sql:update>UPDATE trabajo_fases SET estado = 'Aprobada', fecha_fin = CURDATE() WHERE trabajo_id = ? AND fase_id IN (3, 4)<sql:param value="${param.trabajo}"/></sql:update>
          <sql:update>INSERT INTO trabajo_fases (trabajo_id, fase_id, estado, fecha_inicio, fecha_limite) VALUES (?, 5, 'En proceso', CURDATE(), DATE_ADD(CURDATE(), INTERVAL ? DAY))
            <sql:param value="${param.trabajo}"/><sql:param value="${plazo}"/>
          </sql:update>
          <sql:update>UPDATE trabajos_grado SET fase_actual_id = 5, estado = 'Aprobado' WHERE id = ?<sql:param value="${param.trabajo}"/></sql:update>
          <c:set var="nTitulo" value="Anteproyecto aprobado"/>
          <c:set var="nMensaje" value="Tu anteproyecto fue aprobado. Tienes ${plazo} días para registrar el trabajo final (documento final, manual y código fuente)."/>
          <c:set var="nTipo" value="Trabajo"/>
        </c:when>
        <c:when test="${decision eq 'Aprobada'}">
          <sql:update>UPDATE entregas SET estado = 'Aprobada' WHERE trabajo_id = ? AND fase_id = 5 AND estado = 'En comite'<sql:param value="${param.trabajo}"/></sql:update>
          <sql:update>UPDATE trabajo_fases SET estado = 'Finalizada', fecha_fin = CURDATE() WHERE trabajo_id = ? AND fase_id = 5<sql:param value="${param.trabajo}"/></sql:update>
          <sql:update>UPDATE trabajos_grado SET estado = 'Finalizado', fecha_finalizacion = CURDATE() WHERE id = ?<sql:param value="${param.trabajo}"/></sql:update>
          <c:set var="nTitulo" value="Trabajo de grado aprobado"/>
          <c:set var="nMensaje" value="¡Felicitaciones! Tu trabajo de grado fue aprobado y quedó finalizado."/>
          <c:set var="nTipo" value="Trabajo"/>
        </c:when>
        <c:when test="${decision eq 'Aplazada'}">
          <sql:update>UPDATE entregas SET estado = 'Aplazada' WHERE trabajo_id = ? AND fase_id = ? AND estado = 'En comite'<sql:param value="${param.trabajo}"/><sql:param value="${faseId}"/></sql:update>
          <sql:update>UPDATE trabajo_fases SET estado = 'Aplazada' WHERE trabajo_id = ? AND fase_id = ?<sql:param value="${param.trabajo}"/><sql:param value="${faseId}"/></sql:update>
          <sql:update>UPDATE trabajos_grado SET estado = 'Aplazado' WHERE id = ?<sql:param value="${param.trabajo}"/></sql:update>
          <c:set var="nTitulo" value="Decisión del Comité: aplazado"/>
          <c:set var="nMensaje" value="El Comité aplazó tu entrega. Revisa las observaciones y vuelve a cargarla corregida."/>
          <c:set var="nTipo" value="Trabajo"/>
        </c:when>
        <c:otherwise>
          <c:set var="nTitulo" value="Trabajo rechazado"/>
          <c:set var="nMensaje" value="El Comité rechazó tu trabajo de grado. Puedes iniciar un nuevo proceso con una idea diferente."/>
          <c:set var="nTipo" value="Trabajo"/>
        </c:otherwise>
      </c:choose>
      <%-- Se notifica antes de un posible rechazo, que desvincula a los estudiantes --%>
      <%@ include file="/WEB-INF/vistas/comunes/notificar-estudiantes.jspf" %>
      <c:if test="${decision eq 'Rechazada'}">
        <sql:update>UPDATE entregas SET estado = 'Rechazada' WHERE trabajo_id = ? AND fase_id = ? AND estado = 'En comite'<sql:param value="${param.trabajo}"/><sql:param value="${faseId}"/></sql:update>
        <sql:update>UPDATE trabajo_fases SET estado = 'Rechazada' WHERE trabajo_id = ? AND estado IN ('En proceso','Aplazada')<sql:param value="${param.trabajo}"/></sql:update>
        <sql:update>UPDATE trabajos_grado SET estado = 'Rechazado' WHERE id = ?<sql:param value="${param.trabajo}"/></sql:update>
      </c:if>
      <c:set var="hEntidad" value="Trabajo"/><c:set var="hId" value="${param.trabajo}"/>
      <c:set var="hAccion" value="${decision eq 'Aprobada' ? 'Aprobar' : (decision eq 'Rechazada' ? 'Rechazar' : 'Cambiar estado')}"/>
      <c:set var="hDesc" value="Decisión del Comité: ${decision}. ${obs}"/>
      <%@ include file="/WEB-INF/vistas/comunes/historial.jspf" %>
    </sql:transaction>
  </c:catch>
</c:if>
<c:set var="okMsg" value="Decisión del Comité registrada: ${fn:toLowerCase(decision)}."/>
<%@ include file="/WEB-INF/vistas/comunes/finalizar.jspf" %>
