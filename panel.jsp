<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="/WEB-INF/vistas/comunes/guardia.jspf" %>
<%-- Enrutador de vistas privadas: solo sirve vistas de la lista blanca del rol de la sesión --%>
<c:set var="v" value="${empty param.v ? 'dashboard' : fn:trim(param.v)}"/>
<c:choose>
  <c:when test="${sessionScope.carpeta eq 'administrador'}">
    <c:set var="permitidas" value="|dashboard|usuarios/listar|usuarios/crear|usuarios/editar|usuarios/detalle|notificaciones|"/>
  </c:when>
  <c:when test="${sessionScope.carpeta eq 'comite'}">
    <c:set var="permitidas" value="|dashboard|ideas/listar|ideas/revisar|propuestas/listar|propuestas/revisar|asignaciones/pagos|asignaciones/director|asignaciones/evaluador|trabajos/listar|trabajos/detalle|solicitudes/listar|actas/listar|notificaciones|"/>
  </c:when>
  <c:when test="${sessionScope.carpeta eq 'docente'}">
    <c:set var="permitidas" value="|dashboard|ideas/mis-ideas|ideas/crear|trabajos/asignados|director/revisiones|director/evaluar-entregas|evaluador/proyectos|evaluador/registrar-evaluacion|historial|notificaciones|"/>
  </c:when>
  <c:when test="${sessionScope.carpeta eq 'estudiante'}">
    <c:set var="permitidas" value="|dashboard|ideas/banco|ideas/detalle|propuestas/crear|asignaciones/solicitar|trabajo/mi-trabajo|entregas/listar|entregas/registrar|entregas/corregir|solicitudes/listar|notificaciones|"/>
  </c:when>
  <c:otherwise><c:set var="permitidas" value="|"/></c:otherwise>
</c:choose>
<c:set var="clave" value="|${v}|"/>
<c:if test="${fn:contains(v, '|') or not fn:contains(permitidas, clave)}">
  <c:set var="ignorar" value="${pageContext.response.setStatus(404)}"/>
  <jsp:forward page="/WEB-INF/vistas/errores/404.jsp"/>
</c:if>
<c:choose>
  <c:when test="${v eq 'notificaciones'}"><c:set var="vista" value="estudiante/notificaciones/listar"/></c:when>
  <c:otherwise><c:set var="vista" value="${sessionScope.carpeta}/${v}"/></c:otherwise>
</c:choose>
<c:set var="vistaActual" value="${v}"/>
<c:set var="tituloPagina" value="Panel | Trabajos de Grado UTS"/>
<c:set var="cssExtra" value="dashboard"/>
<c:set var="jsExtra" value="dashboard"/>
<c:set var="bodyClass" value="app-body"/>
<%@ include file="/WEB-INF/vistas/comunes/cabecera.jspf" %>
<div class="app-shell">
  <%@ include file="/WEB-INF/vistas/comunes/menu-lateral.jspf" %>
  <div class="app-main">
    <%@ include file="/WEB-INF/vistas/comunes/barra-superior.jspf" %>
    <main class="app-content">
      <%@ include file="/WEB-INF/vistas/comunes/mensajes.jspf" %>
      <jsp:include page="/WEB-INF/vistas/${vista}.jsp"/>
    </main>
  </div>
</div>
<%@ include file="/WEB-INF/vistas/comunes/pie.jspf" %>
