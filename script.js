const header = document.getElementById("site-header");
const toggle = document.querySelector(".menu-toggle");
const nav = document.querySelector(".main-nav");
const links = document.querySelectorAll(".main-nav a");

toggle.addEventListener("click", () => {
  const open = nav.classList.toggle("open");
  toggle.setAttribute("aria-expanded", open ? "true" : "false");
});

links.forEach(link => link.addEventListener("click", () => {
  nav.classList.remove("open");
  toggle.setAttribute("aria-expanded", "false");
}));

const sections = [...document.querySelectorAll("main section[id]")];
const navItems = [...links];
const observer = new IntersectionObserver(entries => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      navItems.forEach(a => a.classList.toggle("active", a.getAttribute("href") === "#" + entry.target.id));
    }
  });
}, {rootMargin: "-35% 0px -55% 0px"});
sections.forEach(section => observer.observe(section));

document.getElementById("year").textContent = new Date().getFullYear();

document.getElementById("enquiry-form").addEventListener("submit", e => {
  e.preventDefault();
  const form = new FormData(e.currentTarget);
  const subject = encodeURIComponent("Website enquiry — St. Britto's High School");
  const body = encodeURIComponent(
    `Name: ${form.get("name")}\nPhone: ${form.get("phone")}\n\nMessage:\n${form.get("message")}`
  );
  window.location.href = `mailto:Stbrittoshighschool@gmail.com?subject=${subject}&body=${body}`;
});
