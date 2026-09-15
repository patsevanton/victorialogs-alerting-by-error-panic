// Возвращает 500 через createError. Ошибка пишется в stderr (console.error),
// чтобы Vector разметил её stream=stderr и правило ловило её дешёвым фильтром.
export default defineEventHandler(() => {
  console.error('NUXT_ERROR: upstream database unavailable on /api/error')
  throw createError({
    statusCode: 500,
    statusMessage: 'Upstream database unavailable',
  })
})
