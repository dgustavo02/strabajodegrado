<%@ page contentType="text/html;charset=UTF-8" %>
<c:set var="tituloPagina" value="Trabajos de Grado | Unidades Tecnológicas de Santander"/>
<c:set var="cssExtra" value="landing"/>
<c:set var="jsExtra" value="landing"/>
<c:set var="bodyClass" value="landing-page"/>
<%@ include file="/WEB-INF/vistas/comunes/cabecera.jspf" %>

<nav class="navbar navbar-expand-lg landing-nav fixed-top" id="navLanding">
  <div class="container">
    <a class="navbar-brand d-flex align-items-center gap-2" href="#inicio">
      <span class="brand-mark">UTS</span>
      <span class="lh-sm"><strong>Trabajos de Grado</strong><small class="d-block text-white-50">Universitaria Tecnológica de Santander</small></span>
    </a>
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#menuLanding" aria-controls="menuLanding" aria-expanded="false" aria-label="Abrir menú">
      <i class="bi bi-list"></i>
    </button>
    <div class="collapse navbar-collapse" id="menuLanding">
      <ul class="navbar-nav ms-auto align-items-lg-center gap-lg-2">
        <li class="nav-item"><a class="nav-link" href="#proceso">Proceso</a></li>
        <li class="nav-item"><a class="nav-link" href="#modalidades">Modalidades</a></li>
        <li class="nav-item"><a class="nav-link" href="#etapas">Etapas</a></li>
        <li class="nav-item"><a class="nav-link" href="#perfiles">Perfiles</a></li>
        <li class="nav-item ms-lg-3">
          <c:choose>
            <c:when test="${not empty sessionScope.usuarioId}"><a class="btn btn-primary" href="${ctx}/panel.jsp">Ir a mi panel</a></c:when>
            <c:otherwise><a class="btn btn-primary" href="${ctx}/login.jsp">Iniciar sesión</a></c:otherwise>
          </c:choose>
        </li>
      </ul>
    </div>
  </div>
</nav>

<header class="hero" id="inicio">
  <div class="container">
    <div class="row align-items-center g-5">
      <div class="col-lg-7 hero-text">
        <span class="hero-chip"><i class="bi bi-stars"></i> Plataforma Académica</span>
        <h1 class="display-4 fw-bold mt-4" style="letter-spacing: -1px;">Tu trabajo de grado, de la idea a la aprobación final</h1>
        <p class="lead mt-3 text-white-50">Propón o elige una idea, entrega tus documentos, recibe observaciones de tu Director y Evaluador y sigue el estado de tu proceso en un solo lugar.</p>
        <div class="d-flex flex-wrap gap-3 mt-5">
          <c:choose>
            <c:when test="${not empty sessionScope.usuarioId}"><a class="btn btn-light btn-lg px-4 fw-bold" href="${ctx}/panel.jsp">Ir a mi panel</a></c:when>
            <c:otherwise><a class="btn btn-light btn-lg px-4 fw-bold" href="${ctx}/login.jsp">Iniciar sesión</a></c:otherwise>
          </c:choose>
          <a class="btn btn-outline-light btn-lg px-4" href="#proceso" style="backdrop-filter: blur(10px);">Conoce el proceso</a>
        </div>
      </div>
      
      <!-- Tarjeta de los pasos -->
      <div class="col-lg-5 d-none d-lg-block">
        <div class="hero-card">
          <div class="hero-step"><i class="bi bi-lightbulb"></i><div><strong>Idea</strong><small>Banco de ideas o propuesta propia</small></div></div>
          <div class="hero-step"><i class="bi bi-person-check"></i><div><strong>Asignación</strong><small>Director y Evaluador</small></div></div>
          <div class="hero-step"><i class="bi bi-file-earmark-text"></i><div><strong>Anteproyecto</strong><small>Revisión y correcciones</small></div></div>
          <div class="hero-step"><i class="bi bi-patch-check"></i><div><strong>Trabajo final</strong><small>Aprobación del Comité</small></div></div>
        </div>
      </div>
    </div>
  </div>
</header>

<section class="seccion" id="proceso">
  <div class="container">
    <div class="titulo-seccion reveal"><h2>¿Cómo funciona?</h2><p>Un proceso claro, con responsables y plazos definidos en cada paso.</p></div>
    <div class="row g-4">
      <div class="col-md-6 col-lg-3 reveal">
        <div class="tarjeta">
          <div class="icono"><i class="bi bi-lightbulb"></i></div>
          <h3>1. Elige tu idea</h3>
          <p>Selecciona una idea aprobada del banco o presenta tu propia propuesta al Comité.</p>
        </div>
      </div>
      <div class="col-md-6 col-lg-3 reveal">
        <div class="tarjeta">
          <div class="icono"><i class="bi bi-receipt"></i></div>
          <h3>2. Registra el pago</h3>
          <p>Adjunta el enlace de tu comprobante. El Comité valida el pago y reserva la idea para ti.</p>
        </div>
      </div>
      <div class="col-md-6 col-lg-3 reveal">
        <div class="tarjeta">
          <div class="icono"><i class="bi bi-cloud-upload"></i></div>
          <h3>3. Entrega y corrige</h3>
          <p>Registra tus entregas por enlace, consulta las observaciones y corrige cuando se aplace.</p>
        </div>
      </div>
      <div class="col-md-6 col-lg-3 reveal">
        <div class="tarjeta">
          <div class="icono"><i class="bi bi-patch-check"></i></div>
          <h3>4. Aprobación final</h3>
          <p>Director, Evaluador y Comité revisan tu trabajo final hasta su aprobación.</p>
        </div>
      </div>
    </div>
  </div>
</section>

<section class="seccion seccion-alt" id="modalidades">
  <div class="container">
    <div class="titulo-seccion reveal"><h2>Modalidades de trabajo de grado</h2><p>Elige la modalidad que se ajusta a tu idea. Puedes trabajar solo o con un compañero.</p></div>
    <div class="row g-4">
      <div class="col-md-6 col-lg-3 reveal"><div class="tarjeta"><div class="icono"><i class="bi bi-cpu"></i></div><h3>Desarrollo tecnológico</h3><p>Diseño y construcción de soluciones, sistemas o prototipos tecnológicos.</p></div></div>
      <div class="col-md-6 col-lg-3 reveal"><div class="tarjeta"><div class="icono"><i class="bi bi-rocket-takeoff"></i></div><h3>Emprendimiento</h3><p>Creación y planeación de una iniciativa empresarial con base en tu formación.</p></div></div>
      <div class="col-md-6 col-lg-3 reveal"><div class="tarjeta"><div class="icono"><i class="bi bi-book"></i></div><h3>Monografía</h3><p>Estudio documentado y analítico de un tema específico de tu área.</p></div></div>
      <div class="col-md-6 col-lg-3 reveal"><div class="tarjeta"><div class="icono"><i class="bi bi-search"></i></div><h3>Investigación</h3><p>Indagación sistemática que genera conocimiento a partir de una pregunta.</p></div></div>
    </div>
  </div>
</section>

<section class="seccion" id="etapas">
  <div class="container">
    <div class="titulo-seccion reveal"><h2>Etapas del trabajo de grado</h2><p>Cada trabajo avanza por fases y siempre sabes en cuál está y quién debe actuar.</p></div>
    <ol class="linea-tiempo">
      <li class="reveal"><span class="punto">0</span><div><h3>Validaciones iniciales</h3><p>El Comité verifica las condiciones académicas para iniciar el proceso.</p></div></li>
      <li class="reveal"><span class="punto">1</span><div><h3>Idea y asignación</h3><p>Idea, comprobante de pago, revisión del Comité y asignación de Director y Evaluador.</p></div></li>
      <li class="reveal"><span class="punto">2</span><div><h3>Anteproyecto</h3><p>Entregas el anteproyecto y tu Director lo revisa.</p></div></li>
      <li class="reveal"><span class="punto">3</span><div><h3>Evaluación y revisión del Comité</h3><p>El Evaluador revisa el anteproyecto y el Comité decide.</p></div></li>
      <li class="reveal"><span class="punto">4</span><div><h3>Trabajo final</h3><p>Documento final, manual y código fuente, con plazo de 90 a 180 días.</p></div></li>
    </ol>
  </div>
</section>

<section class="cta">
  <div class="container text-center reveal">
    <h2>¿Listo para comenzar?</h2>
    <p>Ingresa con tu correo institucional y continúa tu proceso.</p>
    <c:choose>
      <c:when test="${not empty sessionScope.usuarioId}"><a class="btn btn-light btn-lg px-5 fw-bold mt-3" href="${ctx}/panel.jsp">Ir a mi panel</a></c:when>
      <c:otherwise><a class="btn btn-light btn-lg px-5 fw-bold mt-3" href="${ctx}/login.jsp">Iniciar sesión</a></c:otherwise>
    </c:choose>
  </div>
</section>

<footer class="landing-footer">
  <div class="container d-flex flex-column flex-md-row justify-content-between gap-2">
    <span><strong>Universitaria Tecnológica de Santander</strong> · Sistema de Gestión de Trabajos de Grado</span>
    <jsp:useBean id="hoy" class="java.util.Date"/>
    <span>© <fmt:formatDate value="${hoy}" pattern="yyyy"/></span>
  </div>
</footer>
<%@ include file="/WEB-INF/vistas/comunes/pie.jspf" %>