<%@ page contentType="text/html;charset=UTF-8" %>
<c:set var="rolRequerido" value="comite"/>
<%@ include file="/WEB-INF/vistas/comunes/guardia-accion.jspf" %>
<c:set var="destinoOk" value="solicitudes/listar"/>
<c:set var="destinoErr" value="solicitudes/listar"/>
<c:set var="decision" value="${param.decision}"/>
<c:set var="respuesta" value="${fn:trim(param.respuesta)}"/>
<sql:query var="sol">SELECT id, usuario_id, trabajo_id, tipo, estado FROM solicitudes WHERE id = ?<sql:param value="${param.id}"/></sql:query>
<c:if test="${sol.rowCount eq 0 or sol.rows[0].estado ne 'Pendiente'}"><c:set var="errValidacion" value="La solicitud no existe o ya fue resuelta."/></c:if>
<c:if test="${empty errValidacion and decision ne 'Aprobada' and decision ne 'Rechazada'}"><c:set var="errValidacion" value="Decisión no válida."/></c:if>
<c:if test="${empty errValidacion and (fn:length(respuesta) lt 5 or fn:length(respuesta) gt 3000)}"><c:set var="errValidacion" value="La respuesta es obligatoria (entre 5 y 3000 caracteres)."/></c:if>
<c:set var="esProrroga" value="${not empty sol.rows and sol.rows[0].tipo eq 'Prorroga' and decision eq 'Aprobada'}"/>
<c:if test="${empty errValidacion and esProrroga}">
  <c:set var="plazoOk" value="false"/>
  <c:catch var="ignorar">
    <c:set var="plazo" value="${fn:trim(param.plazo) + 0}"/>
    <c:if test="${plazo ge 90 and plazo le 180}"><c:set var="plazoOk" value="true"/></c:if>
  </c:catch>
  <c:if test="${plazoOk ne 'true'}"><c:set var="errValidacion" value="Para aprobar una prórroga indica el nuevo plazo total (entre 90 y 180 días)."/></c:if>
</c:if>
<c:if test="${empty errValidacion}">
  <c:catch var="err">
    <sql:transaction>
      <sql:update>UPDATE solicitudes SET estado = ?, respuesta = ?, fecha_respuesta = NOW() WHERE id = ? AND estado = 'Pendiente'
        <sql:param value="${decision}"/><sql:param value="${respuesta}"/><sql:param value="${param.id}"/>
      </sql:update>
      <c:if test="${esProrroga and not empty sol.rows[0].trabajo_id}">
        <sql:update>UPDATE trabajo_fases SET fecha_limite = DATE_ADD(fecha_inicio, INTERVAL ? DAY) WHERE trabajo_id = ? AND fase_id = 5 AND fecha_inicio IS NOT NULL
          <sql:param value="${plazo}"/><sql:param value="${sol.rows[0].trabajo_id}"/>
        </sql:update>
      </c:if>
      <c:set var="nUsuario" value="${sol.rows[0].usuario_id}"/>
      <c:set var="nTitulo" value="Solicitud ${fn:toLowerCase(decision)}"/>
      <c:set var="nMensaje" value="Tu solicitud (${sol.rows[0].tipo}) fue ${fn:toLowerCase(decision)}. Respuesta: ${respuesta}"/>
      <c:set var="nTipo" value="Solicitud"/>
      <%@ include file="/WEB-INF/vistas/comunes/notificar.jspf" %>
      <c:set var="hEntidad" value="Solicitud"/><c:set var="hId" value="${param.id}"/><c:set var="hAccion" value="${decision eq 'Aprobada' ? 'Aprobar' : 'Rechazar'}"/>
      <c:set var="hDesc" value="${respuesta}"/>
      <%@ include file="/WEB-INF/vistas/comunes/historial.jspf" %>
    </sql:transaction>
  </c:catch>
</c:if>
<c:set var="okMsg" value="Solicitud ${fn:toLowerCase(decision)}."/>
<%@ include file="/WEB-INF/vistas/comunes/finalizar.jspf" %>
