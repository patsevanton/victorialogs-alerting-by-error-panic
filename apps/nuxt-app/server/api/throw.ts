// Необработанное исключение в обработчике. Nitro логирует его в stderr.
export default defineEventHandler(() => {
  console.error('NUXT_UNHANDLED: unhandled rejection on /api/throw')
  throw new Error('unhandled exception in /api/throw')
})
