document.addEventListener("DOMContentLoaded", () => {
    const navToggle = document.querySelector(".nav-toggle");
    const navList = document.querySelector(".nav-list");
    const themeToggle = document.querySelector(".theme-toggle");
    const body = document.body;
    
    // Mobile nav toggle
    navToggle.addEventListener("click", () => {
      navList.classList.toggle("show");
    });
  
    // Theme toggle (dark / light)
    themeToggle.addEventListener("click", () => {
      body.classList.toggle("dark");
      // Save preference
      localStorage.setItem("theme", body.classList.contains("dark") ? "dark" : "light");
      updateThemeIcon();
    });
  
    // Load theme from localStorage
    const saved = localStorage.getItem("theme");
    if (saved === "dark") {
      body.classList.add("dark");
    }
    updateThemeIcon();
  
    function updateThemeIcon() {
      if (body.classList.contains("dark")) {
        themeToggle.textContent = "☀️";
      } else {
        themeToggle.textContent = "🌙";
      }
    }
  
    // Set current year in footer
    document.getElementById("year").textContent = new Date().getFullYear();
  
    // Contact form submission (dummy)
    const form = document.getElementById("contact-form");
    const responseEl = document.getElementById("form-response");
    form.addEventListener("submit", (e) => {
      e.preventDefault();
      const name = form.name.value;
      responseEl.textContent = `Thanks, ${name}! We'll be in touch soon.`;
      form.reset();
    });
  });