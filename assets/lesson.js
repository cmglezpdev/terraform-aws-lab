/* ============================================================
   Componentes interactivos compartidos por las lecciones.
   Sin dependencias. Se auto-inicializa al cargar.

   1. Quiz    — <div class="quiz"> con botones data-correct / data-why
   2. Checklist con memoria — <ul class="checklist" data-key="...">
   3. Toggle de tema claro/oscuro
   ============================================================ */

(function () {
  "use strict";

  /* --- almacenamiento tolerante a fallos (modo privado, previews) --- */
  const store = {
    get(k) { try { return localStorage.getItem(k); } catch { return null; } },
    set(k, v) { try { localStorage.setItem(k, v); } catch { /* no-op */ } },
  };

  /* ---------------- 1. Quiz ---------------- */
  /*
    <div class="quiz">
      <p class="quiz-kicker">Comprueba</p>
      <p class="quiz-q">¿Pregunta?</p>
      <ul class="quiz-opts">
        <li><button data-correct="true"  data-why="Explicación.">Opción A</button></li>
        <li><button data-correct="false" data-why="Por qué no.">Opción B</button></li>
      </ul>
      <div class="quiz-feedback"></div>
    </div>
  */
  function initQuiz(quiz) {
    const buttons = [...quiz.querySelectorAll(".quiz-opts button")];
    const feedback = quiz.querySelector(".quiz-feedback");
    if (!buttons.length || !feedback) return;

    buttons.forEach((btn) => {
      btn.addEventListener("click", () => {
        if (quiz.dataset.answered === "true") return;
        quiz.dataset.answered = "true";

        const right = btn.dataset.correct === "true";

        buttons.forEach((b) => {
          b.disabled = true;
          if (b.dataset.correct === "true") b.classList.add("correct");
          else if (b === btn) b.classList.add("wrong");
          else b.classList.add("faded");
        });

        const verdict = right
          ? '<b class="verdict-ok">Correcto.</b> '
          : '<b class="verdict-no">No exactamente.</b> ';

        // Siempre se explica la respuesta elegida; si fue errónea, también la correcta.
        let body = btn.dataset.why || "";
        if (!right) {
          const good = buttons.find((b) => b.dataset.correct === "true");
          if (good && good.dataset.why) {
            body += ` <span class="small">La correcta es «${good.textContent.trim()}»: ${good.dataset.why}</span>`;
          }
        }
        feedback.innerHTML = verdict + body;
        feedback.setAttribute("role", "status");
      });
    });
  }

  /* ---------------- 2. Checklist con memoria ---------------- */
  /*
    <ul class="checklist" data-key="l01-setup">
      <li><input type="checkbox" id="x"><label for="x">Paso</label></li>
    </ul>
    El estado se guarda por índice. Si reordenas los items, se desalinea:
    cambia el data-key cuando edites la lista.
  */
  function initChecklist(list) {
    const key = "tfcourse:" + (list.dataset.key || "anon");
    const boxes = [...list.querySelectorAll('input[type="checkbox"]')];
    if (!boxes.length) return;

    const saved = (store.get(key) || "").split(",");
    boxes.forEach((box, i) => {
      if (saved[i] === "1") box.checked = true;
      box.addEventListener("change", () => {
        store.set(key, boxes.map((b) => (b.checked ? "1" : "0")).join(","));
      });
    });
  }

  /* ---------------- 3. Tema ---------------- */
  function initTheme() {
    const KEY = "tfcourse:theme";
    const saved = store.get(KEY);
    if (saved === "dark" || saved === "light") {
      document.documentElement.setAttribute("data-theme", saved);
    }

    const btn = document.createElement("button");
    btn.className = "theme-toggle";
    btn.type = "button";
    btn.setAttribute("aria-label", "Cambiar entre tema claro y oscuro");

    const isDark = () => {
      const attr = document.documentElement.getAttribute("data-theme");
      if (attr) return attr === "dark";
      return window.matchMedia("(prefers-color-scheme: dark)").matches;
    };
    const label = () => { btn.textContent = isDark() ? "claro" : "oscuro"; };
    label();

    btn.addEventListener("click", () => {
      const next = isDark() ? "light" : "dark";
      document.documentElement.setAttribute("data-theme", next);
      store.set(KEY, next);
      label();
    });

    document.body.appendChild(btn);
  }

  /* ---------------- arranque ---------------- */
  function boot() {
    document.querySelectorAll(".quiz").forEach(initQuiz);
    document.querySelectorAll(".checklist[data-key]").forEach(initChecklist);
    initTheme();
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot);
  } else {
    boot();
  }
})();
