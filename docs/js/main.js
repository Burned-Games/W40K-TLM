// Scroll to top button functionality
const toTop = document.querySelector('.to-top');
const nav = document.querySelector('.main-nav');

// Event listener for scrolling
window.addEventListener('scroll', () => {
    // If the page is scrolled more than 100px, show a gray background
    if (window.scrollY > 100) {
        nav.classList.add('scrolled');
        nav.style.backgroundColor = "rgba(128, 128, 128, 0.9)"; // Gray background
    } else {
        nav.classList.remove('scrolled');
        nav.style.backgroundColor = "transparent"; // Initial transparent background
    }

    // Show or hide the "back to top" button based on scroll position
    toTop.classList.toggle('visible', window.scrollY > 500);
});

// Smooth scrolling for anchor links
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function(e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        target.scrollIntoView({
            behavior: 'smooth',
            block: 'start'
        });
    });
});

// Mobile menu toggle
const navToggle = document.createElement('button');
navToggle.classList.add('nav-toggle');
navToggle.innerHTML = '<span class="hamburger"></span>'; // Hamburger icon for mobile
navToggle.addEventListener('click', () => {
    document.querySelector('.nav-menu').classList.toggle('active');
});

document.querySelector('.main-nav').appendChild(navToggle); // Add the toggle button to the nav

// Intersection Observer for section visibility on scroll
const sections = document.querySelectorAll('.page-section');
const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        // Toggle 'active' class based on whether the section is in the viewport
        entry.target.classList.toggle('active', entry.isIntersecting);
    });
}, { threshold: 0.25 }); // Trigger when 25% of the section is visible

sections.forEach(section => observer.observe(section)); // Observe all sections

// Narrative carousel (previous and next buttons)
const slides = document.querySelectorAll(".slide");
const prevBtn = document.querySelector(".prev");
const nextBtn = document.querySelector(".next");
let index = 0;

function showSlide(n) {
    index = (n + slides.length) % slides.length; // Ensure the index stays within bounds
    slides.forEach((slide, i) => {
        slide.style.transform = `translateX(${-index * 100}%)`; // Slide to the correct position
    });
}

// Attach event listeners to previous and next buttons
prevBtn.addEventListener("click", () => showSlide(index - 1));
nextBtn.addEventListener("click", () => showSlide(index + 1));

showSlide(index); // Initialize carousel

// Narrative content switcher (tabs and images)
const buttons = document.querySelectorAll('.tab-button');
const contents = document.querySelectorAll('.content');
const images = document.querySelectorAll('.main-image');

buttons.forEach((button, index) => {
    button.addEventListener('click', () => {
        // Remove 'active' class from all buttons, contents, and images
        buttons.forEach(btn => btn.classList.remove('active'));
        contents.forEach(content => content.classList.remove('active'));
        images.forEach(img => img.classList.remove('active'));

        // Add 'active' class to the clicked button and corresponding content/image
        button.classList.add('active');
        document.getElementById(`content-${index + 1}`).classList.add('active');
        images[index].classList.add('active'); // Show the corresponding image
    });
});
