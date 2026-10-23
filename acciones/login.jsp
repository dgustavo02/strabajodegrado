<%@ page contentType="text/html;charset=UTF-8" %>
<c:if test="${pageContext.request.method ne 'POST' or empty param.csrf or param.csrf ne sessionScope.csrf}"><c:redirect url="/login.jsp"/></c:if>
<c:set var="correo" value="${fn:toLowerCase(fn:trim(param.correo))}"/>
<c:set var="msg" value=""/>
<c:if test="${empty correo or empty param.clave}"><c:set var="msg" value="Ingresa tu correo y tu contraseña."/></c:if>
<c:if test="${empty msg}">
  <sql:query var="u">
    SELECT u.id, u.nombre, u.estado, ru.role_id,
           IF(u.bloqueado_hasta IS NOT NULL AND u.bloqueado_hasta > NOW(), 1, 0) AS bloqueado,
           IF(u.password = CONCAT(SUBSTRING_INDEX(u.password, '$', 1), '$', SHA2(CONCAT(SUBSTRING_INDEX(u.password, '$', 1), ?), 256)), 1, 0) AS ok
      FROM users u JOIN role_user ru ON ru.user_id = u.id
     WHERE u.email_institucional = ?
    <sql:param value="${param.clave}"/><sql:param value="${correo}"/>
  </sql:query>
  <c:choose>
    <c:when test="${u.rowCount eq 0}"><c:set var="msg" value="Correo o contraseña incorrectos."/></c:when>
    <c:when test="${u.rows[0].bloqueado eq 1}"><c:set var="msg" value="Demasiados intentos fallidos. Intenta de nuevo en 15 minutos."/></c:when>
    <c:when test="${u.rows[0].ok ne 1}">
      <%-- Si un bloqueo anterior ya venció, el conteo empieza de nuevo (MySQL asigna de izquierda a derecha) --%>
      <sql:update>UPDATE users SET intentos_fallidos = IF(bloqueado_hasta IS NOT NULL AND bloqueado_hasta <= NOW(), 1, intentos_fallidos + 1),
                    bloqueado_hasta = IF(intentos_fallidos >= 5, DATE_ADD(NOW(), INTERVAL 15 MINUTE), IF(bloqueado_hasta <= NOW(), NULL, bloqueado_hasta))
                  WHERE id = ?<sql:param value="${u.rows[0].id}"/></sql:update>
      <c:set var="msg" value="Correo o contraseña incorrectos."/>
    </c:when>
    <c:when test="${u.rows[0].estado ne 'Activo'}"><c:set var="msg" value="Tu cuenta no está habilitada. Comunícate con el administrador."/></c:when>
  </c:choose>
</c:if>
<c:if test="${not empty msg}">
  <c:set var="flashTipo" value="danger" scope="session"/>
  <c:set var="flashMsg" value="${msg}" scope="session"/>
  <c:redirect url="/login.jsp"/>
</c:if>
<%-- Credenciales correctas: reinicia contadores, renueva la sesión y crea un nuevo token CSRF --%>
<sql:update>UPDATE users SET intentos_fallidos = 0, bloqueado_hasta = NULL, ultimo_acceso = NOW() WHERE id = ?<sql:param value="${u.rows[0].id}"/></sql:update>
<sql:query var="tk">SELECT LOWER(HEX(RANDOM_BYTES(16))) AS t</sql:query>
<c:set var="ignorar" value="${pageContext.request.changeSessionId()}"/>
<c:set var="usuarioId" value="${u.rows[0].id}" scope="session"/>
<c:set var="usuarioNombre" value="${u.rows[0].nombre}" scope="session"/>
<c:set var="csrf" value="${tk.rows[0].t}" scope="session"/>
<c:choose>
  <c:when test="${u.rows[0].role_id eq 1}"><c:set var="rol" value="Administrador" scope="session"/><c:set var="carpeta" value="administrador" scope="session"/></c:when>
  <c:when test="${u.rows[0].role_id eq 2}"><c:set var="rol" value="Coordinación/Comité" scope="session"/><c:set var="carpeta" value="comite" scope="session"/></c:when>
  <c:when test="${u.rows[0].role_id eq 3}"><c:set var="rol" value="Docente" scope="session"/><c:set var="carpeta" value="docente" scope="session"/></c:when>
  <c:otherwise><c:set var="rol" value="Estudiante" scope="session"/><c:set var="carpeta" value="estudiante" scope="session"/></c:otherwise>
</c:choose>
<c:redirect url="/panel.jsp"/>
