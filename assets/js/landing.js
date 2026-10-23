(function () {
  var nav = document.getElementById('navLanding');
  function alDesplazar() {
    if (!nav) return;
    nav.classList.toggle('scrolled', window.scrollY > 40);
  }
  window.addEventListener('scroll', alDesplazar, { passive: true });
  alDesplazar();

  var items = document.querySelectorAll('.reveal');
  if (!('IntersectionObserver' in window)) {
    items.forEach(function (el) { el.classList.add('visible'); });
    return;
  }
  var obs = new IntersectionObserver(function (entradas) {
    entradas.forEach(function (e) {
      if (e.isIntersecting) { e.target.classList.add('visible'); obs.unobserve(e.target); }
    });
  }, { threshold: 0.15 });
  items.forEach(function (el, i) {
    el.style.transitionDelay = (i % 4) * 80 + 'ms';
    obs.observe(el);
  });
})();
