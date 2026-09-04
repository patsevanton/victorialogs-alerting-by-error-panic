// Фатальная ошибка: пишем маркер и завершаем процесс. Pod перезапускается,
// лог остаётся в VictoriaLogs — его ловит правило по NUXT_FATAL.
export default defineEventHandler(() => {
  console.error('NUXT_FATAL: unrecoverable configuration error on /api/fatal')
  process.exit(1)
})
