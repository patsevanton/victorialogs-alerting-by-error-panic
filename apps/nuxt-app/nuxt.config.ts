export default defineNuxtConfig({
  compatibilityDate: '2025-07-01',
  nitro: {
    // Выводим логи Nitro в консоль (stdout/stderr), чтобы vlagent их собрал.
    logging: {
      // Выводим ошибки Nitro в консоль.
      level: 'verbose',
    },
  },
})
