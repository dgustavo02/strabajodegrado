<sql:query var="r">
  SELECT (SELECT COUNT(*) FROM users) AS total,
         (SELECT COUNT(*) FROM users WHERE estado = 'Activo') AS activos,
         (SELECT COUNT(*) FROM users WHERE estado = 'Inactivo') AS inactivos,
         (SELECT COUNT(*) FROM ideas) AS ideas,
         (SELECT COUNT(*) FROM propuestas_estudiantes) AS propuestas,
         (SELECT COUNT(*) FROM trabajos_grado) AS trabajos
</sql:query>
<sql:query var="porRol">
  SELECT r.nombre, COUNT(ru.user_id) AS n FROM roles r LEFT JOIN role_user ru ON ru.role_id = r.id
   WHERE r.id IN (1, 2, 3, 6) GROUP BY r.id, r.nombre ORDER BY r.id
</sql:query>
<sql:query var="porEstado">SELECT estado, COUNT(*) AS n FROM trabajos_grado GROUP BY estado ORDER BY n DESC</sql:query>
<c:set var="d" value="${r.rows[0]}"/>
<div class="page-header"><h1>Panel del administrador</h1><p>Resumen general del sistema.</p></div>
<div class="row g-3 mb-4">
  <div class="col-6 col-lg-3"><a class="stat-card" href="${ctx}/panel.jsp?v=usuarios/listar"><div class="stat-icon"><i class="bi bi-people"></i></div><div><div class="stat-num">${d.total}</div><div class="stat-label">Usuarios</div></div></a></div>
  <div class="col-6 col-lg-3"><a class="stat-card" href="${ctx}/panel.jsp?v=usuarios/listar&estado=Activo"><div class="stat-icon"><i class="bi bi-person-check"></i></div><div><div class="stat-num">${d.activos}</div><div class="stat-label">Activos</div></div></a></div>
  <div class="col-6 col-lg-3"><a class="stat-card peligro" href="${ctx}/panel.jsp?v=usuarios/listar&estado=Inactivo"><div class="stat-icon"><i class="bi bi-person-x"></i></div><div><div class="stat-num">${d.inactivos}</div><div class="stat-label">Inactivos</div></div></a></div>
  <div class="col-6 col-lg-3"><div class="stat-card"><div class="stat-icon"><i class="bi bi-mortarboard"></i></div><div><div class="stat-num">${d.trabajos}</div><div class="stat-label">Trabajos de grado</div></div></div></div>
  <div class="col-6 col-lg-3"><div class="stat-card"><div class="stat-icon"><i class="bi bi-lightbulb"></i></div><div><div class="stat-num">${d.ideas}</div><div class="stat-label">Ideas de docentes</div></div></div></div>
  <div class="col-6 col-lg-3"><div class="stat-card"><div class="stat-icon"><i class="bi bi-journal-text"></i></div><div><div class="stat-num">${d.propuestas}</div><div class="stat-label">Propuestas de estudiantes</div></div></div></div>
</div>
<div class="row g-3">
  <div class="col-lg-6"><div class="panel">
    <h2>Usuarios por rol</h2>
    <table class="table table-sm mb-0"><tbody>
      <c:forEach var="f" items="${porRol.rows}"><tr><td><c:out value="${f.nombre}"/></td><td class="text-end fw-semibold">${f.n}</td></tr></c:forEach>
    </tbody></table>
  </div></div>
  <div class="col-lg-6"><div class="panel">
    <h2>Trabajos por estado</h2>
    <c:choose>
      <c:when test="${porEstado.rowCount eq 0}"><p class="text-muted mb-0">Aún no hay trabajos de grado.</p></c:when>
      <c:otherwise>
        <table class="table table-sm mb-0"><tbody>
          <c:forEach var="f" items="${porEstado.rows}"><tr><td><span class="estado" data-estado="${f.estado}"><c:out value="${f.estado}"/></span></td><td class="text-end fw-semibold">${f.n}</td></tr></c:forEach>
        </tbody></table>
      </c:otherwise>
    </c:choose>
  </div></div>
</div>
