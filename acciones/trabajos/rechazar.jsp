<%@ page contentType="text/html;charset=UTF-8" %>
<c:set var="rolRequerido" value="comite"/>
<%@ include file="/WEB-INF/vistas/comunes/guardia-accion.jspf" %>
<c:set var="destinoOk" value="trabajos/detalle"/>
<c:set var="destinoErr" value="trabajos/detalle"/>
<c:set var="destinoId" value="${param.trabajo}"/>
<c:set var="obs" value="${fn:trim(param.motivo)}"/>
<sql:query var="tr">SELECT id, estado FROM trabajos_grado WHERE id = ?<sql:param value="${param.trabajo}"/></sql:query>
<c:if test="${tr.rowCount eq 0 or tr.rows[0].estado eq 'Rechazado' or tr.rows[0].estado eq 'Finalizado'}"><c:set var="errValidacion" value="El trabajo no existe o ya está cerrado."/></c:if>
<c:if test="${empty errValidacion and (fn:length(obs) lt 5 or fn:length(obs) gt 3000)}"><c:set var="errValidacion" value="El motivo del rechazo es obligatorio (entre 5 y 3000 caracteres)."/></c:if>
<c:if test="${empty errValidacion}">
  <c:catch var="err">
    <sql:transaction>
      <sql:update>INSERT INTO actas (usuario_comite_id, trabajo_id, tipo, decision, observaciones) VALUES (?, ?, 'Decision de trabajo', 'Rechazada', ?)
        <sql:param value="${sessionScope.usuarioId}"/><sql:param value="${param.trabajo}"/><sql:param value="${obs}"/>
      </sql:update>
      <c:set var="nTrabajo" value="${param.trabajo}"/>
      <c:set var="nTitulo" value="Trabajo rechazado"/>
      <c:set var="nMensaje" value="El Comité rechazó tu trabajo de grado. Motivo: ${obs} Puedes iniciar un nuevo proceso con una idea diferente."/>
      <c:set var="nTipo" value="Trabajo"/>
      <%@ include file="/WEB-INF/vistas/comunes/notificar-estudiantes.jspf" %>
      <sql:update>UPDATE entregas SET estado = 'Rechazada' WHERE trabajo_id = ? AND estado IN ('Pendiente','En revision','En comite')<sql:param value="${param.trabajo}"/></sql:update>
      <sql:update>UPDATE trabajo_fases SET estado = 'Rechazada' WHERE trabajo_id = ? AND estado IN ('En proceso','Aplazada')<sql:param value="${param.trabajo}"/></sql:update>
      <sql:update>UPDATE trabajos_grado SET estado = 'Rechazado' WHERE id = ?<sql:param value="${param.trabajo}"/></sql:update>
      <c:set var="hEntidad" value="Trabajo"/><c:set var="hId" value="${param.trabajo}"/><c:set var="hAccion" value="Rechazar"/>
      <c:set var="hDesc" value="Rechazo por el Comité. ${obs}"/>
      <%@ include file="/WEB-INF/vistas/comunes/historial.jspf" %>
    </sql:transaction>
  </c:catch>
</c:if>
<c:set var="okMsg" value="Trabajo rechazado. Los estudiantes fueron desvinculados."/>
<%@ include file="/WEB-INF/vistas/comunes/finalizar.jspf" %>
