<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="/WEB-INF/vistas/comunes/guardia-accion.jspf" %>
<c:choose>
  <c:when test="${param.todas eq '1'}">
    <sql:update>UPDATE notificaciones SET leida = 1, fecha_lectura = NOW() WHERE usuario_id = ? AND leida = 0<sql:param value="${sessionScope.usuarioId}"/></sql:update>
  </c:when>
  <c:otherwise>
    <sql:update>UPDATE notificaciones SET leida = 1, fecha_lectura = NOW() WHERE id = ? AND usuario_id = ? AND leida = 0<sql:param value="${param.id}"/><sql:param value="${sessionScope.usuarioId}"/></sql:update>
  </c:otherwise>
</c:choose>
<c:redirect url="/panel.jsp"><c:param name="v" value="notificaciones"/></c:redirect>
