document.addEventListener("turbo:load", () => {
    const mobileMenuBtn = document.getElementById("mobile-menu-btn")
    const mobileMenu = document.getElementById("mobile-menu")

    if (mobileMenuBtn && mobileMenu) {
        mobileMenuBtn.addEventListener("click", () => {
            if (mobileMenu.classList.contains("max-h-0")) {
                mobileMenu.classList.remove("max-h-0", "opacity-0")
                mobileMenu.classList.add("max-h-60", "opacity-100")
            } else {
                mobileMenu.classList.remove("max-h-60", "opacity-100")
                mobileMenu.classList.add("max-h-0", "opacity-0")
            }
        })
    }
})