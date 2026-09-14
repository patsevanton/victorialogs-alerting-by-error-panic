// Необработанное исключение в обработчике. Пишем маркер в stderr (console.error):
// правило ловит по NUXT_UNHANDLED + дешёвому фильтру stream:=stderr.
export default defineEventHandler(() => {
  console.error('NUXT_UNHANDLED: unhandled rejection on /api/throw')
  throw new Error('unhandled exception in /api/throw')
})
