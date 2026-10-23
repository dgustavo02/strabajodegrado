<%@ page contentType="text/html;charset=UTF-8" %>
<c:set var="rolRequerido" value="estudiante"/>
<%@ include file="/WEB-INF/vistas/comunes/guardia-accion.jspf" %>
<c:set var="destinoOk" value="dashboard"/>
<c:set var="destinoErr" value="dashboard"/>
<c:set var="url" value="${fn:trim(param.url)}"/>
<sql:query var="pend">SELECT COUNT(*) AS n FROM solicitudes WHERE usuario_id = ? AND tipo = 'Prueba TyT' AND estado = 'Pendiente'<sql:param value="${sessionScope.usuarioId}"/></sql:query>
<sql:query var="tr">SELECT te.trabajo_id AS id FROM trabajo_estudiantes te WHERE te.estudiante_id = ?<sql:param value="${sessionScope.usuarioId}"/></sql:query>
<c:if test="${pend.rows[0].n gt 0}"><c:set var="errValidacion" value="Ya tienes un enlace de la prueba TyT pendiente de verificación."/></c:if>
<c:if test="${empty errValidacion and (not fn:startsWith(url, 'https://') or fn:length(url) gt 500 or fn:contains(url, ' '))}"><c:set var="errValidacion" value="El enlace debe empezar por https:// (sin espacios, máximo 500 caracteres)."/></c:if>
<c:if test="${empty errValidacion}">
  <c:set var="trabajoId" value="${tr.rowCount gt 0 ? tr.rows[0].id : ''}"/>
  <c:catch var="err">
    <sql:transaction>
      <sql:update>INSERT INTO solicitudes (usuario_id, trabajo_id, tipo, descripcion, url) VALUES (?, NULLIF(?, ''), 'Prueba TyT', 'Enlace con el resultado de la prueba Saber TyT', ?)
        <sql:param value="${sessionScope.usuarioId}"/><sql:param value="${trabajoId}"/><sql:param value="${url}"/>
      </sql:update>
      <sql:query var="nueva">SELECT LAST_INSERT_ID() AS id</sql:query>
      <c:set var="nTitulo" value="Prueba TyT por verificar"/>
      <c:set var="nMensaje" value="${sessionScope.usuarioNombre} registró el enlace de su prueba TyT."/>
      <c:set var="nTipo" value="Solicitud"/>
      <%@ include file="/WEB-INF/vistas/comunes/notificar-comite.jspf" %>
      <c:set var="hEntidad" value="Solicitud"/><c:set var="hId" value="${nueva.rows[0].id}"/><c:set var="hAccion" value="Crear"/>
      <c:set var="hDesc" value="Enlace de la prueba TyT"/>
      <%@ include file="/WEB-INF/vistas/comunes/historial.jspf" %>
    </sql:transaction>
  </c:catch>
</c:if>
<c:set var="okMsg" value="Enlace de la prueba TyT enviado. El Comité lo verificará."/>
<%@ include file="/WEB-INF/vistas/comunes/finalizar.jspf" %>