// Фатальная ошибка: пишем маркер в stderr (console.error) и завершаем процесс.
// Pod перезапускается, лог остаётся в VictoriaLogs размеченным как
// stream=stderr — его ловит правило по NUXT_FATAL + stream:=stderr.
export default defineEventHandler(() => {
  console.error('NUXT_FATAL: unrecoverable configuration error on /api/fatal')
  process.exit(1)
})
