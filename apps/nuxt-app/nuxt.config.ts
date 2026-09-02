export default defineNuxtConfig({
  compatibilityDate: '2025-07-01',
  nitro: {
    // Пишем логи в stdout, чтобы vlagent их собрал.
    logging: {
      // Выводим ошибки Nitro в консоль.
      level: 'verbose',
    },
  },
})
