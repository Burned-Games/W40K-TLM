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
document.addEventListener('DOMContentLoaded', () => {
    const carousel = document.querySelector('.carousel');
    const items = document.querySelectorAll('.item');
    const prevButton = document.querySelector('.prev');
    const nextButton = document.querySelector('.next');
    const dotsContainer = document.querySelector('.dots-container');
    const carouselContainer = document.querySelector('.carousel-container');

    let currentIndex = 0;
    let autoPlayTimer;
    const totalItems = items.length;

    // Create indicator dots
    items.forEach((_, index) => {
        const dot = document.createElement('div');
        dot.classList.add('dot');
        if(index === 0) dot.classList.add('active');
        dot.addEventListener('click', () => goToSlide(index));
        dotsContainer.appendChild(dot);
    });

    // Carousel transition logic
    function updateCarousel() {
        carousel.style.transform = `translateX(-${currentIndex * 100}%)`;
        document.querySelectorAll('.dot').forEach((dot, index) => {
            dot.classList.toggle('active', index === currentIndex);
        });
    }

    function goToSlide(index) {
        currentIndex = (index + totalItems) % totalItems;
        updateCarousel();
        resetAutoPlay();
    }

    function nextSlide() {
        currentIndex = (currentIndex + 1) % totalItems;
        updateCarousel();
        resetAutoPlay();
    }

    function prevSlide() {
        currentIndex = (currentIndex - 1 + totalItems) % totalItems;
        updateCarousel();
        resetAutoPlay();
    }

    // Auto-play control
    function startAutoPlay() {
        autoPlayTimer = setInterval(nextSlide, 5000);
    }

    function stopAutoPlay() {
        clearInterval(autoPlayTimer);
    }

    function resetAutoPlay() {
        stopAutoPlay();
        startAutoPlay();
    }

    // Event listeners
    nextButton.addEventListener('click', nextSlide);
    prevButton.addEventListener('click', prevSlide);
    
    carouselContainer.addEventListener('mouseenter', stopAutoPlay);
    carouselContainer.addEventListener('mouseleave', startAutoPlay);

    // Initialize auto-play
    startAutoPlay();
});

// Narrative content switcher (tabs and images)
document.addEventListener('DOMContentLoaded', () => {
    // Retrieve all interactive elements
    const navButtons = document.querySelectorAll('.wh-nav-btn');
    const textContents = document.querySelectorAll('.wh-text');
    const previewImages = document.querySelectorAll('.wh-preview-img');
    const featuredImages = document.querySelectorAll('.wh-featured-img');

    // Initialize first content
    activateContent(1);

    // Bind click events to navigation buttons
    navButtons.forEach(button => {
        button.addEventListener('click', () => {
            const target = button.dataset.target;
            activateContent(target);
        });
    });

    function activateContent(targetId) {
        // Remove all active states
        navButtons.forEach(btn => btn.classList.remove('active'));
        textContents.forEach(content => content.classList.remove('active'));
        previewImages.forEach(img => img.classList.remove('active'));
        featuredImages.forEach(img => img.classList.remove('active'));

        // Set new active state
        const activeButton = document.querySelector(`.wh-nav-btn[data-target="${targetId}"]`);
        const activeContent = document.querySelector(`.wh-text[data-content="${targetId}"]`);
        const activePreview = document.querySelector(`.wh-preview-img[data-preview="${targetId}"]`);
        const activeFeatured = document.querySelector(`.wh-featured-img[data-featured="${targetId}"]`);

        if(activeButton) activeButton.classList.add('active');
        if(activeContent) activeContent.classList.add('active');
        if(activePreview) activePreview.classList.add('active');
        if(activeFeatured) activeFeatured.classList.add('active');
    }
});



document.addEventListener("DOMContentLoaded", () => {
  const left = document.querySelector(".team-left");
  const nameElem = document.getElementById("team-name");
  const descElem = document.getElementById("team-description");
  const photoElem = document.getElementById("team-photo");

  const departmentsContainer = document.getElementById("team-departments");


  const departments = {};
  teamData.forEach(member => {
    if (!departments[member.department]) {
      departments[member.department] = [];
    }
    departments[member.department].push(member);
  });


  for (const dept in departments) {
    const section = document.createElement("div");
    section.classList.add("department-section");

    const title = document.createElement("h3");
    title.textContent = dept;
    section.appendChild(title);

    const avatarContainer = document.createElement("div");
    avatarContainer.classList.add("avatar-container");

    departments[dept].forEach(member => {
      const avatarWrapper = document.createElement("div");
      avatarWrapper.classList.add("avatar-wrapper");

      const img = document.createElement("img");
      img.src = member.avatar;
      img.classList.add("avatar");

      const name = document.createElement("div");
      name.classList.add("avatar-name");
      name.textContent = member.name;

      avatarWrapper.appendChild(img);
      avatarWrapper.appendChild(name);
      avatarContainer.appendChild(avatarWrapper);

      img.addEventListener("click", () => {
        nameElem.textContent = member.name;
        descElem.textContent = member.description;
        photoElem.src = member.avatar;
        left.style.backgroundImage = `url(${member.background})`;
      });
    });

    section.appendChild(avatarContainer);
    departmentsContainer.appendChild(section);
  }
});


