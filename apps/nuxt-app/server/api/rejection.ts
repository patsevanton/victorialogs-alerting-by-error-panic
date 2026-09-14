// Необработанный promise rejection: промис отклоняется, но его никто не ждёт
// и не перехватывает. Node логирует это как unhandledRejection (в stderr).
// Маркер пишем в stderr (console.error), чтобы правило ловило по stream:=stderr.
export default defineEventHandler(() => {
  console.error('NUXT_REJECTION: unhandled promise rejection on /api/rejection')
  void Promise.reject(new Error('unhandled rejection in /api/rejection'))
  return { status: 'triggered' }
})
