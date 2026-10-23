<%@ page contentType="text/html;charset=UTF-8" %>
<c:set var="rolRequerido" value="comite"/>
<%@ include file="/WEB-INF/vistas/comunes/guardia-accion.jspf" %>
<c:set var="destinoOk" value="trabajos/detalle"/>
<c:set var="destinoErr" value="asignaciones/director"/>
<c:set var="destinoId" value="${param.trabajo}"/>
<c:set var="msgDuplicado" value="Ese docente ya participa en este trabajo con otra función."/>
<sql:query var="tr">SELECT id, estado FROM trabajos_grado WHERE id = ?<sql:param value="${param.trabajo}"/></sql:query>
<sql:query var="actual">SELECT docente_id FROM trabajo_docentes WHERE trabajo_id = ? AND funcion = 'Director'<sql:param value="${param.trabajo}"/></sql:query>
<c:if test="${tr.rowCount eq 0 or tr.rows[0].estado eq 'Rechazado' or tr.rows[0].estado eq 'Finalizado'}"><c:set var="errValidacion" value="El trabajo no existe o ya está cerrado."/></c:if>
<c:if test="${empty errValidacion and empty param.docente}"><c:set var="errValidacion" value="Selecciona un docente."/></c:if>
<c:if test="${empty errValidacion and actual.rowCount gt 0 and actual.rows[0].docente_id eq param.docente}"><c:set var="errValidacion" value="Ese docente ya es el Director del trabajo."/></c:if>
<c:if test="${empty errValidacion}">
  <c:catch var="err">
    <sql:transaction>
      <c:choose>
        <c:when test="${actual.rowCount gt 0}">
          <sql:update>UPDATE trabajo_docentes SET docente_id = ?, fecha_asignacion = NOW() WHERE trabajo_id = ? AND funcion = 'Director'
            <sql:param value="${param.docente}"/><sql:param value="${param.trabajo}"/>
          </sql:update>
        </c:when>
        <c:otherwise>
          <sql:update>INSERT INTO trabajo_docentes (trabajo_id, docente_id, funcion) VALUES (?, ?, 'Director')
            <sql:param value="${param.trabajo}"/><sql:param value="${param.docente}"/>
          </sql:update>
        </c:otherwise>
      </c:choose>
      <c:set var="nUsuario" value="${param.docente}"/>
      <c:set var="nTitulo" value="Asignación como Director"/>
      <c:set var="nMensaje" value="Fuiste designado Director de un trabajo de grado. Revisa la sección «Como Director»."/>
      <c:set var="nTipo" value="Trabajo"/>
      <%@ include file="/WEB-INF/vistas/comunes/notificar.jspf" %>
      <c:set var="nTrabajo" value="${param.trabajo}"/>
      <c:set var="nTitulo" value="Director asignado"/>
      <c:set var="nMensaje" value="El Comité asignó el Director de tu trabajo de grado."/>
      <c:set var="nTipo" value="Trabajo"/>
      <%@ include file="/WEB-INF/vistas/comunes/notificar-estudiantes.jspf" %>
      <c:set var="hEntidad" value="Trabajo"/><c:set var="hId" value="${param.trabajo}"/><c:set var="hAccion" value="Asignar"/>
      <c:set var="hDesc" value="Director asignado (docente ${param.docente})"/>
      <%@ include file="/WEB-INF/vistas/comunes/historial.jspf" %>
    </sql:transaction>
  </c:catch>
</c:if>
<c:set var="okMsg" value="Director asignado correctamente."/>
<%@ include file="/WEB-INF/vistas/comunes/finalizar.jspf" %>
