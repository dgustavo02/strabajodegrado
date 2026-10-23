<%@ page contentType="text/html;charset=UTF-8" %>
<c:set var="rolRequerido" value="estudiante"/>
<%@ include file="/WEB-INF/vistas/comunes/guardia-accion.jspf" %>
<c:set var="destinoOk" value="dashboard"/>
<c:set var="destinoErr" value="asignaciones/solicitar"/>
<c:set var="destinoId" value="${param.idea}"/>
<c:set var="msgDuplicado" value="Esa idea ya fue tomada por otro estudiante o ya tienes una solicitud activa."/>
<c:set var="url" value="${fn:trim(param.url)}"/>
<sql:query var="estado">SELECT
    (SELECT COUNT(*) FROM trabajo_estudiantes WHERE estudiante_id = ?) AS trabajos,
    (SELECT COUNT(*) FROM asignaciones_ideas WHERE estudiante_id = ? AND estado IN ('Pendiente_validacion','Validada')) AS asignaciones,
    (SELECT COUNT(*) FROM propuestas_estudiantes WHERE estudiante_id = ? AND estado = 'Pendiente') AS propuestas
  <sql:param value="${sessionScope.usuarioId}"/><sql:param value="${sessionScope.usuarioId}"/><sql:param value="${sessionScope.usuarioId}"/>
</sql:query>
<sql:query var="idea">SELECT id, titulo, estado FROM ideas WHERE id = ?<sql:param value="${param.idea}"/></sql:query>
<c:if test="${estado.rows[0].trabajos gt 0 or estado.rows[0].asignaciones gt 0}"><c:set var="errValidacion" value="Ya tienes un trabajo de grado o una solicitud de idea en curso."/></c:if>
<c:if test="${empty errValidacion and estado.rows[0].propuestas gt 0}"><c:set var="errValidacion" value="Tienes una propuesta propia pendiente de revisión."/></c:if>
<c:if test="${empty errValidacion and (idea.rowCount eq 0 or idea.rows[0].estado ne 'Aprobada')}"><c:set var="errValidacion" value="La idea no está disponible en el banco de ideas."/></c:if>
<c:if test="${empty errValidacion and (not fn:startsWith(url, 'https://') or fn:length(url) gt 500 or fn:contains(url, ' '))}"><c:set var="errValidacion" value="El comprobante de pago debe ser un enlace que empiece por https:// (sin espacios, máximo 500 caracteres)."/></c:if>
<c:if test="${empty errValidacion}">
  <c:catch var="err">
    <sql:transaction>
      <sql:update>INSERT INTO asignaciones_ideas (idea_id, estudiante_id, comprobante_pago_url) VALUES (?, ?, ?)
        <sql:param value="${param.idea}"/><sql:param value="${sessionScope.usuarioId}"/><sql:param value="${url}"/>
      </sql:update>
      <sql:query var="nueva">SELECT LAST_INSERT_ID() AS id</sql:query>
      <c:set var="nTitulo" value="Pago por validar"/>
      <c:set var="nMensaje" value="${sessionScope.usuarioNombre} seleccionó la idea «${idea.rows[0].titulo}» y registró su comprobante de pago."/>
      <c:set var="nTipo" value="Idea"/>
      <%@ include file="/WEB-INF/vistas/comunes/notificar-comite.jspf" %>
      <c:set var="hEntidad" value="Asignacion"/><c:set var="hId" value="${nueva.rows[0].id}"/><c:set var="hAccion" value="Crear"/>
      <c:set var="hDesc" value="Solicitud de la idea ${idea.rows[0].titulo}"/>
      <%@ include file="/WEB-INF/vistas/comunes/historial.jspf" %>
    </sql:transaction>
  </c:catch>
</c:if>
<c:set var="okMsg" value="Solicitud enviada. El Comité validará tu comprobante de pago y la asignación."/>
<%@ include file="/WEB-INF/vistas/comunes/finalizar.jspf" %>
