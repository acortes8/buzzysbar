// const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}'
  ],
  theme: {
    extend: {
      fontFamily: {
//         sans: ['Inter var', ...defaultTheme.fontFamily.sans],
      },
      colors: {
        'tropical-green': '#28A745',
        'bright-orange': '#FF5733',
        'deep-blue': '#007BFF',
        'soft-beige': '#F5F5F5',
        'golden-yellow': '#FFC107'
      }
    },
  },
  plugins: [
    // require('@tailwindcss/forms'),
    // require('@tailwindcss/typography'),
    // require('@tailwindcss/container-queries'),
  ]
}
