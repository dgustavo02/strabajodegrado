<%@ page contentType="text/html;charset=UTF-8" %>
<c:set var="rolRequerido" value="administrador"/>
<%@ include file="/WEB-INF/vistas/comunes/guardia-accion.jspf" %>
<c:set var="destinoOk" value="usuarios/listar"/>
<c:set var="destinoErr" value="usuarios/listar"/>
<c:set var="nuevoEstado" value="${param.estado}"/>
<c:if test="${nuevoEstado ne 'Activo' and nuevoEstado ne 'Inactivo'}"><c:set var="errValidacion" value="Estado no válido."/></c:if>
<c:if test="${empty errValidacion and param.id eq sessionScope.usuarioId}"><c:set var="errValidacion" value="No puedes desactivar tu propia cuenta."/></c:if>
<c:if test="${empty errValidacion}">
  <c:catch var="err">
    <sql:transaction>
      <sql:update>UPDATE users SET estado = ? WHERE id = ?<sql:param value="${nuevoEstado}"/><sql:param value="${param.id}"/></sql:update>
      <c:set var="hEntidad" value="Usuario"/><c:set var="hId" value="${param.id}"/><c:set var="hAccion" value="Cambiar estado"/>
      <c:set var="hDesc" value="Usuario marcado como ${nuevoEstado}"/>
      <%@ include file="/WEB-INF/vistas/comunes/historial.jspf" %>
    </sql:transaction>
  </c:catch>
</c:if>
<c:set var="okMsg" value="El usuario quedó ${fn:toLowerCase(nuevoEstado)}."/>
<%@ include file="/WEB-INF/vistas/comunes/finalizar.jspf" %>
