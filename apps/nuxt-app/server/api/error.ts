// Возвращает 500 через createError. Nitro логирует ошибку в stderr.
export default defineEventHandler(() => {
  console.error('NUXT_ERROR: upstream database unavailable on /api/error')
  throw createError({
    statusCode: 500,
    statusMessage: 'Upstream database unavailable',
  })
})
