<%@ page contentType="text/html;charset=UTF-8" %>
<c:set var="rolRequerido" value="estudiante"/>
<%@ include file="/WEB-INF/vistas/comunes/guardia-accion.jspf" %>
<c:set var="destinoOk" value="dashboard"/>
<c:set var="destinoErr" value="dashboard"/>
<c:set var="tipo" value="${fn:trim(param.tipo)}"/>
<c:set var="asunto" value="${fn:trim(param.asunto)}"/>
<c:set var="mensaje" value="${fn:trim(param.mensaje)}"/>
<c:set var="claveTipo" value="|${tipo}|"/>
<c:set var="salto" value="
"/>
<sql:query var="tr">SELECT te.trabajo_id AS id FROM trabajo_estudiantes te WHERE te.estudiante_id = ?<sql:param value="${sessionScope.usuarioId}"/></sql:query>
<c:if test="${not fn:contains('|Peticion|Queja|Reclamo|Sugerencia|', claveTipo)}"><c:set var="errValidacion" value="Selecciona el tipo de PQRS."/></c:if>
<c:if test="${empty errValidacion and (fn:length(asunto) lt 5 or fn:length(asunto) gt 120)}"><c:set var="errValidacion" value="El asunto debe tener entre 5 y 120 caracteres."/></c:if>
<c:if test="${empty errValidacion and (fn:length(mensaje) lt 10 or fn:length(mensaje) gt 3000)}"><c:set var="errValidacion" value="El mensaje debe tener entre 10 y 3000 caracteres."/></c:if>
<c:if test="${empty errValidacion}">
  <c:set var="trabajoId" value="${tr.rowCount gt 0 ? tr.rows[0].id : ''}"/>
  <c:catch var="err">
    <sql:transaction>
      <sql:update>INSERT INTO solicitudes (usuario_id, trabajo_id, tipo, descripcion) VALUES (?, NULLIF(?, ''), ?, ?)
        <sql:param value="${sessionScope.usuarioId}"/><sql:param value="${trabajoId}"/><sql:param value="${tipo}"/><sql:param value="${asunto}${salto}${salto}${mensaje}"/>
      </sql:update>
      <sql:query var="nueva">SELECT LAST_INSERT_ID() AS id</sql:query>
      <c:set var="nTitulo" value="Nueva PQRS: ${tipo}"/>
      <c:set var="nMensaje" value="${sessionScope.usuarioNombre} envió: ${asunto}"/>
      <c:set var="nTipo" value="Solicitud"/>
      <%@ include file="/WEB-INF/vistas/comunes/notificar-comite.jspf" %>
      <c:set var="hEntidad" value="Solicitud"/><c:set var="hId" value="${nueva.rows[0].id}"/><c:set var="hAccion" value="Crear"/>
      <c:set var="hDesc" value="PQRS: ${tipo}"/>
      <%@ include file="/WEB-INF/vistas/comunes/historial.jspf" %>
    </sql:transaction>
  </c:catch>
</c:if>
<c:set var="okMsg" value="Tu ${fn:toLowerCase(tipo)} fue enviada al Comité. Recibirás la respuesta en tus solicitudes."/>
<%@ include file="/WEB-INF/vistas/comunes/finalizar.jspf" %>