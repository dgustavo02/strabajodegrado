<%@ page contentType="text/html;charset=UTF-8" %>
<c:set var="rolRequerido" value="comite"/>
<%@ include file="/WEB-INF/vistas/comunes/guardia-accion.jspf" %>
<c:set var="destinoOk" value="ideas/listar"/>
<c:set var="destinoErr" value="ideas/revisar"/>
<c:set var="destinoId" value="${param.id}"/>
<c:set var="decision" value="${param.decision}"/>
<c:set var="obs" value="${fn:trim(param.observaciones)}"/>
<sql:query var="idea">SELECT id, docente_id, titulo, estado FROM ideas WHERE id = ?<sql:param value="${param.id}"/></sql:query>
<c:if test="${idea.rowCount eq 0 or idea.rows[0].estado ne 'Pendiente'}"><c:set var="errValidacion" value="La idea no existe o ya fue revisada."/></c:if>
<c:if test="${empty errValidacion and decision ne 'Aprobada' and decision ne 'Rechazada'}"><c:set var="errValidacion" value="Decisión no válida."/></c:if>
<c:if test="${empty errValidacion and decision eq 'Rechazada' and fn:length(obs) lt 5}"><c:set var="errValidacion" value="Para rechazar debes escribir el motivo (mínimo 5 caracteres)."/></c:if>
<c:if test="${empty errValidacion and fn:length(obs) gt 2000}"><c:set var="errValidacion" value="Las observaciones son demasiado largas."/></c:if>
<c:if test="${empty errValidacion}">
  <c:if test="${empty obs}"><c:set var="obs" value="Aprobada sin observaciones."/></c:if>
  <c:set var="tipoActa" value="${decision eq 'Aprobada' ? 'Aprobacion de idea' : 'Rechazo de idea'}"/>
  <c:catch var="err">
    <sql:transaction>
      <sql:update>UPDATE ideas SET estado = ?, observaciones_comite = ?, fecha_decision = NOW() WHERE id = ? AND estado = 'Pendiente'
        <sql:param value="${decision}"/><sql:param value="${obs}"/><sql:param value="${param.id}"/>
      </sql:update>
      <sql:update>INSERT INTO actas (usuario_comite_id, idea_id, tipo, decision, observaciones) VALUES (?, ?, ?, ?, ?)
        <sql:param value="${sessionScope.usuarioId}"/><sql:param value="${param.id}"/><sql:param value="${tipoActa}"/><sql:param value="${decision}"/><sql:param value="${obs}"/>
      </sql:update>
      <c:set var="nUsuario" value="${idea.rows[0].docente_id}"/>
      <c:set var="nTitulo" value="${decision eq 'Aprobada' ? 'Idea aprobada' : 'Idea rechazada'}"/>
      <c:set var="nMensaje" value="Tu idea «${idea.rows[0].titulo}» fue ${decision eq 'Aprobada' ? 'aprobada y pasó al banco de ideas' : 'rechazada'}. Observaciones: ${obs}"/>
      <c:set var="nTipo" value="Idea"/>
      <%@ include file="/WEB-INF/vistas/comunes/notificar.jspf" %>
      <c:set var="hEntidad" value="Idea"/><c:set var="hId" value="${param.id}"/><c:set var="hAccion" value="${decision eq 'Aprobada' ? 'Aprobar' : 'Rechazar'}"/>
      <c:set var="hDesc" value="${obs}"/>
      <%@ include file="/WEB-INF/vistas/comunes/historial.jspf" %>
    </sql:transaction>
  </c:catch>
</c:if>
<c:set var="okMsg" value="Decisión registrada: idea ${fn:toLowerCase(decision)}."/>
<%@ include file="/WEB-INF/vistas/comunes/finalizar.jspf" %>
