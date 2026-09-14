// Ошибка без краха: логируем проблему в stderr (console.error) и отдаём 502,
// процесс живёт. Правило ловит по NUXT_502 + stream:=stderr.
export default defineEventHandler((event) => {
  console.error('NUXT_502: upstream timeout on /api/error-502')
  setResponseStatus(event, 502)
  return { error: 'Bad Gateway' }
})
